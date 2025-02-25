package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"runtime/debug"
	"strings"
	"syscall"
	"time"
)

type Config struct {
	PushgatewayURL string
	JobName        string
	InstanceName   string
	Labels         string
	Debug          bool
	Version        bool
	Info           bool
}

func main() {
	config := Config{
		InstanceName: getHostname(),
		Info:         true,
	}

	flag.StringVar(&config.PushgatewayURL, "pushgateway-url", "", "Pushgateway URL (required)")
	flag.StringVar(&config.JobName, "job-name", "", "Job name for metrics (required)")
	flag.StringVar(&config.InstanceName, "instance-name", config.InstanceName, "Instance name for metrics")
	flag.StringVar(&config.Labels, "labels", "", "Additional labels in key=value format, comma-separated (e.g., env=prod,team=infra)")
	flag.BoolVar(&config.Debug, "debug", false, "Enable debug mode")
	flag.BoolVar(&config.Version, "version", false, "Output version")
	showHelp := flag.Bool("help", false, "Show help message")
	flag.BoolVar(showHelp, "h", false, "Show help message (shorthand)")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: %s [OPTIONS] -- COMMAND [ARGS...]\n\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "Executes a command and reports its duration to a Prometheus Pushgateway.\n\n")
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nExample:\n")
		fmt.Fprintf(os.Stderr, "    %s \\\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "        --pushgateway-url http://pushgateway:9091 \\\n")
		fmt.Fprintf(os.Stderr, "        --job-name backup --instance-name db01 \\\n")
		fmt.Fprintf(os.Stderr, "        --labels env=prod,team=infra,type=full \\\n")
		fmt.Fprintf(os.Stderr, "        -- \\\n")
		fmt.Fprintf(os.Stderr, "        pg_dump database\n\n")
		fmt.Fprintf(os.Stderr, "Note: Use -- to separate the wrapper options from the command to be executed.\n")
	}

	argsIndex := -1
	for i, arg := range os.Args {
		if arg == "--" {
			argsIndex = i
			break
		}
	}

	var cmdArgs []string
	if argsIndex != -1 {
		flag.CommandLine.Parse(os.Args[1:argsIndex])

		if argsIndex+1 < len(os.Args) {
			cmdArgs = os.Args[argsIndex+1:]
		}
	} else {
		flag.Parse()
		cmdArgs = flag.Args()
	}

	if *showHelp {
		flag.Usage()
		os.Exit(0)
	}

	if config.Version {
		buildInfo, _ := debug.ReadBuildInfo()
		fmt.Println("Version:", buildInfo.Main.Version)
		fmt.Println("Go Version:", buildInfo.GoVersion)
		os.Exit(0)
	}

	if config.Debug {
		fmt.Println("Debug mode enabled")
	}

	if config.PushgatewayURL == "" || config.JobName == "" {
		fmt.Fprintln(os.Stderr, "Error: Missing required parameters")
		flag.Usage()
		os.Exit(1)
	}

	if len(cmdArgs) == 0 {
		fmt.Fprintln(os.Stderr, "Error: No command specified")
		flag.Usage()
		os.Exit(1)
	}

	logStdout(&config, "Pushgateway URL: %s", config.PushgatewayURL)
	logStdout(&config, "Job name: %s", config.JobName)
	logStdout(&config, "Instance name: %s", config.InstanceName)
	logStdout(&config, "Labels: %s", config.Labels)

	exitCode := executeCommand(&config, cmdArgs)
	os.Exit(exitCode)
}

func executeCommand(config *Config, cmdArgs []string) int {
	startTime := time.Now().Unix()

	cmd := exec.Command(cmdArgs[0], cmdArgs[1:]...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	err := cmd.Run()

	exitStatus := 0
	if err != nil {

		if exitErr, ok := err.(*exec.ExitError); ok {
			if status, ok := exitErr.Sys().(syscall.WaitStatus); ok {
				exitStatus = status.ExitStatus()
			}
		} else {

			exitStatus = 1
		}
	}

	endTime := time.Now().Unix()
	duration := endTime - startTime

	sendMetric(config, "job_duration_seconds", fmt.Sprintf("%d", duration), "gauge", "Total time taken for job execution in seconds")
	sendMetric(config, "job_exit_status", fmt.Sprintf("%d", exitStatus), "gauge", "Exit status code of the last job execution (0=success)")
	sendMetric(config, "job_last_execution_timestamp", fmt.Sprintf("%d", endTime), "gauge", "Timestamp of the last job execution")
	sendMetric(config, "job_executions_total", "1", "counter", "Total number of job executions")

	return exitStatus
}

func buildPushgatewayURL(config *Config) (string, error) {
	url := fmt.Sprintf("%s/metrics/job/%s/instance/%s",
		strings.TrimSuffix(config.PushgatewayURL, "/"),
		config.JobName,
		config.InstanceName)

	if config.Labels != "" {
		labels := strings.Split(config.Labels, ",")
		for _, label := range labels {
			parts := strings.SplitN(label, "=", 2)
			if len(parts) != 2 {
				return "", fmt.Errorf("invalid label format: %s (must be key=value)", label)
			}

			key := parts[0]
			value := parts[1]

			if !isValidLabelKey(key) {
				return "", fmt.Errorf("invalid label key: %s (must start with a letter or underscore)", key)
			}

			url = fmt.Sprintf("%s/%s/%s", url, key, value)
		}
	}

	return url, nil
}

func isValidLabelKey(key string) bool {
	if len(key) == 0 {
		return false
	}

	first := key[0]
	if !((first >= 'a' && first <= 'z') || (first >= 'A' && first <= 'Z') || first == '_') {
		return false
	}

	return true
}

func sendMetric(config *Config, metricName, value, metricType, helpText string) {
	url, err := buildPushgatewayURL(config)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		return
	}

	logStdout(config, "Sending metric: %s=%s (%s)", metricName, value, metricType)

	payload := fmt.Sprintf("# TYPE %s %s\n# HELP %s %s\n%s %s\n",
		metricName, metricType, metricName, helpText, metricName, value)

	req, err := http.NewRequest("POST", url, strings.NewReader(payload))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: Failed to create HTTP request: %v\n", err)
		return
	}

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: Failed to send metrics to Pushgateway: %v\n", err)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		fmt.Fprintf(os.Stderr, "Error: Failed to send metrics to Pushgateway (HTTP status %d)\n", resp.StatusCode)
	}
}

func getHostname() string {
	hostname, err := os.Hostname()
	if err != nil {
		return "unknown"
	}
	return hostname
}

func logStdout(config *Config, format string, args ...interface{}) {
	if config.Info {
		timestamp := time.Now().Format("2006-01-02T15:04:05-0700")
		fmt.Printf("[%s]: %s\n", timestamp, fmt.Sprintf(format, args...))
	}
}

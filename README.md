# Prometheus Command Timer

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
  - [Using the Docker Image](#using-the-docker-image)
  - [Direct Download](#direct-download)
  - [Manual Installation](#manual-installation)
- [Quick Start](#quick-start)
- [Kubernetes Example](#kubernetes-example)
- [Usage](#usage)
- [Metrics](#metrics)
- [Building from Source](#building-from-source)
- [Contributing](#contributing)
- [License](#license)
- [Author](#author)
- [Acknowledgments](#acknowledgments)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

A utility that executes commands and reports execution metrics to a Prometheus
Pushgateway.

## Overview

Prometheus Command Timer is a lightweight tool that wraps around command
execution to collect and send performance metrics to a Prometheus Pushgateway.

It measures execution time, tracks exit status, and records timestamps, making
it ideal for monitoring batch jobs, cron tasks, and other command-line
operations in a Kubernetes environment.

## Features

- Measures command execution duration
- Records command exit status
- Tracks execution timestamps
- Sends metrics to Prometheus Pushgateway
- Supports custom labels for metrics
- Works on Linux, macOS, and Windows
- Architecture support for x86_64, arm64, and i386

## Installation

### Using the Docker Image

```bash
docker run --rm -v \
  $(pwd):/cwd ghcr.io/meysam81/prometheus-command-timer \
  -d /cwd
```

### Direct Download

The script will automatically detect your OS and architecture:

```bash
curl -sL https://raw.githubusercontent.com/meysam81/prometheus-command-timer/main/install.sh | sh
./prometheus-command-timer -version
```

### Manual Installation

1. Download the appropriate binary for your platform from the [releases page].
2. Extract the archive
3. Place the binary in your `$PATH`

## Quick Start

Basic usage:

```bash
prometheus-command-timer \
  --pushgateway-url http://pushgateway:9091 \
  --job-name backup \
  -- \
  pg_dump database
```

## Kubernetes Example

Create a job that runs a command with timing metrics:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: sleep
spec:
  template:
    spec:
      containers:
        - args:
            - |
              sleep 10
          command:
            - /shared/prometheus-command-timer
            - "--pushgateway-url"
            - http://pushgateway.monitoring.svc.cluster.local:9091
            - "--job-name"
            - sleep
            - "--"
          image: busybox:1
          name: sleep
          volumeMounts:
            - mountPath: /shared
              name: shared
      initContainers:
        - args:
            - -d
            - /shared
          image: ghcr.io/meysam81/prometheus-command-timer
          name: install-prometheus-command-timer
          volumeMounts:
            - mountPath: /shared
              name: shared
      restartPolicy: OnFailure
      volumes:
        - emptyDir: {}
          name: shared
```

## Usage

```
Usage: prometheus-command-timer [OPTIONS] -- COMMAND [ARGS...]

Executes a command and reports its duration to a Prometheus Pushgateway.

Options:
  -pushgateway-url string
        Pushgateway URL (required)
  -job-name string
        Job name for metrics (required)
  -instance-name string
        Instance name for metrics (default: hostname)
  -labels string
        Additional labels in key=value format, comma-separated (e.g., env=prod,team=infra)
  -version
        Output version
  -help, -h
        Show help message

Example:
    prometheus-command-timer \
        --pushgateway-url http://pushgateway:9091 \
        --job-name backup --instance-name db01 \
        --labels env=prod,team=infra,type=full \
        -- \
        pg_dump database

Note: Use -- to separate the wrapper options from the command to be executed.
```

## Metrics

The following metrics are collected:

- `job_duration_seconds` - Total time taken for job execution in seconds
- `job_exit_status` - Exit status code of the last job execution (0=success)
- `job_last_execution_timestamp` - Timestamp of the last job execution
- `job_executions_total` - Total number of job executions

## Building from Source

```bash
git clone https://github.com/meysam81/prometheus-command-timer.git
cd prometheus-command-timer
go build -o prometheus-command-timer
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the Apache License 2.0 - see the
[LICENSE](LICENSE) file for details.

[releases page]: https://github.com/meysam81/prometheus-command-timer/releases

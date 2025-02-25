#!/bin/sh

set -eu

PUSHGATEWAY_URL=""
JOB_NAME=""
INSTANCE_NAME="$(hostname)"
LABELS=""
DEBUG=false
INFO=true

curl_cmd="curl"
if [ -x "${PWD}/curl" ]; then
    curl_cmd="${PWD}/curl"
fi

log_stdout() {
    if [ "$INFO" = "true" ]; then
        echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*"
    fi
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] -- COMMAND [ARGS...]

Executes a command and reports its duration to a Prometheus Pushgateway.

Options:
    -h, --help                Show this help message
    --pushgateway-url URL     Pushgateway URL (required)
    --job-name NAME           Job name for metrics (required)
    --instance-name NAME      Instance name for metrics (default: \$HOSTNAME)
    --labels LABELS           Additional labels in key=value format, comma-separated
                              Example: env=prod,team=infra
    --debug                   Enable debug mode

Example:
    $(basename "$0") \\
        --pushgateway-url http://pushgateway:9091 \\
        --job-name backup --instance-name db01 \\
        --labels env=prod,team=infra,type=full \\
        -- \\
        pg_dump database

Note: Use -- to separate the wrapper options from the command to be executed.
EOF
}

while [ $# -gt 0 ]; do
    case $1 in
        -h|--help)
            usage
            exit 0
        ;;
        --debug)
            DEBUG=true
            shift
        ;;
        --pushgateway-url)
            [ $# -ge 2 ] || { echo "Error: Missing value for --pushgateway-url" >&2; exit 1; }
            PUSHGATEWAY_URL="$2"
            shift 2
        ;;
        --job-name)
            [ $# -ge 2 ] || { echo "Error: Missing value for --job-name" >&2; exit 1; }
            JOB_NAME="$2"
            shift 2
        ;;
        --instance-name)
            [ $# -ge 2 ] || { echo "Error: Missing value for --instance-name" >&2; exit 1; }
            INSTANCE_NAME="$2"
            shift 2
        ;;
        --labels)
            [ $# -ge 2 ] || { echo "Error: Missing value for --labels" >&2; exit 1; }
            LABELS="$2"
            shift 2
        ;;
        --)
            shift
            break
        ;;
        *)
            echo "Error: Unknown option: $1" >&2
            usage >&2
            exit 1
        ;;
    esac
done

if [ "$DEBUG" = "true" ]; then
    set -x
fi

if [ -z "$PUSHGATEWAY_URL" ] || [ -z "$JOB_NAME" ]; then
    echo "Error: Missing required parameters" >&2
    usage >&2
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Error: No command specified" >&2
    usage >&2
    exit 1
fi

log_stdout "Pushgateway URL: $PUSHGATEWAY_URL"
log_stdout "Job name: $JOB_NAME"
log_stdout "Instance name: $INSTANCE_NAME"
log_stdout "Labels: $LABELS"

build_pushgateway_url() {
    url="${PUSHGATEWAY_URL}/metrics/job/${JOB_NAME}/instance/${INSTANCE_NAME}"
    if [ -n "$LABELS" ]; then
        OLDIFS="$IFS"
        IFS=","
        for label in $LABELS; do
            case "$label" in
                [a-zA-Z_]*=*)
                    key="${label%%=*}"
                    value="${label#*=}"
                    url="${url}/${key}/${value}"
                ;;
                *)
                    IFS="$OLDIFS"
                    echo "Error: Invalid label format: $label" >&2
                    echo "Labels must be in key=value format and keys must start with a letter or underscore" >&2
                    exit 1
                ;;
            esac
        done
        IFS="$OLDIFS"
    fi

    echo "$url"
}

send_metric() {
    metric_name="$1"
    value="$2"
    metric_type="$3"
    help_text="$4"
    endpoint=$(build_pushgateway_url)

    log_stdout "Sending metric: ${metric_name}=${value} (${metric_type})"

    (
        echo "# TYPE ${metric_name} ${metric_type}"
        echo "# HELP ${metric_name} ${help_text}"
        echo "${metric_name} ${value}"
        ) | "$curl_cmd" --silent --show-error --fail --data-binary @- "$endpoint" || {
        echo "Error: Failed to send metrics to Pushgateway" >&2
        return 1
    }
}

start_time=$(date +%s)

set +e
"$@"
command_status=$?
set -e

end_time=$(date +%s)
duration=$((end_time - start_time))

send_metric "job_duration_seconds" "$duration" "gauge" "Total time taken for job execution in seconds"
send_metric "job_exit_status" "$command_status" "gauge" "Exit status code of the last job execution (0=success)"
send_metric "job_last_execution_timestamp" "$end_time" "gauge" "Timestamp of the last job execution"
send_metric "job_executions_total" "1" "counter" "Total number of job executions"

exit "$command_status"

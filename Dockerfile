FROM busybox:1

ENV URL=https://github.com/meysam81/prometheus-command-timer/raw/refs/heads/main/main.sh \
    INSTALL_DIR=/usr/local/bin/prometheus-command-timer

COPY install.sh /

ENTRYPOINT ["/install.sh"]

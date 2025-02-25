FROM busybox:1

COPY install.sh /

ENTRYPOINT ["/install.sh"]
CMD ["--directory", "/", "--version", "latest"]

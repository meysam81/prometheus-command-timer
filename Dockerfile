FROM busybox:1

ARG VERSION=latest
ENV VERSION=${VERSION}

COPY install.sh /

ENTRYPOINT ["/install.sh"]
CMD ["--directory", "/", "--version", "${VERSION}"]

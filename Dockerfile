FROM busybox:1

ARG VERSION=latest
ENV DEFAULT_VERSION=$VERSION

COPY install.sh /

ENTRYPOINT ["/install.sh"]
CMD ["--directory", "/"]

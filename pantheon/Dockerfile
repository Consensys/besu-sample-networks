FROM pegasyseng/pantheon:latest

# Copy new entrypoint scripts
COPY *_start.sh /opt/pantheon/

# Install a dos 2 unix EOL converter
RUN apk add --update dos2unix && \
    rm -rf /var/cache/apk/*

# Run dos2unix EOL conversion on all shell scripts to prevent scripts to fail if edited with a windows IDE
# that rewrote the EOL to CRLF before we build the image. See issue #4
RUN find /opt/pantheon/*.sh -type f -print0 | xargs -0 dos2unix

# specify default command
ENTRYPOINT ["/opt/pantheon/node_start.sh"]

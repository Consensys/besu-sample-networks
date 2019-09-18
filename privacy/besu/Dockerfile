#default version to latest
ARG BESU_VERSION=develop

FROM hyperledger/besu:$BESU_VERSION

# Copy new entrypoint scripts
COPY *_start.sh /opt/besu/

# Copy Orion public keys
COPY orion/* /orion/

# Install a dos 2 unix EOL converter (supporting either alpine or ubuntu images)
RUN (apt-get update && apt-get install dos2unix || apk add --update dos2unix) && \
    rm -rf /var/cache/apt/* && rm -rf /var/cache/apk/*

# Run dos2unix EOL conversion on all shell scripts to prevent scripts to fail if edited with a windows IDE
# that rewrote the EOL to CRLF before we build the image. See issue #4
RUN find /opt/besu/*.sh -type f -print0 | xargs -0 dos2unix

EXPOSE 8545 8546
# specify default entrypoint to start the node
ENTRYPOINT ["/opt/besu/node_start.sh"]

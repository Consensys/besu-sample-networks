FROM pegasyseng/pantheon:latest

# copy application (with libraries inside)
COPY *_start.sh /opt/pantheon/

# specify default command
ENTRYPOINT ["/opt/pantheon/node_start.sh"]

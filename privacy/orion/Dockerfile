
FROM openjdk:8-jdk

RUN apt-get -qq update && \
    apt-get -qq -y install libsodium-dev && \
    apt-get -qq -y install git

RUN git clone https://github.com/PegaSysEng/orion.git && \
    cd orion && \
    ./gradlew build

WORKDIR orion

RUN mv build/distributions/orion*.tar.gz /tmp
WORKDIR /

RUN rm -rf /orion/*
RUN mv /tmp/orion* /orion

WORKDIR orion

RUN tar -xvzf orion*
RUN rm orion*.tar.gz
RUN mv orion* build

COPY data /orion/data

ENV DATA_FOLDER = data/data1
ENTRYPOINT ./build/bin/orion $DATA_FOLDER/orion.conf

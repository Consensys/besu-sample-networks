
FROM openjdk:11-jdk as builder

RUN apt-get -qq update && \
    apt-get -qq -y install git && \
    apt-get -qq -y install libsodium-dev

RUN git clone https://github.com/PegaSysEng/orion.git && \
    cd orion && \
    ./gradlew build && \
    mkdir /toCopy && \
    mv ./build/distributions/orion*.tar.gz /toCopy

WORKDIR toCopy

RUN tar -xvzf orion* && \
    rm orion*.tar.gz && \
    mv orion* build

FROM openjdk:11-jre

RUN apt-get -qq update && \
    apt-get -qq -y install libsodium-dev

COPY --from=builder /toCopy/* /orion/

WORKDIR orion

COPY data /orion/data

ENV DATA_FOLDER = data/data1
ENTRYPOINT ./orion/bin/orion $DATA_FOLDER/orion.conf

ARG PYTHON_VERSION=3.8-slim
FROM python:$PYTHON_VERSION as builder
# FROM ubuntu:focal as watchman
# FROM clears the ARGS, need to do it again
ARG WATCHMAN_TAG

# The "folly" component currently fails if "fmt" is not explicitly installed first.
ENV TZ=America/Chicago DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y git cmake build-essential libssl-dev libpcre3-dev m4 curl unzip
WORKDIR /watchman
RUN git clone --branch $WATCHMAN_TAG --depth 1 https://github.com/facebook/watchman.git .
# RUN ./autogen.sh
# RUN find built -type f -exec strip {} ";"
# RUN chmod +x built/lib/*
RUN cd /watchman/watchman/python \
    && CMAKE_CURRENT_SOURCE_DIR=/watchman python setup.py bdist_wheel
# RUN ./configure --enable-stack-protector
# RUN make -j$(nproc) && mkdir /dist && make install DESTDIR=/dist
WORKDIR /
RUN curl -sSLO https://github.com/facebook/watchman/releases/download/${WATCHMAN_TAG}/watchman-${WATCHMAN_TAG}-linux.zip && \
    unzip watchman-${WATCHMAN_TAG}-linux.zip && \
    chmod +x watchman-${WATCHMAN_TAG}-linux/bin/* \
    watchman-${WATCHMAN_TAG}-linux/lib/*

FROM python:$PYTHON_VERSION
ENV PIP_NO_CACHE_DIR=1

COPY --from=builder /watchman-*-linux/ /usr/local/
COPY --from=builder /watchman/watchman/python/dist/ /pywatchman/

RUN pip install /pywatchman/pywatchman-*.whl
RUN mkdir -p /usr/local/var/run/watchman/ && \
    chmod 2777 /usr/local/var/run/watchman/

ARG PYTHON_VERSION
FROM ubuntu:focal as watchman
# FROM clears the ARGS, need to do it again
ARG FMT_TAG
ARG WATCHMAN_TAG

# The "folly" component currently fails if "fmt" is not explicitly installed first.
ENV TZ=America/Chicago DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y git cmake build-essential libssl-dev libpcre3-dev m4 python-dev-is-python3
WORKDIR /watchman
RUN git clone --branch $WATCHMAN_TAG --depth 1 https://github.com/facebook/watchman.git .
RUN ./autogen.sh
RUN find built -type f -exec strip {} ";"
RUN chmod +x built/lib/*
# RUN ./configure --enable-stack-protector
# RUN make -j$(nproc) && mkdir /dist && make install DESTDIR=/dist
WORKDIR /dist

FROM python:$PYTHON_VERSION
ENV PIP_NO_CACHE_DIR=1

COPY --from=watchman /watchman/built/ /usr/local/
COPY --from=watchman /watchman/python/ /watchman/python/
RUN apt-get update \
    && apt-get install -y  \
    gcc \
    libdouble-conversion1 \
    libgoogle-glog0v5 \
    libsnappy1v5 \
    libboost-filesystem1.67.0 \
    libboost-program-options1.67.0 \
    libboost-regex1.67.0 \
    libevent-2.1-6 \
    libboost-context1.67.0 \
    libboost-thread1.67.0 \
    libboost-chrono1.67.0 \
    libboost-date-time1.67.0 \
    && cd /watchman/python \
    && sed -i "s/^from distutils.core import /from setuptools import /g" setup.py \
    && python setup.py bdist_wheel \
    && cp /watchman/python/dist/pywatchman-*.whl / \
    && rm -r /watchman \
    && rm -rf /var/lib/apt/lists/*
RUN pip install /pywatchman-*.whl
RUN mkdir -p /usr/local/var/run/watchman/ && \
    chmod 2777 /usr/local/var/run/watchman/

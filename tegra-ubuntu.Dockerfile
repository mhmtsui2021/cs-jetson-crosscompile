# MIT License

# Copyright (c) 2020 Michael de Gans

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# modified from mdegans repo https://github.com/mdegans/docker-tegra-ubuntu

ARG JETPACK_VERSION=r32.6.1
# ARG BASE_IMAGE=ubuntu:bionic
ARG BASE_IMAGE=nvcr.io/nvidia/l4t-base:${JETPACK_VERSION}

FROM ${BASE_IMAGE} as base

ARG SOC="t210"



ADD --chown=root:root https://repo.download.nvidia.com/jetson/jetson-ota-public.asc /etc/apt/trusted.gpg.d/jetson-ota-public.asc
RUN chmod 644 /etc/apt/trusted.gpg.d/jetson-ota-public.asc \
    && apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
    && echo "deb https://repo.download.nvidia.com/jetson/common r32.6 main" > /etc/apt/sources.list.d/nvidia-l4t-apt-source.list \
    && echo "deb https://repo.download.nvidia.com/jetson/${SOC} r32.6 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get upgrade -y
RUN apt-get update
RUN apt-get install -y \
    build-essential \
    manpages-dev \
    software-properties-common \
    protobuf-compiler \ 
    git \ 
    wget \
    libncurses5-dev
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt install -y gcc-9 g++-9
# RUN update-alternatives --remove-all gcc
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 --slave /usr/bin/g++ g++ /usr/bin/g++-9 --slave /usr/bin/gcov gcov /usr/bin/gcov-9 --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-9 --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-9
RUN update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-9 90
RUN update-alternatives --config gcc

WORKDIR /home
RUN wget https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1-linux-aarch64.sh
RUN mv cmake-3.25.1-linux-aarch64.sh /opt
WORKDIR /opt
RUN chmod +x cmake-3.25.1-linux-aarch64.sh
RUN bash ./cmake-3.25.1-linux-aarch64.sh --skip-license --include-subdir 
RUN ln -s /opt/cmake-3.25.1-linux-aarch64/bin/* /usr/local/bin
RUN ln -s /opt/cmake-3.25.1-linux-aarch64/share/cmake-3.25 /usr/local/share
RUN cmake --version

WORKDIR /home
RUN git clone https://github.com/nanomsg/nanomsg
WORKDIR /home/nanomsg
RUN mkdir build
WORKDIR /home/nanomsg/build
RUN cmake ..
RUN cmake --build . --target install -j$(nproc)
RUN ldconfig

ARG UNAME=testuser
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME
USER $UNAME
WORKDIR /workspace
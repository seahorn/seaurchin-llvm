#
# seaurchin-llvm build image. Contains all the necessary dependencies
# to build seaurchin-llvm. 
# Used by the CI to start the build
#

ARG BASE_IMAGE=noble-scm
# Base image with usual build dependencies
FROM buildpack-deps:$BASE_IMAGE

# Install dependencies
ARG DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1
RUN apt-get update && \
  apt-get install -yqq software-properties-common && \
  apt-get update && \
  apt-get upgrade -yqq && \
  apt-get install -yqq cmake cmake-data unzip \
      zlib1g-dev \
      ninja-build libgraphviz-dev \
      libboost1.83-dev \
      python3-pip \
      less vim \
      gcc-multilib \
      sudo \
      graphviz libgraphviz-dev python3-pygraphviz \
      lcov gcovr rsync lld zstd \
      pkg-config libssl-dev && \
  pip3 install lit OutputCheck && \
  pip3 install networkx && \
  pip3 install cmake --upgrade && \
  mkdir seaurchin-llvm
RUN wget -qO- https://apt.llvm.org/llvm.sh | bash -s -- 18

# Install sccache for caching compiler output in CI
ARG SCCACHE_VERSION=0.8.2
RUN curl -fsSL "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    | tar -xz -C /tmp && \
    mv "/tmp/sccache-v${SCCACHE_VERSION}-x86_64-unknown-linux-musl/sccache" /usr/local/bin/sccache && \
    chmod +x /usr/local/bin/sccache && \
    rm -rf "/tmp/sccache-v${SCCACHE_VERSION}-x86_64-unknown-linux-musl"

WORKDIR /seaurchin-llvm
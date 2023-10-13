FROM debian:11

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        git \
        autoconf \
        automake \
        autotools-dev \
        curl \
        python3.9 \
        python3-pip \
        libmpc-dev \
        libmpfr-dev \
        libgmp-dev \
        gawk \
        libtool \
        patchutils \
        libexpat1-dev \
        zlib1g-dev && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    ln -s /usr/bin/pip3 /usr/bin/pip && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --recursive https://github.com/riscv/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain && \
    ./configure --prefix=/opt/riscv && \
        --disable-linux \
        --disable-multilib \
        --with-arch=rv32imac \
        --with-cmodel=medany \
    make -j$(nproc) && \
    rm -rf riscv-gnu-toolchain

ENV PATH="/opt/riscv/bin:${PATH}"

COPY requirements.txt /tmp/requirements.txt

RUN pip3 install -r /tmp/requirements.txt

COPY ../ /adam

WORKDIR /adam
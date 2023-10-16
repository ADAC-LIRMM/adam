FROM debian:11

RUN apt-get update && \
    apt-get install -y \
        autoconf \
        automake \
        autotools-dev \
        curl \
        python3 \
        python3-pip \
        python3-venv \
        libmpc-dev \
        libmpfr-dev \
        libgmp-dev \
        gawk \
        build-essential \
        bison \
        flex \
        texinfo \
        gperf \
        libtool \
        patchutils \
        bc \
        zlib1g-dev \
        libexpat-dev \
        ninja-build \
        git \
        cmake \
        libglib2.0-dev \
        device-tree-compiler \
    && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    rm -rf /var/lib/apt/lists/*

ARG ARCH="rv32imc_zicsr_zifencei"

ENV PATH="/opt/riscv/bin:${PATH}"

RUN git clone https://github.com/riscv/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain && \
    git checkout e65e7fc58543c821baf4f1fb6d0ef700177b9d89 && \
    ./configure --prefix=/opt/riscv \
        --disable-linux \
        --disable-multilib \
        --with-arch=${ARCH} \
        --with-abi=ilp32 \
        --with-cmodel=medlow \
    && make -j$(nproc) && \
    cd .. && rm -rf riscv-gnu-toolchain

RUN git clone https://github.com/riscv/riscv-isa-sim.git && \
    cd riscv-isa-sim && \
    git checkout 530af85d83781a3dae31a4ace84a573ec255fefa && \
    mkdir build/ && cd build/ && \
    ../configure --prefix=/opt/riscv \
        --enable-histogram \
        --with-isa=${ARCH} \
    && make -j$(nproc) && \
    make install && \
    cd ../.. && rm -rf riscv-isa-sim

RUN git clone https://github.com/riscv-software-src/riscv-pk && \
    cd riscv-pk && \
    git checkout fafaedd2825054222ce2874bf4a90164b5b071d4 && \
    mkdir build/ && cd build/ && \
    ../configure --prefix=/opt/riscv \
        --host=riscv32-unknown-elf \
        --with-arch=${ARCH} \
    && make -j$(nproc) && \
    make install && \
    cd ../.. && rm -rf riscv-pk

RUN git clone https://github.com/riscv/riscv-openocd && \
    cd riscv-openocd && \
    git checkout 6e9514efcd0b5af1f5ffae5d1afa7e7640962ca6 && \
    ./bootstrap && \
    ./configure --prefix=/opt/riscv \
    && make -j$(nproc) && \
    make install && \
    cd ../.. && rm -rf riscv-openocd

ENV PATH="/adam/scripts:${PATH}"

COPY ../ /adam

RUN setup.bash --no-venv

WORKDIR /adam

RUN chmod 777 /adam

ENV HOME="/adam"

RUN echo "PS1='(adam) \w \$ '" >> /etc/bash.bashrc
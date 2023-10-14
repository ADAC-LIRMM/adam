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

RUN git clone https://github.com/riscv/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain && \
    git checkout e65e7fc58543c821baf4f1fb6d0ef700177b9d89 && \
    ./configure --prefix=/opt/riscv \
        --disable-linux \
        --disable-multilib \
        --with-arch=rv32gc \
        --with-cmodel=medany \
    && make -j$(nproc) && \
    cd .. && rm -rf riscv-gnu-toolchain

RUN git clone https://github.com/riscv/riscv-isa-sim.git && \
    cd riscv-isa-sim && \
    git checkout 530af85d83781a3dae31a4ace84a573ec255fefa && \
    mkdir build/ && cd build/ && \
    ../configure --prefix=/opt/riscv --with-isa=rv32gc && \
    make -j$(nproc) install && \
    cd ../.. && rm -rf riscv-isa-sim

ENV PATH="/opt/riscv/bin:${PATH}"

COPY ../ /adam

RUN /adam/scripts/setup.bash --no-venv

ENV PATH="/adam/scripts:${PATH}"

WORKDIR /adam

RUN chmod 777 /adam

ENV HOME="/adam"

RUN echo "PS1='(adam) \w \$ '" >> /etc/bash.bashrc
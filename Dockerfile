FROM debian:11

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        autoconf \
        automake \
        bison \
        bc \
        build-essential \
        cmake \
        curl \
        device-tree-compiler \
        flex \
        gawk \
        gcc gcc-multilib \
        git \
        gperf \
        libtool \
        locales \
        ninja-build \
        patchutils \
        python3 \
        python3-pip \
        python3-venv \
        texinfo \
        libxext6 libxext6:i386 \
        autotools-dev \
        libc6 libc6:i386 \
        libexpat-dev \
        libftdi1-dev \
        libglib2.0-dev \
        libgmp-dev \
        libmpc-dev \
        libmpfr-dev \
        libncurses5 libncurses5:i386 \
        libpixman-1-dev \
        libstdc++6 libstdc++6:i386 \
        libtinfo5 \
        libusb-1.0-0-dev \
        libxft2 libxft2:i386 \
        zlib1g-dev \
        libxtst6 \
        libxrender1 \
        libxi6 \
        libxrandr2 \
        libfreetype6 \
        libxinerama1 \
        libxfixes3 \
        libxcursor1 \
        wget \
    && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen

ENV PATH="/opt/riscv/bin:${PATH}"

RUN git clone https://github.com/riscv/riscv-gnu-toolchain.git && \
    cd riscv-gnu-toolchain && \
    git checkout e65e7fc58543c821baf4f1fb6d0ef700177b9d89 && \
    ./configure --prefix=/opt/riscv \
        --enable-debug-info=yes \
        --disable-linux \
        --enable-multilib \
        --with-abi=ilp32 \
        --with-arch=rv32imc_zicsr \
        --with-cmodel=medlow \
    && make -j$(nproc) && \
    cd .. && rm -rf riscv-gnu-toolchain

RUN git clone https://github.com/riscv/riscv-isa-sim.git && \
    cd riscv-isa-sim && \
    git checkout b0d7621ff8e9520aaacd57d97d4d99a545062d14 && \
    mkdir build/ && cd build/ && \
    ../configure --prefix=/opt/riscv \
        --enable-histogram \
        --with-isa=rv32gc \
    && make -j$(nproc) && \
    make install && \
    cd ../.. && rm -rf riscv-isa-sim

RUN git clone https://github.com/riscv/riscv-openocd.git && \
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

RUN cat >> /etc/bash.bashrc <<'EOF'
if [ ! -z "$XILINX_PATH" ]; then
    VER=$(ls $XILINX_PATH/Vivado/ | sort -V | tail -n 1)
    export PATH="$XILINX_PATH/Vivado/$VER/bin:$PATH"
fi

if [ ! -z "$MODELSIM_PATH" ]; then
    export PATH="$MODELSIM_PATH/bin:$PATH"
fi

PS1="(adam) \$(pwd | sed 's|^/adam|~|') \\$ "

export HOME="/adam/work"

export HISTCONTROL=ignoredups
export HISTFILE="$HOME/.bash_history"
export HISTFILESIZE=100000
export HISTSIZE=1000

git config --global --add safe.directory '*'
EOF

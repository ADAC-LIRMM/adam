#!/bin/bash
# Copyright 2025 LIRMM
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

BUILD=0
ROOT=0
IMAGE="adam"
WORK="$PWD"

while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            BUILD=1
            shift
            ;;
        --root)
            ROOT=1
            shift
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

cd "$(dirname "$0")"/..

image_exists() {
    docker images | awk -v image="$IMAGE" \
        '$1 == image {found=1} END {print found+0}'
}

if [[ $(image_exists) -eq 0 ]] || [[ $BUILD -eq 1 ]]; then
    docker build -t $IMAGE .
fi

RUN_CMD=(docker run -it --rm --network host --privileged)

if [ $ROOT -eq 0 ]; then
    RUN_CMD+=(-u $(id -u):$(id -g))
fi

if [ "$WORK" == "$PWD" ]; then
    RUN_CMD+=(-v "$PWD:/adam" -w /adam)
else
    RUN_CMD+=(-v "$PWD:/adam" -v "$WORK:/work" -w /work)
fi

if [ ! -z "$DISPLAY" ]; then
    xhost +local:docker > /dev/null
    RUN_CMD+=(-v /tmp/.X11-unix:/tmp/.X11-unix \
        -e "DISPLAY=$DISPLAY")
fi

if [ ! -z "$MODELSIM_PATH" ]; then
    RUN_CMD+=(-v "$MODELSIM_PATH:/opt/modelsim" \
        -e "MODELSIM_PATH=/opt/modelsim")
fi

if [ ! -z "$XILINX_PATH" ]; then
    RUN_CMD+=(-v "$XILINX_PATH:/opt/xilinx" \
        -e "XILINX_PATH=/opt/xilinx")
fi

RUN_CMD+=("$IMAGE")

# Execute docker run
"${RUN_CMD[@]}"

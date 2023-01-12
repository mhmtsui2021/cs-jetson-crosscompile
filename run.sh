#!/bin/bash

docker run --rm --privileged multiarch/qemu-user-static --reset -p yes 

docker run -it --platform linux/arm64/v8 --privileged -v $1:/workspace tegra-ubuntu
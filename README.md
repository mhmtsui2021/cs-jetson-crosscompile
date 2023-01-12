``` shell
sudo apt-get install qemu binfmt-support qemu-user-static # Install the qemu packages
```

``` shell
sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes # This step will execute the registering scripts
```

```shell
sudo docker run --rm -t arm64v8/ubuntu uname -m # Testing the emulation environment
#aarch64
```

To build the container
```shell
sudo ./build.sh
```

To run the built container
use -v to bind mount the code for compilation
```shell
sudo ./run.sh [path to the workspace]
```
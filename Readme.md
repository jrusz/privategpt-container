# Arch based container for running privateGPT

I've created a simple Containerfile for running
[privateGPT](https://github.com/imartinez/privateGPT) on an NVIDIA GPU. Once
built it has all the dependencies, you just need to download your model and run
it. This has been tested with `podman` on Arch Linux so no SELinux.

## Usage

You have to build the container first, it's about ~25GB when finished but needs
a lot more when building. This is going to take a while depending on your
system and internet connection.

```
podman build -t . $NAME
```

Now just run the container passing all the nvidia devices and forwarding the 8001 port. Example command:

```
podman run -it --rm --device /dev/nvidia0 --device /dev/nvidiactl --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools --device /dev/nvidia-caps/nvidia-cap1 --device /dev/nvidia-caps/nvidia-cap2 --name ai-test -p 8001:8001 $NAME /bin/bash
```

When inside just change to the `privateGPT` directory, change any settings, download the models and run it.

```
cd privateGPT
vim settings.yaml #change your embedding or llm modesl or whatever
poetry run python scripts/setup
make run
```

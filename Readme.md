# Arch based container for running privateGPT

I've created a simple Containerfile for running
[privateGPT](https://github.com/imartinez/privateGPT) on an NVIDIA GPU. Once
built it has all the dependencies, you just need to download your model and run
it. This has been tested with `podman` on Arch Linux so no SELinux.

## Usage

You have to build the container first, it's about 6.37 GB when finished. This
is going to take a while depending on your system and internet connection.

```
podman build -t . $NAME
```

In order to pass the NVIDIA GPU to the container it's most convenient to use
the
[nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).
After the installation you should just need to run `sudo nvidia-ctk cdi
generate --output=/etc/cdi/nvidia.yaml` and you're good to go.

Now just run the container passing all the nvidia devices and forwarding the 8001 port. Example command:

```
podman run -it --rm --device nvidia.com/gpu=all --name ai-test -p 8001:8001 $NAME /bin/bash
```

When inside just change whatever you need and run it:

```
vim settings.yaml #change your embedding or llm modesl or whatever
poetry run python scripts/setup
make run
```
## Credits

Big thanks to @icsy7867 for suggesting to use the cuda image as a base and for
using the Nvidia CDI!

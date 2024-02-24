# Container image for running privateGPT

I've created a simple Containerfile for running
[privateGPT](https://github.com/imartinez/privateGPT) on an NVIDIA GPU. Once
built it has all the dependencies, you just need to download your model and run
it. This has been tested with `podman` on Arch Linux so no SELinux.

## Usage

You have to build the container first, it's about 6.36 GB when finished. This
is going to take a while depending on your system and internet connection.

```
podman build -t . $IMAGE_NAME
```

In order to pass the NVIDIA GPU to the container it's most convenient to use
the
[nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).
After the installation you should just need to run `sudo nvidia-ctk cdi
generate --output=/etc/cdi/nvidia.yaml` and you're good to go.

Now just run the container passing all the nvidia devices, forwarding the 8001
port and mounting you local privateGPT checkout. Example command:

```
podman run -it --rm --device nvidia.com/gpu=all -v ./privateGPT:/app -p 8001:8001 $IMAGE_NAME
```

Make any config changes in your local checkout including downloading the models prior to running.

## Credits

Big thanks to [icsy7867](https://github.com/icsy7867) for suggesting to use the cuda image as a base and for
using the Nvidia CDI!

# Container image for running privateGPT

I've created a simple Containerfile for running
[privateGPT](https://github.com/imartinez/privateGPT) on an NVIDIA GPU. Once
built it has all the dependencies, you just need to download your model and run
it. I prefer to use `podman` so this guide assumes that you're using that as well.

## Usage

You can either use the image from the packages that was built by me locally and
pushed to ghcr registry (free GitHub runners don't have enough space to build
it) or build it yourself.

In case you want to build it yourself just clone the repo and run:
```
podman build -t . $IMAGE_NAME
```

In order to pass the NVIDIA GPU to the container it's most convenient to use
the
[nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).
On Fedora you should be able to just use `dnf install nvidia-container-toolkit`
on Arch you can use AUR to get it .
After the installation you should just need to run `sudo nvidia-ctk cdi
generate --output=/etc/cdi/nvidia.yaml` and you're good to go. If you want to
check all the nvidia devices it generated you can run `nvidia-ctk cdi list`
which can be useful in case you want to pass a specific GPU

Now just run the container passing all the desired nvidia devices, forwarding
the 8001 port and mounting you local privateGPT checkout. Example command:

```
podman run -it --rm --device nvidia.com/gpu=all -v ./privateGPT:/app -p 8001:8001 $IMAGE_NAME /bin/bash
```

Make any config changes in your local checkout including downloading the models prior to running.
When inside run the setup first which will download all the models:
```
poetry run python scripts/setup
```

Afterwards you can just use `make run`. If you've done the setup previously you
can just run the container without `/bin/bash` as `make run` is the default
CMD.

In case you're running on a SELinux system and don't want to disable it you
need to download the Nvidia SELinux policy from
https://github.com/NVIDIA/dgx-selinux. I tried the RHEL-9 one on Fedora-38 and
it worked.
```
curl -O https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp
semodule -i nvidia-container.pp
```
the updated podman command looks like this then:
```
podman run -it --rm --device nvidia.com/gpu=all -v ./privateGPT:/app:z --security-opt=label=type:nvidia_container_t -p 8001:8001 $IMAGE_NAME /bin/bash
```


## Credits

Big thanks to [icsy7867](https://github.com/icsy7867) for suggesting to use the
cuda image as a base and for suggesting to use the nvidia-container-toolkit and
selinux policy!

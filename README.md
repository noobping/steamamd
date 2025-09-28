
# Containerised Steam Remote Play

The goal of this project is to containerize Steam in a way that allows enabling and using Steam Remote Play. By running Steam inside a container with VNC access, you can log in once, enable Remote Play, and turn your machine into a cloud gaming service.
This setup is designed to run on Fedora CoreOS (or Fedora Silverblue) with a AMD GPU.
This project aims to:
 - Run Steam in a headless container.
 - Allow VNC access to perform the initial login and configuration.
 - Expose the necessary ports for Steam Remote Play.
 - Provide a repeatable, isolated, and portable deployment method using Podman or Docker.

With this, you can transform your machine into your own personal cloud gaming host.

## Quickstart

Pull the image:

```sh
podman pull ghcr.io/noobping/steamamd:latest
```

Or build it locally:

```sh
podman build -t steamamd .
```

Run the container:

```sh
podman run --rm -p 5900:5900/tcp \
  -p 27031-27036:27031-27036/udp \
  -p 27036:27036/tcp \
  --device /dev/dri \
  --shm-size=4g \
  --security-opt seccomp=unconfined \
  --security-opt label=disable \
  --tmpfs /run --tmpfs /tmp \
  -v ./steam/data:/data/.steam:Z \
  -v ./steam/local:/data/.local/share/Steam:Z \
  steamamd
```

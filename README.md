Build

```sh
podman build -t headless-sway-vnc .
```

Run (change VNC_PASSWORD, geometry, etc. as you like)

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
  headless-sway-vnc
```

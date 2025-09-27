
build

```sh
podman build -t arch-steam-headless -f Dockerfile .
```

Persist Steam data on the host

```sh
mkdir -p ~/docker-steam/home \
         ~/docker-steam/.steam \
         ~/docker-steam/.local/share/Steam
```

Run headless

```sh
podman run --rm -it \
  --name steam-headless \
  --network host \
  --device /dev/dri \
  --userns=keep-id \
  --user $(id -u):$(id -g) \
  --ipc=host \
  --shm-size=2g \
  -e HOME=/home/steamuser \
  -e GAMESCOPE_WIDTH=1920 \
  -e GAMESCOPE_HEIGHT=1080 \
  -e GAMESCOPE_FPS=60 \
  -v ~/docker-steam/home:/home/steamuser:Z \
  -v ~/docker-steam/.steam:/home/steamuser/.steam:Z \
  -v ~/docker-steam/.local/share/Steam:/home/steamuser/.local/share/Steam:Z \
  arch-steam-headless
```

First run: Steam will start in Big Picture inside gamescope.
From your client device (Steam Desktop app or Steam Link), log in with the same account, you should see this machine available—select Stream and finish login/Steam Guard headlessly.

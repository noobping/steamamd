FROM registry.fedoraproject.org/fedora:43
RUN dnf -y install \
      sway wayvnc xorg-x11-server-Xwayland \
      mesa-dri-drivers mesa-libgbm mesa-libEGL \
      mesa-vulkan-drivers mesa-libGL vulkan-loader vainfo vulkan-tools \
      pipewire wireplumber pipewire-pulseaudio pipewire-alsa pulseaudio-utils \
      xdg-user-dirs glibc-langpack-* shadow-utils tini foot wofi coreutils wlr-randr \
      pciutils util-linux procps-ng iproute net-tools findutils which less vim-minimal \
    && dnf clean all
RUN setcap -r /usr/bin/sway || true && \
    setcap -r /usr/bin/wayvnc || true
RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf && \
    ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

RUN bash -lc 'set -e; \
  ver=$(rpm -E %fedora); \
  dnf -y install \
    "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${ver}.noarch.rpm" \
    "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${ver}.noarch.rpm"; \
  dnf -y install steam; \
  dnf clean all'

RUN mkdir -p /etc/{sway,wayvnc}
COPY sway.conf /etc/sway/config
COPY wayvnc.conf /etc/wayvnc/config
RUN useradd -m -b /data -u 1000 -U -s /bin/bash player

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY resolution.sh /usr/local/bin/resolution.sh
RUN chmod +x /usr/local/bin/*.sh

EXPOSE 5900/tcp 27031-27036/udp 27036/tcp

USER player
WORKDIR /data
ENV XDG_RUNTIME_DIR=/tmp/run/user/1000 \
    WLR_BACKENDS=headless \
    __GLX_VENDOR_LIBRARY_NAME=mesa \
    STEAM_RUNTIME_HEAVY=1 \
    GTK_THEME=Adwaita:dark \
    ADW_DISABLE_PORTAL=1

VOLUME ["/data/.steam", "/data/.local/share/Steam"]

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]

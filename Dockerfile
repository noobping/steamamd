FROM archlinux:latest

RUN printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf \
 && pacman -Syu --noconfirm

RUN pacman -S --noconfirm \
    steam \
    mesa lib32-mesa \
    vulkan-radeon lib32-vulkan-radeon vulkan-tools \
    libva-mesa-driver lib32-libva-mesa-driver \
    gamescope xorg-xwayland \
    pulseaudio \
    ttf-liberation \
 && pacman -Scc --noconfirm

RUN useradd -m -s /bin/bash steamuser || true
ENV HOME=/home/steamuser
WORKDIR /home/steamuser

RUN echo WLR_BACKENDS=headless >> /etc/environment
RUN echo WLR_LIBINPUT_NO_DEVICES=1 >> /etc/environment
RUN echo WLR_SESSION=0 >> /etc/environment
RUN echo LIBVA_DRIVER_NAME=radeonsi >> /etc/environment
RUN echo VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json >> /etc/environment
RUN echo __GL_SHADER_DISK_CACHE=1 >> /etc/environment
RUN echo PULSE_SERVER="unix:$XDG_RUNTIME_DIR/pulse/native" >> /etc/environment

COPY ./run.sh /usr/local/bin/headless.sh
RUN chmod +x /usr/local/bin/headless.sh

RUN printf '#!/bin/bash\nchown -R $(id -u):$(id -g) "$HOME" 2>/dev/null || true\nexec "$@"\n' \
  > /usr/local/bin/entry.sh && chmod +x /usr/local/bin/entry.sh

ENTRYPOINT ["/usr/local/bin/entry.sh"]
CMD ["/usr/local/bin/headless.sh"]

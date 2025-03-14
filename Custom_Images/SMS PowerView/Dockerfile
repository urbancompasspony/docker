uversion=jammy

FROM ubuntu:$uversion
ENV PASS='123456'
SHELL [ "/bin/bash", "-c" ]

ARG DEBIAN_FRONTEND=noninteractive

USER root
RUN <<EOF
echo 'export LC_ALL=pt_BR.UTF-8' >> /etc/profile.d/locale.sh
echo 'export LANG=pt_BR.UTF-8' >> /etc/profile.d/locale.sh
echo 'LANG=pt_BR.UTF-8' >> /etc/locale.conf
apt-get update
apt-get install -y locales tzdata
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
dpkg-reconfigure -fnoninteractive tzdata
echo -e 'pt_BR.UTF-8 UTF-8\nen_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen
EOF

ENV LANG='pt_BR.UTF-8'
ENV LANGUAGE='pt_BR:en'
ENV LC_ALL='pt_BR.UTF-8'
################----------------> locale/timezone
#
#
#
################----------------> xpra
USER root
RUN <<EOF
apt-get install -y \
            bash-completion \
            bzip2 \
            curl \
            dbus-x11 \
            dbus-user-session \
            flatpak \
            fonts-noto-color-emoji \
            git \
            gnupg \
            gzip \
            htop \
            iproute2 \
            iptables \
            jq \
            less \
            libarchive-tools \
            binutils \
            libpulse0 \
            python3-pip \
            python3-uinput \
            python3-watchdog \
            sudo \
            terminator \
            tmux \
            uuid-runtime \
            vim \
            wget \
            x11-xserver-utils \
            xdg-desktop-portal \
            xdg-desktop-portal-gnome \
            xdg-desktop-portal-gtk \
            xsel \
            xvfb \
            xz-utils \
            python3 \
            --no-install-recommends

apt-get install -y \
            gir1.2-gstreamer-1.0 \
            glib-networking \
            glib-networking-common \
            glib-networking-services \
            gstreamer1.0-alsa \
            gstreamer1.0-gl \
            gstreamer1.0-pipewire \
            gstreamer1.0-plugins-bad \
            gstreamer1.0-plugins-base \
            gstreamer1.0-plugins-good \
            gstreamer1.0-plugins-ugly \
            gstreamer1.0-pulseaudio

adduser ubuntu
usermod -aG sudo ubuntu
EOF

USER root
RUN <<EOF
wget -q -O- https://xpra.org/gpg.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/xpra.gpg
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/xpra.gpg arch=amd64] https://xpra.org $uversion main' > /etc/apt/sources.list.d/xpra.list
apt-get update
apt-get install -y xpra xpra-x11 xpra-html5 --no-install-recommends
#apt-get install -y xpra --no-install-recommends
EOF
################----------------> xpra

RUN <<EOF
cat > /usr/local/bin/xpra-exec.sh <<-IS_XPRA_STARTER
#!/bin/bash
export PASS="\${PASS}"
printf "\$PASS\n\$PASS" | passwd ubuntu
printf "\n\n                password xpra/sudo: \$PASS                \n\n\n"


rm -rf /tmp/.X* 2>>/dev/null
mkdir -p -m 0700 /run/xpra/ubuntu 2>>/dev/null
mkdir -p -m 0700 /run/xpra/1000 2>>/dev/null
mkdir -p -m 0700 /run/user/1000 2>>/dev/null
chown -R ubuntu:ubuntu /run/user/1000 2>>/dev/null
chown -R ubuntu:ubuntu /run/xpra/ubuntu 2>>/dev/null
chown -R ubuntu:ubuntu /run/xpra/1000 2>>/dev/null

mkdir -pv /run/dbus

mkdir -pv -m0700 /run/user/1000
mkdir -pv -m0775 /run/xpra
chown -Rv ubuntu:ubuntu /run/user/1000
chown -Rv ubuntu:ubuntu /run/xpra

rm -rv /run/dbus/* || true
rm -rv /run/dbus/.* || true
dbus-daemon --system --fork 2>/dev/null

#####

printf "\$PASS\n\$PASS" | passwd ubuntu
printf "\n\n                password xpra/sudo: \$PASS                \n\n\n"

runuser -P -l ubuntu -c "
    XDG_RUNTIME_DIR='/run/user/1000' \\
    DISPLAY=':15000' \\
    XCURSOR_SIZE='50' \\
        xpra start  \\
        ':15000' \\
        '--bind-tcp=0.0.0.0:15000' \\
        '--mdns=no' \\
        '--webcam=no' \\
        '--notifications=no' \\
        '--bell=no' \\
        '--no-daemon' \\
        '--no-audio' \\
        '--start-on-connect=/usr/bin/terminator' \\
        '--start=xhost +'
"
IS_XPRA_STARTER

chmod +x /usr/local/bin/xpra-exec.sh
EOF

EXPOSE 15000

VOLUME /home/ubuntu

USER root

ENTRYPOINT [ "/usr/local/bin/xpra-exec.sh" ]

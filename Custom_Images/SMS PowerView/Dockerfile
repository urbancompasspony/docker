FROM ubuntu:noble

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
            xsel \
            xvfb \
            xz-utils \
            python3 \
            --no-install-recommends

adduser ubuntu
usermod -aG sudo ubuntu
EOF

USER root
RUN <<EOF
wget -q -O- https://xpra.org/gpg.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/xpra.gpg
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/xpra.gpg arch=amd64] https://xpra.org noble main' > /etc/apt/sources.list.d/xpra.list
apt-get update
apt-get install -y xpra xpra-x11 xpra-html5
EOF
################----------------> xpra

RUN <<EOF
cat > /usr/local/bin/xpra-exec.sh <<-IS_XPRA_STARTER
#!/bin/bash
export PASS="\${PASS}"
printf "\$PASS\n\$PASS" | passwd ubuntu
printf "\n\n                password xpra/sudo: \$PASS                \n\n\n"

cat >> /home/ubuntu/.bashrc <<-IS_SMSStart
echo "\$PASS" | sudo -S rm -R /SMS/lib/app/resource/external/pid.txt
echo "\$PASS" | sudo -S rm -R /SMS/lib/app/resource/external/lock.txt
echo "\$PASS" | sudo -S rm -R /SMS/lib/app/SMSPowerView.tmp
echo "\$PASS" | sudo -S /SMS/bin/powerview start -g &
IS_SMSStart

rm -rf /tmp/.X* 2>>/dev/null
mkdir -p -m 0700 /run/xpra/ubuntu 2>>/dev/null
mkdir -p -m 0700 /run/xpra/1000 2>>/dev/null
mkdir -p -m 0700 /run/user/1000 2>>/dev/null
chown -R ubuntu:ubuntu /run/user/1000 2>>/dev/null
chown -R ubuntu:ubuntu /run/xpra/ubuntu 2>>/dev/null
chown -R ubuntu:ubuntu /run/xpra/1000 2>>/dev/null

mkdir -pv -m0700 /run/user/1000
mkdir -pv -m0775 /run/xpra
chown -Rv ubuntu:ubuntu /run/user/1000
chown -Rv ubuntu:ubuntu /run/xpra

#####

printf "\$PASS\n\$PASS" | passwd ubuntu
printf "\n\n                password xpra/sudo: \$PASS                \n\n\n"

chown -R ubuntu:ubuntu /etc/xpra/ssl

runuser -P -l ubuntu -c "
    XDG_RUNTIME_DIR='/run/user/1000' \\
    DISPLAY=':15000' \\
    XCURSOR_SIZE='50' \\
        xpra start  \\
        ':15000' \\
        '-d auth' \\
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

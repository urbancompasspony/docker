FROM ubuntu:22.04

ENV container docker
#ENV DEBIAN_FRONTEND noninteractive

RUN apt -y update

RUN apt -y install systemd && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/cryptsetup.target && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-journald.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/dev-hugepages.mount && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-journal-flush.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/dev-mqueue.mount && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-machine-id-commit.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/kmod-static-nodes.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-modules-load.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/plymouth-read-write.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-random-seed.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/plymouth-start.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-sysctl.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/proc-sys-fs-binfmt_misc.automount && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-sysusers.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/sys-fs-fuse-connections.mount && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup-dev.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/sys-kernel-config.mount && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/sys-kernel-debug.mount && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-udevd.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/sys-kernel-tracing.mount && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-udev-trigger.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-ask-password-console.path && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-update-utmp.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-binfmt.service && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/veritysetup.target && \
rm -f /usr/lib/systemd/system/sysinit.target.wants/systemd-boot-system-token.service && \
rm -f /usr/lib/systemd/system/multi-user.target.wants/* && \
rm -f /usr/lib/systemd/system/local-fs.target.wants/* && \
rm -f /usr/lib/systemd/system/sockets.target.wants/*udev* && \
rm -f /usr/lib/systemd/system/sockets.target.wants/*initctl* && \
rm -f /usr/lib/systemd/system/basic.target.wants/* && \
rm -f /usr/etc/systemd/system/*.wants/*

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]

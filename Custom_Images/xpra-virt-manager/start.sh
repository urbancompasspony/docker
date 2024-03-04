#!/bin/bash

dbus-launch gsettings set org.virt-manager.virt-manager.connections uris "$HOSTS"
dbus-launch gsettings set org.virt-manager.virt-manager.connections autoconnect "$HOSTS"
dbus-launch gsettings set org.virt-manager.virt-manager xmleditor-enabled true

trap 'exit 0' SIGTERM

rm /tmp/.X100-lock

while true;
  do
    chmod 777 /var/run/libvirt/libvirt-sock
    xpra start --bind-tcp=0.0.0.0:$PORTS,auth=password:value=$passw0rd --html=on --start=virt-manager --daemon=no --xvfb="/usr/bin/Xvfb +extension Composite -screen 0 "$resolution"x24+32 -nolisten tcp -noreset" --pulseaudio=no --notifications=no --bell=no :100
    sleep 5
  done

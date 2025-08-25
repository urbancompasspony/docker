#!/bin/bash

# Fix permissions and create necessary files
sudo touch ~/.Xauthority
sudo chmod 600 ~/.Xauthority
export XAUTHORITY=~/.Xauthority

# Create .xpra directory if it doesn't exist
sudo mkdir -p ~/.xpra
sudo chmod 700 ~/.xpra

# Set up dbus
dbus-launch gsettings set org.virt-manager.virt-manager.connections uris "$HOSTS"
dbus-launch gsettings set org.virt-manager.virt-manager.connections autoconnect "$HOSTS"
dbus-launch gsettings set org.virt-manager.virt-manager xmleditor-enabled true

trap 'exit 0' SIGTERM

# Clean up any existing locks
sudo rm -f /tmp/.X100-lock
sudo rm -f ~/.xpra/100

# Ensure temp directories have correct permissions
sudo mkdir -p /tmp/.X11-unix
sudo chmod 1777 /tmp/.X11-unix

while true;
do
    # Fix libvirt socket permissions if it exists
    if [ -e /var/run/libvirt/libvirt-sock ]; then
        sudo chmod 777 /var/run/libvirt/libvirt-sock
    fi

    # Start xpra with proper error handling
    echo "Starting Xpra on port $PORTS with display :100"
    xpra start \
        --bind-tcp=0.0.0.0:$PORTS \
        --auth=password:value=$passw0rd \
        --html=on \
        --start=catfish \
        --daemon=no \
        --xvfb="/usr/bin/Xvfb +extension Composite -screen 0 ${resolution}x24+32 -nolisten tcp -noreset" \
        --pulseaudio=no \
        --notifications=no \
        --bell=no \
        --file-transfer=on \
        --printing=no \
        --exit-with-children=no \
        :100

    echo "Xpra exited, waiting 5 seconds before restart..."
    sleep 5
done

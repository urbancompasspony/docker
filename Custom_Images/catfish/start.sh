#!/bin/bash

trap 'exit 0' SIGTERM

rm -f /tmp/.X100-lock

# Configurar e executar indexação inicial se INDEX_PATH estiver definido
if [ ! -z "$INDEX_PATH" ]; then
    echo "Configurando indexação para: $INDEX_PATH"

    # Configurar updatedb para indexar apenas o caminho especificado
    cat > /etc/updatedb.conf << EOF
PRUNE_BIND_MOUNTS="no"
PRUNEPATHS="/tmp /var/tmp /dev /proc /sys"
PRUNEFS="NFS nfs nfs4 rpc_pipefs afs binfmt_misc proc smbfs autofs iso9660 ncpfs coda devpts ftpfs devfs mfs shfs sysfs cifs lustre tmpfs usbfs udf fuse.glusterfs fuse.sshfs curlftpfs"
PRUNE_REGEXP=""
EOF

    echo "Executando indexação inicial (pode demorar)..."
    updatedb --localpaths="$INDEX_PATH" &

    # Agendar re-indexação a cada 6 horas
    (
        while true; do
            sleep 21600  # 6 horas
            echo "Re-indexando $INDEX_PATH..."
            updatedb --localpaths="$INDEX_PATH"
        done
    ) &
fi

# Loop principal idêntico ao seu código original
while true;
  do
    sudo chmod 777 /var/run/libvirt/libvirt-sock 2>/dev/null || true
    xpra start --bind-tcp=0.0.0.0:$PORTS,auth=password:value=$passw0rd --html=on --start=catfish --daemon=no --xvfb="/usr/bin/Xvfb +extension Composite -screen 0 "$resolution"x24+32 -nolisten tcp -noreset" --pulseaudio=no --notifications=no --bell=no :100
    sleep 5
  done

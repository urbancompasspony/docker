# 🐳 Docker Environment

> **Note**: Since it's challenging to find reliable `compose.yaml` base code for Docker Compose, this repository is designed to run with bash scripts (`.sh` files). Maintenance and additional configurations must be handled separately.

## 📋 Table of Contents

- [Installation](#-installation)
- [Network Configuration](#-network-configuration)
- [Platform-Specific Setup](#-platform-specific-setup)
- [Common Use Cases](#-common-use-cases)
- [Backup & Restore](#-backup--restore)
- [Samba Domain Controller](#-samba-domain-controller)
- [FAQ & Troubleshooting](#-faq--troubleshooting)

## 🚀 Installation

### Debian/Ubuntu-based Systems

#### Standard Installation
```bash
sudo apt install docker.io
```
*This provides stable packages sufficient for most use cases.*

#### Ubuntu-specific DNS Configuration
**⚠️ Only required if NOT using virtual IP:**

1. **Stop and disable systemd-resolved:**
   ```bash
   sudo systemctl stop systemd-resolved
   sudo systemctl disable systemd-resolved
   sudo unlink /etc/resolv.conf
   ```

2. **Create new DNS configuration:**
   ```bash
   sudo nano /etc/resolv.conf
   ```
   
   Add the following content:
   ```
   nameserver IP_OF_YOUR_GATEWAY
   search HOSTNAME_OF_GATEWAY_IF_THERES_ANY
   ```
   
   **Example with pfSense:**
   ```
   nameserver 192.168.0.1
   search mypfsense.localdomain
   ```

> **💡 Note**: This prevents ethernet connection loss on Docker server. Not necessary when using macvlan network!

## 🌐 Network Configuration

### MAC Address Customization
Add this line inside your script to change MAC address:
```bash
--mac-address 02:42:c0:a8:00:02 \
```

### Creating macvlan Network
Expose your Docker container on LAN through a different IP:

```bash
sudo docker network create -d macvlan \
  --subnet=192.168.0.0/24 \
  --gateway=192.168.0.1 \
  -o parent=eth0 \
  macvlan
```

> **📌 Default**: All scripts in this repository use `macvlan` as the default network.

### Multiple Subnets
For different subnets on the same parent interface:

```bash
sudo docker network create -d macvlan \
  --subnet=192.168.0.0/24 \
  --gateway=192.168.0.1 \
  -o parent=eth0.20 \
  macvlan-custom
```

> **⚠️ Warning**: Docker treats the number after `.` as a sub-parent, but requires additional configuration. **Recommendation**: Run each macvlan on its own network adapter.

## 🔧 Platform-Specific Setup

### Raspberry Pi
Install required modules and reboot:
```bash
sudo apt install linux-modules-extra-raspi
sudo reboot
```

**Without this, you'll encounter:**
```
failed to create the macvlan port: operation not supported
```

### PiHole on Domain Network
1. **Access container:**
   ```bash
   sudo docker exec -it pihole /bin/bash
   ```

2. **Install nano and configure:**
   ```bash
   apt update && apt install nano
   nano /etc/pihole/pihole-FTL.conf
   ```

3. **Add rate limit configuration:**
   ```
   RATE_LIMIT=0/0
   ```

4. **Restart container** (not just the service)

## 💻 Common Use Cases

### SSH into Container
```bash
sudo docker exec -it <container_name> /bin/bash
```

### View Running Containers
```bash
sudo docker ps -a
```

### Check Docker Images
```bash
sudo docker images
```

## 💾 Backup & Restore

### Creating Backups

#### Method 1: Commit and Save
```bash
# Get container ID
sudo docker images

# Create backup (stop container first)
sudo docker commit -p <CONTAINER_ID> my-backup

# Save to tar file
sudo docker save -o /path/to/my-backup.tar my-backup
```

#### Method 2: Export Running Container
```bash
# On source host
docker export <container_name> > my_container.tar

# Transfer to target host
scp my_container.tar user@target_host:~
```

> **⚠️ Important**: Container backups store only system configurations, not data files. Remember to backup volumes (`-v`) and note all parameters used!

### Restoring Backups

#### Method 1: Load from Save
```bash
sudo docker image load -i /path/to/my-backup.tar
```

Then run with original parameters:
```bash
docker run -t -i -d \
    --network macvlan \
    --ip=THE_SAME_IP_AS_BEFORE \
    -v /SAME/PATH/TO:/var/lib/samba \
    -v /SAME/PATH/TO/ANOTHER:/etc/samba/external \
    --privileged \
    --restart=unless-stopped \
    --name samba \
    my-backup
```

#### Method 2: Import from Export
```bash
# On target host
cat my_container.tar | docker import - my_container:latest

# Create new container
docker run -d --name my_new_container my_container:latest
```

## 🏢 Samba Domain Controller

### Credits & References
- **Base**: [Fmstrat/samba-domain](https://github.com/Fmstrat/samba-domain)
- **Inspiration**: [crazy-max/docker-samba](https://github.com/crazy-max/docker-samba)
- **Additional Help**: [instantlinux/samba-dc](https://hub.docker.com/r/instantlinux/samba-dc)

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOMAIN` | `CORP.EXAMPLE.COM` | Your domain name |
| `DOMAINPASS` | *(required)* | Administrator password (remove after first setup) |
| `HOSTIP` | *(optional)* | IP address to advertise |
| `JOIN` | `false` | Set to `true` to join existing domain |
| `JOINSITE` | *(optional)* | Site name when joining domain |
| `DNSFORWARDER` | *(optional)* | DNS server IP for unresolved requests |
| `INSECURELDAP` | `false` | Remove secure LDAP requirement (not recommended for production) |
| `MULTISITE` | `false` | Connect to OpenVPN site via ovpn file |
| `NOCOMPLEXITY` | `false` | Remove password complexity requirements |

### Volume Mappings

```bash
# Essential volumes
-v /etc/localtime:/etc/localtime:ro                           # Timezone sync
-v /data/docker/containers/samba/data/:/var/lib/samba         # Samba data
-v /data/docker/containers/samba/config/samba:/etc/samba/external  # Configuration

# Optional (for VPN connectivity)
-v /data/docker/containers/samba/config/openvpn/docker.ovpn:/docker.ovpn
-v /data/docker/containers/samba/config/openvpn/credentials:/credentials
```

### VPN Credentials Format
Create credentials file with:
```
username
password
```

Ensure your `.ovpn` file contains:
```
auth-user-pass /credentials
```

## ❓ FAQ & Troubleshooting

### Common Issues

**Q: Container can't access network**
- Check if macvlan network is properly configured
- Verify parent interface name (`eth0`, `ens33`, etc.)

**Q: DNS resolution fails**
- Ensure DNS configuration is correct
- Check if systemd-resolved conflicts exist

**Q: Permission denied errors**
- Use `--privileged` flag for containers requiring system access
- Check volume mount permissions

**Q: Container won't start after reboot**
- Add `--restart=unless-stopped` to your run command
- Check if required networks exist after reboot

### Best Practices

1. **Always backup** volumes and configurations before major changes
2. **Use macvlan** for production deployments requiring LAN integration
3. **Document all parameters** used in container creation
4. **Test restores** regularly to ensure backup integrity
5. **Monitor logs** with `docker logs <container_name>`

---

> **💡 Pro Tip**: Keep a script file with your exact `docker run` command for easy container recreation!

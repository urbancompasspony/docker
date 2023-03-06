# Run This:

# SAMBA

mount -t cifs -o user=USERNAME,password=PASSWORD,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm //xxx.xxx.xxx.xxx/remote/folder /local/folder

# SSH

sshfs -o allow_other,default_permissions sammy@your_other_server:~/ /mnt/droplet

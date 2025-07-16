for dir in /mnt/disk02/rsnapshot/*/localhost/mnt/disk01/Lixeira/; do
    find "$dir" -type f -mtime +180 -delete
done

find /mnt/disk02/rsnapshot/*/localhost/mnt/disk01/Lixeira/ -type f -mtime +180 -delete

Model AutoDelete Examples:
#find "/mnt/disk01/dominio/Lixeira/" -maxdepth 1 -type d -atime +120 -exec rm -rf {}
#find . -mtime +0 # find files modified greater than 24 hours ago
#find . -mtime 0 # find files modified between now and 1 day ago

## (i.e., in the past 24 hours only)

#find . -mtime -1 # find files modified less than 1 day ago (SAME AS -mtime 0)
#find . -mtime 1 # find files modified between 24 and 48 hours ago
#find . -mtime +1 # find files modified more than 48 hours ago
#find /opt/backup -type f -mtime +5 -delete 
#find /var/log -type d -mtime +5 -exec rm -rf {} \; 

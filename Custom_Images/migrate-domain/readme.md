Use this to migrate an existing domain controller from host to inside a container!
Use this dockerfile to build a new whole system with these folders and files inside, extracted from original server:

/var/cache/samba

/var/lib/samba

/var/log/samba

/etc/samba

/run/samba

/etc/hosts

/etc/krb5.conf

/etc/resolv.conf

After this, just run the service samba-ad-dc

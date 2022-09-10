## Use this to migrate an existing domain controller from host to inside a container!

If you want to make a definitive migration, catch all these files and folders:

/var/cache/samba

/var/lib/samba

/var/log/samba

/etc/samba

/run/samba

/etc/hosts

/etc/krb5.conf

/etc/resolv.conf

After this, just run the service samba-ad-dc, Dockerfile will run automatically.

## Files for 05-samba model!

smb.conf:
ad dc functional level = 2016

samba-tool domain schemaupgrade --schema=2019
samba-tool domain functionalprep --function-level=2016
samba-tool domain level raise --domain-level=2016 --forest-level=2016

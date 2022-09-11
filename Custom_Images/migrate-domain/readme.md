## Use this to migrate an existing domain controller from host to inside a container!

If you want to make a definitive migration, use the AutoExport script to catch all needed files and folders.

Put them inside container, passing through the -volume of the folder ACTIVE_DIRECTORY.

After this, just run the service samba-ad-dc, Dockerfile will run automatically.

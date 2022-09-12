# Use this to migrate an existing Samba Shared Server from host to inside a container!

If you want to make a definitive migration, use the AutoExport script to catch all needed files and folders.

Put them inside container, passing through the -volume of the folder SAMBA_SHARED.

After this, just run the service smbd, nmbd and winbind; Dockerfile will run automatically.

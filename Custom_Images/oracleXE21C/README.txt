Custom docker image for general purposes!

You will need to download it:

wget https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-21c-1.0-1.el7.x86_64.rpm

wget https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol7.x86_64.rpm

Two .rpm files on same folder as Dockerfile

BUILD:
docker buildx create --name mybuilder
docker buildx use mybuilder
docker login

docker buildx build --push --platform linux/amd64 --tag urbancompasspony/centosoracle .

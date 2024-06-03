
## Here I will unite some scripts Dockfile and .sh to build custom images with special parameters.

Commands:

docker buildx create --name mybuilder

docker buildx use mybuilder

docker login

docker build --tag domain-teste .

EXAMPLE

docker buildx build --push --platform linux/amd64,linux/arm64 --tag urbancompasspony/domain-teste .

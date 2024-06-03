
MULTIARCH!

docker buildx create --name mybuilder

docker buildx use mybuilder

docker login

EXAMPLE

docker buildx build --push --platform linux/amd64,linux/arm64 --tag urbancompasspony/domain-teste .

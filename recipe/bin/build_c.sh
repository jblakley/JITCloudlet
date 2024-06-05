MAGMA_ROOT=/home/jblake1/build/magma
TAG=local
DOCKER_BUILDKIT=1 docker build -t local/agw_gateway_c:${TAG} -f services/c/Dockerfile $MAGMA_ROOT
# DOCKER_BUILDKIT=1 docker build --no-cache -t local/agw_gateway_c:${TAG} -f services/c/Dockerfile $MAGMA_ROOT


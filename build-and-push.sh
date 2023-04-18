#!/bin/bash

set -euo pipefail

ECR_REGISTRY=$(echo "$1" | tr -d '[:space:]')
ECR_REPOSITORY=$(echo "$2" | tr -d '[:space:]')
IMAGE_TAG=$(echo "$3" | tr -d '[:space:]')
DOCKERFILE_PATH=$(echo "$4" | tr -d '[:space:]')
TARGET=$(echo "$5" | tr -d '[:space:]')
EXTRA_BUILD_ARG=$(echo "$6" | tr -d '[:space:]')

# Concatenate the ECR repository URI with the image tag
image_uri="$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

echo "image tag"

# Set the base build command
base_build_cmd="docker build --cache-from $image_uri --cache-from $ECR_REGISTRY/$ECR_REPOSITORY:latest \
            -t $image_uri -t $ECR_REGISTRY/$ECR_REPOSITORY:latest \
            . -f $DOCKERFILE_PATH"

# Concatenate --target if target is not null
if [ -n "$TARGET" ]; then
  base_build_cmd+=" --target $TARGET"
fi

# Concatenate --build-arg if extra_build_arg is not null
if [ -n "$EXTRA_BUILD_ARG" ]; then
  base_build_cmd+=" --build-arg $EXTRA_BUILD_ARG"
fi

docker pull $ECR_REGISTRY/$ECR_REPOSITORY:latest || docker pull $image_uri || true

# Build the Docker image
$base_build_cmd

# Push the Docker image to the ECR repository
docker push $ECR_REGISTRY/$ECR_REPOSITORY --all-tags
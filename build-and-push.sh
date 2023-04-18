#!/bin/bash

set -euo pipefail

ECR_REGISTRY="$1"
ECR_REPOSITORY="$2"
IMAGE_TAG="$3"
DOCKERFILE_PATH="$4"
TARGET="$5"
EXTRA_BUILD_ARG="$6"

# Concatenate the ECR repository URI with the image tag
image_uri="$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

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
$base_build_cmd -t "$image_uri" .

# Push the Docker image to the ECR repository
docker push "$image_uri"

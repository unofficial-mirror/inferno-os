#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

# The repository root location in the container.
# Must be the same as the $INFERNO variable in the Dockerfile.
WORKSPACE=/usr/inferno

docker run \
    --detach \
    --restart unless-stopped \
    --interactive \
    --tty \
    --network=host \
    --name inferno_emu \
    --mount type=bind,src="$(pwd)/usr/inferno",dst=$WORKSPACE/usr/inferno \
    --mount type=bind,src="$(pwd)/lib",dst=$WORKSPACE/lib \
    --mount type=bind,src="$(pwd)/keydb",dst=$WORKSPACE/keydb \
    inferno/386:latest emu -c1 sh -l

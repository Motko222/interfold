#!/bin/bash
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
source $path/env

docker run -d \
  --name $CONTAINER \
  --network host \
  --restart unless-stopped \
  -v $path/enclave.config.yaml:/home/ciphernode/.config/interfold/config.yaml:ro \
  -v $path/secrets.json:/run/secrets/secrets.json:ro \
  -v $path/entrypoint.sh:/usr/local/bin/ciphernode-entrypoint.sh:ro \
  ghcr.io/gnosisguild/ciphernode:latest

echo "$CONTAINER started"

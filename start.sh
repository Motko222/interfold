#!/bin/bash
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
source $path/env

docker run -d \
  --name $CONTAINER \
  --network host \
  --restart unless-stopped \
  -v /root/interfold/interfold:/usr/local/bin/interfold:ro \
  -v $path/enclave.config.yaml:/home/ciphernode/.config/interfold/config.yaml:ro \
  -v $path/secrets.json:/run/secrets/secrets.json:ro \
  -v $path/ubuntu-entrypoint.sh:/usr/local/bin/ciphernode-entrypoint.sh:ro \
  -v interfold-data:/home/ciphernode/.config/interfold/.interfold \
  --entrypoint /usr/local/bin/ciphernode-entrypoint.sh \
  ubuntu:24.04

echo "$CONTAINER started"

#!/bin/bash
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
source $path/env

docker pull ghcr.io/gnosisguild/ciphernode:latest
docker stop $CONTAINER && docker rm $CONTAINER
bash $path/start.sh

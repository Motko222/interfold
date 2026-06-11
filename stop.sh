#!/bin/bash
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
source $path/env

docker stop $CONTAINER && docker rm $CONTAINER
echo "$CONTAINER stopped"

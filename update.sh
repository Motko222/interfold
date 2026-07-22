#!/bin/bash
# To upgrade: download new binary to /root/interfold/interfold, then run this script.
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
source $path/env

docker stop $CONTAINER && docker rm $CONTAINER
bash $path/start.sh

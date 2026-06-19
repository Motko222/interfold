#!/bin/bash
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
source $path/env

docker exec $CONTAINER interfold ciphernode status --config /home/ciphernode/.config/interfold/config.yaml

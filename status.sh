#!/bin/bash
path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
source $path/env

docker exec $CONTAINER enclave ciphernode status

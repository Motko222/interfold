#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=~/logs/report-$folder
source ~/.bash_profile
source $path/env

docker_status=$(docker inspect $CONTAINER 2>/dev/null | jq -r '.[].State.Status' 2>/dev/null || echo "missing")
version=$(docker inspect $CONTAINER 2>/dev/null | jq -r '.[].Config.Image' | awk -F: '{print $NF}')
errors=$(docker logs $CONTAINER --since 1h 2>&1 | grep -c -iE "error|ERROR")
peers=$(docker logs $CONTAINER --since 5m 2>&1 | grep -oP 'peers=\K[0-9]+' | tail -1)
subscribed=$(docker logs $CONTAINER --since 5m 2>&1 | grep -c "Live event subscription active")

case $docker_status in
  running) status="ok" ;;
  *) status="error"; message="docker not running ($docker_status)" ;;
esac
[ $errors -gt 10 ] && status="warning" && message="$errors errors last hour"

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
       "id":"$folder-$ID",
       "machine":"$MACHINE",
       "grp":"node",
       "owner":"$OWNER"
  },
  "fields": {
        "chain":"sepolia",
        "network":"testnet",
        "version":"$version",
        "status":"$status",
        "message":"$message",
        "errors":"$errors",
        "m1":"peers=$peers",
        "m2":"subscribed=$subscribed",
        "m3":""
  }
}
EOF

cat $json | jq

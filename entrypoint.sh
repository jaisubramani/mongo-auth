#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
  set -- mongod "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'mongod' -a "$(id -u)" = '0' ]; then
  chown -R mongodb /data/configdb /data/db
  exec gosu mongodb "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'mongod' ]; then
  numa='numactl --interleave=all'
  if $numa true &> /dev/null; then
    set -- $numa "$@"
  fi
fi

# start mongod
exec "$@" &

# wait until mongod starts up
RET=1
while [[ $RET -ne 0 ]]; do
    sleep 2
    mongo admin --eval "help" >/dev/null 2>&1
    RET=$?
done

# storage is persisted so add mongo user if it doesn't exist
result=`mongo admin --eval "db.getUser('admin');" --quiet`
if [ "$result" = 'null' ]; then
  mongo admin --eval "db.createUser({user: 'admin', pwd: 'admin', roles:['root']});" --quiet
fi

# shutdown mongod
exec "$@" --shutdown &

sleep 2

# start mongod with auth enabled
exec "$@" --auth

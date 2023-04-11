#!/bin/bash
# Adapted from https://serverfault.com/a/995377
HOST=$1
PORT=$2
REMOTE_USER=$3
if [ -z "$1" ]
  then
    echo "Missing argument for host."
    exit 1
fi
if [ -z "$2" ]
  then
    echo "Missing argument for port."
    exit 1
fi
if [ -z "$3" ]
  then
    echo "Missing argument for remote user."
    exit 1
fi
echo "polling to see that host is up and ready"
RESULT=1 # 0 upon success
TIMEOUT=30 # number of iterations (5 minutes?)
while :; do
    echo "waiting for server ping ..."
    status=$(ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${HOST} -p ${PORT} echo ok 2>&1)
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
        echo "connected ok"
        break
    fi
    TIMEOUT=$((TIMEOUT-1))
    if [ $TIMEOUT -eq 0 ]; then
        echo "timed out"
        exit 1
    fi
    sleep 10
done
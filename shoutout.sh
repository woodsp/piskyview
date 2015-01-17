#!/bin/bash

## try and connect to the outside world
## by looking for a network connection and attempting a reverse ssh
## that would allow us to ssh to the raspberry without needing to know its IP
## mostly from http://stackoverflow.com/questions/10839014/reverse-ssh-tunnel

REMOTE_USER="piroot"
REMOTE_DOMAIN="naturalcapitalproject.org"
SOCKETS_USED=`netstat -p ssh | grep 'ssh ESTABLISHED' | grep -c $(host $REMOTE_DOMAIN | head -n 1 | awk {'print $NF'} | awk -F"." '{print $4"."$3"."$2"."$1}')`

establish_connecton() {
  echo "establishing reverse ssh tunnel connection..."
  ssh -R 12222:localhost:22 -oStrictHostKeyChecking=no -f -N -T ${REMOTE_USER}@${REMOTE_DOMAIN} &
  echo "done."
  echo
  exit
}

# check for network connection
cable=$(grep "" /sys/class/net/eth0/carrier)
if [ $cable -eq 1 ]; then
  echo "network cable is connected."
  # check for existing connection
  if [ $(ps -ef | grep "ssh -R 12222" | grep -v grep | wc -l) == 0 ]; then
    echo "no reverse ssh tunnel connection exists."
    establish_connecton
  fi

  if [ "$SOCKETS_USED" -lt 1 ]; then
    echo "no reverse ssh tunnel sockets are connected. nuking stale pids and re-establishing connection"
    # check for stale pids and kill them if found.
    if [ $(ps -ef | grep "ssh -R 12222" | grep -v grep | wc -l) -gt 0 ]; then
      # stale pids exist, kill them...
      ps -ef | grep "ssh -R 12222" | grep -v grep | awk {'print $2'} | \
        while read PID; do
          echo "kill -9 $PID"
        done
    fi
    establish_connecton
  else
    echo "sockets appear connected. assuming reverse ssh tunnel is running fine."
  fi
fi

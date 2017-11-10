#!/bin/bash

PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
MAPPED_DIR=/home/acn-iot/node-red-user-data
LOCAL_IP_FILE=$MAPPED_DIR/local_ip.txt
VERBOSE=
IMAGE=dockerhub.accenture.com/renato.mintz/rpdlite-agent
CONTAINER_NAME=agent-container
HOSTNAME=$(hostname -f)
LOCAL_IP=$(ip -4 addr show wlan0 | grep -Po 'inet \K[\d.]+')

echo $LOCAL_IP > $LOCAL_IP_FILE

function usage
{
    echo "usage: run_agent.sh <options>"
    echo "options:"
    echo "     -i <image> optional - default is $IMAGE"
    echo "     -d <mapped dir> optional - default is $MAPPED_DIR"
    echo "     -v verbose output"
    echo "     -h prints this message"
}

while [ "$1" != "" ]; do
    case $1 in
        -i)    shift
               IMAGE=$1
               ;;

        -d)    shift
               MAPPED_DIR=$1
               ;;

        -v)    VERBOSE=-vvvvv
               ;;
               
        -n)    shift
               CONTAINER_NAME=$1
               ;;

        -h | --help)
               usage
               exit
               ;;

        * )    usage
               exit 1
    esac
    shift
done

if [ ! -z "$VERBOSE" ]; then
   echo $VERSION
   echo "IMAGE: $IMAGE"
   echo "CONTAINER NAME: $CONTAINER_NAME"
   echo "MAPPED DIR: $MAPPED_DIR"
   echo "VERBOSE: $VERBOSE"
fi

if [ ! "$(docker ps -a | grep $CONTAINER_NAME)" ]; then
   echo $(date -u) "Container $CONTAINER_NAME not found"
   docker run -d --net=host -v $MAPPED_DIR:/data  --user=root --hostname=$HOSTNAME --name $CONTAINER_NAME $IMAGE
else
   if [ "$(docker ps -aq -f status=running -f name=$CONTAINER_NAME)" ]; then
      echo $(date -u) "Container $CONTAINER_NAME already running"
   else
      echo $(date -u) "Starting container $CONTAINER_NAME"
      docker start $CONTAINER_NAME
   fi
fi

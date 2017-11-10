#!/bin/bash

PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
VERBOSE=
IMAGE=dockerhub.accenture.com/renato.mintz/rpdlite
MAPPED_DIR=/home/acn-iot/node-red-user-data
SERIAL_PORT=/dev/ttyACM0
CONTAINER_NAME=node-red-container
HOSTNAME=$(hostname -f)

function usage
{
    echo "usage: run_docker.sh <options>"
    echo "options:"
    echo "     -i <image> optional - default is $IMAGE"
    echo "     -d <mapped dir> optional - default is $MAPPED_DIR"
    echo "     -s <serial port> optional - default is $SERIAL_PORT"
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

        -s)    shift
               SERIAL_PORT=$1
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
   docker run -d -p 1880:1880 --net=host -v $MAPPED_DIR:/data  --user=root --hostname=$HOSTNAME --device $SERIAL_PORT:$SERIAL_PORT --privileged=true --name $CONTAINER_NAME $IMAGE
else
   if [ "$(docker ps -aq -f status=running -f name=$CONTAINER_NAME)" ]; then
      echo $(date -u) "Container $CONTAINER_NAME already running"
   else
      echo $(date -u) "Starting container $CONTAINER_NAME"
      docker start $CONTAINER_NAME
   fi
fi

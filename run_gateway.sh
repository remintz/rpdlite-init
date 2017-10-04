#!/bin/bash

# script to install the basic tools to run the rapid prototyping gateway
# to run:
#    run_gateway <device ip> <host name>
# example
#    ./run_gateway raspberrypi.local home-blue
#
# it asks for the password for user "pi", generally "raspberry"
#


DEVICE_IP="raspberrypi.local"
NEW_HOSTNAME=
VERBOSE=
ANSIBLE_PULL_TAG='production'
VERSION=$(git describe)
RPI2=

function usage
{
    echo "usage: run_gateway <options>"
    echo "options:"
    echo "     -n <hostname to be assigned to the gateway>"
    echo "     -i <the gateway ip address>"
    echo "     -t <tag used on ansible pull> optional - the default is production"
    echo "     -2 RaspberryPi 2 with EDIMAX dongle"
    echo "     -v verbose output"
    echo "     -h prints this message"
}

while [ "$1" != "" ]; do
    case $1 in
        -n )   shift
               NEW_HOSTNAME=$1
               ;;

        -i )   shift
        	   DEVICE_IP=$1
               ;;

        -t)    shift
			   ANSIBLE_PULL_TAG=$1
               ;;

        -v)    VERBOSE=-vvvvv
			   ;;

        -h | --help)
        	   usage
               exit
               ;;

        -2)   RPI2=True
              ;;
        * )    usage
               exit 1
    esac
    shift
done

if [ -z "$NEW_HOSTNAME" ]; then
	echo "New hostname must be defined."
	echo
	usage
	exit 1
fi

if [ -z "$VERBOSE" ]; then
   echo "Verbose is off"
else
   echo $VERSION
   echo "NEW_HOSTNAME: $NEW_HOSTNAME"
   echo "DEVICE_IP: $DEVICE_IP"
   echo "ANSIBLE_PULL_TAG: $ANSIBLE_PULL_TAG"
   echo "VERBOSE: $VERBOSE"
   echo "RASPI2/EDIMAX: $RPI2"
fi

if [ ! -z $DEVELOPMENT_MODE ]; then
	ANSIBLE_PULL_TAG='development'
fi


EXTRA_OPTIONS="'{"
EXTRA_OPTIONS=$EXTRA_OPTIONS'"host_key_checking":"False"'
EXTRA_OPTIONS=$EXTRA_OPTIONS',"version":"'$VERSION'"'
EXTRA_OPTIONS=$EXTRA_OPTIONS',"new_hostname":"'$NEW_HOSTNAME'"'
EXTRA_OPTIONS=$EXTRA_OPTIONS',"ansible_pull_tag":"'$ANSIBLE_PULL_TAG'"'
if [ ! -z $RPI2 ]; then
  EXTRA_OPTIONS=$EXTRA_OPTIONS',"isRPi2":"TRUE"'
fi
EXTRA_OPTIONS=$EXTRA_OPTIONS"}'"

echo "EXTRA_OPTIONS: $EXTRA_OPTIONS"

COMMAND="ansible-playbook -i $DEVICE_IP, -u pi -k -e $EXTRA_OPTIONS gateway.yml $VERBOSE"
echo "COMMAND: $COMMAND"
eval $COMMAND



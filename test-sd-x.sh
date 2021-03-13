#!/bin/bash
## test sd card / USB stick

## global variables
SCRIPT=`basename $0`
DEBUG=false
VERBOSE=true

## script specific variables
DEFAULTDEVICE="/dev/sdb"

## end script specific variables

(${DEBUG}) && set -x

#warning, this will terminate the script on errors
#do not use this if errors are expected behavior!
set -e

## display usage on invalid amount of arguments or help arguments
usage()
{
echo "usage: $SCRIPT"
echo "       $SCRIPT -h|--help"
echo "arguments"
echo "  -h|--help  display help information"
echo ""
exit 1
}

#if arguments > 1 or first argument == -h| --help show usage
if [ $# -gt 1 -o "$1" == "-h" -o "$1" == "--help" ]
then
usage
fi

read -p  "device to test? [${DEFAULTDEVICE}]: " DEVICE
if [ "${DEVICE}" == "" ]
then
  DEVICE=${DEFAULTDEVICE}
fi

read -p  "test in RW mode? [Y/n]: " WRITE
if [ "${WRITE}" == "" -o "${WRITE}" == "y" -o "${WRITE}" == "Y" ]
then
  WRITE=true
else
  WRITE=false
fi


## VERBOSE
(${VERBOSE}) && echo "device: ${DEVICE}"
(${VERBOSE}) && echo "write mode: ${WRITE}"

MOUNTED=`mount | grep ${DEVICE} | awk '{ print $1 }'`
for MOUNT in ${MOUNTED}
do
echo "umounting ${MOUNT}"
umount ${MOUNT}
done

sleep 5

DATETIME=`date +"%Y-%m-%d %H:%M"`
echo "### started at ${DATETIME} ###"

if [ ${WRITE} == "true" ]
then
  sleep 5
  echo "### running f3probe in destructive mode ###"
  f3probe --destructive --time-ops ${DEVICE}
  echo "### running badblocks in write mode ###"
  badblocks -w -v ${DEVICE}
else
  echo "### running f3probe in RO mode ###"
  f3probe --time-ops ${DEVICE}
  echo "### running badblocks in RO mode ###"
  badblocks -v ${DEVICE}
fi

DATETIME=`date +"%Y-%m-%d %H:%M"`
echo "### finished at ${DATETIME} ###"

exit 0

#!/bin/bash

set -e

# hide ^C
stty -echoctl

# please make sure these paths exist!
VIRTMICPATH=~/virtmic
AUDIOFILE=input.mp3

# This script will create a virtual microphone for PulseAudio to use and set it as the default device.

# trap ctrl-c and call stop()
trap stop SIGINT

function start()
{
# Load the "module-pipe-source" module to read audio data from a FIFO special file.
echo "Creating virtual microphone."
pactl load-module module-pipe-source source_name=virtmic file=${VIRTMICPATH}/virtmic format=s16le rate=16000 channels=1

# Set the virtmic as the default source device.
echo "Set the virtual microphone as the default device."
pactl set-default-source virtmic

# Create a file that will set the default source device to virtmic for all PulseAudio client applications.
echo "default-source = virtmic" > ~/.config/pulse/client.conf

# Write the audio file to the named pipe virtmic. This will block until the named pipe is read.
echo "Writing audio file to virtual microphone (in a loop)."
while :
do 
 ffmpeg -loglevel quiet -re -i ${AUDIOFILE} -f s16le -ar 16000 -ac 1 - > ${VIRTMICPATH}/virtmic 
done
}


# Uninstall the virtual microphone.
function stop()
{
echo ""
echo "virtmic interrupted... cleaning up..."
echo "removing virtual microphone"
pactl unload-module module-pipe-source
echo "removing the virtual microphone as the default device."
rm ~/.config/pulse/client.conf
}

function usage()
{
echo "Usage: $0 {start|stop|show|restart}"
exit 1
}

case "$1" in
  start)
    start
  ;;
  stop)
    stop  
  ;;
  show)
    show
  ;;
  restart)
    stop
    sleep 1
    start
  ;;
  *)
    usage
  ;;
esac

exit 0


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

function createvirtualmic()
{
  # Load the "module-pipe-source" module to read audio data from a FIFO special file.
  echo "Creating virtual microphone."
  pacmd load-module module-pipe-source source_name=virtmic file=${VIRTMICPATH}/virtmic format=s16le rate=16000 channels=1

  # Set the virtmic as the default source device.
  echo "Set the virtual microphone as the default device."
  pacmd set-default-source virtmic

  # Create a file that will set the default source device to virtmic for all PulseAudio client applications.
  echo "default-source = virtmic" > ~/.config/pulse/client.conf
}

function start()
{
  createvirtualmic
  echo "start your own stream:"
  echo "ffmpeg -loglevel quiet -re -i ${AUDIOFILE} -f s16le -ar 16000 -ac 1 - > ${VIRTMICPATH}/virtmic"
  echo "and don't forget to run '$0 stop' when you are finished"
}

function startlooped()
{
  createvirtualmic
  loopmp3
}

function startplayonce()
{
  createvirtualmic
  playmp3
  stop
}

function loopmp3()
{
  # Write the audio file to the named pipe virtmic. This will block until the named pipe is read.
  echo "Writing audio file to virtual microphone (in a loop)."
  echo "press ctrl-c to stop"
  while :
  do
    playmp3
  done
}

function playmp3()
{
  ffmpeg -loglevel quiet -re -i ${AUDIOFILE} -f s16le -ar 16000 -ac 1 - > ${VIRTMICPATH}/virtmic
}

# Uninstall the virtual microphone.
function stop()
{
  echo ""
  echo "virtmic stopped... cleaning up..."
  echo "removing virtual microphone"
  pacmd unload-module module-pipe-source
  echo "removing the virtual microphone as the default device."
  rm ~/.config/pulse/client.conf
}

function usage()
{
  echo "Usage: $0 {start|startlooped|startplayonce|stop}"
  exit 1
}

case "$1" in
  start)
    start
  ;;
  stop)
    stop  
  ;;
  startlooped)
    startlooped
  ;;
  startplayonce)
    startplayonce
  ;;
  *)
    usage
  ;;
esac

exit 0

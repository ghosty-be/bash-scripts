#!/bin/bash
## script description
# this script allows to 
# - list the application sinks
# - set the volume for an application sink by application name
# based on https://askubuntu.com/a/1418749

## global variables
SCRIPT=`basename $0`
DEBUG=false

(${DEBUG}) && echo "debug mode active"
(${DEBUG}) && set -x

#warning, this will terminate the script on errors
#do not use this if errors are expected behavior!
set -e

## display usage on invalid amount of arguments or help arguments
function usage() {
  echo "usage: $SCRIPT {list|set <app> <volume>}"
  echo "arguments"
  echo "  argument            argument description"
  echo "  list                list app sinks"
  echo "  set <app> <volume>  set volume for <app> to <volume>%"
  exit 1
}

function set-app-volume() {
  player="$1"
  volume="$2"
  # get specific app sink
  firstPlayerSinkIndex="$(pacmd list-sink-inputs | awk '/index:|application.name |application.process.binary / {print $0}' | sed 's/^ *//g ; s/.*= //' | grep -iB 1 "${player}" | awk '/index:/ {print $2; exit}')"
  # I don't see the need to do this calculation here if pactl takes percentages direct anyway...
  # 100% → 65536
  #[[ $firstPlayerSinkIndex ]] && pacmd set-sink-input-volume "$firstPlayerSinkIndex" "$((volume*65536/100))"
  [[ $firstPlayerSinkIndex ]] && pactl set-sink-input-volume "$firstPlayerSinkIndex" "${volume}%"
}

function list-app-sinks() {
  pacmd list-sink-inputs | awk '/index:|volume: |application.name |application.process.binary / {print $0}' | sed 's/^[ \t]*//g'
}

case "$1" in
  list)
    list-app-sinks
  ;;
  set)
    #if arguments < 3 show usage
    if [ $# -ne 3 ]
    then
      usage
    fi
    set-app-volume $2 $3
  ;;
  *)
    usage
  ;;
esac

(${DEBUG}) && set +x

exit 0

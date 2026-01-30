#!/bin/bash

# export WINEPREFIX=/home/wreckfest/wreckfest/
# export WINEARCH=win64
# export WINEDEBUG=-all
# export XDG_RUNTIME_DIR=/tmp

PORT="27016"
INTERVAL=60 # Check every 30 seconds

wineserver -k
screen -XS wreckfest quit

while :
do
  # Check if the port is open using netstat or ss
  # Use 'ss -tuln' or 'netstat -tuln' depending on your system
  if ! ss -tuln | grep -q ":$PORT\b"; then
    echo "Port $PORT is closed. Starting/Restarting program..."
    wineserver -k
    screen -XS wreckfest quit

    screen -dmS wreckfest $@
    #screen -dmS wreckfest xvfb-run -a wine Wreckfest.exe -s server_config=server_config.cfg log=/tmp/wreckfest.log
	
  else
    echo "Program is running and port $PORT is open... "
    echo "Wreckfest sucessfully started... "
    #screen -r wreckfest
    break
  fi
  sleep $INTERVAL
  echo "checking port...."
done
screen -r wreckfest
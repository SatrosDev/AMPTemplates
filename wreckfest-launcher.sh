#!/bin/bash

#set job control
set -m


cleanup() {
    echo "Cleanup initiated."
    if [ -n "$(jobs -r)" ]; then
      echo "Background jobs are running."
      echo "Killing background jobs..."
      #close job if it failed
      if [ -n "$JOB_PID" ]; then
        #check for wf pid and kill?
        echo "Killing process group -$JOB_PID with SIGTERM..."
        #kill -9 -$JOB_PID #this works to close the jobs
        kill -TERM -$JOB_PID #this also works
        wait
      else
        echo "Variable 'JOB_PID' is unset"
      fi
    else
      echo "No background jobs are running."
    fi
    exit
}
trap cleanup INT TERM EXIT

#jobs -p | xargs -r kill

# export WINEPREFIX=/home/wreckfest/wreckfest/
# export WINEARCH=win64
# export WINEDEBUG=-all
# export XDG_RUNTIME_DIR=/tmp

PORT="27016"
INTERVAL=32 # Check every 30 seconds

# Clear any wreckfest stuff?

while :
do
  echo "Checking if [Port $PORT] is in use..."
  # Check if the port is open using ss
  if ! ss -tuln | grep -q ":$PORT\b"; then

    #close job if it failed
    if [ -n "$JOB_PID" ]; then
      #check for wf pid and kill?
      echo "Killing process group -$JOB_PID with SIGTERM..."
      #kill -9 -$JOB_PID #this works to close the jobs
      kill -TERM -$JOB_PID #this also works
      #set job_pid to none?
      wait
    else
      echo "Variable 'JOB_PID' is unset"
    fi

    echo "Starting program... [Port $PORT is closed]"

    #Run wreckfest startup command in the background
    #echo $@
    ($@) &
    JOB_PID=$!
    echo "Job (subshell) PID: $JOB_PID"
    if [ -n "$JOB_PID" ]; then
      echo "JOB_PIT was set: $JOB_PID"
    else
      echo "Variable 'JOB_PID' is unset"
    fi

    #xvfb-run -a wine Wreckfest.exe -s server_config=server_config.cfg &

    echo "Program should be in the background... "
    jobs
    #screen -dmS wreckfest $@
    #screen -dmS wreckfest xvfb-run -a wine Wreckfest.exe -s server_config=server_config.cfg
	
  else
    echo "[SUCCESS] Program is running and port $PORT is open... "
    echo "Wreckfest server started... "
    break
  fi
  sleep $INTERVAL
done

# Resume wreckfest
jobs
fg
jobs
#PID1=""
#jobs
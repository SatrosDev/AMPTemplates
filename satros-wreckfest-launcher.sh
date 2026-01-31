#!/bin/bash

#Set job control
set -m

# Clean up function
cleanup() {
    # echo "Cleanup initiated."
    if [ -n "$(jobs -r)" ]; then
      echo "Background jobs are running..."
      #close job if it failed
      if [ -n "$JOB_PID" ]; then
        #check for wf pid and kill?
        echo "Stopping failed server launch attempt..."
        #kill -9 -$JOB_PID #this works to close the jobs
        kill -TERM -$JOB_PID #this also works
        wait
      fi
    fi
    exit
}
trap cleanup INT TERM EXIT


PORT="27016"
INTERVAL=30 # Check port every 30 seconds

while :
do
  echo "Checking if [Port $PORT] is in use..."
  # Check if the port is open using ss
  if ! ss -tuln | grep -q ":$PORT\b"; then

    #If last job failed then close it
    if [ -n "$JOB_PID" ]; then
      echo "Stopping failed server launch attempt..."
      kill -TERM -$JOB_PID #this also works
      wait
      sleep 1
      echo "Relaunching Wreckfest Server..."
    else
      echo "Starting Wreckfest Server..."
    fi

    # Server startup command
    ($@) &
    # Save Job PID
    JOB_PID=$!
  else
    echo "[SUCCESS] Wreckfest server has started with port $PORT"
    break
  fi
  sleep $INTERVAL
done

# Resume Wreckfest Server Process
fg
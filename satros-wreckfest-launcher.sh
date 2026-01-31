#!/bin/bash

#Set job control
set -m

# Clean up function
cleanup() {
    # echo "Cleanup initiated."
    if [ -n "$(jobs -r)" ]; then
      echo "[INFO] Background jobs are running."
      #close job if it failed
      if [ -n "$JOB_PID" ]; then
        #check for wf pid and kill?
        echo "[INFO] Stopping failed server launch attempt..."
        #kill -9 -$JOB_PID #this works to close the jobs
        kill -TERM -$JOB_PID #this also works
        wait
      fi
    fi
    exit
}
trap cleanup INT TERM EXIT


PORT="27016"
INTERVAL=35 # Check port every 35 seconds

while :
do
  echo "[INFO] Checking if [Port $PORT] is being used."
  # Check if the port is open using ss
  if ! ss -tuln | grep -q ":$PORT\b"; then

    #If last job failed then close it
    if [ -n "$JOB_PID" ]; then
      echo "[INFO] Stopping failed server launch attempt..."
      kill -TERM -$JOB_PID #this also works
      wait
      sleep 5
      echo "[INFO] Relaunching Wreckfest Server..."
    else
      echo "[INFO] Starting Wreckfest Server..."
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
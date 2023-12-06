#!/bin/bash

CLUSTER=`sacctmgr show cluster  -P | tail -n 1 | cut -f1 -d "|"`
JOBID=`cut -f1 -d";" ~/.jupyter-${CLUSTER}-shutdown-information`
SSH_TUNNEL_PID=`cut -f2 -d";" ~/.jupyter-${CLUSTER}-shutdown-information`
NODE_LIST=`cut -f3 -d";" ~/.jupyter-${CLUSTER}-shutdown-information`


echo -e "Canceling job $JOBID running on nodes ${NODE_LIST}..."
scancel $JOBID

# echo -e "Killing SSH tunnel at PID $SSH_TUNNEL_PID"

if ps -p $SSH_TUNNEL_PID > /dev/null; then
    # Process is running, proceed to kill
    kill -9 $SSH_TUNNEL_PID
    echo "SSH tunnel process (PID $SSH_TUNNEL_PID) has been terminated."
  else
    # Process not running
    echo "No process found with PID $SSH_TUNNEL_PID. The SSH tunnel may not be running."
  fi

# Archive logs. Fail silently if the logs no longer exist at the expected location.
mkdir -p jupyter-logs/$JOBID
mv jupyter-logs/jupyter-log-$JOBID.err jupyter-logs/$JOBID/ 2>/dev/null || true
mv jupyter-logs/jupyter-log-$JOBID.out jupyter-logs/$JOBID/ 2>/dev/null || true

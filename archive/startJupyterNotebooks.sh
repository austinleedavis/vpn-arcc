#!/bin/bash

mkdir -p jupyter-logs/

# accept environment.yml or an environment name as a second argument
ENV_FILE=$1

PORT="$UID"
CLUSTER=`sacctmgr show cluster  -P | tail -n 1 | cut -f1 -d "|"`
EXIT_STATUS=0
PWD=`pwd -P`

if [[ "${PWD}" =~ ^/examples ]]; then
  echo -e "\a\nThis example must not be run from the examples directory!"
  echo -e "Current Directory: `pwd`"
  echo -e "Please copy the contents of the current directory to a directory you own, such as your home directory."
  echo -e "Please read README.txt for more information."
  exit 1
fi

# Check first to see if a tunnel already exists
SSH_TUNNEL_PID=`ps --no-headers -eo pid,uid,command | grep $UID | grep "ssh .* $PORT:.*:$PORT" | grep -v grep | cut -c1-7 | sed s/" "/""/g`
if [[ $SSH_TUNNEL_PID != "" ]] ; then
  echo -e "\nSorry, there is already an SSH tunnel running at PID $SSH_TUNNEL_PID for you."
  echo -e "Please kill that tunnel first:"
  echo -e "  kill -9 $SSH_TUNNEL_PID\n"
  echo -e "You may also want to stop any jobs running Jupyter Notebook.  You can see if there are such jobs with:"
  echo -e "  squeue -u `whoami`\n"
  exit 1
fi

# Get a string from the user to authenticate against JN
echo -e "\nPlease provide a token string to authenticate yourself (I will remove all spaces):"
read USER_TOKEN
export USER_TOKEN=`echo ${USER_TOKEN} | sed s/" "/""/g`

# Start the job, including launching JN, then collect info about the job
echo -e "\nSpinning up your Jupyter Notebook! (Give me about 5s...)"
JOBID="$(sbatch --parsable submit-jupyter-notebook-server.slurm $PORT $ENV_FILE)"
sleep 5
JOB_NODELIST="$(squeue -j $JOBID -o %N | grep ^e)"
BATCH_NODE=`scontrol show job $JOBID | grep BatchHost | cut -d"=" -f2`

# Report information about the job
echo -e "\nJobID: $JOBID"
echo -e "NodeList:   $JOB_NODELIST"
echo -e "BatchNode:  $BATCH_NODE"

# Try to create an SSH tunnel so the user can connect via a web browser
echo "Attempting to start SSH tunnel using the following command:"
SSH_TUNNEL_CMD="ssh -f -o ExitOnForwardFailure=yes -g -q -N localhost  -L  $PORT:$BATCH_NODE:$PORT sleep 10"
echo "  $SSH_TUNNEL_CMD"
($SSH_TUNNEL_CMD)
#SSH_TUNNEL_PID=$!  ## RPW:  Not working for some reason ...
SSH_TUNNEL_PID=`ps --no-headers -eo pid,uid,command | grep $UID | grep "ssh .* $PORT:$BATCH_NODE:$PORT" | grep -v grep | cut -c1-7`

# Give the user instructions if the tunnel succceeded
if [[ $SSH_TUNNEL_PID ]] ; then
  {
    cat <<EOF

The SSH tunnel succeeded, and  Jupyter Notebooks is running. 
The SSH_TUNNEL_PID is $SSH_TUNNEL_PID

You may now:
-----------------------------------------------------------------------
 1. Exit this ssh session and restablish an ssh tunnel using the 
    following command:

      ssh -L $PORT:$BATCH_NODE:$PORT $CLUSTER.ist.ucf.edu

 2. Point your browser to http://localhost:$PORT
 3. Enter the following token:  $USER_TOKEN
-----------------------------------------------------------------------
NOTE:
- Use the stopJupyterNotebooks.sh script to stop the notebook.
- Do not run more than one notebook per cluster at a time.
- Creating a NEW environment using conda may take a while. Monitor the progress with:
    tail -f jupyter-logs/jupyter-log-${JOBID}.err
- Whenever the node (in this case $BATCH_NODE) changes, you must re-establish the SSH tunnel with port forwarding enabled.  Remove the previous tunnel with the following command:
    kill \$(ss -nltp | grep ':$PORT' | awk -F',' 'NR==1 {print \$2}' | awk -F'=' '{print \$2}')

EOF
  }
  echo -e "$JOBID;$SSH_TUNNEL_PID;$JOB_NODELIST" > ~/.jupyter-${CLUSTER}-shutdown-information

# Inform the dissappointed user if the tunnel failed
else
  echo -e "The SSH tunnel failed.  Jupyter Notebooks is not running."
  EXIT_STATUS=1
fi

echo -e

exit $EXIT_STATUS


#!/bin/bash

remote_values=$(ssh newton.ist.ucf.edu 'echo $UID && squeue -u $(whoami)')
port_value=$(echo "$remote_values" | head -n 1 | awk '{print $1}')
token_value=$(echo "$remote_values" | tail -n 1 | grep evc | awk '{print $4}')
node_value=$(echo "$remote_values" | tail -n 1 | grep evc | awk '{print $8}')

# setup ssh forwarding
ssh newton.ist.ucf.edu -fNL $port_value:$node_value:$port_value

# start jupyter lab
startup_command="jupyter lab --no-browser --port=$port_value --ip='*' --NotebookApp.token=$token_value"

echo $startup_command | xclip -selection clipboard

echo "=====================INSTRUCTIONS==============================="
echo "✅ You are now connecting to $node_value "
echo "📋 Jupyter startup command copied to clipboard:"
echo "    $startup_command"
echo "Run the copied command to start jupyter lab"
echo "Once jupyter lab is running, you can access it at:"
echo "   http://localhost:$port_value/lab?token=$token_value"
echo "==============================================================="
echo " "
ssh $node_value


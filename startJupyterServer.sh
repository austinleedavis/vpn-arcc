#!/bin/bash

remote_values=$(ssh newton.ist.ucf.edu 'echo $UID && squeue -u $(whoami)')
port_value=$(echo "$remote_values" | head -n 1 | awk '{print $1}')
token_value=$(echo "$remote_values" | tail -n 1 | grep evc | awk '{print $4}')
node_value=$(echo "$remote_values" | tail -n 1 | grep evc | awk '{print $8}')

echo "remote_values: $remote_values"
echo "Token: $token_value"
echo "Node: $node_value"
echo "Port: $port_value"

# setup ssh forwarding
ssh newton.ist.ucf.edu -fNL $port_value:$node_value:$port_value

# start jupyter lab
startup_command="jupyter lab --no-browser --port=$port_value --ip='*' --NotebookApp.token=$token_value"
echo $startup_command | xclip -selection clipboard
echo "📋 Startup command copied to clipboard :
    $startup_command"
echo "Once connected to $node_value, paste the command into the terminal to start jupyter lab."
ssh $node_value

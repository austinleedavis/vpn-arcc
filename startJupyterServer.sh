#!/bin/bash

server_address="newton.ist.ucf.edu"

display_help() {
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   --help     Display this help message"
    echo "   --server   Specify the server name. Options are:"
    echo "              newton - Sets the server to newton.ist.ucf.edu"
    echo "              stokes - Sets the server to stokes.ist.ucf.edu"
    echo "              If not specified, defaults to newton.ist.ucf.edu"
    echo
    exit 1
}


# Parse command line options
while true; do
  case "$1" in
    --help ) display_help; shift ;;
    --server )
      case "$2" in
        newton ) server_address="newton.ist.ucf.edu"; shift 2 ;;
        stokes ) server_address="stokes.ist.ucf.edu"; shift 2 ;;
        * ) echo "Invalid server name"; exit 1 ;;
      esac
      ;;
    * ) break ;;
  esac
done


remote_values=$(ssh "$server_address" 'echo $UID && squeue -u $(whoami)')
port_value=$(echo "$remote_values" | head -n 1 | awk '{print $1}')
token_value=$(echo "$remote_values" | tail -n 1 | grep evc | awk '{print $4}')
node_value=$(echo "$remote_values" | tail -n 1 | grep evc | awk '{print $8}')

# setup ssh forwarding
ssh "$server_address" -fNL $port_value:$node_value:$port_value

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


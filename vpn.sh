#!/bin/bash

# bookmarklet: javascript:window.alert(document.cookie.match(/webvpn=(.*);/)[1])

set -e

PIDFILE=/var/run/openconnect.pid
salloc_command=$(<my_alloc_command.txt)
server_name="newton.ist.ucf.edu"

# Function to display help message
display_help() {
    echo "Usage: $0 [option...]" >&2
    echo 
    echo "   --kill      Kill the VPN connection"
    echo "   --help      Display this help message"
    echo "   --salloc    Specify a custom file for salloc_command"
    echo "   --server    Server to perform operations on. Default: 'newton'"
    echo "   --bookmark  Display the bookmarklet code and copy it to clipboard using xclip"
    echo "Note: This script requires root privileges."
    exit 1
}

kill_ssh() {
    echo "Shutting down ARCC VPN components"

    socket_newton=$(ssh -G newton.ist.ucf.edu | awk '/^controlpath / {print $2}')
    socket_stokes=$(ssh -G stokes.ist.ucf.edu | awk '/^controlpath / {print $2}')

    if [ -S "$socket_newton" ]; then
        ssh -S "$socket_newton" newton.ist.ucf.edu -O exit
        echo "  Terminating shared connection to newton.ist.ucf.edu"
    fi

    if [ -S "$socket_stokes" ]; then
        ssh -S "$socket_stokes" stokes.ist.ucf.edu -O exit
        echo "  Terminating shared connection to newton.ist.ucf.edu"
    fi

    if [ -f "$PIDFILE" ]; then
        sudo kill $(cat $PIDFILE)
        echo "  Terminated ssh process"
    fi
    echo   "ARCC VPN is no longer running"
    exit 0
}


show_bookmarklet(){
    echo "Add a bookmark in your with the following URL: (copied to your clipboard)"
    echo
    bookmarklet_cmd="javascript:(function() {  var cookieMatch = document.cookie.match(/webvpn=(.*?);/);  if (cookieMatch && cookieMatch[1]) {    navigator.clipboard.writeText(cookieMatch[1]);} else {    alert(%27No matching cookie found%27);  }})();"
    echo $bookmarklet_cmd
    echo $bookmarklet_cmd | xclip -selection clipboard
    echo 
    exit 1
}

# Parse command line options
while true; do
  case "$1" in
    --kill ) kill_ssh; shift ;;
    --help ) display_help; shift ;;
    --salloc-file ) salloc_command=$(<$2); shift 2 ;;
    --bookmark ) show_bookmarklet; shift ;;
    --server )
      case "$2" in
        newton ) server_name="newton.ist.ucf.edu"; shift 2 ;;
        stokes ) server_name="stokes.ist.ucf.edu"; shift 2 ;;
        * ) echo "Invalid server name"; exit 1 ;;
      esac
      ;;
    * ) break ;;
  esac
done


display_vpn_login_instructions() {
    echo "=====================INSTRUCTIONS==============================="
    echo -e "Follow the prompts at ${BLUE}https://secure.vpn.ucf.edu/${NC} to authenticate with the UCF VPN."
    echo "Then use the bookmarklet to copy your authentication Cookie 🍪."
    echo "Bookmarklet command:"
    echo "    javascript:window.alert(document.cookie.match(/webvpn=([^;]*)/)[1])"
    echo "=====================++++++++++++==============================="
}

display_instructions() {
    echo "=====================INSTRUCTIONS==============================="
    echo $salloc_command | xclip -selection clipboard && echo "📋 Interactive session command copied to your clipboard :
    $salloc_command"

    cat <<EOF

🎉 You are connected to the UCF VPN 

Next step:
-----------------------------------------------------------------------
 1. Connect to server with:
      ssh $server_name
 2. Run the command we copied to your clipboard, modifying any parameters as needed.
    Default parameters:
        --nodes=1
        --ntasks-per-node=1
        --mem=64GB
        --time=01:00:00
 3. DO NOT close this terminal; salloc starts an INTERACTIVE session!
-----------------------------------------------------------------------
Shutdown: There are two methods to shutdown your connection.
 Automatic:
   1. run \`$0 --kill\`
 Manual: 
   1. Clean up port forwarding with:
      ssh $server_name -O exit
   2. Terminate VPN connection with:
      sudo kill $(cat $PIDFILE)
-----------------------------------------------------------------------
EOF
}

test $UID -ne 0 && echo 👑 Must be root  && exit 2

BLUE="\033[1;34m"
NC="\033[0m"


test -f $PIDFILE && pgrep -aF $PIDFILE > /dev/null && echo 👍 openconnect already running  && display_instructions && exit 3

display_vpn_login_instructions

# javascript:window.alert(document.cookie.match(/webvpn=(.*?);/)[1])
printf "Paste the Cookie 🍪: "
read COOKIE

test -z "$COOKIE" && echo Must offer cookie 👹🍪 && exit 4

openconnect --background --reconnect-timeout=60 --non-inter --pfs --syslog --force-dpd=47 --pid-file=$PIDFILE --disable-ipv6 secure.vpn.ucf.edu --usergroup="UCF Students" -C $COOKIE

display_instructions

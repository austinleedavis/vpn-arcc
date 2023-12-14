#!/bin/bash

# bookmarklet: javascript:window.alert(document.cookie.match(/webvpn=(.*);/)[1])

set -e

salloc_command='salloc --job-name=Jupyter_Server --nodes=1 --ntasks-per-node=1 --mem=64GB --time=01:00:00'

PIDFILE=/var/run/openconnect.pid

display_instructions() {
    echo "=====================INSTRUCTIONS==============================="
    echo $salloc_command | xclip -selection clipboard && echo "📋 Interactive session command copied to your clipboard :
    $salloc_command"

    cat <<EOF

🎉 You are connected to the UCF VPN 

Next step:
-----------------------------------------------------------------------
 1. Connect to newton with:
      ssh newton.ist.ucf.edu
 2. Run the command we copied to your clipboard, modifying any parameters as needed.
    Default parameters:
        --nodes=1
        --ntasks-per-node=1
        --mem=64GB
        --time=01:00:00
 3. DO NOT close this terminal; salloc starts an INTERACTIVE session!
-----------------------------------------------------------------------
Shutdown:
 1. Clean up port forwarding with:
    ssh newton.ist.ucf.edu -O exit
 2. Terminate VPN connection with:
    sudo kill $(cat $PIDFILE)
-----------------------------------------------------------------------
EOF
}

test $UID -ne 0 && echo 👑 Must be root  && exit 2

BLUE="\033[1;34m"
NC="\033[0m"

echo "=====================INSTRUCTIONS==============================="
echo -e "Follow the prompts at ${BLUE}https://secure.vpn.ucf.edu/${NC} to authenticate with the UCF VPN."
echo "Then use the bookmarklet to copy your authentication cookie."
echo "Bookmarklet command:"
echo "    javascript:window.alert(document.cookie.match(/webvpn=(.*);/)[1])"
echo "=====================++++++++++++==============================="

test -f $PIDFILE && pgrep -aF $PIDFILE > /dev/null && echo 👍 openconnect already running  && display_instructions && exit 3

# javascript:window.alert(document.cookie.match(/webvpn=(.*?);/)[1])
printf "Cookie 🍪: "
read COOKIE

test -z "$COOKIE" && echo Must offer cookie 👹🍪 && exit 4

openconnect --background --reconnect-timeout=60 --non-inter --pfs --syslog --force-dpd=47 --pid-file=$PIDFILE --disable-ipv6 secure.vpn.ucf.edu --usergroup="UCF Students" -C $COOKIE

display_instructions

#!/bin/bash

# bookmarklet: javascript:window.alert(document.cookie.match(/webvpn=(.*);/)[1])

set -e


salloc_command='salloc --job-name=chessGPT --nodes=1 --ntasks-per-node=1 --mem=64GB --time=02:00:00'

PIDFILE=/var/run/openconnect.pid

test $UID -ne 0 && echo Must be root 👑 && exit 2

test -f $PIDFILE && pgrep -aF $PIDFILE && echo openconnect already running 👹 && echo $salloc_command | xclip -selection clipboard && echo "Interactive session command copied to your clipboard 📋:
    $salloc_command" && exit 3

# javascript:window.alert(document.cookie.match(/webvpn=(.*?);/)[1])
printf "Cookie 🍪: "
read COOKIE

test -z "$COOKIE" && echo Must offer cookie 👹🍪 && exit 4

openconnect --background --reconnect-timeout=60 --non-inter --pfs --syslog --force-dpd=47 --pid-file=$PIDFILE --disable-ipv6 secure.vpn.ucf.edu --usergroup="UCF Students" -C $COOKIE

echo $salloc_command | xclip -selection clipboard && echo "Interactive session command copied to your clipboard 📋:
    $salloc_command"

{
    cat <<EOF

You are now connected to the UCF VPN 🎉

Next step:
-----------------------------------------------------------------------
 1. Connect to newton with:
      ssh newton.ist.ucf.edu
 2. Run the command we copied to your clipboard, modifying any parameters as needed.
    Default parameters:
        --nodes=1
        --ntasks-per-node=1
        --gpus=1
        --mem=128GB
        --time = 08:30:00
        --constraint=h100
 3. DO NOT close this terminal; salloc starts an INTERACTIVE session!
-----------------------------------------------------------------------

EOF
  }

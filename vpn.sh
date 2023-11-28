#!/bin/bash

# bookmarklet: javascript:window.alert(document.cookie.match(/webvpn=(.*);/)[1])

set -e

PIDFILE=/var/run/openconnect.pid

test $UID -ne 0 && echo Must be root 👑 && exit 2

test -f $PIDFILE && pgrep -aF $PIDFILE && echo openconnect already running 👹 && exit 3

# javascript:window.alert(document.cookie.match(/webvpn=(.*?);/)[1])
printf "Cookie 🍪: "
read COOKIE

test -z "$COOKIE" && echo Must offer cookie 👹🍪 && exit 4

openconnect --background --reconnect-timeout=60 --non-inter --pfs --syslog --force-dpd=47 --pid-file=$PIDFILE --disable-ipv6 secure.vpn.ucf.edu --usergroup="UCF Students" -C $COOKIE
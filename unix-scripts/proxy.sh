#!/bin/bash
set +x
hostip=$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2)
port=10801

PROXY_URL=http://$hostip:$port
enable_proxy(){
	export http_proxy=$PROXY_URL
	export https_proxy=$PROXY_URL
	export HTTP_PROXY=$PROXY_URL
	export HTTPS_PROXY=$PROXY_URL
}

disable_proxy(){
	export http_proxy=
	export https_proxy=
	export HTTP_PROXY=
	export HTTPS_PROXY=
}

show_proxy(){
	echo http_proxy=${http_proxy}
}

if [ "$1" = "enable" ]; then
	enable_proxy
elif [ "$1" = "disable" ]; then
	disable_proxy
elif [ "$1" = "show" ]; then
	show_proxy
else
	echo "Invalid argument: $1" >&2
fi

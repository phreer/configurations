#!/bin/bash
set +x
enable_proxy(){
    if [ $# -ne 0 -a $# -ne 2 ]; then
        printf "enable_proxy(): invalid argument count (%d)" $# 2>&2
    fi
    if [ $# -eq 0 ]; then
        if grep -i "microsoft" /proc/version >/dev/null; then
            hostip=$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2)
            port=10801
        else
            echo "enable_proxy(): the host is not WSL, please specify <proxy_ip> and <proxy_port>"
        fi
    else
        hostip=$1
        port=$2
    fi
    PROXY_URL=http://$hostip:$port
	export http_proxy=$PROXY_URL
	export https_proxy=$PROXY_URL
	export all_proxy=$PROXY_URL
	export HTTP_PROXY=$PROXY_URL
	export HTTPS_PROXY=$PROXY_URL
	export ALL_PROXY=$PROXY_URL
}

disable_proxy(){
	export http_proxy=
	export https_proxy=
	export all_proxy=
	export HTTP_PROXY=
	export HTTPS_PROXY=
	export ALL_PROXY=
}

show_proxy(){
	echo http_proxy=${http_proxy}
	echo https_proxy=${https_proxy}
	echo HTTPS_PROXY=${HTTPS_PROXY}
	echo HTTP_PROXY=${HTTP_PROXY}
}

show_help(){
    echo "Usage: "
    echo "  source $0 enable <proxy_ip> <proxy_port>: enable proxy"
    echo "  source $0 disable                       : disable proxy"
    echo "  source $0 show                          : show current proxy setting"
    echo "  source $0 show_help                     : show this message"
}

if [ "$1" = "enable" ]; then
	enable_proxy $2 $3
elif [ "$1" = "disable" ]; then
	disable_proxy
elif [ "$1" = "show" ]; then
	show_proxy
elif [ "$1" = "help" ]; then
    show_help
else
	echo "Invalid argument: $1" 1>&2
    show_help 1>&2
fi

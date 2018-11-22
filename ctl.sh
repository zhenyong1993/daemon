#!/bin/bash
#do not execute manually, refer to readme.Md

if [ `ps -ef | grep daemon.sh | grep -v grep | wc -l` -eq 0 ]; then # not running
    echo -e "\033[0;31mdaemon is not running!!!\033[0m"
    exit 1
fi

if [ $# != 1 ]; then
    echo "please refer to README.md"
    echo "usage:"
    echo -e "\033[0;32m./ctl.sh ibstart\033[0m      --- restart ibox"
    echo -e "\033[0;32m./ctl.sh agstart\033[0m      --- restart agentServer"
    echo -e "\033[0;32m./ctl.sh adstart\033[0m      --- restart adapter"
    echo -e "\033[0;32m./ctl.sh ovstart\033[0m      --- restart openvpn"
    echo -e "\033[0;32m./ctl.sh ibstop\033[0m       --- stop ibox"
    echo -e "\033[0;32m./ctl.sh agstop\033[0m       --- stop agentServer"
    echo -e "\033[0;32m./ctl.sh adstop\033[0m       --- stop adapter"
    echo -e "\033[0;32m./ctl.sh ovstop\033[0m       --- stop openvpn"
    exit 1
fi

#DIR='/home/i5/bin/collector'
DIR=$HOME/tp

ff=$DIR/cmd.fifo

if [ -e $ff ]; then
    echo $1 > $ff
else
    echo "fifo not exist! please check if daemon running"
fi
#EOF

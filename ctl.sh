#!/bin/bash
#do not execute manually, refer to readme.Md

if [ $# != 1 ]; then
    echo "usage:"
    echo -e "\033[0;32m./ctl.sh ibstart\033[0m    --- restart ibox"
    echo -e "\033[0;32m./ctl.sh agstart\033[0m    --- restart agentServer"
    echo -e "\033[0;32m./ctl.sh ibstop\033[0m       --- stop ibox"
    echo -e "\033[0;32m./ctl.sh agstop\033[0m       --- stop agentServer"
    exit 1
fi

#DIR='/home/i5/bin/collector'
DIR=$HOME

ff=$DIR/cmd.fifo

if [ -e $ff ]; then
    echo $1 > $ff
else
    echo "fifo not exist! please check if daemon running"
fi
#EOF

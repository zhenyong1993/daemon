#!/bin/bash

# VERSION:  1.1
# DATE:     2018/11/02
# FUNCTION: monitor process and handle request

# DO NOT EXECUTE THIS FILE MANUALLY

#env ==============================#
DIR='/home/i5/bin/collector'       #
ADAPTER='/home/i5/bin/adaptive'    #
AGENTSERVER='/home/i5/bin'         #
LOGDIR='/home/i5/data/logs/daemon' #
LOGFILE="$LOGDIR/DM"$$".log"       #
USER="Jim"                         #
FIFO="/home/$USER/cmd.fifo"        #
MONITORCONF="/home/$USER/dmconf"   #
#env ==============================#

#it seems operator & is not supported
#by bash, use opeartor % instead to
#check mask
#mask==============================#
SIGCO=2              #   collector #
SIGAG=3              # agentServer #
SIGAD=5              #     adapter #
SIGOV=7              #     openvpn #
#env ==============================#

#func =============================#
func_lg()
{
    echo "--- `date` ---" >> $LOGFILE
    echo "Daemon start" >> $LOGFILE
}

func_collectorStart()
{
    #workaround
    #alt2 is to use [ldconfig]
    cd $DIR
    $DIR/ibox > /dev/null 2>&1 &
    cd -
}
func_agentServerStart()
{
#   service monexecd start
    $AGENTSERVER/agentServer > /dev/null 2>&1 &
}
func_adapterStart()
{
    #workaround
    #alt2 is to use [ldconfig]
    cd $ADAPTER
    $ADAPTER/self > /dev/null 2>&1 &
    cd -
}
func_openvpnStart()
{
    #TODO: add command
    echo " +_+ fake openvpn start"
}

func_checkRunning()
{
    #not used yet
    if [ ! -n $1 ]; then
        return 0
    fi

    if [ `ps -ef | grep $1 | grep -v grep | wc -l` -eq 0 ]; then # not running
        return 0
    else
        return 1
    fi
}


func_stop() #stop
{
    if [ ! -n $1 ]; then
        return 0
    fi
    _ARG=$1
#temp solution for naming issue adapter->adaptive
    if [ "adapter" == $_ARG ]; then
        _ARG=adaptive
    fi
#temp solution for naming issue adapter->adaptive
    echo "--- `date` ---" >> $LOGFILE
    if [ `ps -ef | grep $_ARG | grep -v grep | wc -l` -eq 0 ]; then # not running
        echo "INFO: $_ARG not running, no need to kill" >> $LOGFILE
    else
        ps -ef | grep $_ARG | egrep -v "grep|$0" | awk '{print $2}' | xargs kill -9
        echo "INFO: $_ARG kill success!" >> $LOGFILE
    fi
}

func_start() #start
{
    if [ ! -n $1 ]; then
        return 0
    fi
    _ARG=$1
#temp solution for naming issue adapter->adaptive
    if [ "adapter" == $_ARG ]; then
        if [ `ps -ef | grep adaptive | grep -v grep | wc -l` -ne 0 ]; then # is running, no need to start
            return 1
        fi
    fi
#temp solution for naming issue adapter->adaptive
    if [ "openvpn" == $_ARG ]; then
        if [ `ps -ef | grep vpnlogin_autoconnec | grep -v grep | wc -l` -ne 0 ]; then # is running, no need to start
            return 1
        fi
    fi
#temp solution for openvpn

    if [ `ps -ef | grep $_ARG | grep -v grep | wc -l` -ne 0 ]; then # is running, no need to start
        return 1
    fi

    echo "--- `date` ---" >> $LOGFILE
    echo "INFO: $_ARG not running, will restart" >> $LOGFILE
    case "$_ARG" in
        collector)
            func_collectorStart
            ;;
        agentServer)
            func_agentServerStart
            ;;
    	adapter)
            func_adapterStart
            ;;
        openvpn)
            func_openvpnStart
            ;;
        *)
            echo "Unknown app to start: $_ARG" >> $LOGFILE
            return 0
    esac

    if [ `ps -ef | grep $_ARG | grep -v grep | wc -l` -ne 0 ]; then # is running
        echo "INFO: $_ARG startup success!" >> $LOGFILE
    else
        echo "INFO: $_ARG startup failed!" >> $LOGFILE
    fi
}

func_monitor()
{
    local LISTENBIT=210  #magic number
    func_NOTIFY()
    {
        LISTENBIT=`cat $MONITORCONF/not.conf`
    }
    trap func_NOTIFY USR1

    while true; do
        if [ 0 -eq `expr $LISTENBIT % $SIGCO` ];then
            func_start collector
        fi
        sleep 3

        if [ 0 -eq `expr $LISTENBIT % $SIGAG` ]; then
            func_start agentServer
        fi
        sleep 3

        if [ 0 -eq `expr $LISTENBIT % $SIGAD` ]; then
            func_start adapter
        fi
        sleep 3

        if [ 0 -eq `expr $LISTENBIT % $SIGOV` ]; then
            func_start openvpn
        fi
        sleep 3
    done
}

func_err()
{
    echo "--- `date` ---" >> $LOGFILE
    echo "INFO: invalid request" >> $LOGFILE".1"
}

func_clean()
{
#handle SIGINT in debug mode
    rm $LOGDIR/DM*.log.1
    cp $LOGFILE $LOGFILE".1"
    date >> $LOGFILE".1"
    echo "INFO: quit" >> $LOGFILE".1"
    rm $LOGFILE
    rm $FIFO
    rm $MONITORCONF/not.conf
    rmdir $MONITORCONF
    exit 1
}
#func ==========================


#trap =========================#
trap func_clean INT            #
trap func_clean KILL           #
#trap =========================#

####################################### start ########################################

#log file
if [ ! -d $LOGDIR ]; then
    mkdir $LOGDIR
fi
func_lg

#agentServer
func_start agentServer &
wait
#collector
func_start collector &
wait
#adapter
func_start adapter &
wait
#openvpn
func_start openvpn &
wait

#init conf
if [ ! -d $MONITORCONF ]; then
    mkdir $MONITORCONF
fi
echo "210" > $MONITORCONF/not.conf #config file

#make fifo, offer permission to user
if [ -e $FIFO ]; then
    rm $FIFO
fi
su -c "mkfifo $FIFO" $USER

#monitor running state
func_monitor &
SUBPID=$!

#listen cmd
sleep 1
while true; do
    sleep 1
    cmd=$(cat $FIFO)
    confmask=`cat $MONITORCONF/not.conf`
    if [ "ibstart" == $cmd ]; then
        func_start collector
        if [ 0 -ne `expr $confmask % $SIGCO` ]; then #add this mask 2
            echo `expr $confmask \* 2` > $MONITORCONF/not.conf
        fi
    elif [ "agstart" == $cmd ]; then
        func_start agentServer
        if [ 0 -ne `expr $confmask % $SIGAG` ]; then #add this mask 3
            echo `expr 3 \* $confmask` > $MONITORCONF/not.conf
        fi
    elif [ "ibstop" == $cmd ]; then
        func_stop collector
        if [ 0 -eq `expr $confmask % $SIGCO` ]; then #remove this mask 2
            echo `expr $confmask / 2` > $MONITORCONF/not.conf
        fi
    elif [ "agstop" == $cmd ]; then
        func_stop agentServer
        if [ 0 -eq `expr $confmask % $SIGAG` ]; then #remove this mask 3
            echo `expr $confmask / 3` > $MONITORCONF/not.conf
        fi
#---
    elif [ "adstart" == $cmd ]; then
        func_start adapter
        if [ 0 -ne `expr $confmask % $SIGAD` ]; then #add this mask 5
            echo `expr $confmask \* 5` > $MONITORCONF/not.conf
        fi
    elif [ "ovstart" == $cmd ]; then
        func_start openvpn
        if [ 0 -ne `expr $confmask % $SIGOV` ]; then #add this mask 7
            echo `expr 7 \* $confmask` > $MONITORCONF/not.conf
        fi
    elif [ "adstop" == $cmd ]; then
        func_stop adapter
        if [ 0 -eq `expr $confmask % $SIGAD` ]; then #remove this mask 5
            echo `expr $confmask / 5` > $MONITORCONF/not.conf
        fi
    elif [ "ovstop" == $cmd ]; then
        func_stop openvpn
        if [ 0 -eq `expr $confmask % $SIGOV` ]; then #remove this mask 7
            echo `expr $confmask / 7` > $MONITORCONF/not.conf
        fi
    else
        func_err
    fi
    kill -USR1 $SUBPID 
done

#EOF

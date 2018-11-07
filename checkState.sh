#!/bin/bash

#refer to readme.Md

if [ `ps -ef | grep collector | grep -v grep | wc -l` -ne 0 ]; then # not running
    collectorState="Running"
else
    collectorState="Not Running"
fi

if [ `ps -ef | grep agentServer | grep -v grep | wc -l` -ne 0 ]; then # not running
    agentServerState="Running"
else
    agentServerState="Not Running"
fi

if [ `ps -ef | grep adaptive | grep -v grep | wc -l` -ne 0 ]; then # not running
    adaptiveState="Running"
else
    adaptiveState="Not Running"
fi

if [ `ps -ef | grep vpnlogin_autoconnec | grep -v grep | wc -l` -ne 0 ]; then # not running
    openVpnState="Running"
else
    openVpnState="Not Running"
fi

echo "collector:   --   $collectorState"
echo "agentServer: --   $agentServerState"
echo "adapter:     --   $adaptiveState"
echo "openvpn:     --   $openVpnState"

#EOF

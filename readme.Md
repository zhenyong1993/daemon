
prerequisit:
daemon.sh is running

ensure you have add following content to your ~/.bashrc:
alias collector-start="~/ctl.sh ibstart"
alias agentServer-start="~/ctl.sh agstart"
alias adapter-start="~/ctl.sh adstart"
alias openvpn-start="~/ctl.sh opvstart"
alias collector-stop="~/ctl.sh ibstop"
alias agentServer-stop="~/ctl.sh agstop"
alias adapter-stop="~/ctl.sh adstop"
alias openvpn-stop="~/ctl.sh ovstop"
alias checkState="~/checkState.sh"

command:
collector-start        --- start collector and monitor it
agentServer-start      --- start agentServer and monitor it
adapter-start          --- start adapter and monitor it
openvpn-start          --- start openvpn and monitor it
collector-stop         --- stop collector and stop monitoor it
agentServer-stop       --- stop agentServer and stop monitor it
adapter-stop           --- stop adapter ad stop monitor it
openvpn-stop           --- stop openvpn and stop monitor it
checkState             --- check running state


alias kdiff='kitten diff'

alias onwifihotspot='nmcli connection up hotspot'
alias offwifihotspot='nmcli connection down hotspot'

alias offhotspot='offwifihotspot && nmcli radio wifi off'
alias onhotspot='nmcli radio wifi on && onwifihotspot'

alias update='sudo apt --fix-broken install && sudo apt update && sudo apt upgrade -y && flatpak update -y && sudo apt autopurge -y && sudo apt autoclean && sudo journalctl --vacuum-time=2weeks'

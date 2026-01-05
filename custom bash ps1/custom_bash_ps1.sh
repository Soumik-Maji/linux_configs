#!/usr/bin/bash

# Unicodes
begining=$'\ue0b6'
divider=$'\ue0b0'
promptStart=$'\Uf17aa'

# Chalk asthetic colors
gitColor="105;191;100"  # Green
pathShortenColor="74;158;255" # Blue
starterColor="255;212;163" # Peach
colors=(
    "149;225;211" # Mint
    "243;139;168" # Rose
    "196;167;231" # Lavender
    "249;226;175" # Yellow
    "245;194;231" # Pink
    "137;220;235" # Aqua
    "255;158;158" # Coral
    "166;227;161" # Lime
    "180;165;245" # Purple
    "255;179;128" # Orange
)
colorIndex=0

ansiCode=""
# Helper: Create ANSI escape sequence
ansi() {
    ansiCode="\\[\033[$1m\\]"
}

# Apply foreground color to text
fg_color() {
    ansi "38;2;$1"
    local ac=$ansiCode
    ansi "38;2;0;0;0"
    local rc=$ansiCode
    echo "${ac}$2${rc}"
}

# Apply background color to text
bg_color() {
    ansi "1;48;2;$1"
    local ac=$ansiCode
    ansi "49"
    local rc=$ansiCode
    echo "${ac}$2${rc}"
}

lastColorIndex=$((${#colors[@]} - 1))
next_index() {
    if [[ $colorIndex -ge $lastColorIndex ]]; then
        colorIndex=$((colorIndex % $lastColorIndex))        
    else
        ((colorIndex++))
    fi
}

uhOut=""
uh_color() {
    local text="${USER}@${HOSTNAME}: "
    uhOut="$(fg_color $starterColor $begining)"
    uhOut+="$(bg_color $starterColor $text)"
    uhOut+="$(bg_color ${colors[$colorIndex]} $(fg_color $starterColor $divider))"
}

pwd_divider_color() {
    local temp=$(fg_color ${colors[$colorIndex]} $divider)
    next_index
    echo $(bg_color ${colors[$colorIndex]} $temp)
}

shortenPwdOut=""
shorten_pwd() {
    local pwd="${PWD/#$HOME/\~}" 
    local IFS=/ 
    local parts=($pwd)
    local arrayLen=${#parts[@]}
    shortenPwdOut=""
    if [[ $arrayLen -le 4 ]]; then
        for (( i=0; i<$arrayLen; i++ )); do
            local item=${parts[i]}
            shortenPwdOut+=$(bg_color ${colors[$colorIndex]} $item)
            if [[ $i -eq $((arrayLen - 1)) ]]; then
                shortenPwdOut+=$(bg_color "49" $(fg_color ${colors[$colorIndex]} $divider))
            else
                shortenPwdOut+=$(pwd_divider_color)
                next_index
            fi
        done
    else
        shortenPwdOut="$(bg_color ${colors[$colorIndex]} ${parts[0]})$(pwd_divider_color)"
        next_index
        shortenPwdOut+="$(bg_color ${colors[$colorIndex]} ${parts[1]})$(bg_color $pathShortenColor $(fg_color ${colors[$colorIndex]} $divider))"
        colorIndex=$((colorIndex + $arrayLen - 4))
        next_index
        shortenPwdOut+="$(bg_color $pathShortenColor '...')$(bg_color ${colors[$colorIndex]} $(fg_color $pathShortenColor $divider))"
        shortenPwdOut+="$(bg_color ${colors[$colorIndex]} ${parts[-2]})$(pwd_divider_color)"
        next_index
        shortenPwdOut+="$(bg_color ${colors[$colorIndex]} ${parts[-1]})$(bg_color "49" $(fg_color ${colors[$colorIndex]} $divider))"
    fi
}

source "$HOME/.custom-config/git_prompt.sh"
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWCONFLICTSTATE="yes"
GIT_PS1_SHOWUPSTREAM="verbose name"
gitModOut=""
git_mod() {
    gitModOut=$(fg_color $gitColor "$(__git_ps1 "(%s)")")
}

output_func() {
    uh_color
    shorten_pwd
    git_mod

	local output="\\n${uhOut}${shortenPwdOut} ${gitModOut}\\n"
    ansi "0"
    output+="$ansiCode $promptStart "
	PS1=$output
}

PROMPT_COMMAND=( "colorIndex=0" "output_func" )

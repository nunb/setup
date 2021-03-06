export TERM="xterm-color"
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# ==================================================================
# Most of this was taken from the example .bash_profile on tldp.org.
# ==================================================================
# =================
# COLORS
# =================

# Normal Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

NC="\033[m"               # Color Reset


ALERT=${BWhite}${On_Red} # Bold White on red background

# ================================
# EXTRAS
# ================================


# =================
# SET PROMPT
# =================
set_bash_prompt() {
  # ==========================================
  # Check if I'm root or someone else.
  # ==========================================
  my_username="carlosnunez"
  fmtd_username=$my_username

  if [ $USER != $my_username ]; then
    fmtd_username="\[$On_Purple\]\[$BWhite\]$my_username\[$NC\]"
  elif [ $EUID -eq 0 ]; then
    fmtd_username="\[$ALERT\]$my_username\[$NC\]"
  else
    fmtd_username="\[$On_Green\]\[$BBlack\]$my_username\[$NC\]"
  fi

  # ===================
  # Error code
  # ===================
  error_code_str=""
  [[ "$1" != "0" ]] && error_code_str="\[$On_Red\]\[$BWhite\]<<$1>>\[$NC\]"

  # ===================
  # Machine name
  # ===================
  hostname_fmtd="\[$On_Yellow\]\[$BBlack\]localhost\[$NC\]"
  if [ ! -z "$SSH_CLIENT" ]; then
    hostname_fmtd="\[$On_Yellow\]\[$BBlack\]$HOSTNAME\[$NC\]"
  fi
  if [ "`git branch >/dev/null 2>/dev/null; echo $?`" -ne "0" ]; then
    PS1="$error_code_str\[$BCyan\][$(date "+%Y-%m-%d %H:%M:%S")\[$NC\] $fmtd_username@$hostname_fmtd \[$BCyan\]\W]\[$NC\]\[$Yellow\]\$\[$NC\]: "
  elif [ `git status --porcelain 2>/dev/null | wc -l | tr -d ' '` -eq 0 ]; then
    PS1="$error_code_str\[$BCyan\][$(date "+%Y-%m-%d %H:%M:%S")\[$NC\] $fmtd_username@$hostname_fmtd \[$Green\]<<\$(get_git_branch)>>\[$NC\] \[$BCyan\]\W]\[$NC\]\[$Yellow\]\$\[$NC\]: "
  else
    PS1="\[$BCyan\][$(date "+%Y-%m-%d %H:%M:%S")\[$NC\] $fmtd_username@$hostname_fmtd \[$Red\]<<\$(get_git_branch)>>\[$NC\] \[$BCyan\]\W]\[$NC\] \[$Yellow\]\$\[$NC\]: "
  fi
}

# =================
# ALIASES
# =================
alias killmatch='kill_all_matching_pids'
alias clip='xclip'
[[ "$(uname)" == "Darwin" ]] && {
  alias ls='ls -Glart --group-directories-first'
} || {
  alias ls='ls -lar --color --group-directories-first'
}
[[ "$(uname)" == "Linux" ]] && {
  alias sudo='sudo -i'
}
eval "$(hub alias -s)"

# Check that homebrew is installed.
# ==================================
[ "$(uname)" == "Darwin" ] && {
  which brew > /dev/null || {
    echo "Installing homebrew."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  }
}

# Load bash submodules
# ======================
find $HOME -maxdepth 1 -name ".bash_*" | sort | egrep -v "bash_(profile|custom_profile|history|sessions)$" |  while read file; do
  printf "${BYellow}INFO${NC}: Loading ${BGreen}$file${NC}\n"
  source $file; 
done

# Can't get this one to load for some reason using the loop above.
[[ -f $HOME/.bash_functions ]] && source $HOME/.bash_functions

# Load SSH keys into ssh-agent
# ============================
killall ssh-agent
eval $(ssh-agent -s) > /dev/null
grep -HR "RSA" $HOME/.ssh | cut -f1 -d: | sort -u | xargs ssh-add {}

# =====================
# ATTACH TMUX
# =====================
which tmux > /dev/null || do_install tmux
[ -z "$TMUX" ]
tmux ls 2>&1 && { tmux attach-session -t $(tmux ls | cut -f1 -d ':' | head -n 1); } || { tmux ; }

# ============
# emacs keybindings
# ==============
set -o emacs

# ===========================================
# Display last error code, when applicable
# ===========================================
PROMPT_COMMAND='e=$?; set_bash_prompt $e'

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

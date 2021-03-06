source ~/.zprofile

PATH=".:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/usr/X11/bin:/usr/local/sbin/:/opt/local/bin/:/opt/local/sbin/:$PATH"

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# Variables

export EDITOR="mvim"
export PAGER="less"

# Less Colors for Man Pages

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

function env() {
  exec /usr/bin/env "$@" | grep -v ^LESS_TERMCAP_
}
    
export GTAGSLABEL=rtags
RUBYOPT="rubygems"
export RUBYOPT


# Dircolors

LS_COLORS='rs=0:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:';
export LS_COLORS

# Keybindings

bindkey -v
typeset -g -A key
#bindkey '\e[3~' delete-char
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line
#bindkey '\e[2~' overwrite-mode
bindkey '^?' backward-delete-char
bindkey '^[[1~' beginning-of-line
bindkey '^[[5~' up-line-or-history
bindkey '^[[3~' delete-char
bindkey '^[[4~' end-of-line
bindkey '^[[6~' down-line-or-history
bindkey '^[[A' up-line-or-search
bindkey '^[[D' backward-char
bindkey '^[[B' down-line-or-search
bindkey '^[[C' forward-char
# for rxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line

# Alias stuff

alias update="sudo softwareupdate --download --all --install"
alias dfix="diskutil repairPermissions /Volumes/Aluminium"
alias gc='gcc -ansi -pedantic -Wall -W -Wshadow -Wcast-qual -Wwrite-strings -Wextra -Werror -fstrength-reduce -fomit-frame-pointer -finline-functions '
alias gs='gcc -Wall -Wextra -pedantic'
alias chat='ssh ssh.blinkenshell.org -p 2222 -t "tmux a"'
alias t='todo'
alias td='todo --database ~/.todo.daily'
alias ts='todo --database ~/.todo.schedule'

alias e='emacs -nw'
alias ee='sudo emacs -nw'
alias v='vim'
alias vv='sudo vim'
alias ls='ls -G'
# Tmux

tm() { tmux attach -t $1; }
tmn() { tmux new -n $1 $1; }

# {{{ Git shortcuts

alias a='git add'
alias d='git diff'
alias p='git push origin master'
alias pu='git pull origin master'
alias gpo='git push origin'
alias gpom='git push origin master'
alias gpuo='git pull origin'
alias gp='git push'
alias gpu='git pull'

# Commit everything or specified path
c() {
    if [[ "$1" == "-i" ]]; then
        shift; git commit -s --interactive $@
    else
        if [[ -n "$@" ]]; then
            git commit -s $@
        else
            git commit -s -a
        fi;
    fi;
}

# Git show relevant status
sa() {
    git status | ack -B 999 --no-color "Untracked"
}
# }}}

# Auto-Ls after CD
cd() { if [[ -n "$1" ]]; then builtin cd "$1" && ls;
                         else builtin cd && ls; fi; }
,cd() { [[ -n "$1" ]] && builtin cd "$1" || builtin cd; }
ca() { ,cd "$1"; ls -la; }
cn() { ,cd "$1"; ls -a; }

alias grep="grep -i"
alias ack="ack -i"

# Unpack programs
if [[ -x '/usr/bin/aunpack' ]]; then
    alias un='aunpack'
else
    alias un='tar xvf'
fi
# }}}

# {{{ Daemons
rc.d() { [[ -d /etc/rc.d ]] && sudo /etc/rc.d/$@;
         [[ -d /etc/init.d ]] && sudo /etc/init.d/$@; }
dr() { for d in $@; do rc.d $d restart; done; }
ds() { for d in $@; do rc.d $d start; done; }
dt() { for d in $@; do rc.d $d stop; done; }
# }}}

alias spb="sudo brew"
alias brewi="brew -v install --debug "
alias brew="brew -v "

extract () {
  until [[ -z "$1" ]]; do
    echo Extracting $1 ...
    if [[ -f "$1" ]] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1  ;;
        *.tar.gz)    tar xzf $1  ;;
        *.lzma)      lzma -d $1 ;;
        *.tar.lzma)  tar --lzma xf $1 ;;
        *.bz2)       bunzip2 $1  ;;
        *.rar)       rar x $1    ;;
        *.gz)        gunzip $1   ;;
        *.tar)       tar xf $1   ;;
        *.tbz2)      tar xjf $1  ;;
        *.tgz)       tar xzf $1  ;;
        *.zip)       unzip $1   ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1  ;;
        *)        echo "Don't know how to extract '$1'" ;;
      esac
    else
      echo "'$1' is not a valid file"
    fi
    shift
  done
} 

archive () {
  FILE=$1
  case $FILE in
    *.tar.bz2) shift && tar cjf $FILE $* ;;
    *.tar.gz) shift && tar czf $FILE $* ;;
    *.tar.lzma) shift && tar --lzma cf $FILE $* ;;
    *.tgz) shift && tar czf $FILE $* ;;
    *.zip) shift && zip $FILE $* ;;
    *.rar) shift && rar $FILE $* ;;
  esac
}

# recursively 'fix' dir/file perm
fix() {
  for dir in "$@"; do
    find "$dir" -type d -exec chmod 700 {} \;
    find "$dir" -type f -exec chmod 600 {} \;
  done
}


# {{{ Kill an orphaned console
sk(){
    skill -KILL -t $1
}

# go to google for a definition
define() {
  which lynx &>/dev/null || return 1

  local lang=$(echo $LANG | cut -d '_' -f 1)
  local charset=$(echo $LANG | cut -d '.' -f 2)

  lynx -accept_all_cookies -dump -hiddenlinks=ignore -nonumbers -assume_charset="$charset" -display_charset="$charset" "http://www.google.com/search?hl=$lang&q=define%3A+$1&btnG=Google+Search" | grep -m 5 -C 2 -A 5 -w "*" > /tmp/define

  if [ ! -s /tmp/define ]; then
    echo -e "No definition found.\n"
  else
    echo -e "$(grep -v Search /tmp/define | sed "s/$1/\\\e[1;32m&\\\e[0m/g")\n"
  fi

  rm -f /tmp/define
}

# simple spellchecker, uses /usr/share/dict/words
spellcheck() {
  [ -f /usr/share/dict/words ] || return 1

  for word in "$@"; do
    if grep -Fqx "$word" /usr/share/dict/words; then
      echo -e "\e[1;32m$word\e[0m" # green
    else
      echo -e "\e[1;31m$word\e[0m" # red
    fi
  done
}

# omp load
ompload() { 
  curl -# -F file1=@"$1" http://omploader.org/upload|awk '/Info:|File:|Thumbnail:|BBCode:/ {
    gsub(/<[^<]*?\/?>/,"");
    $1 = $1;
    print
  }';
}
#------------------------------
# Comp stuff
#------------------------------

zmodload zsh/complist
autoload -Uz compinit
compinit
zstyle :compinstall filename '${HOME}/.zshrc'

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always

zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

#------------------------------
# Window title
#------------------------------
case $TERM in
    *xterm*|rxvt|rxvt-unicode|rxvt-256color|(dt|k|E)term)
    precmd () { print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~]\a" }
    preexec () { print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~] ($1)\a" }
  ;;
    screen)
      precmd () {
      print -Pn "\e]83;title \"$1\"\a"
      print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~]\a"
    }
    preexec () {
      print -Pn "\e]83;title \"$1\"\a"
      print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~] ($1)\a"
    }
  ;;
esac

#------------------------------
# Prompt
#------------------------------
setprompt () {
  # load some modules
  autoload -U colors zsh/terminfo # Used in the colour alias below
  colors
  setopt prompt_subst

  # make some aliases for the colours: (coud use normal escap.seq's too)
  for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    eval PR_$color='%{$fg[${(L)color}]%}'
  done
  PR_NO_COLOR="%{$terminfo[sgr0]%}"

  # Check the UID
  if [[ $UID -ge 1000 ]]; then # normal user
    eval PR_USER='${PR_GREEN}%n${PR_NO_COLOR}'
    eval PR_USER_OP='${PR_GREEN}%#${PR_NO_COLOR}'
  elif [[ $UID -eq 0 ]]; then # root
    eval PR_USER='${PR_RED}%n${PR_NO_COLOR}'
    eval PR_USER_OP='${PR_RED}%#${PR_NO_COLOR}'
  fi 

  # Check if we are on SSH or not --{FIXME}-- always goes to |no SSH|
  if [[ -z "$SSH_CLIENT" || -z "$SSH2_CLIENT" ]]; then
    eval PR_HOST='${PR_GREEN}%M${PR_NO_COLOR}' # no SSH
  else
    eval PR_HOST='${PR_YELLOW}%M${PR_NO_COLOR}' #SSH
  fi

  # set the prompt
  echo `fortune`
  PS1=$'%B%{\e[0;36m%}[%{\e[0;33m%}%n%{\e[0;36m%}@%{\e[0;33m%}%m%{\e[0;36m%}](%{\e[0;33m%}%~%{\e[0;36m%}) %{\e[0;15m%]'

}

setprompt

[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

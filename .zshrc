PLATFORM=`uname`

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="miloshadzic"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

source $ZSH/oh-my-zsh.sh

# add autocompletion for man pages
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

# history
setopt hist_ignore_dups

#autocomplete
setopt menucomplete
setopt nocorrectall
bindkey -M menuselect '^M' .accept-line

# show user and host on the right
RPROMPT="%{$fg[cyan]%}%n%{$reset_color%}|%{$fg[red]%}%m%{$reset_color%}"

# nice git log alias
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

# Osx settings
if [[ "$PLATFORM" == "Darwin" ]]
then
    plugins=(git osx)

    export PATH=/usr/local/sbin:/usr/local/share/python:/usr/local/bin:/Users/denis/Bin:/Users/denis/Scripts:/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/share/npm/bin:/usr/local/heroku/bin;
    
    # Python startup
    export PYTHONSTARTUP='/Users/denis/.pythonrc'

    # virtualenvwrapper
    export WORKON_HOME=$HOME/Envmts
    export PIP_VIRTUALENV_BASE=$WORKON_HOME
    export PIP_RESPECT_VIRTUALENV=true
    source virtualenvwrapper_lazy.sh

    # brew went pretty much mental without this
    export PYTHONPATH=$(brew --prefix)/lib/python2.7/site-packages

    # editor
    export EDITOR='subl'
fi

# Linux settings
if [[ "$PLATFORM" == "Linux" ]]
then
    plugins=(git)

    export WORKON_HOME=$HOME/.virtualenvs
    export PIP_RESPECT_VIRTUALENV=true
    source /usr/local/bin/virtualenvwrapper.sh

    # I can't for the live of me figure out why the ssh-agent plugin won't run
    # with my zsh, so here's the manual approach

    # start agent and set environment variables, if needed
    agent_started=0
    if ! env | grep -q SSH_AGENT_PID >/dev/null; then
      echo "Starting ssh agent"
      eval $(ssh-agent -s)
      agent_started=1
    fi

    # ssh become a function, adding identity to agent when needed
    function ssh() {
      if ! ssh-add -l >/dev/null 2>/dev/null; then
        ssh-add ~/.ssh/href.ch
      fi
      /usr/bin/ssh "$@"
    }

    export EDITOR='vim'

    # if [ "$TMUX" = "" ]; then tmux; fi
fi

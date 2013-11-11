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

    # Paths
    PATH=${PATH}:/usr/local/sbin
    PATH=${PATH}:/usr/local/share/python
    PATH=${PATH}:/usr/local/bin
    PATH=${PATH}:/Users/denis/Bin
    PATH=${PATH}:/Users/denis/Scripts
    PATH=${PATH}:/opt/local/bin
    PATH=${PATH}:/opt/local/sbin
    PATH=${PATH}:/usr/bin
    PATH=${PATH}:/bin
    PATH=${PATH}:/usr/sbin
    PATH=${PATH}:/sbin
    PATH=${PATH}:/usr/local/share/npm/bin
    PATH=${PATH}:/usr/local/heroku/bin
    
    # Python startup
    export PYTHONSTARTUP='/Users/denis/.pythonrc'

    # editor
    export EDITOR='subl -w'
    
    # fixes a number of weird bugs with ruby and boxen
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8

    # boxen!
    source /opt/boxen/env.sh

    # editor
    export EDITOR='subl'

    # provisioner
    export VAGRANT_DEFAULT_PROVIDER='vmware_fusion'

    # virtualenvwrapper (loaded by boxen)
    export WORKON_HOME="$HOME/.virtualenvs"
    export VIRTUALENVWRAPPER_HOOK_DIR=$WORKON_HOME
    export PIP_VIRTUALENV_BASE=$WORKON_HOME
    export PIP_RESPECT_VIRTUALENV=true
fi

# Linux settings
if [[ "$PLATFORM" == "Linux" ]]
then
    plugins=(git)
    
    export EDITOR='vim'
fi

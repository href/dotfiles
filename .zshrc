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

# Comment this out to disable weekly auto-update checks
DISABLE_AUTO_UPDATE="true"

# Include ZSH BD Plugin
if [ -f $HOME/.zsh/plugins/bd/bd.zsh ]; then
    source $HOME/.zsh/plugins/bd/bd.zsh
fi

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="false"

source $ZSH/oh-my-zsh.sh

# add autocompletion for man pages
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

# history
setopt hist_ignore_dups

# autocomplete
setopt menucomplete
setopt nocorrectall
bindkey -M menuselect '^M' .accept-line

ZSH_THEME_GIT_PROMPT_PREFIX="|%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}" 
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}*%{$reset_color%}" 

# show if the current host is a vagrant host
if [ -d /vagrant ]; then
    extra=".dev"
else
    extra=""
fi

# left prompt
PROMPT='%{$fg[blue]%}%1~%{$reset_color%}$(git_prompt_info) '

# show user and host on the right
RPROMPT="%{$fg[blue]%}%n%{$reset_color%}|%{$fg[red]%}%M%{$reset_color%}$extra"

# nice git log alias
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

# alias for mkvirtualenv
alias mk2="mkvirtualenv --python=/opt/boxen/homebrew/bin/python2"
alias mk3="mkvirtualenv --python=/opt/boxen/homebrew/bin/python3"

alias ls="ls -GF"

# postgresql service alias
alias pgstart="sudo launchctl load /Library/LaunchDaemons/dev.postgresql.plist"
alias pgstop="sudo launchctl unload /Library/LaunchDaemons/dev.postgresql.plist"

# sublime fails to open the given fails in 90% of the cases,
# it only works using -w, which makes subl wait for the main process
# -> this function wraps the 'wait' parameter, yielding immediately anyway
edit() { 
    ((/opt/boxen/bin/subl -w $* & pid=$!; sleep 5 && kill "$pid" &> /dev/null ) &);
}

# Osx settings
if [[ "$PLATFORM" == "Darwin" ]]
then
    plugins=(git osx)

    # Paths
    PATH=${PATH}:/usr/local/sbin
    PATH=${PATH}:/usr/local/share/python
    PATH=${PATH}:/usr/local/bin
    PATH=${PATH}:/Users/denis/.local/bin
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
    PATH=${PATH}:/opt/boxen/homebrew/bin
    PATH=${PATH}:/Users/denis/.cabal/bin
    
    # Python startup
    export PYTHONSTARTUP='/Users/denis/.pythonrc'

    # editor
    export EDITOR='subl -w'
    
    # fixes a number of weird bugs with ruby and boxen
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8

    # boxen!
    source /opt/boxen/env.sh

    # provisioner
    export VAGRANT_DEFAULT_PROVIDER='virtualbox'

    # virtualenvwrapper (loaded by boxen)
    export WORKON_HOME="$HOME/.virtualenvs"
    export VIRTUALENVWRAPPER_HOOK_DIR=$WORKON_HOME
    export PIP_VIRTUALENV_BASE=$WORKON_HOME
    export PIP_RESPECT_VIRTUALENV=true

    # llvm
    export LLVM_CONFIG_PATH="/opt/boxen/homebrew/opt/llvm/bin/llvm-config"

    # docker
    export DOCKER_HOST=tcp://localhost:4243
fi

# Linux settings
if [[ "$PLATFORM" == "Linux" ]]
then
    plugins=(git)
    
    export EDITOR='vim'
    alias edit="vim"
fi

# FreeBSD settings
if [[ "$PLATFORM" == "FreeBSD" ]]
then
    export EDITOR='vim'
    alias edit="vim"
fi

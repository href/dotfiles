PLATFORM=`uname`

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="miloshadzic"

DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="false"

source $ZSH/oh-my-zsh.sh

# ignore duplicates in history
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
alias ipython="ipython \
--PromptManager.in_template='>>> ' \
--PromptManager.in2_template='... ' \
--TerminalIPythonApp.display_banner=False"

# postgresql service alias
alias pgstart="sudo launchctl load /Library/LaunchDaemons/dev.postgresql.plist"
alias pgstop="sudo launchctl unload /Library/LaunchDaemons/dev.postgresql.plist"

# sublime fails to open the given fails in 90% of the cases,
# it only works using -w, which makes subl wait for the main process
# -> this function wraps the 'wait' parameter, yielding immediately anyway
edit() {
    ((/opt/boxen/bin/subl -w $* & pid=$!; sleep 5 && kill "$pid" &> /dev/null ) &);
}

# zsh scripts
source ~/.dotfiles/zshscripts/k.sh

# Osx settings
if [[ "$PLATFORM" == "Darwin" ]]
then
    # framework paths
    export DYLD_FRAMEWORK_PATH=/opt/boxen/homebrew/lib/
    export DYLD_FALLBACK_LIBRARY_PATH=/opt/boxen/homebrew/lib/

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
    PATH=${PATH}:/Library/Ruby/Gems/2.0.0/gems/bundler-1.5.3/bin
    PATH=${PATH}:/Users/denis/.pyenv

    # Python startup
    export PYTHONSTARTUP='/Users/denis/.pythonrc'

    # editor
    export EDITOR='subl -w'

    # fixes a number of weird bugs with ruby and boxen
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8

    # Boxen is really slow to source, mainly because it gets the git
    # HEAD of its repository, which doesn't even seem necessary:
    # https://github.com/boxen/puppet-boxen/issues/140
    #
    # The following scripts replicates env.sh, without the overhead of
    # loading the HEAD
    export BOXEN_HOME=/opt/boxen
    PATH=$BOXEN_HOME/bin:$PATH

    # Add any binaries specific to Boxen to the path.
    PATH=$BOXEN_HOME/bin:$PATH

    for f in $BOXEN_HOME/env.d/*.sh ; do
        if [ -f $f ] ; then
            source $f
        fi
    done

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

    # switch to a different profile when reaching out to another server from osx
    ssh () {
        command ssh "$@"; echo -ne "\033]50;SetProfile=Default\a";
    }
fi

# Linux settings
if [[ "$PLATFORM" == "Linux" ]]
then
    plugins=(git)

    export EDITOR='vim'
    alias edit="vim"

    if [ ! -d /vagrant ]; then
        echo -ne "\033]50;SetProfile=Dangerous\a"
    fi
fi

# FreeBSD settings
if [[ "$PLATFORM" == "FreeBSD" ]]
then
    export EDITOR='vim'
    alias edit="vim"

    if [ ! -d /vagrant ]; then
        echo -ne "\033]50;SetProfile=Dangerous\a"
    fi
fi

#!/bin/zsh
PLATFORM=`uname`

if [[ "$PLATFORM" == "Darwin" ]]; then
    HISTFILE="${HOME}/Library/Mobile Documents/com~apple~CloudDocs/.zsh_history"
fi

# Set a proper language if none is set
if [[ "$LC_ALL" == "" ]]; then
    export LC_ALL="en_US.UTF-8"
fi

if [[ "$LANG" == "" ]]; then
    export LANG="en_US.UTF-8"
fi

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

# history
setopt hist_ignore_dups
setopt inc_append_history
setopt share_history

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

# sum number output from a command
PERL_SUM='$x += $_; END { print $x; }'
alias sum-lines="perl -lne '${PERL_SUM}'"

# virtualenv info
export VIRTUAL_ENV_DISABLE_PROMPT=1

function virtualenv_prompt {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "(${VIRTUAL_ENV##*/})"
    fi
}

# left prompt
PROMPT='$(virtualenv_prompt)%{%(?.$fg[blue].$fg[red])%}%1~%{$reset_color%}$(git_prompt_info) '

# show user and host on the right
RPROMPT="%{$fg[blue]%}%n%{$reset_color%}|%{$fg[red]%}%M%{$reset_color%}$extra"

# nice git log alias
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"

# alias for mkvirtualenv
alias mk2="mkvirtualenv --python=python2"
alias mk="mkvirtualenv --python=python3"

alias ls="ls -GF"
alias ipython="ipython --TerminalIPythonApp.display_banner=False"

function set-repository-author () {
    local repo=${1}
    local name=${2}
    local mail=${3}

    git -C "${repo}" config user.name "${name}"
    git -C "${repo}" config user.email "${mail}"
}

function as-work-repository () {
    local repos=${@:-'.'}

    for repo in "${(ps: :)repos}"; do
        set-repository-author "$repo" 'Denis Krienbühl' 'denis.krienbuehl@seantis.ch'
    done
}

function as-personal-repository () {
    local repos=${@:-'.'}

    for repo in "${(ps: :)repos}"; do
        set-repository-author "$repo" 'Denis Krienbühl' 'denis@href.ch'
    done
}

# postgresql service alias
alias pgstart="sudo launchctl load /Library/LaunchDaemons/dev.postgresql.plist"
alias pgstop="sudo launchctl unload /Library/LaunchDaemons/dev.postgresql.plist"

# zsh scripts
source ~/.dotfiles/zshscripts/k.sh

# macOS settings
if [[ "$PLATFORM" == "Darwin" ]]
then

    # via https://remysharp.com/2018/08/23/cli-improved
    alias cat="bat"
    alias ping="prettyping --nolegend"

    # FZF
    alias preview="fzf --preview 'bat --color \"always\" {}'"

    if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
      export PATH="$PATH:/usr/local/opt/fzf/bin"
    fi

    [[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

    if [[ -e /usr/local/opt/fzf/shell/key-bindings.zsh ]]; then
        source "/usr/local/opt/fzf/shell/key-bindings.zsh"
    fi

    if [[ -e /opt/boxen/homebrew/Cellar/fzf/0.17.4/shell/key-bindings.zsh ]]; then
        source "/opt/boxen/homebrew/Cellar/fzf/0.17.4/shell/key-bindings.zsh"
    fi

    export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(subl -w {})+abort'"

    # have proper languages set up
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8

    # go binaries
    export GOPATH=~/.go

    # Paths
    PATH=~/.pyenv/shims:${PATH}
    PATH=/usr/local/opt/ruby/bin:${PATH}
    PATH=${PATH}:~/.go/bin
    PATH=${PATH}:~/.nodenv/shims
    PATH=${PATH}:/usr/local/sbin
    PATH=${PATH}:/usr/local/share/python
    PATH=${PATH}:/usr/local/bin
    PATH=${PATH}:~/.local/bin
    PATH=${PATH}:~/iCloud/Scripts
    PATH=${PATH}:/opt/local/bin
    PATH=${PATH}:/opt/local/sbin
    PATH=${PATH}:/usr/bin
    PATH=${PATH}:/bin
    PATH=${PATH}:/usr/sbin
    PATH=${PATH}:/sbin
    PATH=${PATH}:/Applications/fman.app/Contents/SharedSupport/bin

    # Postgres default port
    export PGPORT=5432

    # Rust
    if [ -d ~/.cargo ]; then
        source ~/.cargo/env
    fi

    # Python startup
    export PYTHONSTARTUP="${HOME}/.pythonrc"

    # editor
    export EDITOR='subl -w'
    alias edit='subl'

    # provisioner
    export VAGRANT_DEFAULT_PROVIDER='virtualbox'

    # virtualenvwrapper
    export WORKON_HOME="$HOME/.virtualenvs"
    export VIRTUALENVWRAPPER_HOOK_DIR=~/.dotfiles/virtualenvhooks
    export PIP_VIRTUALENV_BASE=$WORKON_HOME
    export PIP_RESPECT_VIRTUALENV=true

    # Switch to a different profile when reaching out to another server from
    # OSX unless the ssh command output is being piped to another process
    ssh () {
        command ssh "$@"; [ -t 1 ] && echo -ne "\033]50;SetProfile=Default\a";
    }

    # always start with the default profile
    echo -ne "\033]50;SetProfile=Default\a";

    # unset the docker environment variable
    unset DOCKER_HOST

    # iterm2 shell integration
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

    # pyenv integration
    eval "$(pyenv init -)"
    pyenv virtualenvwrapper_lazy

    # google cloud sdk
    if test -d '/usr/local/Caskroom/google-cloud-sdk'; then
        source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
        source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
    fi

    # folder-based environment variables
    eval "$(direnv hook zsh)"
fi

# Linux settings
if [[ "$PLATFORM" == "Linux" ]]
then
    plugins=(git)

    export EDITOR='vim'
    alias edit="vim"

    if [ ! -e /vagrant ]; then
        echo -ne "\033]50;SetProfile=Dangerous\a"
    fi
fi

# FreeBSD settings
if [[ "$PLATFORM" == "FreeBSD" ]]
then
    export EDITOR='vim'
    alias edit="vim"

    if [ ! -e /vagrant ]; then
        echo -ne "\033]50;SetProfile=Dangerous\a"
    fi
fi

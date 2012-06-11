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
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git osx vagrant )

source $ZSH/oh-my-zsh.sh

# Customize to your needs...
export PATH=/Users/denis/Scripts:/Users/denis/Tools/casperjs/bin:/Users/denis/Tools/phantomjs/bin:/Library/Frameworks/Python.framework/Versions/2.7/bin:/Library/Frameworks/Python.framework/Versions/Current/bin:/opt/local/bin:/opt/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/Users/denis/Tools/Jslint:/usr/local/git/bin:/usr/X11/bin:/Users/denis/Tools/less/node_modules/less/bin:/Users/denis/bin:/usr/local/bin:/Users/denis/local/node/bin:/Library/PostgreSQL/9.0/bin/:/usr/local/mysql-5.5.16-osx10.6-x86_64/bin/:/usr/local/mysql-5.5.16-osx10.6-x86_64/lib/:/User/denis/Tools/sshfs/

# Python startup
export PYTHONSTARTUP='/Users/denis/.pythonrc'

# add autocompletion for man pages
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

# virtualenvwrapper
export WORKON_HOME=$HOME/Envmts
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
source /usr/local/bin/virtualenvwrapper.sh

# default editor
export EDTIOR='subl -w'

# history
setopt hist_ignore_dups

#autocomplete
setopt menucomplete

# show user and host on the right
RPROMPT="%{$fg[cyan]%}%n%{$reset_color%}≪%{$fg[red]%}%m%{$reset_color%}"



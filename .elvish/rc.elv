# start the prompts empty, to prevent some flickering
edit:prompt = { put '' }
edit:rprompt = { put '' }

# if the prompt is stale, do not update it, to avoid flickering
edit:prompt-stale-transform = [text]{
    put $text
}

# external modules
use epm
epm:install &silent-if-installed=$true github.com/href/elvish-gitstatus

# make sure the private module is there if it doesn't exist yet
touch ~/.elvish/lib/private.elv

# included modules
use github.com/href/elvish-gitstatus/gitstatus
use cloudscale
use private
use projects
use utils
use system
use str
use internal

# locale
E:LANG="en_US.UTF-8"
E:LC_ALL="en_US.UTF-8"

# go
E:GOPATH=~/.go

# paths
paths=[
    ~/iCloud/Scripts
    ~/.pyenv/shims
    ~/.go/bin
    ~/.cargo/bin
    /Library/TeX/texbin
    /usr/local/sbin
    /usr/local/bin
    ~/.local/bin
    /opt/local/bin
    /opt/local/sbin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
    $@paths
]

# better key bindings
edit:insert:binding[Ctrl-A] = { edit:move-dot-sol }
edit:insert:binding[Ctrl-E] = { edit:move-dot-eol }

# use fzf for history, instead of the built in command
fn unique {
    perl -ne'print unless $h{$_}++' /dev/stdin
}

fn history {
    edit:current-command = (all [(edit:command-history)] | each [cmd]{
        print $cmd[cmd]"\000" 
    } | unique | fzf --no-sort --tac --read0 | slurp | str:trim-right (all) "\n")
}

edit:insert:binding[Ctrl-R] = {
    history </dev/tty </dev/tty >/dev/tty 2>&1
}

# add the ability to edit the current command in vim
fn edit-command {
    print $edit:current-command > /tmp/elvish-edit-command-$pid.elv
    vim /tmp/elvish-edit-command-$pid.elv </dev/tty >/dev/tty 2>&1
    edit:current-command = (cat /tmp/elvish-edit-command-$pid.elv | slurp | str:trim-right (all) "\n")
}

edit:insert:binding[CTRL-O] = $edit-command~

# seantis build artifacts
E:ARTIFACTS_REPOSITORY = ~/Code/artifacts

# aliases
fn ls [@a]{ e:ls -G $@a }
fn html { w3m -T text/html -dump }

fn glog {
    git log \
        --graph\
        --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\
        --abbrev-commit
}

# functions
fn current-directory-name {
    path-base (tilde-abbr $pwd)
}

fn workon [project]{
    projects:activate $project
}

fn short-id {
    str:to-lower (uuidgen | cut -d '-' -f 1)
}

fn edit [@a]{
    if (has-external subl) {
        subl $@a
    } elif (has-external vim) {
        subl $@a
    } elif (has-external nano) {
        subl $@a
    } else {
        vi $@a
    }
}

fn activate-profile [profile]{
    print "\033]50;SetProfile="$profile"\a" > /dev/tty
}

# when exiting from ssh, reset the profile
fn ssh [@a]{
    use re

    try {
        if (not (re:match '\.dev' $a[0])) {
            activate-profile "Dangerous"
        }
        e:ssh $@a
    } finally {
        activate-profile "Default"
    }
}

fn set-repository-author [repository author email]{
    git -C $repository config user.name $author
    git -C $repository config user.email $email
}

fn as-work-repository {
    set-repository-author $pwd "Denis Krienbühl" "denis.krienbuehl@cloudscale.ch"
}

fn as-personal-repository {
    set-repository-author $pwd "Denis Krienbühl" "denis@href.ch"
}

fn rm-host-line [@lines]{
    lines = [(each [l]{ echo $l } $lines | sort --human-numeric-sort --reverse)]

    for line $lines {
        sed -i '' $line'd' ~/.ssh/known_hosts
    }
}

# when starting the shell, activate the default profile
activate-profile "Default"

edit:completion:arg-completer[workon] = [@args]{
    ls $projects:projects-dir
}

# left prompt
edit:prompt = {

    # show the current project
    project = (projects:current)
    if (not-eq $project "") {
        if (str:has-prefix $pwd (projects:path $project)) {
            put (styled ▶" " green)
        } else {
            put ▷" "
        }
    }

    put (styled (current-directory-name) blue)

    # show git information
    git = (gitstatus:query $pwd)
    if (bool $git[is-repository]) {

        # show the branch or current commit if not on a branch
        branch = ''
        if (eq $git[local-branch] "") {
            branch = $git[commit][:8]
        } else {
            branch = $git[local-branch]
        }

        put '|'
        put (styled $branch red)

        # show a state indicator
        if (> $git[conflicted] 0) {
            put (styled '!' yellow)
        } elif (or (> $git[unstaged] 0) (> $git[untracked] 0)) {
            put (styled '*' yellow)
        } elif (> $git[staged] 0) {
            put (styled '*' green)
        } elif (> $git[commits-ahead] 0) {
            put (styled '^' yellow)
        } elif (> $git[commits-behind] 0) {
            put (styled '⌄' yellow)
        }

    }

    # add a space before the prompt
    put ' '

    # fetch history from other sessions
    edit:history:fast-forward
}

# right prompt
edit:rprompt = ((constantly {
    put (styled (whoami) blue)
    put '|'
    put (styled (str:trim-suffix (hostname) '.local') red)
}))

# iTerm 2 integration
use iterm2
iterm2:clear-scrollback
iterm2:init

# SSH autocomplete
cache = [&]

edit:completion:arg-completer[ssh] = [@args]{
    if (not (has-key $cache servers)) {
        cache[servers] = [(guy hosts -d list)]
    }

    servers = $cache[servers]
    put $@servers
}

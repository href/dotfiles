# external modules
use epm
epm:install &silent-if-installed=$true github.com/href/elvish-gitstatus

# Dim stale prompts
edit:prompt-stale-transform = [text]{
    put (styled $text dim)
}

# make sure the private module is there if it doesn't exist yet
touch ~/.elvish/lib/private.elv

# included modules
use github.com/href/elvish-gitstatus/gitstatus
use cloudscale
use internal
use notes
use path
use private
use projects
use str
use system
use utils

# locale
set E:LANG = "en_US.UTF-8"
set E:LC_ALL = "en_US.UTF-8"

# default editor
set E:EDITOR = "subl -w"

# go
set E:GOPATH = ~/.go

# Ansible
set E:ANSIBLE_STDOUT_CALLBACK = actionable

# Notes
set E:NOTES = ~/Documents/Notes

# paths
set paths = [
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
edit:insert:binding[Shift-Left] = { edit:kill-left-alnum-word }
edit:insert:binding[Shift-Right] = { edit:kill-right-alnum-word }
edit:insert:binding[Ctrl-K] = { edit:kill-line-left; edit:kill-line-right}

# use fzf for history, instead of the built in command
fn unique {
    perl -0 -ne"$SIG{PIPE}= 'IGNORE'; print unless $h{$_}++" /dev/stdin
}

fn history [&sep="\n"]{
    edit:history:fast-forward

    all [(edit:command-history)] | each [cmd]{
        print $cmd[cmd]$sep
    } | unique
}

fn search-history {
    try {
        edit:current-command = (history &sep="\000" | zsh -c (echo "
            SHELL=/bin/zsh fzf
                --no-sort
                --tac
                --read0
                --preview-window=bottom:40%:wrap
                --exact
                --reverse
                --preview='echo {} | bat -l elv --color=always --style=plain'
        " | tr -d "\n") | slurp | str:trim-right (all) "\n")
    } except {
        # pass
    }
}

edit:insert:binding[Ctrl-R] = {
    search-history </dev/tty >/dev/tty 2>&1
}

# add the ability to edit the current command in vim
fn edit-command {
    print $edit:current-command > /tmp/elvish-edit-command-$pid.elv
    subl -w /tmp/elvish-edit-command-$pid.elv </dev/tty >/dev/tty 2>&1
    edit:current-command = (cat /tmp/elvish-edit-command-$pid.elv | slurp | str:trim-right (all) "\n")
}

edit:insert:binding[Ctrl-O] = $edit-command~

# aliases
fn ls [@a]{ e:ls -G $@a }
fn html { w3m -T text/html -dump }

fn glog {
    git log ^
        --graph ^
        --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' ^
        --abbrev-commit
}

# functions
fn current-directory-name {
    path:base (tilde-abbr $pwd)
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

fn watch [f &wait=1]{
    while $true {
        var output = ($f | slurp)
        clear
        echo $output
        sleep $wait
    }
}

# Syncs the current path to the given remote (in SSH notation), taking
# .gitignore into consideration
fn sync-current [dst &delete=$false]{

    if (str:contains $dst ":/") {
        fail "Unsafe sync: only use relative paths"
    }

    rsync -az ({
        if $delete {
            put '--delete'
        }
    }) --out-format="%n" --filter=':- .gitignore' . $dst
}

# Return the IP address of the given host (host/nslookup may fail with VPN)
fn ip [host]{
    python -c 'import socket; print(socket.gethostbyname("'$host'"))'
}

fn trust [host]{
    _ = ?(ssh-keygen -R (ip $host) stdout>/dev/null stderr>/dev/null)
    _ = ?(ssh-keygen -R $host stdout>/dev/null stderr>/dev/null)
    ssh-keyscan -H $host >> ~/.ssh/known_hosts stderr>/dev/null
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
            branch = $git[commit][..8]
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
        cache[servers] = [(guy hosts -f list)]
    }

    servers = $cache[servers]
    put $@servers
}

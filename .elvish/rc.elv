# Elvish shell configuration 🧝‍♂️
# ==============================

# Private modules
# ---------------
touch ~/.elvish/lib/private.elv
touch ~/.elvish/lib/internal.elv
touch ~/.elvish/lib/cs.elv

# Local Modules
# -------------
use cloudscale
use cmdline
use epm
use file
use history
use cs
use iterm2
use notes
use path
use private
use projects
use str
use system
use utils

# External Modules
# ----------------
epm:install &silent-if-installed=$true github.com/href/elvish-gitstatus
use github.com/href/elvish-gitstatus/gitstatus

# Elvish Configuration
# --------------------
set notify-bg-job-success = $false

# Environment Settings
# --------------------
set E:LANG = "en_US.UTF-8"
set E:LC_ALL = "en_US.UTF-8"
set E:EDITOR = "subl -w"
set E:GOPATH = ~/.go

# Prevents Homebrew from updating packages when installing new ones
set E:HOMEBREW_NO_AUTO_UPDATE = "1"

# Limits Ansible output to actual changes
set E:ANSIBLE_STDOUT_CALLBACK = actionable

# Enables PycURL builds on macOS
set E:PYCURL_SSL_LIBRARY = "openssl"
set E:CPPFLAGS = -I/usr/local/opt/openssl/include
set E:LDFLAGS = -L/usr/local/opt/openssl/lib

# Workaround for Ansible issues on macOS
set E:OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES"

# The path for notes managed by the "notes" module
set E:NOTES = ~/Documents/Notes

# Configures the PATH
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

# Key Bindings
# ------------
set edit:insert:binding[Ctrl-A] = { edit:move-dot-sol }
set edit:insert:binding[Ctrl-E] = { edit:move-dot-eol }
set edit:insert:binding[Shift-Left] = { edit:kill-left-alnum-word }
set edit:insert:binding[Shift-Right] = { edit:kill-right-alnum-word }
set edit:insert:binding[Ctrl-K] = { edit:kill-line-left; edit:kill-line-right}
set edit:insert:binding[Ctrl-R] = { history:fzf-search </dev/tty >/dev/tty 2>&1 }
set edit:insert:binding[Ctrl-P] = $cmdline:copy-to-clipboard~
set edit:insert:binding[Ctrl-O] = $cmdline:open-in-editor~
set edit:insert:binding[Ctrl-N] = { edit:location:start }

# Prompt Config
# -------------

# Dim the prompt if it isn't ready
set edit:prompt-stale-transform = {|text|
    put (styled $text dim)
}

# Left prompt
set edit:prompt = {

    # show the current project
    var project; set project = (projects:current)
    var short; set short = ({
        if (> (count $project) 3) {
            put $project[..3]
        } else {
            put $project
        }
    })
    if (not-eq $project "") {
        if (str:has-prefix $pwd (projects:path $project)) {
            put (styled $short green)":"
        } else {
            put (styled $short dim)":"
        }
    }

    put (styled (path:base (tilde-abbr $pwd)) blue)

    # show git information
    var git = (gitstatus:query $pwd)
    if (bool $git[is-repository]) {

        # show the branch or current commit if not on a branch
        var branch = ''
        if (eq $git[local-branch] "") {
            set branch = $git[commit][..8]
        } else {
            set branch = $git[local-branch]
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

# Right prompt
set edit:rprompt = ((constantly {
    put (styled (whoami) blue)
    put '|'
    put (styled (str:trim-suffix (hostname) '.local') red)
}))

# Aliases / Short Commands
# ------------------------

# ls, but without group information
fn ls {|@a| e:ls -G $@a }

# Takes HTML by stdin and dumps text
fn html { w3m -T text/html -dump }

# Generate short random ids
fn short-id {
    str:to-lower (uuidgen | cut -d '-' -f 1)
}

# Open the right editor, depending on what is present
fn edit {|@a|
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

# When exiting from ssh, reset the profile
fn ssh {|@a|
    use re

    try {
        if (not (re:match '\.dev' $a[0])) {
            iterm2:activate-profile "Dangerous"
        }
        e:ssh $@a
    } finally {
        iterm2:activate-profile "Default"
    }
}

# Colorful git log
fn glog {
    git log ^
        --graph ^
        --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' ^
        --abbrev-commit
}

# Repository author changes
fn set-repository-author {|repository author email|
    git -C $repository config user.name $author
    git -C $repository config user.email $email
}

fn as-work-repository {
    set-repository-author $pwd "Denis Krienbühl" "denis.krienbuehl@cloudscale.ch"
}

fn as-personal-repository {
    set-repository-author $pwd "Denis Krienbühl" "denis@href.ch"
}

# Poor man's watch(1)
fn watch {|f &wait=1|
    while $true {
        var output = ($f | slurp)
        clear
        echo $output
        sleep $wait
    }
}

# Run the given function whenever there's a change in the current directory
fn on-change {|f &include=$nil &exclude=$nil &verbose=$false|
    var call; set call = 0

    fswatch . ({
        if (not-eq $include $nil) {
            put "-i" $include
        }
        if (not-eq $exclude $nil) {
            put "-e" $exclude
        }
    }) | each {|path|
        if (eq $verbose $true) {
            set call = (+ $call 1)
            echo "["(date +"%Y-%m-%d %H:%M:%S")" "$call"] "$path
        }
        try {
            $f
        } catch {
            # pass
        }
    }
}

# Open the given URL in the default browser
fn open-url {|url|
    if (or (str:has-prefix $url "http://") (str:has-prefix $url "https://")) {
        open $url
    } else {
        open "https://"$url
    }
}

# Return the IP address of the given host (host/nslookup may fail with VPN)
fn ip {|host|
    python -c 'import socket; print(socket.gethostbyname("'$host'"))'
}

# Trust the given host in SSH
fn trust {|host|
    set _ = ?(ssh-keygen -R (ip $host) stdout>/dev/null stderr>/dev/null)
    set _ = ?(ssh-keygen -R $host stdout>/dev/null stderr>/dev/null)
    ssh-keyscan -H $host >> ~/.ssh/known_hosts stderr>/dev/null
}

# iTerm 2 Integration
# -------------------
iterm2:activate-profile "Default"
iterm2:clear-scrollback
iterm2:init

# Projects
# --------

set edit:completion:arg-completer[workon] = {|@args|
    ls $projects:projects-dir
}

set after-chdir = [{|dir| projects:auto-activate }]

# Broot integration
# -----------------
fn br {|@args|
    var cmds; set cmds = (mktemp)
    try {
        broot --outcmd $cmds $@args
        try {
            eval (cat $cmds)
        } catch {
            # pass
        }
    } finally {
        rm -f $cmds
    }
}

# SSH auto-complete
# -----------------
set edit:completion:arg-completer[ssh] = {|@args|
    infra hosts
}

# SSH helper
fn ssh-each {|@args|
    each {|host|
        print $host" → "
        try {
            ssh -o StrictHostKeyChecking=accept-new $host $@args < /dev/null
        } catch e {
            echo "Exited with "$e[reason][exit-status]
        }
    }
}

fn ssh-each-tty {|hosts @args|
    each {|host|
        print $host" → "
        try {
            ssh -o StrictHostKeyChecking=accept-new -t $host $@args
        } catch e {
            echo "Exited with "$e[reason][exit-status]
        }
    } $hosts
}

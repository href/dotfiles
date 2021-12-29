# Elvish shell configuration 🧝‍♂️
# ==============================

# Private modules
# ---------------
touch ~/.elvish/lib/private.elv
touch ~/.elvish/lib/internal.elv

# Local Modules
# -------------
use cloudscale
use cmdline
use epm
use file
use history
use internal
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
notify-bg-job-success = $false

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
edit:insert:binding[Ctrl-A] = { edit:move-dot-sol }
edit:insert:binding[Ctrl-E] = { edit:move-dot-eol }
edit:insert:binding[Shift-Left] = { edit:kill-left-alnum-word }
edit:insert:binding[Shift-Right] = { edit:kill-right-alnum-word }
edit:insert:binding[Ctrl-K] = { edit:kill-line-left; edit:kill-line-right}
edit:insert:binding[Ctrl-R] = { history:fzf-search </dev/tty >/dev/tty 2>&1 }
edit:insert:binding[Ctrl-P] = $cmdline:copy-to-clipboard~
edit:insert:binding[Ctrl-O] = $cmdline:open-in-editor~
edit:insert:binding[Ctrl-N] = { edit:location:start }

# Prompt Config
# -------------

# Dim the prompt if it isn't ready
edit:prompt-stale-transform = [text]{
    put (styled $text dim)
}

# Left prompt
edit:prompt = {

    # show the current project
    set project = (projects:current)
    set short = ({
        if (> (count $project) 3) {
            put $project[..3]
        } else {
            put $project
        }
    })
    if (not-eq $project "") {
        if (str:has-prefix $pwd (projects:path $project)) {
            put (styled $short green)"∙"
        } else {
            put (styled $short dim)"∙"
        }
    }

    put (styled (path:base (tilde-abbr $pwd)) blue)

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

# Right prompt
edit:rprompt = ((constantly {
    put (styled (whoami) blue)
    put '|'
    put (styled (str:trim-suffix (hostname) '.local') red)
}))

# Aliases / Short Commands
# ------------------------

# ls, but without group information
fn ls [@a]{ e:ls -G $@a }

# Takes HTML by stdin and dumps text
fn html { w3m -T text/html -dump }

# Generate short random ids
fn short-id {
    str:to-lower (uuidgen | cut -d '-' -f 1)
}

# Open the right editor, depending on what is present
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

# When exiting from ssh, reset the profile
fn ssh [@a]{
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

# Poor man's watch(1)
fn watch [f &wait=1]{
    while $true {
        var output = ($f | slurp)
        clear
        echo $output
        sleep $wait
    }
}

# Run the given function whenever there's a change in the current directory
fn on-change [f &include=$nil &exclude=$nil &verbose=$false]{
    set call = 0

    fswatch . ({
        if (not-eq $include $nil) {
            put "-i" $include
        }
        if (not-eq $exclude $nil) {
            put "-e" $exclude
        }
    }) | each [path]{
        if (eq $verbose $true) {
            call = (+ $call 1)
            echo "["(date +"%Y-%m-%d %H:%M:%S")" "$call"] "$path
        }
        try {
            $f
        } except {
            # pass
        }
    }
}

# Open the given URL in the default browser
fn open-url [url]{
    python3 -c "import webbrowser; webbrowser.open_new_tab('"$url"')"
}

# Return the IP address of the given host (host/nslookup may fail with VPN)
fn ip [host]{
    python -c 'import socket; print(socket.gethostbyname("'$host'"))'
}

# Trust the given host in SSH
fn trust [host]{
    _ = ?(ssh-keygen -R (ip $host) stdout>/dev/null stderr>/dev/null)
    _ = ?(ssh-keygen -R $host stdout>/dev/null stderr>/dev/null)
    ssh-keyscan -H $host >> ~/.ssh/known_hosts stderr>/dev/null
}

# iTerm 2 Integration
# -------------------
iterm2:activate-profile "Default"
iterm2:clear-scrollback
iterm2:init

# Projects
# --------

edit:completion:arg-completer[workon] = [@args]{
    ls $projects:projects-dir
}

after-chdir = [[dir]{ projects:auto-activate }]

# Broot integration
# -----------------
fn br [@args]{
    set cmds = (mktemp)
    try {
        broot --outcmd $cmds $@args
        try {
            eval (cat $cmds)
        } except {
            # pass
        }
    } finally {
        rm -f $cmds
    }
}

# SSH auto-complete
# -----------------
hosts-cache = "/tmp/"(date '+%Y-%m-%d.hosts')

edit:completion:arg-completer[ssh] = [@args]{
    if (not (path:is-regular $hosts-cache)) {
        guy hosts -f list > $hosts-cache
    }

    cat $hosts-cache
}

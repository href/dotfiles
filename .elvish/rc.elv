# Elvish shell configuration 🧝‍♂️
# ==============================
use path

# Configures the PATH
fn available-paths {|paths|
  for path $paths {
    if (path:is-dir $path) {
      put $path
    }
  }
}

set paths = [(available-paths [
  ~/iCloud/Scripts
  ~/.cargo/bin
  ~/.go/bin
  ~/.zig
  /Library/TeX/texbin
  /usr/local/sbin
  /usr/local/bin
  /opt/homebrew/bin
  /home/linuxbrew/.linuxbrew/bin
  /opt/local/bin
  /opt/local/sbin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $@paths
])]

# Immediately switch to tmux, if not active yet
if (not (has-env TMUX)) {
    # Attach to the first detached session, if there is one
    try {
        var session = (tmux ls | grep -v attached | cut -d ':' -f 1 | head -n 1)
        exec tmux attach -t $session
    } catch {
        exec tmux new-session -n SHELL
    }
}

# Private modules
# ---------------
touch ~/.config/elvish/lib/private.elv
touch ~/.config/elvish/lib/internal.elv
touch ~/.config/elvish/lib/cs.elv

# Local Modules
# -------------
use cloudscale
use cmdline
use epm
use file
use history
use cs
use iterm2
use private
use projects
use str
use system
use tmux
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
set E:EDITOR = "hx"
set E:GOPATH = ~/.go

# Prevents Homebrew from updating packages when installing new ones
set E:HOMEBREW_NO_AUTO_UPDATE = "1"

# Limits Ansible output to actual changes
set E:ANSIBLE_DISPLAY_OK_HOSTS = false
set E:ANSIBLE_DISPLAY_SKIPPED_HOSTS = false
set E:ANSIBLE_SHOW_PER_HOST_START = false
set E:ANSIBLE_SHOW_TASK_PATH_ON_FAILURE = true
set E:ANSIBLE_CHECK_MODE_MARKERS = true
set E:ANSIBLE_CALLBACK_RESULT_FORMAT = yaml
set E:ANSIBLE_SHOW_CUSTOM_STATS = true
set E:ANSIBLE_DEPRECATION_WARNINGS = false

# https://serverfault.com/a/1110179/124501
set E:no_proxy = "*"

# Enable inventory caching
set E:ANSIBLE_INVENTORY_CACHE = true
set E:ANSIBLE_INVENTORY_CACHE_PLUGIN = ansible.builtin.jsonfile
set E:ANSIBLE_CACHE_PLUGIN_CONNECTION = /tmp/.ansible-inventory-cache
set E:ANSIBLE_CACHE_PLUGIN_TIMEOUT = 900

fn ansible-verbose {
    set E:ANSIBLE_DISPLAY_OK_HOSTS = true
    set E:ANSIBLE_DISPLAY_SKIPPED_HOSTS = true
}

fn ansible-quiet {
    set E:ANSIBLE_DISPLAY_OK_HOSTS = false
    set E:ANSIBLE_DISPLAY_SKIPPED_HOSTS = false
}

# Enables PycURL builds on macOS
set E:PYCURL_SSL_LIBRARY = "openssl"
set E:CPPFLAGS = -I/usr/local/opt/openssl/include
set E:LDFLAGS = -L/usr/local/opt/openssl/lib

# Workaround for Ansible issues on macOS
set E:OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES"

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
set edit:insert:binding[Ctrl-L] = { edit:clear; printf "\033[3J" >/dev/tty }
set edit:insert:binding[Ctrl-G] = { echo (git select </dev/tty >/dev/tty 2>&1) }

# Prompt Config
# -------------

# Dim the prompt if it isn't ready
set edit:prompt-stale-transform = {|text|
    put (styled $text dim)
}

# Left prompt
var prompt-red-bg = bg-color196
var prompt-red-fg = fg-color196
var prompt-blue-bg = bg-color33
var prompt-blue-fg = fg-color33
var prompt-black-fg = fg-color232

set edit:prompt = {

    # Show the current host
    if (has-env SSH_CONNECTION) {
        var host = ' '(str:to-upper (hostname))' '
        put (styled $host $prompt-red-bg bold $prompt-black-fg)' '
    }
    
    # Show the current project
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

    put (styled (path:base (tilde-abbr $pwd)) $prompt-blue-fg)

    # Show git information
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

    # Add a space before the prompt
    put ' '
}

# Right prompt
set edit:rprompt = { put '' }

# Aliases / Short Commands
# ------------------------

# ls, but with colors
fn ls {|@a| eza $@a }

# cat, but with syntax highlighting
fn cat {|@a| bat --style=plain $@a }

# Takes HTML by stdin and dumps text
fn html { w3m -T text/html -dump }

# Shorten kubectl
fn k {|@a| kubectl $@a }

# Generate short random ids
fn short-id {
    str:to-lower (uuidgen | cut -d '-' -f 1)
}

# Reset terminal
fn reset {
    projects:clear
    cd ~
    edit:clear
    printf "\033[3J" >/dev/tty
    tmux selectp -P bg=default
    tmux rename-window SHELL
}

# Open the right editor, depending on what is present
fn edit {|@a|
    if (has-external hx) {
        hx $@a
    } elif (has-external code) {
        code $@a
    } elif (has-external subl) {
        subl $@a
    } elif (has-external vim) {
        vim $@a
    } elif (has-external nano) {
        nano $@a
    } else {
        vi $@a
    }
}

# Change background color of the current tmux pane, when using SSH
fn ssh {|@a|
    use re

    try {
        tmux selectp -P bg='#200000'
        e:ssh $@a
    } finally {
        tmux selectp -P bg=default
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
fn on-change {|f &include=$nil &exclude=$nil &verbose=$false &clear=$false|
    var call; set call = 0

    fswatch . ({
        if (not-eq $include $nil) {
            put "-i" $include
        }
        if (not-eq $exclude $nil) {
            put "-e" $exclude
        }

        put "-e" "/.git/"
        put "-e" "/.mypy_cache/"
        put "-e" "/__pycache__/"
        put "-e" '\.pyc'

    }) | each {|path|
        echo $path
        if (eq $clear $true) {
            clear
        }
        if (eq $verbose $true) {
            set call = (+ $call 1)
            echo "["(date +"%Y-%m-%d %H:%M:%S")" "$call"] "$path
        }
        try {
            $f
        } catch e {
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

# Trust the given host in SSH
fn trust {|host|
    set host = [(str:split '@' $host)][-1]
    set _ = ?(ssh-keygen -R (ip $host) stdout>/dev/null stderr>/dev/null)
    set _ = ?(ssh-keygen -R $host stdout>/dev/null stderr>/dev/null)
    ssh-keyscan -H $host >> ~/.ssh/known_hosts stderr>/dev/null
}

# iTerm 2 Integration
# -------------------
iterm2:activate-profile "Default"
iterm2:init

# Projects
# --------
set edit:completion:arg-completer[workon] = {|@args|
    ls $projects:projects-dir
}

set after-chdir = [{|dir| projects:auto-activate }]
projects:auto-activate

# SSH auto-complete
# -----------------
set edit:completion:arg-completer[ssh] = {|@args|
    infra hosts
}

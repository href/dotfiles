# start the prompts empty, to prevent some flickering
edit:prompt = { put '' }
edit:rprompt = { put '' }

# if the prompt is stale, do not update it, to avoid flickering
edit:prompt-stale-transform = $all~

# external modules
use epm
epm:install &silent-if-installed=$true github.com/href/elvish-gitstatus

# included modules
use github.com/href/elvish-gitstatus/gitstatus
use private
use projects
use str

# locale
E:LANG="en_US.UTF-8"
E:LC_ALL="en_US.UTF-8"

# paths
paths=[
    ~/iCloud/Scripts
    ~/.pyenv/shims
    /usr/local/lib/ruby/gems/2.6.0/bin
    /usr/local/opt/ruby/bin
    ~/.go/bin
    ~/.nodenv/shims
    /usr/local/sbin
    /usr/local/share/python
    /usr/local/bin
    ~/.local/bin
    /opt/local/bin
    /opt/local/sbin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
    /Applications/fman.app/Contents/SharedSupport/bin
    /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin
    $@paths
]

# better key bindings
edit:insert:binding[Ctrl-A] = { edit:move-dot-sol }
edit:insert:binding[Ctrl-E] = { edit:move-dot-eol }

# seantis build artifacts
E:ARTIFACTS_REPOSITORY = ~/Documents/Code/artifacts

# aliases
fn ls [@a]{ e:ls -G $@a }
fn push-all { git push; git push --tags }
fn python-clean { find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete }

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

fn activate-default-profile {
    print "\033]50;SetProfile=Default\a" > /dev/tty
}

# when exiting from ssh, reset the profile
fn ssh [@a]{ e:ssh $@a; activate-default-profile }

# when starting the shell, activate the default profile
activate-default-profile

edit:completion:arg-completer[workon] = [@args]{
    ls $projects:projects-dir
}

# left prompt
edit:prompt = {

    # show the current project
    project = (projects:current)
    if (not-eq $project "") {
        put '('
        put $project
        put ')'
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
        if (or (> $git[unstaged] 0) (> $git[untracked] 0)) {
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

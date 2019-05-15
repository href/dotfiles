# included modules
use virtualenv

# paths
paths=[
    ~/.pyenv/shims
    /usr/local/lib/ruby/gems/2.6.0/bin
    /usr/local/opt/ruby/bin
    ~/.go/bin
    ~/.nodenv/shims
    /usr/local/sbin
    /usr/local/share/python
    /usr/local/bin
    ~/.local/bin
    ~/iCloud/Scripts
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

# functions
fn current-directory-name {
    path-base (tilde-abbr $pwd)
}

fn workon [project]{
    virtualenv:activate $project
    cd ~/Documents/Code/$project
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

edit:completion:arg-completer[workon] = [@args]{
    use virtualenv
    e:ls $virtualenv:virtualenv-directory
}

# left prompt
edit:prompt = {
    venv = (virtualenv:current)

    if (not-eq $venv "") {
        put '('
        put $venv
        put ')'
    }

    put (styled (current-directory-name) blue)
    put ' '
}

# right prompt
edit:rprompt = ((constantly {
    put (styled (whoami) blue)
    put '|'
    put (styled (hostname) red)
}))

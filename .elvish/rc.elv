# included modules
use virtualenv

# better key bindings
use readline-binding

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

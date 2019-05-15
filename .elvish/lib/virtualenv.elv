# adapted from https://github.com/iwoloschin/elvish-packages/blob/master/python.elv

virtualenv-directory = $E:HOME/.virtualenvs

fn current {
    if (not-eq $E:VIRTUAL_ENV "") {
        echo (path-base $E:VIRTUAL_ENV)
    } else {
        echo ""
    }
}

fn activate [name]{
    _ = ?(confirmed-name = (
        ls $virtualenv-directory | each [virtualenv]{
            if (eq $name $virtualenv) {
                put $name
            }
        }
    ))

    if (eq $name $confirmed-name) {
        E:VIRTUAL_ENV = $virtualenv-directory/$name
        E:PATH = $E:VIRTUAL_ENV/bin:$E:PATH
    } else {
        fail 'Virtual Environment "'$name'" not found.'
    }
}

edit:completion:arg-completer[python:activate] = [@args]{
    e:ls $virtualenv-directory
}

fn list-virtualenvs {
    explode [(ls $virtualenv-directory)]
}

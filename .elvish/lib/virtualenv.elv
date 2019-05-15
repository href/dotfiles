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
    virtualenvs = [(ls $virtualenv-directory)]

    error = ?(confirmed-name = (
        each [virtualenv]{
            if (eq $name $virtualenv) { put $name }
        } $virtualenvs)
    )

    if (eq $name $confirmed-name) {
        E:VIRTUAL_ENV = $virtualenv-directory/$name
        E:_OLD_VIRTUAL_PATH = $E:PATH
        E:PATH = $E:VIRTUAL_ENV/bin:$E:PATH

        if (not-eq $E:PYTHONHOME "") {
            E:_OLD_VIRTUAL_PYTHONHOME = $E:PYTHONHOME
            del E:PYTHONHOME
        }
    } else {
        echo 'Virtual Environment "'$name'" not found.'
    }
}

edit:completion:arg-completer[python:activate] = [@args]{
    e:ls $virtualenv-directory
}

fn deactivate {
    if (not-eq $E:_OLD_VIRTUAL_PATH "") {
        E:PATH = $E:_OLD_VIRTUAL_PATH
        del E:_OLD_VIRTUAL_PATH
    }

    if (not-eq $E:_OLD_VIRTUAL_PYTHONHOME "") {
        E:PYTHONHOME = $E:_OLD_VIRTUAL_PYTHONHOME
        del E:_OLD_VIRTUAL_PYTHONHOME
    }

    if (not-eq $E:VIRTUAL_ENV "") {
        del E:VIRTUAL_ENV
    }
}

fn list-virtualenvs {
    explode [(ls $virtualenv-directory)]
}

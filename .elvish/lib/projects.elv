projects-dir = ~/.projects
default-path = ~/Code
python-path = ~/.pyenv/versions/

fn current {
    echo $E:CURRENT_PROJECT
}

fn list {
    mkdir -p $projects-dir
    put [(ls $projects-dir)]
}

fn exists [name]{
    put (has-value (list) $name)
}

fn exclude-projects [list]{
    each [p]{
        if (not (has-prefix $p $projects-dir)) {
            put $p
        }
    } $list
}

fn path [name]{
    cat $projects-dir/$name/path
}

fn clear {
    del E:VIRTUAL_ENV
    del E:CURRENT_PROJECT
    paths = [(exclude-projects $paths)]
}

fn activate [name]{
    if (not (exists $name)) {
        fail "unknown project: "$name
    }

    clear

    E:CURRENT_PROJECT = $name
    E:VIRTUAL_ENV = $projects-dir/$name/venv
    E:PATH = $projects-dir/$name/venv/bin:$E:PATH

    cd (path $name)
}

fn create [name &path=default &python=default]{
    if (exists $name) {
        fail "project already created: "$name
    }

    if (eq $path 'default') {
        path = $default-path/$name
    }

    if (eq $python 'default') {
        python = (search-external python)
    } elif (has-prefix $python '/') {
        python = $python
    } else {
        python = $python-path/(ls $python-path | grep $python)/bin/python
    }

    if (not (has-external $python)) {
        fail "unknown python: "$python
    }

    mkdir -p $projects-dir/$name
    (external $python) -m venv $projects-dir/$name/venv

    mkdir -p $path
    print $path > $projects-dir/$name/path
    print $python > $projects-dir/$name/python

    activate $name

    pip install --upgrade pip setuptools > /dev/null
}

fn reset [name]{
    if (not (exists $name)) {
        fail "unknown project: "$name
    }

    clear

    path = (cat $projects-dir/$name/path)
    python = (cat $projects-dir/$name/python)

    rm -rf $projects-dir/$name
    create $name &path=$path &python=$python
}

fn delete [name]{
    if (not (exists $name)) {
        fail "unknown project: "$name
    }

    rm -rf $projects-dir/$name
    clear
}

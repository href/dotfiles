use str
use path

var projects-dir = ~/.projects
var default-path = ~/Code
var python-path = ~/.pyenv/versions/

fn current {
    echo $E:CURRENT_PROJECT
}

fn list {
    mkdir -p $projects-dir
    put [(ls $projects-dir)]
}

fn exists {|name|
    put (has-value (list) $name)
}

fn exclude-projects {|list|
    each {|p|
        if (not (str:has-prefix $p $projects-dir)) {
            put $p
        }
    } $list
}

fn path {|name|
    cat $projects-dir/$name/path
}

fn clear {
    del E:VIRTUAL_ENV
    del E:CURRENT_PROJECT
    set paths = [(exclude-projects $paths)]
}

fn activate {|name|
    if (not (exists $name)) {
        fail "unknown project: "$name
    }

    set E:CURRENT_PROJECT = $name
    set E:VIRTUAL_ENV = $projects-dir/$name/venv
    set E:PATH = $projects-dir/$name/venv/bin:$E:PATH

    set-tab-title (str:to-upper $name) &
}

fn workon {|name|
    activate $name

    cd (path $name)

    if (not (path:is-regular .project)) {
        echo $name > .project
    }
}

fn create {|name &path=default &python=default|
    if (exists $name) {
        fail "project already created: "$name
    }

    if (eq $path 'default') {
        set path = $default-path/$name
    }

    if (eq $python 'default') {
        set python = (pyenv which python)
    } elif (str:has-prefix $python '/') {
        set python = $python
    } else {
        set python = $python-path/(ls $python-path | grep $python)/bin/python
    }

    if (not (has-external $python)) {
        fail "unknown python: "$python
    }

    echo "Creating "$name" using "$python
    mkdir -p $projects-dir/$name

    try {
        virtualenv -q --python=$python $projects-dir/$name/venv
    } except {
        rm -rf $projects-dir/$name
        fail "Failed to create "$name
    }

    mkdir -p $path
    print $path > $projects-dir/$name/path
    print $python > $projects-dir/$name/python

    activate $name
    cd (path $name)

    pip install --upgrade pip setuptools > /dev/null
}

fn auto-activate {|&dir=""|
    set dir = ({
        if (eq $dir "") {
            put $pwd
        } else {
            put $dir
        }
    })

    if (eq $dir "/") {
        return
    }

    if (eq $dir "/Users/denis") {
        return
    }

    if (path:is-regular $dir/.project) {
        var found = (cat $dir/.project)

        if (not-eq $found (current)) {
            activate $found
        }
    } else {
        auto-activate &dir=(path:dir $dir)
    }
}

fn reset {|name|
    if (not (exists $name)) {
        fail "unknown project: "$name
    }

    clear

    var path = (cat $projects-dir/$name/path)
    var python = (cat $projects-dir/$name/python)

    rm -rf $projects-dir/$name
    create $name &path=$path &python=$python
}

fn delete {|name|
    if (not (exists $name)) {
        fail "unknown project: "$name
    }

    rm -rf $projects-dir/$name
    clear
}

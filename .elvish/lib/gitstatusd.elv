use str

path = ~/.elvish/package-data/gitstatusd

lock = $path/lock
binary = $path/gitstatusd
stdin = $path/stdin
stdout = $path/stdout

fn download-url {
    base = 'https://github.com/romkatv/gitstatus/raw/master/bin/gitstatusd'
    echo (str:to-lower $base"-"(uname -s)"-"(uname -m))
}

fn download {
    if (has-external curl) {
        curl -L -s (download-url) > $binary
    } elif (has-external wget) {
        wget -O $binary (download-url)
    } else {
        fail("found no http client to download gitstatusd with")
    }
}

fn install {
    mkdir -p $path

    if (not (has-external $binary)) {
        download
        chmod 0700 $binary
    }
}

fn update {
    rm $binary
    install
}

fn is-running {
    try {
        pgrep gitstatusd -U (id -u)
    } except {
        put $false
    } else {
        put $true
    }
}

fn stop {
    pkill gitstatusd -U (id -u)
}

fn launch {
    if (is-running) {
        fail "gitstatusd is already running"
    }

    # this is a race condition, but without flock I don't see a way of
    # doing this properly across Linux/macOS
    rm -f $stdout $stdin

    try {
        mkfifo $stdin $stdout
    } except {
        return
    } else {

        # the last to call wins this race
        try {
            stop
        } except {
            nop
        }
    }

    # stdin needs to always have one writer, otherwise gitstatusd will
    # quit after a single request
    cat <> $stdin &

    # spawn the process
    (external $binary) 2> /dev/null &
}

# this package installs itself as a side-effect -> this should be rather
# quick and only takes some time the first time we import, but it is
# still something that is a bit bad - shell startup shouldn't trigger
# actions like these..
install

use path
use str

fn ls {
    set output = [(git worktree list --porcelain)]
    set home = (path:abs ~)

    for line $output {
        if (str:has-prefix $line "worktree") {
            print (str:replace $home "~" (str:replace "worktree " "" $line))
        }
        if (str:has-prefix $line "branch") {
            echo " ["(str:replace "branch refs/heads/" "" $line)"]"
        }
    }
}

fn switch [branch]{
    set name = (echo $branch | awk -F '/' '{print $NF}')

    if (not ?(git show-ref -q --heads $branch)) {
        git branch $branch
    }

    if (not ?(test -e ../$name)) {
        git worktree add ../$name $branch
    }

    if (not ?(test -e ../$name/secret)) {
        mkdir $pwd/../$name/secret
        encfs $pwd/../$name/.secret $pwd/../$name/secret
    }

    if (not ?(test -e ../$name/roles/*.backup/defaults)) {
        set dir = $pwd
        cd ../$name
        git submodule update --init
        cd $dir
    }

    cd ../$name
}

fn remove [branch]{
    set name = (echo $branch | awk -F '/' '{print $NF}')

    if (not ?(git branch --show-current | grep -E '(master|main)')) {
        fail "Command must be run from the master/main branch"
    }

    if ?(test -e ../$name/secret) {
        try {
            umount $pwd/../$name/secret
        } except {
            # pass
        }
    }

    rm -rf $pwd/../$name

    git worktree prune
}

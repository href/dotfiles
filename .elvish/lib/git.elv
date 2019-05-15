fn branch {
    try {
        git symbolic-ref --short HEAD 2>/dev/null
    } except {
        put ""
    }
}

fn state {
    use re

    try {
        state = "clean"

        git status --porcelain --branch --untracked-files 2>/dev/null | each [line]{
            if (re:match ahead $line) {
                state = "ahead"
            } elif (re:match behind $line) {
                state = "behind"
            } elif (re:match '#' $line) {
                continue
            } else {
                state = "dirty"
                break
            }
        }

        put $state
    } except {
        return
    }
}

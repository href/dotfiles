use utils
use re

fn branch {
    utils:ignore-errors {
        utils:suppress-stderr {
            git symbolic-ref --short HEAD
        }
    }
}

fn state {
    utils:ignore-errors {
        utils:suppress-stderr {
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
        }
    }
}

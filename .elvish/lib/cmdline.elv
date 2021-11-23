# Command Line Editor Helpers
# ===========================
use str

fn open-in-editor {
    print $edit:current-command > /tmp/elvish-edit-command-$pid.elv
    eval $E:EDITOR" -w /tmp/elvish-edit-command-"$pid".elv" </dev/tty >/dev/tty 2>&1
    edit:current-command = (cat /tmp/elvish-edit-command-$pid.elv | slurp | str:trim-right (all) "\n")
}

fn copy-to-clipboard {
    print $edit:current-command | pbcopy
}

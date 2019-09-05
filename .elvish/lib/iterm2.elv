fn set-current-dir [dir]{
    print "\033]1337;CurrentDir="(path-abs $dir)"\007"
}

fn set-mark {
    print "\033]1337;SetMark\007" > /dev/stdout
}

fn clear-scrollback {
    print "\033]1337;ClearScrollback\007" > /dev/stdout
}

fn init {
    set-current-dir $pwd
    after-chdir = [$@after-chdir [dir]{ set-current-dir $pwd} ]
    edit:after-readline = [[line]{ set-mark }]
}

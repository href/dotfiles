fn set-current-dir [dir]{
    print "\033]1337;CurrentDir="(path-abs $dir)"\007"
}

fn init {
    set-current-dir $pwd
    after-chdir = [$@after-chdir [dir]{ set-current-dir $pwd} ]
}

fn suppress-stderr [func @args]{
    $func $@args 2> /dev/null
}

fn suppress-stdout [func @args]{
    $func $@args 1> /dev/null
}

fn ignore-errors [func @args]{
    try {
        $func $@args
    } except {
        put $nil
    }
}
fn is-disk-encrypted {
    put (eq (fdesetup status) "FileVault is On.")
}

fn is-path [path]{
    and (or ?(test -e $path) $false) $true
}

fn is-symbolic-link [path]{
    and (or ?(test -h $path) $false) $true
}

fn is-virtualenv-active {
    not (eq $E:VIRTUAL_ENV "")
}

use math
use str

fn is-disk-encrypted {
    put (eq (fdesetup status) "FileVault is On.")
}

fn is-path {|path|
    and (or ?(test -e $path) $false) $true
}

fn is-symbolic-link {|path|
    and (or ?(test -h $path) $false) $true
}

fn is-virtualenv-active {
    not (eq $E:VIRTUAL_ENV "")
}

fn accept-fingerprint {
    cat | each {|host|
        try {
            printf "Adding %s" $host
            ssh-keyscan $host.mgmt.cloudscale.ch >> ~/.ssh/known_hosts stderr>/dev/null
        } catch {
            printf " 𝙭\n"
            continue
        } else {
            printf " ✔\n"
        }
    }
}

# Returns the given value if not empty, otherwise the default
fn default {|value default|
    if (eq $value "") {
        put $default
    } else {
        put $value
    }
}

# Takes a hash and fills missing keys from the default hash
fn with-defaults {|params defaults|
    keys $defaults | each {|key|
        if (not (has-key $params $key)) {
            set params[$key] = $defaults[$key]
        }
    }

    put $params
}

# Raises an error if the given function does not return true
fn assert {|message fn|
    if (not-eq ($fn) $true) {
        fail $message
    }
}

# Takes a string and adds white-space to the right to reach the given width.
# Should the string already exceed the given width, it is instead clipped with
# an ellipsis.
fn pad-left {|string width|
    var sw = (count $string)

    if (< $width 1) {
        put ''; return
    }

    if (> $sw $width) {
        put $string[:(- $width 1)]'…'
    } else {
        put $string''(str:join '' [(repeat (- $width $sw) ' ')])
    }
}

# Takes a homogeneous list of lists and prints them as a table
fn table {|rows|
    var widths = [&]

    # Convert values to string
    for r [(range (count $rows))] {
        for c [(range (count $rows[$r]))] {
            set rows[$r][$c] = (to-string $rows[$r][$c])
        }
    }

    # Calculate the widths
    for r [(range (count $rows))] {
        for c [(range (count $rows[$r]))] {
            if (not (has-key $widths $c)) {
                set widths[$c] = (count $rows[$r][$c])
            } else {
                set widths[$c] = (math:max (count $rows[$r][$c]) $widths[$c])
            }
        }
    }

    # Print the rows with padding
    for r [(range (count $rows))] {
        for c [(range (count $rows[$r]))] {
            print (pad-left $rows[$r][$c] (+ $widths[$c] 1))
        }
        print "\n"
    }
}

# Ask the user for confirmation, failing if the user does not confirm.
fn confirm {|question|
    while $true {
        print $question" (yes/no): "
        var answer = (read-line)

        if (eq $answer "yes") {
            return
        }

        if (eq $answer "no") {
            fail("Confirmation denied")
        }
    }
}

# Ask the user to press enter
fn press-enter {|note|
    print $note": "
    read-line > /dev/null
}

# Show status of a set of hosts
fn status {|hosts|
    for host $hosts {
        if (is-online $host) {
            echo (styled '•' 'green') $host (ssh $host uptime -p)
        } else {
            echo (styled '•' 'red') $host
        }
    }
}

# Turn a multi-line string into a single line command
fn oneliner {|text| str:replace "\n" "" $text}
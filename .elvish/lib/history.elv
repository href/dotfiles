# FZF-based History Function for Elvish
# =====================================
use str

# Print the full history, using the given separator
fn dump {|&sep="\n"|
    edit:history:fast-forward

    edit:command-history &dedup &newest-first &cmd-only | each {|cmd|
        print $cmd$sep
    }
}

# Show an fzf-based search
fn fzf-search {
    try {
        set edit:current-command = (dump &sep="\000" | zsh -c (echo "
            SHELL=/bin/zsh fzf
                --read0
                --preview-window=bottom:40%:wrap
                --exact
                --scheme=history
                --reverse
                --no-sort
                --preview='echo {} | bat -l elv --color=always --style=plain'
        " | tr -d "\n") | slurp | str:trim-right (all) "\n")
    } catch {
        # pass
    }
}

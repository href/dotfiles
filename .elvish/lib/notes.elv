use path
use str

fn list {
    files = [(success = ?(ls -1t $E:NOTES/*.md))]

    if (not $success) {
        return
    }

    for f $files {
        echo (str:trim-suffix (path:base $f) ".md")
    }
}

fn edit [name]{
    subl $E:NOTES/$name".md"
}

fn vim [name]{
    e:vim $E:NOTES/$name".md"
}

fn rename [old new]{
    mv $E:NOTES/$old".md" $E:NOTES/$new".md"
}

fn remove [name]{
    rm $E:NOTES/$name".md"
}

fn show [name]{
    glow -w (- (tput cols) 1) -s ~/.dotfiles/glow-style.json $E:NOTES/$name".md"
}

edit:completion:arg-completer[notes:edit] = [@args]{list}
edit:completion:arg-completer[notes:rename] = [@args]{list}
edit:completion:arg-completer[notes:remove] = [@args]{list}
edit:completion:arg-completer[notes:show] = [@args]{list}

use str
use utils

icloud-path = ~"/Library/Mobile Documents/com~apple~CloudDocs"
sublime-path = ~"/Library/Application Support/Sublime Text 3"

brew-packages = [
    aria2
    bash
    bat
    curl
    figlet
    fzf
    git
    gnu-tar
    go
    goreleaser
    htop
    imagemagick
    jq
    nmap
    nodenv
    noti
    offlineimap
    pigz
    prettyping
    pup
    pv
    pyenv
    ripgrep
    rlwrap
    shellcheck
    vim
    watch
    w3m
    zsh
]

cask-packages = [
    1password
    alfred
    bitbar
    dash
    firefox
    google-chrome
    hammerspoon
    iterm2
    kaleidoscope
    little-snitch
    monodraw
    numi
    qlstephen
    quicklook-json
    sketch
    sublime-text
    sublime-merge
    transmit
    vagrant
    virtualbox
    viscosity
]

go-packages = [
    github.com/elves/elvish
]

python-releases = [
    3.6.10
    3.7.6
    3.8.1
]

pipx-packages = [
    cookiecutter
    csvkit
    flake8
    httpie
    pex
    shodan
    ansible-lint
]

dotfiles = [
    .elvish
    .hammerspoon
    .pdbrc
    .pdbrc.py
    .psqlrc
    .pythonrc
    .vimrc
]

servers = [
    home.href.ch
    recipes.href.ch
]

fn assert-prerequisites {
    if (not (utils:is-disk-encrypted)) {
        fail "Disk is not encrypted, please activate file vault first!"
    }

    if (not (has-external brew)) {
        fail "Homebrew is not installed, please install it first!"
    }

    if (utils:is-virtualenv-active) {
        fail "Cannot run in an activated virtual env!"
    }
}

fn ensure-symbolic-link [src dst]{
    if (not (utils:is-symbolic-link $dst)) {
        ln -s $src $dst
    }
}

fn setup-icloud-paths {
    ensure-symbolic-link $icloud-path ~/iCloud
    ensure-symbolic-link $icloud-path"/Sublime-Sync/Packages" $sublime-path"/Packages"
}

fn increase-default-file-limit {
    if (utils:is-path /Library/LaunchAgents/com.launchd.maxfiles.plist) {
        return
    }

    sudo /usr/libexec/PlistBuddy /Library/LaunchAgents/com.launchd.maxfiles.plist \
        -c "add Label string com.launchd.maxfiles" \
        -c "add ProgramArguments array" \
        -c "add ProgramArguments: string launchctl" \
        -c "add ProgramArguments: string limit" \
        -c "add ProgramArguments: string maxfiles" \
        -c "add ProgramArguments: string 10240" \
        -c "add ProgramArguments: string unlimited" \
        -c "add RunAtLoad bool true"

    sudo launchctl load /Library/LaunchAgents/com.launchd.maxfiles.plist
}

fn find-missing [new existing]{
    each [n]{
        if (not (has-value $existing $n)) {
            put $n
        }
    } $new
}

fn require-brew [@packages]{
    @existing = (brew list)
    @missing = (find-missing $packages $existing)

    if (eq (count $missing) 0) {
        return
    }

    brew install (explode $missing)
}

fn require-cask [@packages]{
    @existing = (brew cask list)
    @missing = (find-missing $packages $existing)

    if (eq (count $missing) 0) {
        return
    }

    brew cask install (explode $missing)
}

fn require-go [@packages]{
    each [p]{
        go get -u $p
    } $packages
}

fn require-python [@versions]{
    @existing = (pyenv versions --bare)
    @missing = (find-missing $versions $existing)

    each [version]{
        pyenv install $version
    } $missing

    pyenv global $versions[-1]
    pyenv rehash
}

fn require-pipx [@packages]{
    if (str:contains (pipx list | slurp) "nothing has been installed") {
        each [pkg]{ pipx install $pkg } $packages
    } else {
        @existing = (pipx list | grep package | awk '{print $2}')
        @missing = (find-missing $packages $existing)

        each [pkg]{ pipx install $pkg } $missing
    }
}

fn require-dotfiles [@dotfiles]{
    each [dotfile]{
        if (not ?(test -h ~/$dotfile)) {
            ln -sf ~/.dotfiles/$dotfile ~/$dotfile
        }
    } $dotfiles
}

fn configure-system {
    # disable windows reopen after restart by emptying and locking it
    bash -c 'find ~/Library/Preferences/ByHost/ -name "com.apple.loginwindow*" ! -size 0 -exec tee {} \; < /dev/null'
    bash -c 'find ~/Library/Preferences/ByHost/ -name "com.apple.loginwindow*" -exec chflags uimmutable {} \;'

    # no last-login message
    touch ~/.hushlogin

    # more available open files
    increase-default-file-limit

    # trackpad click by tab
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # full keyboard access for all controls
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    # key repeat
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    defaults write com.sublimetext.3 ApplePressAndHoldEnabled -bool false

    # ask for password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0

    # unhide library
    chflags nohidden ~/Library

    # bottom right corner for mission control
    defaults write com.apple.dock wvous-br-corner -int 2

    # disable natural scrolling
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    # show full url in safari
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
}

fn inline-up {
    assert-prerequisites
    setup-icloud-paths

    bullet = (styled '*' blue)

    echo $bullet" Configuring System"
    configure-system

    echo $bullet" Requiring Dotfiles"
    require-dotfiles $@dotfiles

    echo $bullet" Requiring XCode"
    nop ?(xcode-select --install stderr> /dev/null)

    echo $bullet" Requiring Brews"
    require-brew $@brew-packages

    echo $bullet" Requiring Casks"
    require-cask $@cask-packages

    echo $bullet" Requiring Python"
    require-python $@python-releases

    echo $bullet" Requiring Pip"
    pip install --upgrade pip --quiet

    echo $bullet" Requiring Pipx"
    require-pipx $@pipx-packages

    echo $bullet" Requiring Go"
    require-go $@go-packages

    echo $bullet" Updating Brews"
    brew update | sed '/Already up-to-date./d'
    brew upgrade | sed '/Already up-to-date./d'

    echo $bullet" Updating Casks"
    brew cask upgrade | sed '/==> No Casks to upgrade/d'

    echo $bullet" Updating Dotfiles"
    git -C ~/.dotfiles pull -q

    echo $bullet" Updating Pipx"
    pip install --upgrade pipx --quiet
    pipx upgrade-all | sed '/Versions did not change.*/d'

    echo $bullet" Syncing Quick Actions"
    rsync -rtu ~/iCloud/Services/* ~/Library/Services
    rsync -rtu ~/Library/Services/* ~/iCloud/Services

    echo $bullet" Upgrade Servers"
    each [host]{
        ssh $host sudo apt-get -qq update -y
        ssh $host sudo apt-get -qq upgrade -y
        ssh $host sudo apt-get -qq autoremove
    } $servers

    echo (styled "✔" green)" Done"
}

fn up {
    # run system:up in a separate process to always get the latest code
    elvish -c "use system; system:inline-up"
}

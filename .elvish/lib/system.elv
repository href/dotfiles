use str
use utils

icloud-path = ~"/Library/Mobile Documents/com~apple~CloudDocs"
sublime-path = ~"/Library/Application Support/Sublime Text 3"

brew-packages = [
    aria2
    bash
    bat
    curl
    encfs
    figlet
    findutils
    fswatch
    fzf
    fd
    exa
    git
    gnu-sed
    gnu-tar
    go
    htop
    imagemagick
    jo
    jq
    mas
    nmap
    noti
    offlineimap
    pigz
    prettyping
    pup
    pv
    pyenv
    rename
    ripgrep
    rlwrap
    rustup-init
    shellcheck
    syncthing
    vim
    w3m
    watch
]

cask-packages = [
    1password
    alfred
    bitbar
    dash
    docker
    firefox
    google-chrome
    gpg-suite-no-mail
    hammerspoon
    iterm2
    kaleidoscope
    keepassx
    little-snitch
    monodraw
    numi
    osxfuse
    pixelsnap
    qlstephen
    quicklook-json
    seafile-client
    slack
    sketch
    sublime-text
    sublime-merge
    transmit
    vagrant
    virtualbox
    viscosity
]

# use mas search /mas list to find out the proper number
apps = [
    "1039633667 Irvue"
    "1086818840 Rocket.Chat"
    "1091189122 Bear"
    "1099028591 Color Note"
    "1107421413 1Blocker"
    "1191449274 ToothFairy"
    "1384080005 Tweetbot"
    "1449412482 Reeder"
    "1470584107 Dato"
    "409183694 Keynote"
    "409201541 Pages"
    "409203825 Numbers"
    "414528154 ScreenFloat"
    "425424353 The Unarchiver"
    "429449079 Patterns"
    "456362093 MuteMyMic"
    "497799835 Xcode"
    "896450579 Textual IRC Client"
    "904280696 Things"
    "955848755 Theine"
    "964860276 Folder Designer"
]

go-packages = [
    github.com/elves/elvish
    github.com/twhiston/hk
    golang.org/x/tools/cmd/goimports
]

crates = [
    pyoxidizer
]

python-releases = [
    2.7.17
    3.6.10
    3.7.6
    3.8.1
]

pipx-packages = [
    cookiecutter
    csvkit
    flake8
    gitup
    httpie
    ipython
    pex
    shodan
    ansible-lint
]

dotfiles = [
    .elvish
    .gitconfig
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
    if (utils:is-path $icloud-path"/Sublime-Sync/Packages") {
	ensure-symbolic-link $icloud-path"/Sublime-Sync/Packages" $sublime-path"/Packages"
    }
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

fn require-apps [@packages]{
    require-brew mas

    @numbers = (each [app]{ splits " " $app | take 1 } $apps)
    @existing = (mas list | awk '{print $1}')
    @missing = (find-missing $numbers $existing)

    each [number]{
        mas install $number
    } $missing
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
    require-brew go

    each [p]{
        go get -u $p
    } $packages
}

fn require-crates [@crates]{
    if (not ?(test -e ~/.rustup)) {
        rustup-init -y --quiet
    }

    try {
        rustup update stderr>/dev/null | rg -v '^$' | rg -v unchanged
    } except {
        # pass
    }

    @existing = (cargo install --list | awk '{print $1}' | uniq)
    @missing = (find-missing $crates $existing)

    if (eq (count $missing) 0) {
        return
    }

    cargo install (explode $missing)
}

fn require-python [@versions]{
    require-brew pyenv

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

    # enable font smoothing
    defaults write -g CGFontRenderingFontSmoothingDisabled -bool YES

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

    # save username in viscosity, disable KeyChainSupport
    defaults write com.viscosityvpn.Viscosity RememberUsername -bool true
    defaults write com.viscosityvpn.Viscosity KeyChainSupport -bool false

    # disable user switching (only one user at a time)
    if (not-eq (defaults read /Library/Preferences/.GlobalPreferences MultipleSessionEnabled) '0') {
        echo "* Forcing one user at a time"
        sudo defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool NO
    }
}

fn inline-up {
    assert-prerequisites
    setup-icloud-paths

    blue = (styled '*' blue)
    yellow = (styled '*' yellow)
    green = (styled '*' green)

    echo $yellow" Configuring System"
    configure-system

    if (utils:is-path ~/iCloud/Services) {
        echo $yellow" Syncing Quick Actions"
        rsync -rtu ~/iCloud/Services/* ~/Library/Services
        rsync -rtu ~/Library/Services/* ~/iCloud/Services
    }

    echo $blue" Requiring Dotfiles"
    require-dotfiles $@dotfiles
    touch ~/.elvish/lib/private.elv
    chmod 0600 ~/.elvish/lib/private.elv

    echo $blue" Requiring Apps"
    require-apps $@apps

    echo $blue" Requiring Casks"
    require-cask $@cask-packages

    echo $blue" Requiring Brews"
    require-brew $@brew-packages

    echo $blue" Requiring Crates"
    require-crates $@crates

    echo $blue" Requiring XCode"
    nop ?(xcode-select --install stderr> /dev/null)

    echo $blue" Requiring Python"
    require-python $@python-releases

    echo $blue" Requiring Pip"
    pip install --upgrade pip --quiet
    pip install --upgrade pipx --quiet

    echo $blue" Requiring Pipx"
    require-pipx $@pipx-packages

    echo $blue" Requiring Go"
    require-go $@go-packages

    echo $green" Updating Brews"
    brew update | sed '/Already up-to-date./d'
    brew upgrade | sed '/Already up-to-date./d'

    echo $green" Updating Casks"
    brew cask upgrade | sed '/==> No Casks to upgrade/d'

    echo $green" Updating Appstore"
    mas upgrade | sed '/Everything is up-to-date/d'

    echo $green" Updating Pipx"
    pip install --upgrade pipx --quiet
    pipx upgrade-all | sed '/Versions did not change.*/d'

    echo $green" Fixing Virtualbox Crash"
    VBoxManage setextradata global GUI/HidLedsSync 0
}

fn up {
    # run system:up in a separate process to always get the latest code
    git -C ~/.dotfiles pull -q
    elvish -c "use system; system:inline-up"
}

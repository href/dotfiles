use str
use utils

var icloud-path = ~"/Library/Mobile Documents/com~apple~CloudDocs"
var sublime-path = ~"/Library/Application Support/Sublime Text 3"

var brew-taps = [
    melonamin/formulae
]

var brew-packages = [
    aria2
    bash
    bat
    broot
    curl
    dog
    encfs
    figlet
    findutils
    fswatch
    fzf
    fd
    exa
    glow
    git
    git-delta
    gnu-sed
    gnu-tar
    go
    htop
    imagemagick
    jo
    jq
    mas
    mtr
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
    sccache
    sd
    shellcheck
    stgit
    syncthing
    vim
    w3m
    watch
]

var cask-packages = [
    1password
    alfred
    bitbar
    cleanshot
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
    rocket-chat
    seafile-client
    slack
    sketch
    sublime-text
    sublime-merge
    swiftbar
    transmit
    vagrant
    virtualbox
    viscosity
]

# use mas search / mas list to find out the proper number
var apps = [
    "1039633667 Irvue"
    "1091189122 Bear"
    "1099028591 Color Note"
    "1107421413 1Blocker"
    "1191449274 ToothFairy"
    "1384080005 Tweetbot"
    "1449412482 Reeder"
    "1470584107 Dato"
    "1487937127 Craft - Docs and Notes Editor"
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

var go-packages = [
    github.com/nsf/gocode
    golang.org/x/lint/golint
    golang.org/x/tools/cmd/goimports
    golang.org/x/tools/cmd/guru
]

var crates = [
    jless
]

var python-releases = [
    2.7.18
    3.6.10  # upgrade to newer patch releases fails
    3.7.12
    3.8.12
    3.9.7
    3.10.0
]

var pipx-packages = [
    cookiecutter
    csvkit
    flake8
    gitup
    httpie
    ipython
    pex
    poetry
    shodan
    virtualenv
    visidata
]

var dotfiles = [
    .elvish
    .gitconfig
    .hammerspoon
    .pdbrc
    .pdbrc.py
    .psqlrc
    .pythonrc
    .vimrc
    .gitignore
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

fn ensure-symbolic-link {|src dst|
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

    sudo /usr/libexec/PlistBuddy /Library/LaunchAgents/com.launchd.maxfiles.plist ^
        -c "add Label string com.launchd.maxfiles" ^
        -c "add ProgramArguments array" ^
        -c "add ProgramArguments: string launchctl" ^
        -c "add ProgramArguments: string limit" ^
        -c "add ProgramArguments: string maxfiles" ^
        -c "add ProgramArguments: string 10240" ^
        -c "add ProgramArguments: string unlimited" ^
        -c "add RunAtLoad bool true"

    sudo launchctl load /Library/LaunchAgents/com.launchd.maxfiles.plist
}

fn is-empty {|list|
    eq (count $list) (num 0)
}

fn find-missing {|new existing|
    each {|n|
        if (not (has-value $existing $n)) {
            put $n
        }
    } $new
}

fn require-taps {|@taps|
    var @existing = (brew tap)
    var @missing = (find-missing $taps $existing)

    for tap $missing {
        brew $tap
    }
}

fn require-brew {|@packages|
    var @existing = (brew list --formula)
    var @missing = (find-missing $packages $existing)

    if (is-empty $missing) {
        return
    }

    brew install $@missing
}

fn require-apps {|@packages|
    require-brew mas

    var @numbers = (each {|app| str:split " " $app | take 1 } $apps)
    var @existing = (mas list | awk '{print $1}')
    var @missing = (find-missing $numbers $existing)

    for number $missing {
        mas install $number
    }
}

fn require-cask {|@packages|
    var @existing = (brew list --cask)
    var @missing = (find-missing $packages $existing)

    if (is-empty $missing) {
        return
    }

    brew install --cask $@missing
}

fn require-go {|@packages|
    require-brew go

    for package $packages {
        go install $package"@latest"
    }
}

fn require-crates {|@crates|
    if (not ?(test -e ~/.rustup)) {
        rustup-init -y --quiet
    }

    try {
        rustup update stderr>/dev/null | rg -v '^$' | rg -v unchanged
    } catch e {
        # pass
    }

    var @existing = (cargo install --list | awk '{print $1}' | uniq)
    var @missing = (find-missing $crates $existing)

    if (is-empty $missing) {
        return
    }

    cargo install $@missing
}

fn require-python {|@versions|
    require-brew pyenv

    var @existing = (pyenv versions --bare)
    var @missing = (find-missing $versions $existing)

    for v $missing {
        pyenv install $v
    }

    pyenv global $versions[-1]
    pyenv rehash
}

fn require-pipx {|@packages|
    if (str:contains (pipx list | slurp) "nothing has been installed") {
        each {|pkg| pipx install $pkg } $packages
    } else {
        var @existing = (pipx list | grep package | awk '{print $2}')
        var @missing = (find-missing $packages $existing)

        each {|pkg| pipx install $pkg } $missing
    }
}

fn require-dotfiles {|@dotfiles|
    each {|dotfile|
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

fn configure-bat {

    # Add Elvish syntax to bat
    var config-dir = (bat --config-dir)
    mkdir -p $config-dir/syntaxes

    curl -sL https://raw.githubusercontent.com/href/elvish_syntax_for_sublime/master/elvish.sublime-syntax ^
    > $config-dir/syntaxes/elvish.sublime-syntax

    bat cache --build > /dev/null
}

fn configure-broot {
    mkdir -p ~/.config/broot
    ensure-symbolic-link ~/.dotfiles/broot.hjson ~/.config/broot/conf.hjson
}

fn configure-cargo {
    mkdir -p ~/.cargo
    ensure-symbolic-link ~/.dotfiles/.cargo/config ~/.cargo/config
}

fn announce {|msg|
    echo (styled '*' blue)" "$msg
}

fn inline-up {
    assert-prerequisites
    setup-icloud-paths

    announce "Configuring System"
    configure-system

    if (utils:is-path ~/iCloud/Services) {
        announce "Syncing Quick Actions"
        rsync -rtu ~/iCloud/Services/* ~/Library/Services
        rsync -rtu ~/Library/Services/* ~/iCloud/Services
    }

    announce "Linking Dotfiles"
    require-dotfiles $@dotfiles

    touch ~/.elvish/lib/private.elv
    chmod 0600 ~/.elvish/lib/private.elv

    touch ~/.elvish/lib/internal.elv
    chmod 0600 ~/.elvish/lib/internal.elv

    announce "Requiring XCode"
    nop ?(xcode-select --install stderr> /dev/null)

    announce "Requiring Apps"
    require-apps $@apps

    announce "Requiring Taps"
    require-taps $@brew-taps

    announce "Requiring Casks"
    require-cask $@cask-packages

    announce "Requiring Brews"
    require-brew $@brew-packages

    announce "Requiring Crates"
    require-crates $@crates

    announce "Requiring Python"
    require-python $@python-releases

    announce "Requiring Python Packages"
    pip install --upgrade pip --quiet
    pip install --upgrade pipx --quiet
    require-pipx $@pipx-packages

    announce "Requiring Go Packages"
    require-go $@go-packages

    announce "Updating Brews"
    brew update
    brew upgrade

    announce "Updating Casks"
    brew upgrade --cask

    announce "Updating Apps"
    mas upgrade | sed '/Everything is up-to-date/d'

    announce "Updating Python Packages"
    pyenv rehash
    pip install --upgrade pipx --quiet
    pipx upgrade-all | sed '/Versions did not change.*/d' | sed '/upgrading.*/d'

    announce "Updating gitstatus"
    use github.com/href/elvish-gitstatus/gitstatus
    gitstatus:update

    announce "Configuring bat"
    configure-bat

    announce "Configuring broot"
    configure-broot

    announce "Configuring cargo"
    configure-cargo

    announce "Fixing Virtualbox Crash"
    VBoxManage setextradata global GUI/HidLedsSync 0
}

fn up {
    # run system:up in a separate process to always get the latest code
    git -C ~/.dotfiles pull -q
    elvish -c "use system; system:inline-up"
}

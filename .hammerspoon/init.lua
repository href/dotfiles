-- shortcut prefix
local mash = {"cmd", "alt", "ctrl"}

-- quick reload
hs.hotkey.bind(mash, "R", function()
    hs.alert.show("💾 reloading...")
    hs.reload()
end)

-- always start on boot
hs.autoLaunch(true)

-- no animations
hs.window.animationDuration = 0

-- disable non-breaking space everywhere
hs.hotkey.bind("alt", "space", function()
    hs.eventtap.keyStrokes(" ")
end)

-- enable IBM keyboard @
hs.hotkey.bind("alt", "2", function()
    hs.eventtap.keyStrokes("@")
end)

-- dependencies
local colums  = require 'columns'
local utils   = require 'utils'

-- custom layouts
local function macbook_layout()
    move = columns.move_application

    move('1Password 5', 'full')
    move('1Password 6', 'full')
    move('Aurora', 'full')
    move('Calendar', 'full')
    move('Mail', 'full')
    move('Dash', 'full')
    move('Finder', 'full')
    move('FirefoxDeveloperEdition', 'full')
    move('Franz', 'full')
    move('Google Chrome', 'full')
    move('HipChat', 'full')
    move('iTerm', 'full')
    move('iTerm2', 'full')
    move('iTunes', 'full')
    move('Notes', 'full')
    move('Monodraw', 'full')
    move('OmniFocus', 'full')
    move('Patterns', 'full')
    move('Reeder', 'full')
    move('Safari', 'full')
    move('Safari Technology Preview', 'full')
    move('Sketch', 'full')
    move('Spotify', 'full')
    move('Sublime Text', 'full')
    move('Telegram', 'full')
    move('YNAB 4', 'full')
end

local function office_layout()
    move = columns.move_application

    move('1Password 5', 'center')
    move('1Password 6', 'center')
    move('Aurora', 'middle-right')
    move('Calendar', 'center')
    move('Mail', 'center')
    move('Dash', 'center')
    move('Finder', 'center')
    move('FirefoxDeveloperEdition', 'center')
    move('Franz', 'center')
    move('Google Chrome', 'center')
    move('HipChat', 'center')
    move('iTerm', 'left')
    move('iTerm2', 'left')
    move('iTunes', 'center')
    move('Notes', 'center')
    move('Monodraw', 'center')
    move('OmniFocus', 'center')
    move('Patterns', 'center')
    move('Reeder', 'center')
    move('Safari', 'center')
    move('Safari Technology Preview', 'center')
    move('Sketch', 'full')
    move('Spotify', 'middle')
    move('Sublime Text', 'middle-right')
    move('Telegram', 'middle')
    move('YNAB 4', 'center')
end

local function get_layout()
    if utils.has_multiple_screens() then
        return 'office'
    else
        if utils.has_this_screen(2560, 1440) then
            return 'office'
        else
            return 'macbook'
        end
    end
end

local function apply_layout()
    if get_layout() == 'office' then
        office_layout()
    else
        macbook_layout()
    end

    utils.maximize_windows_horizontally(hs.window.allWindows())
end

-- apply the custom layout on start
apply_layout()

-- custom shortcuts
hs.hotkey.bind(mash, "PADENTER", apply_layout)
hs.hotkey.bind(mash, "RETURN", apply_layout)

function throttle(fn, seconds)
    last_run = hs.timer.secondsSinceEpoch()

    function execute(...)
        if (hs.timer.secondsSinceEpoch() - seconds) >= last_run then
            last_run = hs.timer.secondsSinceEpoch()
            return fn(...)
        end
    end

    return execute
end

function throttle_keypress(fn)
    return throttle(fn, 1)
end

function window_move(direction)
    local window = hs.window.focusedWindow()
    columns.move_window(window, direction)
    utils.maximize_window_horizontally(window)
end

function window_move_screen(direction)
    local window = hs.window.focusedWindow()

    if direction == 'right' then
        window:moveOneScreenEast()
    else
        window:moveOneScreenWest()
    end
end

hs.hotkey.bind(mash, "LEFT", function()
    window_move('left')
end, nil, throttle_keypress(function()
    window_move_screen('left')
end))

hs.hotkey.bind(mash, "UP", function()
    window_move('middle')
end, nil, throttle_keypress(function()
    window_move('full')
end))

hs.hotkey.bind(mash, "RIGHT", function()
    window_move('right')
end, nil, throttle_keypress(function()
    window_move_screen('right')
end))

hs.hotkey.bind(mash, "DOWN", function()
    window_move('center')
end, nil, throttle_keypress(function()
    window_move('middle-right')
end))

-- chrome screenshot resolution for github
hs.hotkey.bind(mash, "-", function()
    utils.set_window_resolution(hs.window.focusedWindow(), 1280, 960)
end)

-- apply the layout again when the screen changes
function on_screen_change()
    apply_layout()
end

hs.screen.watcher.new(on_screen_change):start()


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

-- dependencies
local colums  = require 'columns'
local utils   = require 'utils'

-- custom layouts
local function macbook_layout()
    move = columns.move_application

    move('1Password 5', 'full')
    move('Aurora', 'full')
    move('Dash', 'full')
    move('Finder', 'full')
    move('FirefoxDeveloperEdition', 'full')
    move('Google Chrome', 'full')
    move('Harvest', 'left')
    move('HipChat', 'full')
    move('iTerm', 'full')
    move('iTunes', 'full')
    move('Monodraw', 'full')
    move('OmniFocus', 'full')
    move('Patterns', 'full')
    move('Reeder', 'full')
    move('Spotify', 'full')
    move('Sublime Text', 'full')
    move('Telegram', 'full')
end

local function office_layout()
    move = columns.move_application

    move('1Password 5', 'middle')
    move('Aurora', 'middle-right')
    move('Dash', 'center')
    move('Finder', 'center')
    move('FirefoxDeveloperEdition', 'center')
    move('Google Chrome', 'center')
    move('Harvest', 'left')
    move('HipChat', 'center')
    move('iTerm', 'left')
    move('iTunes', 'center')
    move('Monodraw', 'center')
    move('OmniFocus', 'center')
    move('Patterns', 'center')
    move('Reeder', 'center')
    move('Spotify', 'middle')
    move('Sublime Text', 'middle-right')
    move('Telegram', 'middle')
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

hs.hotkey.bind(mash, "LEFT", function()
    columns.move_window(hs.window.focusedWindow(), 'left')
end)

hs.hotkey.bind(mash, "UP", function()
    columns.move_window(hs.window.focusedWindow(), 'middle')
end)

hs.hotkey.bind(mash, "RIGHT", function()
    columns.move_window(hs.window.focusedWindow(), 'right')
end)

hs.hotkey.bind(mash, "DOWN", function()
    columns.move_window(hs.window.focusedWindow(), 'center')
end)

-- chrome screenshot resolution for github
hs.hotkey.bind(mash, "-", function()
    utils.set_window_resolution(hs.window.focusedWindow(), 1280, 960)
end)

-- apply the layout again when the screen changes
function on_screen_change()
    apply_layout()
end

hs.screen.watcher.new(on_screen_change):start()


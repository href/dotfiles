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

-- layouts
local layouts = {}

layouts['large-screen'] = {}
layouts['large-screen']['1Password 7'] = 'center'
layouts['large-screen']['Calendar'] = 'center'
layouts['large-screen']['Mail'] = 'center'
layouts['large-screen']['Dash'] = 'center'
layouts['large-screen']['Kaleidoscope'] = 'center'
layouts['large-screen']['Finder'] = 'center'
layouts['large-screen']['Firefox'] = 'center'
layouts['large-screen']['Franz'] = 'center'
layouts['large-screen']['Google Chrome'] = 'center'
layouts['large-screen']['iTerm2'] = 'left'
layouts['large-screen']['iTunes'] = 'center'
layouts['large-screen']['Notes'] = 'center'
layouts['large-screen']['Monodraw'] = 'center'
layouts['large-screen']['OmniFocus'] = 'center'
layouts['large-screen']['Patterns'] = 'center'
layouts['large-screen']['Rambox'] = 'center'
layouts['large-screen']['Reeder'] = 'center'
layouts['large-screen']['Rocket.Chat'] = 'center'
layouts['large-screen']['Safari'] = 'center'
layouts['large-screen']['Sketch'] = 'full'
layouts['large-screen']['Spotify'] = 'middle'
layouts['large-screen']['Sublime Text'] = 'middle-right'
layouts['large-screen']['Sublime Merge'] = 'center'
layouts['large-screen']['Telegram'] = 'full'
layouts['large-screen']['Things'] = 'center'

layouts['small-screen'] = {}
layouts['small-screen']['1Password 7'] = 'full'
layouts['small-screen']['Calendar'] = 'full'
layouts['small-screen']['Kaleidoscope'] = 'full'
layouts['small-screen']['Mail'] = 'full'
layouts['small-screen']['Dash'] = 'full'
layouts['small-screen']['Finder'] = 'full'
layouts['small-screen']['Franz'] = 'full'
layouts['small-screen']['Google Chrome'] = 'full'
layouts['small-screen']['iTerm2'] = 'full'
layouts['small-screen']['iTunes'] = 'full'
layouts['small-screen']['Notes'] = 'full'
layouts['small-screen']['Monodraw'] = 'full'
layouts['small-screen']['OmniFocus'] = 'full'
layouts['small-screen']['Patterns'] = 'full'
layouts['small-screen']['Rambox'] = 'full'
layouts['small-screen']['Reeder'] = 'full'
layouts['small-screen']['Rocket.Chat'] = 'full'
layouts['small-screen']['Safari'] = 'full'
layouts['small-screen']['Sketch'] = 'full'
layouts['small-screen']['Spotify'] = 'full'
layouts['small-screen']['Sublime Text'] = 'full'
layouts['small-screen']['Sublime Merge'] = 'full'
layouts['small-screen']['Telegram'] = 'full'
layouts['small-screen']['Things'] = 'full'

layouts['small-screen-alt'] = hs.fnutils.copy(layouts['large-screen'])

layouts['large-screen-alt'] = hs.fnutils.copy(layouts['large-screen'])
layouts['large-screen-alt']['iTerm2'] = 'center'
layouts['large-screen-alt']['Sublime Text'] = 'left'

local function layout_suffix()
    mode = hs.settings.get('layout_mode')

    if mode == nil or mode == 'default' then
        return ''
    end

    return '-' .. mode
end

local function get_layout()
    if utils.has_multiple_screens() then
        return layouts['large-screen' .. layout_suffix()]
    else
        if utils.has_this_screen(2560, 1440) or utils.has_this_screen(3840, 2160) then
            return layouts['large-screen' .. layout_suffix()]
        else
            return layouts['small-screen' .. layout_suffix()]
        end
    end
end

local function apply_layout()
    for application, column in pairs(get_layout()) do
        columns.move_application(application, column)
    end

    utils.maximize_windows_horizontally(hs.window.allWindows())
end

local function apply_layout_for_application(application)
    local layout = get_layout()

    if layout[application] ~= nil then
        columns.move_application(application, layout[application])
    end
end

local function toggle_layout_mode()
    local mode = hs.settings.get('layout_mode')

    if mode == nil then
        mode = 'default'
    end

    if mode == 'default' then
        mode = 'alt'
    else
        mode = 'default'
    end

    hs.settings.set('layout_mode', mode)
    apply_layout()
end

-- apply the custom layout on start
apply_layout()

-- custom shortcuts
hs.hotkey.bind(mash, "PADENTER", apply_layout)
hs.hotkey.bind(mash, "RETURN", apply_layout)
hs.hotkey.bind(mash, "0", toggle_layout_mode)

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
    utils.set_window_resolution(hs.window.focusedWindow(), 1280, 1024)
end)

-- apply the layout again when the screen changes
function on_screen_change()
    apply_layout()
end

hs.screen.watcher.newWithActiveScreen(on_screen_change):start()

-- watch certain applications and apply the default window position to them
local enforced = hs.window.filter.new{'Sublime Text', 'Sublime Merge'}
enforced:subscribe(hs.window.filter.windowCreated, function(window, application, event)
    apply_layout_for_application(application)
    utils.maximize_window_horizontally(window)
end)

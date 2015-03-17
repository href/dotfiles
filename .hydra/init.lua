-- href's hydra config

-- always start on boot
autolaunch.set(true)

-- load dependencies
dofile(package.searchpath("update", package.path))
dofile(package.searchpath("utils", package.path))
dofile(package.searchpath("columns", package.path))

-- show a helpful menu
menu.show(function()
    local updatetitles = {[true] = "Install Update", [false] = "Check for Update..."}
    local updatefns = {[true] = updates.install, [false] = checkforupdates}
    local hasupdate = (updates.newversion ~= nil)

    return {
      {title = "Reload Config", fn = hydra.reload},
      {title = "Open Repl", fn = repl.open},
      {title = "-"},
      {title = "About", fn = hydra.showabout},
      {title = updatetitles[hasupdate], fn = updatefns[hasupdate]},
      {title = "Quit Hydra", fn = os.exit},
    }
end)

local function macbook_layout()
    move = ext.columns.move_application

    move('1Password 5', 'full')
    move('Aurora', 'full')
    move('Dash', 'full')
    move('Finder', 'full')
    move('FirefoxDeveloperEdition', 'full')
    move('Google Chrome', 'full')
    move('Harvest', 'left')
    move('HipChat', 'full')
    move('iTerm', 'full')
    move('Monodraw', 'full')
    move('OmniFocus', 'full')
    move('Patterns', 'full')
    move('Spotify', 'full')
    move('Sublime Text', 'full')
    move('Telegram', 'full')
end

local function office_layout()
    move = ext.columns.move_application

    move('1Password 5', 'middle')
    move('Aurora', 'middle-right')
    move('Dash', 'center')
    move('Finder', 'center')
    move('FirefoxDeveloperEdition', 'center')
    move('Google Chrome', 'center')
    move('Harvest', 'left')
    move('HipChat', 'center')
    move('iTerm', 'left')
    move('Monodraw', 'center')
    move('Omnifocus', 'center')
    move('Patterns', 'center')
    move('Spotify', 'middle')
    move('Sublime Text', 'middle-right')
    move('Telegram', 'middle')
end

local function apply_layout()
    if ext.utils.has_multiple_screens() then
        office_layout()
    else
        if ext.utils.has_this_screen(2560, 1440) then
            office_layout()
        else
            macbook_layout()
        end
    end

    ext.utils.maximize_windows_horizontally(window.allwindows())
end

-- apply layout on start
apply_layout()

-- shortcut prefix
local mash = {"cmd", "alt", "ctrl"}

-- setup keybindings
hotkey.bind(mash, "R", function()
    hydra.reload()
    hydra.alert("Config reloaded.")
end)

hotkey.bind(mash, "PAD_ENTER", apply_layout)

hotkey.bind(mash, "RETURN", apply_layout)

hotkey.bind(mash, "LEFT", function()
    ext.columns.move_window(window.focusedwindow(), 'left')
end)

hotkey.bind(mash, "UP", function()
    ext.columns.move_window(window.focusedwindow(), 'middle')
end)

hotkey.bind(mash, "RIGHT", function()
    ext.columns.move_window(window.focusedwindow(), 'right')
end)

hotkey.bind(mash, "DOWN", function()
    ext.columns.move_window(window.focusedwindow(), 'center')
end)

-- chrome screenshot resolution for github
hotkey.bind(mash, "-", function()
    ext.utils.set_window_resolution(window.focusedwindow(), 1280, 960)
end)
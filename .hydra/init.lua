-- href's hydra config

-- always start on boot
autolaunch.set(true)

-- load dependencies
hydra.douserfile('update')
hydra.douserfile('helpers')

-- shortcut prefix
local mash = {"cmd", "alt", "ctrl"}

-- have an easy way to reload the config
hotkey.bind(mash, "R", function()
    hydra.reload()
    hydra.alert("Config reloaded.")
end)

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

-- move the window to the right a bit, and make it a little shorter
hotkey.new({"cmd", "ctrl", "alt"}, "J", function()
    local win = window.focusedwindow()
    local frame = win:frame()
    frame.x = frame.x + 10
    frame.h = frame.h - 10
    win:setframe(frame)
end):enable()


local function one_monitor_layout()
    local push = push_application_to_column

    push('iTerm', 'full')
    push('Sublime Text 2', 'full')
    push('Google Chrome', 'full')
    push('Aurora', 'full')
    push('spotify', 'full')
end

local function two_monitor_layout()
    local push = push_application_to_column

    push('iTerm', 'left')
    push('Sublime Text 2', 'middle-right')
    push('Google Chrome', 'center')
    push('Aurora', 'full')
    push('Spotify', 'left')
end

local function apply_layout()
    if has_multiple_screens() then
        two_monitor_layout()
    else
        one_monitor_layout()
    end

    maximize_windows_horizontally(window.allwindows())
end

apply_layout()

hotkey.bind(mash, "RETURN", apply_layout)
hotkey.bind(mash, "PAD_ENTER", one_monitor_layout)
hotkey.bind(mash, "LEFT", function()
    push_window_to_column(window.focusedwindow(), 'left')
end)
hotkey.bind(mash, "UP", function()
    push_window_to_column(window.focusedwindow(), 'middle')
end)
hotkey.bind(mash, "RIGHT", function()
    push_window_to_column(window.focusedwindow(), 'right')
end)
hotkey.bind(mash, "DOWN", function()
    push_window_to_column(window.focusedwindow(), 'center')
end)
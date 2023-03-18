-- shortcut prefix
local mash = {"cmd", "alt", "ctrl"}
local hyper = { "cmd", "ctrl", "alt", "shift" }

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

-- yabai
local yabai = "/opt/homebrew/bin/yabai"

local function execYabai(args)
    local command = string.format("%s %s", yabai, args)
    print(string.format("yabai: %s", command))
    os.execute(command)
end

-- "directions" for vim keybindings
local directions = {
    h = "west",
    l = "east",
    k = "north",
    j = "south",
}
local opposite = {
    west = "east",
    east = "west",
    north = "north",
    south = "south",
}
for key, direction in pairs(directions) do
    -- focus windows
    -- cmd + ctrl
    hs.hotkey.bind(hyper, key, function()
        execYabai(string.format("-m window --focus %s", direction))
    end)
    -- swap windows
    -- alt + shift
    hs.hotkey.bind({ "shift", "alt" }, key, function()
        execYabai(string.format("-m window --swap %s", direction))
        execYabai(string.format("-m window --focus %s", opposite[direction]))
    end)
end

-- grow windows
hs.hotkey.bind({ "cmd", "shift" }, "h", function()
    execYabai(string.format("-m window --resize left:-100:0", direction))
end)
hs.hotkey.bind({ "cmd", "shift" }, "l", function()
    execYabai(string.format("-m window --resize right:100:0", direction))
end)

-- toggle settings
local toggleArgs = {
    f = "-m window --toggle zoom-fullscreen",
    r = "-m space --rotate 90",
    x = "-m space --mirror x-axis",
    y = "-m space --mirror y-axis",
}
for key, args in pairs(toggleArgs) do
    hs.hotkey.bind(hyper, key, function()
        execYabai(args)
    end)
end

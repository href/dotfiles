utils = {}

-- returns the number of elements in the given table
function utils.length(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

-- returns true if there's more than one screen
function utils.has_multiple_screens()
    return utils.length(hs.screen.allScreens()) > 1
end

-- returns true if there's a screen with the given dimensions
function utils.has_this_screen(width, height)
    for ix, screen in pairs(hs.screen.allScreens()) do
        local frame = screen:fullFrame()
        if frame.w == width and frame.h == height then
            return true
        end
    end

    return false
end

-- maximize the given windows horizontally (keeping them on their screen)
function utils.maximize_windows_horizontally(windows)
    for _, win in pairs(windows) do
        utils.maximize_window_horizontally(win)
    end
end

-- maximize a single window horizontally
function utils.maximize_window_horizontally(windows)
    local frame = windows:frame()
    local screen = windows:screen()

    if screen then
        if windows:title() ~= "Mini Player" then
            frame.y = windows:screen():frame().y
            frame.h = windows:screen():frame().h
            windows:setFrame(frame)
        end
    end
end

-- set the given windows to a specific resolution
function utils.set_window_resolution(win, width, height)
    local frame = win:frame()
    frame.w = width
    frame.h = height
    win:setFrame(frame)
end

return utils
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
        local frame = screen:frame()
        if frame.w == width and frame.h == height then
            return true
        end
    end

    return false
end

-- returns the windows of the given application
function utils.get_application_windows_by_name(name)
    local found = nil

    local windows = {}
    local wix = 0

    for ix, w in pairs(hs.window.allWindows()) do
        if w:application():title() == name then
            windows[wix] = w
            wix = wix + 1
        end
    end

    return windows
end

-- maximize the given windows horizontally (keeping them on their screen)
function utils.maximize_windows_horizontally(windows)
    for _, win in pairs(windows) do

        local frame = win:frame()
        local screen = win:screen()

        if screen then
            if win:title() ~= "MiniPlayer" then
                print(win:title())
                frame.y = win:screen():frame().y
                frame.h = win:screen():frame().h
                win:setFrame(frame)
            end
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
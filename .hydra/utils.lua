ext.utils = {}

-- returns the number of elements in the given table
function ext.utils.length(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

-- returns true if there's more than one screen
function ext.utils.has_multiple_screens()
    return ext.utils.length(screen.allscreens()) > 1
end

-- returns true if there's a screen with the given dimensions
function ext.utils.has_this_screen(width, height)
    for ix, screen in pairs(screen.allscreens()) do
        local frame = screen:frame()
        if frame.w == width and frame.h == height then
            return true
        end
    end

    return false
end

-- returns the windows of the given application
function ext.utils.get_application_windows_by_name(name)
    local found = nil

    local windows = {}
    local wix = 0

    for ix, w in pairs(window.allwindows()) do
        if w:application():title() == name then
            windows[wix] = w
            wix = wix + 1
        end
    end

    return windows
end

-- maximize the given windows horizontally (keeping them on their screen)
function ext.utils.maximize_windows_horizontally(windows)
    for _, win in pairs(windows) do
        local frame = win:frame()
        local screen = win:screen()

        if screen then
            frame.y = win:screen():frame_without_dock_or_menu().y
            frame.h = win:screen():frame_without_dock_or_menu().h

            win:setframe(frame)
        end        
    end
end

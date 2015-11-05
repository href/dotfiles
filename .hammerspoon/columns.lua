local utils = require 'utils'

columns = {}

-- return the exact coordinates for the grid on the given screen
function columns.get(s)
    local columns = {}

    columns['left'] = {
        w = s:frame().w / 100 * 27.5,
        x = 0
    }
    columns['center'] = {
        w = s:frame().w / 100 * 50,
        x = columns['left'].w
    }
    columns['middle'] = {
        w = (s:frame().w - columns['left'].w) / 2,
        x = columns['left'].w
    }
    columns['right'] = {
        w = s:frame().w - columns['left'].w - columns['middle'].w,
        x = columns['middle'].x + columns['middle'].w
    }
    columns['left-middle'] = {
        w = columns['left'].w + columns['middle'].w,
        x = 0
    }
    columns['middle-right'] = {
        w = columns['middle'].w + columns['right'].w,
        x = columns['left'].w
    }
    columns['full'] = {
        w = s:frame().w,
        x = 0
    }

    -- make sure the windows end up on the screen they already are
    local xoffset = s:frame().x

    for name, column in pairs(columns) do
        columns[name].x = columns[name].x + xoffset
    end

    return columns
end

-- move the given window to the given column
function columns.move_window(win, column)
    if win:title() ~= "MiniPlayer" then
        local columns = columns.get(win:screen())
        local frame = win:frame()

        frame.y = win:screen():frame().y
        frame.x = columns[column].x
        frame.w = columns[column].w

        win:setFrame(frame)
    end
end

-- move all windows of the given application to the given column
function columns.move_application(name, column)
    local app = hs.appfinder.appFromName(name)

    if app == nil then
        return
    end

    for _, window in pairs(app:allWindows()) do
        columns.move_window(window, column)
    end
end

return columns
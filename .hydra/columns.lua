require "utils"

ext.columns = {}

-- return the exact coordinates for the grid on the given screen
function ext.columns.get(s)
    local columns = {}

    print(s:frame_without_dock_or_menu().x)

    columns['left'] = {
        w = s:frame_without_dock_or_menu().w / 100 * 27.5,
        x = 0
    }
    columns['center'] = {
        w = s:frame_without_dock_or_menu().w / 100 * 50,
        x = columns['left'].w
    }
    columns['middle'] = {
        w = (s:frame_without_dock_or_menu().w - columns['left'].w) / 2,
        x = columns['left'].w
    }
    columns['right'] = {
        w = s:frame_without_dock_or_menu().w - columns['left'].w - columns['middle'].w,
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
        w = s:frame_without_dock_or_menu().w,
        x = 0
    }

    -- make sure the windows end up on the screen they already are
    local xoffset = s:frame_without_dock_or_menu().x

    for name, column in pairs(columns) do
        columns[name].x = columns[name].x + xoffset
    end

    return columns
end

-- move the given window to the given column
function ext.columns.move_window(win, column)
    local columns = ext.columns.get(win:screen())
    local frame = win:frame()

    frame.y = win:screen():frame_without_dock_or_menu().y
    frame.x = columns[column].x
    frame.w = columns[column].w

    win:setframe(frame)
end

-- move all windows of the given application to the given column
function ext.columns.move_application(name, column)
    for _, win in pairs(ext.utils.get_application_windows_by_name(name)) do
        ext.columns.move_window(win, column)
    end
end

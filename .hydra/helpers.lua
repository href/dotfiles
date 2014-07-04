function table_length(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function index_of_key(table, key)
    local count = 0
    for k, v in pairs(table) do
        count = count + 1

        if k == key then
            return ix
        end
    end

    return nil
end

function has_multiple_screens()
    return table_length(screen.allscreens()) > 1
end

function get_largest_screen()
    local screen_size = 0
    local largest_screen = 1
    local largest_screen_size = 0
    local all_screens = screen.allscreens()

    for ix, s in pairs(all_screens) do
        local screen_size = s:frame_without_dock_or_menu().w * s:frame_without_dock_or_menu().h
        if largest_screen_size < screen_size then
            largest_screen_size = screen_size
            largest_screen = ix
        end
    end

    return all_screens[largest_screen]
end

function get_application_windows_by_name(name)
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

function get_columns(s)
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
        w = (s:frame_without_dock_or_menu().w - columns['left'].w) / 10 * 6,
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

function push_window_to_column(win, column)
    local columns = get_columns(win:screen())
    local frame = win:frame()

    frame.y = win:screen():frame_without_dock_or_menu().y
    frame.x = columns[column].x
    frame.w = columns[column].w

    win:setframe(frame)
end

function push_application_to_column(name, column)
    for _, win in pairs(get_application_windows_by_name(name)) do
        push_window_to_column(win, column)
    end
end

function maximize_windows_horizontally(windows)
    for _, win in pairs(windows) do
        local frame = win:frame()
        
        frame.y = win:screen():frame_without_dock_or_menu().y
        frame.h = win:screen():frame_without_dock_or_menu().h

        win:setframe(frame)
    end
end
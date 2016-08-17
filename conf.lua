local width, height = 128, 96

function love.conf(t)
    t.window.width = width
    t.window.height = height
    t.window.minwidth = width
    t.window.minheight = height
    t.window.resizable = true

    t.console = true
end

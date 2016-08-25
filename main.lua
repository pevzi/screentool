local screentool = require "screentool"

local screen

local grid, quad

local function setScale(scale)
    local width, height = screen:setWindowSize(scale)

    local _, _, flags = love.window.getMode()

    -- center the window
    flags.x = nil
    flags.y = nil

    love.window.setMode(width, height, flags)
end

function love.load()
    local w, h = love.graphics.getDimensions()

    screen = screentool.newFixedScreen(w, h)

    grid = love.graphics.newImage("grid.png")
    grid:setWrap("repeat", "repeat")

    quad = love.graphics.newQuad(0, 0, w, h, grid:getDimensions())
end

function love.draw()
    screen:renderTo(function ()
        love.graphics.draw(grid, quad)
    end)

    screen:draw()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    else
        local scale = tonumber(key)

        if scale and scale > 0 then
            setScale(scale)
        end
    end
end

function love.resize(width, height)
    screen:setWindowSize(width, height)
end

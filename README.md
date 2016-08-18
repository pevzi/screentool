# screentool

screentool is a small library that helps making fixed-resolution games using LÖVE framework. It manages scaling and positioning your game screen within an arbitrarily sized window and provides pixel-perfect rendering.

Note that this library doesn't change the actual window resolution so you have to call `love.window.setMode` yourself.

## Example

```lua
local screentool = require "screentool"

local screen

function love.load()
    screen = screentool.newFixedScreen(128, 96)

    local windowWidth, windowHeight = screen:setWindowSize(2) -- X2 scaling

    love.window.setMode(windowWidth, windowHeight, {
        minwidth = screen:getWidth(),
        minheight = screen:getHeight(),
        resizable = true
    })
end

function love.draw()
    screen:renderTo(function ()
        local mx, my = screen:toGame(love.mouse.getPosition())
        love.graphics.circle("fill", mx, my, math.min(screen:getDimensions()) / 4)
    end)

    screen:draw()
end

function love.resize(w, h)
    screen:setWindowSize(w, h)
end
```

## API

### `screentool.newFixedScreen(width, height, scalingMode)`

Creates a new `FixedScreen` instance. The default value for `scalingMode` is `"floor"` (see `FixedScreen:setScalingMode` for details).

### `FixedScreen:set()`

Sets the canvas as active and clears it. Must be called before any drawing operations related to the game.

### `FixedScreen:unset()`

Sets the previously active canvas. Must be called after all game drawing operations.

### `FixedScreen:renderTo(func)`

Sets the canvas as active, clears it, calls the provided function and then sets the previously active canvas. Can be used instead of the `set`/`unset` pair.

### `FixedScreen:draw()`

Draws the canvas to the actual screen applying all the necessary transformations.

### `FixedScreen:setScalingMode(scalingMode)`

Sets `scalingMode` as the scaling mode for the screen. Accepted values are:

- `"fit"` - fits the game into the window preserving proportions but not necessarily keeping pixels equal
- `"floor"` - uses the biggest possible integer multiplier for scaling and centers the game within the window

### `FixedScreen:getScalingMode()`

Returns the current scaling mode.

### `FixedScreen:setWindowSize(windowWidth, windowHeight)`

Sets the size of the window to fit the game screen into. Should be called in `love.resize` callback and after using `love.window.setMode` with arbitrary width and height.

### `FixedScreen:setWindowSize(multiplier)`

Sets the window size as a multiple of the game size. Returns the new window width and height which then should be used as arguments to `love.window.setMode`.

### `FixedScreen:updateTransformations()`

Updates the canvas position and scaling according to the window size and current scaling mode. This method is called automatically when using `setWindowSize` or `setScalingMode` and doesn't have to be called manually.

### `FixedScreen:toGame(x, y)`

Converts the given point from window coordinates to game coordinates.

### `FixedScreen:toWindow(x, y)`

Converts the given point from game coordinates to window coordinates.

### `FixedScreen:getWidth()`

Returns the game width.

### `FixedScreen:getHeight()`

Returns the game height.

### `FixedScreen:getDimensions()`

Returns the game width and height.

### `FixedScreen:getCanvas()`

Returns the canvas.

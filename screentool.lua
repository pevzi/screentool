local lg = love.graphics

local function assertScalingMode(scalingMode)
    assert(scalingMode == "fit" or scalingMode == "floor",
        ('wrong scaling mode: %q, expected "fit" or "floor"'):format(scalingMode))
    return scalingMode
end

local function clamp(x, min, max)
    if x > max then
        return max
    elseif x < min then
        return min
    end

    return x
end

local function round(x)
    return math.floor(x + 0.5)
end

local function centerRect(width, height, l,t,w,h)
    local x = l + (w - width) / 2
    local y = t + (h - height) / 2

    return x, y
end

local function fitRect(width, height, l,t,w,h, floor)
    local wratio = w / width
    local hratio = h / height

    local scale

    if wratio > hratio then
        scale = hratio
    else
        scale = wratio
    end

    if floor then
        scale = math.floor(scale)
    end

    -- XXX: suffers from a floating point error given some numbers (a / b * b ~= a)
    --      it's probably better to handle the non-floor case independently to avoid extraneous calculations
    local x, y = centerRect(width * scale, height * scale, l,t,w,h)

    return x, y, scale
end

local FixedScreen = {}
FixedScreen.__index = FixedScreen

local function newFixedScreen(width, height, scalingMode)
    local self = setmetatable({}, FixedScreen)

    self.width = width
    self.height = height
    self.scalingMode = assertScalingMode(scalingMode or "fit")

    self.windowWidth, self.windowHeight = lg.getDimensions()

    self:updateTransformations()

    self.canvas = lg.newCanvas(width, height)
    self.canvas:setFilter("nearest", "nearest")

    return self
end

function FixedScreen:set()
    local previousCanvas = lg.getCanvas()

    assert(previousCanvas ~= self.canvas, "the screen is already active")

    self.previousCanvas = previousCanvas
    lg.setCanvas(self.canvas)
    lg.clear()
end

function FixedScreen:unset()
    assert(lg.getCanvas() == self.canvas, "the screen isn't active")

    lg.setCanvas(self.previousCanvas)
    self.previousCanvas = nil
end

function FixedScreen:renderTo(func)
    local previousCanvas = lg.getCanvas()

    assert(previousCanvas ~= self.canvas, "the screen is already active")

    lg.setCanvas(self.canvas)
    lg.clear()
    func()
    lg.setCanvas(previousCanvas)
end

function FixedScreen:draw()
    lg.draw(self.canvas, self.x, self.y, 0, self.scale)
end

function FixedScreen:updateTransformations()
    local x, y, scale = fitRect(self.width, self.height,
        0, 0, self.windowWidth, self.windowHeight,
        self.scalingMode == "floor")

    self.x, self.y, self.scale = round(x), round(y), scale
end

function FixedScreen:getScalingMode()
    return self.scalingMode
end

function FixedScreen:setScalingMode(scalingMode)
    self.scalingMode = assertScalingMode(scalingMode)

    self:updateTransformations()
end

function FixedScreen:resize(w, h)
    self.windowWidth = w
    self.windowHeight = h

    self:updateTransformations()
end

function FixedScreen:toGame(x, y)
    return clamp((x - self.x) / self.scale, 0, self.width),
           clamp((y - self.y) / self.scale, 0, self.height)
end

function FixedScreen:toWindow(x, y)
    return x * self.scale + self.x,
           y * self.scale + self.y
end

function FixedScreen:getWidth()
    return self.width
end

function FixedScreen:getHeight()
    return self.height
end

function FixedScreen:getDimensions()
    return self.width, self.height
end

function FixedScreen:getCanvas()
    return self.canvas
end

return {
    newFixedScreen = newFixedScreen
}

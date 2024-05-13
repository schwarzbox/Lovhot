-- Fri Apr 24 21:09:39 2020
-- (c) Aliaksandr Veledzimovich

-- start HOT
-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local set = dofile('game/set.lua')

local Start = {tag='Start', objects={}, nobj=0, stop=false}
function Start.new() end

function Start.getNumObjects()
    return Start.nobj
end

function Start.label(text, x, y, clr, px, py, size)
    px = px or 0
    py = py or 0
    size = size or 14
    local wid = love.graphics.newFont(size):getWidth(text)
    local hei = love.graphics.newFont(size):getHeight()
    love.graphics.setFont(love.graphics.newFont(size))
    love.graphics.setColor(clr)
    love.graphics.print(text, x - wid * px, y - hei * py)
    love.graphics.setColor({1, 1, 1, 1})
end

function Start.update(dt) end

function Start.draw()
    Start.label(
        'Press Space to Start',
        set.MIDWID,
        set.MIDHEI,
        set.GRAY,
        0.5,
        0.5
    )
end

return Start

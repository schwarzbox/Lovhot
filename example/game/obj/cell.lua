-- Fri Apr 24 21:09:03 2020
-- (c) Aliaksandr Veledzimovich

-- cell HOT
-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local hot = require('lib/lovhot')
local set = dofile('game/set.lua')

local Object = dofile('game/obj/object.lua')

local cnt = 0
local Cell = Object:new{tag='Cell', y=set.MIDHEI + 196}
function Cell:new(o)
    self = Object.new(self, o)

    -- Tag to track state
    self.tag = self.tag..tostring(cnt)
    cnt = cnt + 1

    -- Track state
    hot.state(self.tag, self, 'x', 'y', 'vel')

    return self
end

function Cell:update(dt)
    self:setColor(
        {math.random(), math.random(), math.random(), math.random()}
    )

    local rx = math.random() * 2 - 1
    local ry = math.random() * 2 - 1

    self:applyForce(rx * self.speed,ry * self.speed)

    self:move(dt)

    self:applyDamp(dt)

    self:edge()
end

function Cell:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.wid)
    love.graphics.setColor(set.WHITE)
end

return Cell

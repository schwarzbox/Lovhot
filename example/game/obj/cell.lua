-- Fri Apr 24 21:09:03 2020
-- (c) Alexander Veledzimovich

-- cell HOT
-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local hot = require('lib/lovhot')
local set = dofile('game/set.lua')

local Object = dofile('game/obj/object.lua')
local Cell = Object:new{tag='Cell',y=set.MIDHEI+196}

function Cell:update(dt)
    -- self:setPosition(set.MIDWID,set.MIDHEI)
    self:setColor({math.random(),math.random(),math.random(),math.random()})

    local rx = math.random()*2-1
    local ry = math.random()*2-1
    self:applyForce(rx*self.speed,ry*self.speed)

    self:move(dt)

    self:applyDamp(dt)

    self:edge()

    -- save state
    self.hd.vx=self.vel.x
    self.hd.vy=self.vel.y
    self.hd.x=self.x
    self.hd.y=self.y
end

function Cell:draw()
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', self.x,self.y,self.wid)
    love.graphics.setColor(set.WHITE)
end

return Cell

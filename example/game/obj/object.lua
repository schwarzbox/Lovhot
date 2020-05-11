-- Tue Apr 28 15:50:51 2020
-- (c) Alexander Veledzimovich

-- object HOT
-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local hot = require('lib/lovhot')
local set = dofile('game/set.lua')

local Object = {tag='Object'}
local cnt = 0
function Object:new(o)
    o = o or {}
    self.__index = self
    self=setmetatable(o, self)

    -- init table for save hot data with same uniq key
    self.hd = hot.data(self.tag..tostring(cnt))
    cnt = cnt + 1


    self.x = self.hd.x or o.x or set.MIDWID
    self.y = self.hd.y or o.y or set.MIDHEI
    self.wid = o.wid or 4
    self.hei = o.hei or 4
    self.scale = o.scale or {x=set.SCALE[1],y=set.SCALE[2]}
    self.color = o.color or {1,1,1,1}

    self.speed = o.speed or 100
    self.damp = o.damp or 0.5
    self.mass = self.wid * self.hei

    self.vel = {x=self.hd.vx or 0, y=self.hd.vy or 0}
    self.acc = {x=0,y=0}
    return self
end

function Object:setPosition(x,y)
    self.x = x
    self.y = y
end

function Object:setColor(color)
    self.color = color
end

function Object:setSpeed(sp)
    self.speed = sp
end

function Object:setDamp(dmp)
    self.damp = dmp
end

function Object:setScale(scx, scy)
    self.scale.x = scx or self.scale.x
    self.scale.y = scy or self.scale.y
end

function Object:applyDamp(dt)
    local dmp = self.damp*dt
    self.vel.x = self.vel.x - self.vel.x * dmp
    self.vel.y = self.vel.y - self.vel.y * dmp
end

function Object:applyForce(fx,fy)
    fx = fx / self.mass
    fy = fy / self.mass
    self.acc.x = self.acc.x + fx
    self.acc.y = self.acc.y + fy
end

function Object:move(dt)
    self.vel.x = self.vel.x + self.acc.x * dt
    self.vel.y = self.vel.y + self.acc.y * dt

    self.x = self.x + self.vel.x
    self.y = self.y + self.vel.y

    self.acc = {x=0,y=0}
end

function Object:edge()
    if self.x>set.WID then self.x = 0
    elseif self.x<0 then self.x = set.WID
    elseif self.y<0 then self.y = 0
    elseif self.y>set.HEI then self.y = set.HEI
    end
end

function Object:update(dt)

end

function Object:draw()

end

return Object

-- Fri Apr 24 21:09:03 2020
-- (c) Aliaksandr Veledzimovich

-- tnt HOT

local unpack = table.unpack or unpack
local utf8 = require('utf8')

local set = dofile('game/set.lua')

local tntimg = love.graphics.newImage('res/img/tnt.png')
local twid = tntimg:getWidth()
local thei = tntimg:getHeight()
local tpivot = {twid/2, thei/2}

local bdata = love.image.newImageData('res/img/bik.png')
local bimg = love.graphics.newImage(bdata)
local bwid = bimg:getWidth()
local bhei = bimg:getHeight()
local bpivot = {bwid/2, bhei/2}


local function createTexture(sx, sy, form)
    sx = sx or 1
    sy = sy or 1
    form = form or 'circle'
    local forms = {
        circle=function()
            love.graphics.circle('fill', sx/2, sy/2, sx/2)
        end,
        rectangle=function()
            love.graphics.rectangle('fill', 0, 0, sx, sy)
        end
    }
    local canvas = love.graphics.newCanvas(sx, sy)
    love.graphics.setCanvas(canvas)
    forms[form]()
    love.graphics.setCanvas()
    local data = canvas:newImageData()
    return data
end

local function paintPixels(imgdata,px,py,color)
    local sx, sy = imgdata:getDimensions()
    local data = love.image.newImageData(sx, sy)
    for x=1, sx do
        for y=1, sy do
            local r,g,b,a = imgdata:getPixel(x - 1, y - 1)
            local clr = {r, g, b, a}
            if (r > 0 or g > 0 or b > 0 or a > 0) and (x < px or y < py)
            then
                clr = color
            end
            data:setPixel((x - 1),(y - 1), unpack(clr))
        end
    end
    return data
end

local fireimg = love.graphics.newImage(createTexture(3, 1, 'rectangle'))
local bomimg = love.graphics.newImage('res/img/boom.png')
local bomwid = bomimg:getWidth()
local bomhei = bomimg:getHeight()


local Object = dofile('game/obj/object.lua')

local Tnt = Object:new{
    tag='Tnt',
    cnt=0,
    x=set.MIDWID,
    y=set.MIDHEI+64,
    wid=twid,
    hei=thei,
    pivot=tpivot,
    color=set.GRAY,
    particles={}
}
function Tnt:new(o)
    self = Object.new(self, o)

    self.dead = false

    self.fx = self.x-bpivot[1]
    self.fy = self.y-tpivot[2]

    self.initAnim = {x=self.fx - 2, y=self.fy - bpivot[2]}
    self.initFire = love.graphics.newParticleSystem(fireimg, 8192)

    self.initFire:setPosition(self.initAnim.x, self.initAnim.y)

    self.initFire:setColors(
        set.RED, set.ORANGE, set.ORANGE0, set.GRAY, set.WHITE0
    )
    self.initFire:setSpread(math.pi * 2)

    self.initFire:setSizes(0.1, 0.4, 0.6, 0.8, 1, 0.6, 0.4, 0.1)
    self.initFire:setSizeVariation(1)

    self.initFire:setSpeed(-50, 50)
    self.initFire:setLinearAcceleration(-100, 100, 100, -100)

    self.initFire:setTangentialAcceleration(-40, 80)
    self.initFire:setRotation(3)
    self.initFire:setSpin(-4, 4)
    self.initFire:setSpinVariation(1)
    self.initFire:setParticleLifetime(0.5, 1.5)

    self.boomFire = love.graphics.newParticleSystem(bomimg, 1024)
    self.boomFire:setPosition(self.x,self.y-42)
    self.boomFire:setEmissionArea('ellipse', 64, 64, 0)
    self.boomFire:setColors(set.WHITE0,set.WHITE64, set.WHITE0)
    self.boomFire:setSpread(math.pi * 2)
    self.boomFire:setSizes(0.1, 0.2, 3, 0.2, 0.1)
    self.boomFire:setSizeVariation(1)
    self.boomFire:setSpeed(500, 1000)
    self.boomFire:setTangentialAcceleration(-500, 500)

    self.boomFire:setSpin(-2, 2)
    self.boomFire:setSpinVariation(1)
    self.boomFire:setParticleLifetime(0.1, 2)

    local q1 = love.graphics.newQuad(0, 0, 64, 100, bomwid, bomhei)
    local q2 = love.graphics.newQuad(64, 0, 64, 100, bomwid, bomhei)
    local q3 = love.graphics.newQuad(128, 0, 64, 100, bomwid, bomhei)

    self.boomFire:setQuads(q3,q1,q2)

    self.tmr = {
        ntmr=0,
        timers={},
        add=function(s, timer,...)
            local tmr = s[timer](...)
            s.timers[tmr] = tmr
            s.ntmr = s.ntmr + 1
        end,
        update=function(s, dt)
            for tmr in pairs(s.timers) do
                local done = tmr(dt)
                if done then
                    s.timers[tmr] = nil
                    s.ntmr = s.ntmr - 1
                end
            end
        end,
        after=function(sec, finally)
            return function(t)
                if sec>0 then
                    sec = sec - t
                    return false
                end
                finally()
                return true
            end
        end,
        tween = function(sec, tab, key, goal, finally)
            finally = finally or function() end
            local diff = math.abs(goal - tab[key]) / (sec * 60)
            local speed = tab[key] < goal and diff or -diff
            return function(t)
                if sec>0 then sec = sec - t
                    tab[key] = tab[key] + speed
                    return false
                end
                finally()
                return true
            end
        end
    }

    return self
end

function Tnt:update(dt)
    self.tmr:update(dt)

    for particle in pairs(self.particles) do
        particle:update(dt)
        if particle:getCount() == 0 then
            particle:reset()
            self.particles[particle] = nil
        end
    end

    self.initFire:moveTo(self.initAnim.x, self.initAnim.y)

    local data = paintPixels(
        bdata,
        math.abs(self.fx - 2 - self.initAnim.x),
        math.abs(self.fy - bpivot[2] - self.initAnim.y),
        set.GRAY64
    )
    bimg:replacePixels(data)
end

function Tnt:boom()
    self.notnt = true
    self.boomFire:emit(600)
    self.particles[self.boomFire] = self.boomFire
    self.tmr:add('after', 2, function() self.dead = true end)
end

function Tnt:destroy()
    self.tmr:add(
        'tween',
        2,
        self.initAnim,
        'x',
        self.initAnim.x + 4,
        function() self:boom() end
    )
    self.tmr:add(
        'tween',
        2,
        self.initAnim,
        'y',
        self.initAnim.y + 64,
        function() self:boom() end
    )

    self.particles[self.initFire] = self.initFire
    self.initFire:setEmitterLifetime(2)
    self.initFire:setEmissionRate(800)
end

function Tnt:draw()
    if not self.notnt then
        love.graphics.draw(
            tntimg, self.x, self.y, 0, 1, 1, unpack(self.pivot)
        )
        love.graphics.draw(
            bimg, self.fx, self.fy, 0, 1, 1, unpack(bpivot)
        )
    end

    for particle in pairs(self.particles) do
        love.graphics.draw(particle)
    end
    love.graphics.setColor(set.WHITE)
end

return Tnt

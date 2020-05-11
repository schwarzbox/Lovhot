-- Fri Apr 24 21:09:39 2020
-- (c) Alexander Veledzimovich

-- end HOT
-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')


local hot = require('lib/lovhot')
local set = require('game/set')

local End = {tag='End', objects={}, nobj=0, stop=false}
function End.new()

end

function End.getNumObjects()
    return End.nobj
end

function End.label(text, x, y, clr, px, py, size)
    px = px or 0
    py = py or 0
    size = size or 14
    local wid = love.graphics.newFont(size):getWidth(text)
    local hei = love.graphics.newFont(size):getHeight()
    love.graphics.setFont(love.graphics.newFont(size))
    love.graphics.setColor(clr)
    love.graphics.print(text, x-wid*px,y-hei*py)
    love.graphics.setColor({1,1,1,1})
end

function End.update(dt)

end

function End.draw()
    End.label('Game Over',set.MIDWID,set.MIDHEI,
              set.WHITE,0.5,0.5)
    End.label('Press Space to Restart',set.MIDWID,set.MIDHEI+32,
              set.GRAY,0.5,0.5)
end


return End

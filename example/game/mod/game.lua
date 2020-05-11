-- Fri Apr 24 21:09:39 2020
-- (c) Alexander Veledzimovich

-- game HOT
-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local hot = require('lib/lovhot')

-- local Cell = dofile('game/obj/cell.lua')
local Tnt = dofile('game/obj/tnt.lua')
local Game = {tag='Game', objects={}, nobj=0, stop=false}
function Game.new()
    -- for _=1,220 do
        -- Game.addObject(Cell:new())
    -- end
    Game.tnt = Tnt:new()
    Game.addObject(Game.tnt)
end

function Game.addObject(obj)
    Game.nobj = Game.nobj + 1
    Game.objects[obj]=obj
end

function Game.getNumObjects()
    return Game.nobj
end

function Game.update(dt)
    -- local cnt = 0
    -- for _,_ in pairs(hot.datatab) do
    --     cnt=cnt+1
    -- end
    -- print(cnt)
    for object in pairs(Game.objects) do
        object:update(dt)
        if object.tag=='Tnt' then Game.stop = object.dead end

    end

end
function Game.draw()
    for object in pairs(Game.objects) do
        object:draw()
    end
end

return Game

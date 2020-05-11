-- Sun Apr 26 00:10:23 2020
-- (c) Alexander Veledzimovich

-- root HOT
-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local hot = require('lib/lovhot')

-- use dofile for all files which you want to hotswap
local set = dofile('game/set.lua')

local Start = dofile('game/mod/start.lua')
local Game = dofile('game/mod/game.lua')
local End = dofile('game/mod/end.lua')

local Root = {tag='Root', models={}, active=nil}
function Root.load()
    Root.addModel(Start)
    Root.addModel(Game)
    Root.addModel(End)

    -- init table for save hot data with same uniq key
    Root.hd = hot.data(Root.tag)
    local active = Root.hd.active or Start.tag
    Root.activate(active)
end

function Root.addModel(mod)
    Root.models[mod.tag] = mod
end

function Root.activate(tag)
    Root.active = Root.models[tag]
    Root.active.new()
    Root.hd.active = tag
end

function Root.getActiveObjects()
    return Root.active.getNumObjects()
end

function Root.update(dt)
    local title = string.format('%s %s fps %.2d active %.3d',
                            set.APPNAME, set.VER, love.timer.getFPS(),
                            Root.getActiveObjects())
    love.window.setTitle(title)
    Root.active.update(dt)

    if Root.active==Game and Root.active.stop then
        Root.activate(End.tag)
    end
end

function Root.draw()
    Root.active.draw()
end

function Root.keypressed(key,unicode,isrepeat)

end

function Root.keyreleased(key,unicode)
    if Root.active == Start then
        if key=='space' then
            Root.activate(Game.tag)
        end
    elseif Root.active == Game then
        local tnt = Root.active.tnt
        if key=='space' then
            tnt:destroy()
        end
    elseif Root.active == End then
        if key=='space' then
            Root.activate(Start.tag)
        end
    end
end

function Root.mousepressed(x,y,button,istouch) end
function Root.mousereleased(x,y,button,istouch) end
function Root.mousemoved(x,y,dx,dy,istouch) end
function Root.wheelmoved(x, y) end

return Root

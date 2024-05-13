-- Sun Apr 26 00:10:23 2020
-- (c) Aliaksandr Veledzimovich

-- root HOT
-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local hot = require('lib/lovhot')
-- Use require game/set use love.window.getTitle() and duplicate title
local set = require('game/set')

-- Use dofile for all files which you want to hot swap
local Start = dofile('game/mod/start.lua')
local Game = dofile('game/mod/game.lua')
local End = dofile('game/mod/end.lua')

local Root = {tag='Root', models={}, acttag=nil, active=nil}
function Root.load()
    Root.addModel(Start)
    Root.addModel(Game)
    Root.addModel(End)

    -- Tag to track state
    Root.acttag = Start.tag
    -- Track state
    hot.state(Root.tag, Root, 'acttag')

    Root.activate(Root.acttag)
end

function Root.addModel(mod)
    Root.models[mod.tag] = mod
end

function Root.activate(tag)
    Root.acttag = tag
    Root.active = Root.models[Root.acttag]
    Root.active.new()
end

function Root.getActiveObjects()
    return Root.active.getNumObjects()
end

function Root.update(dt)
    local title = string.format(
        '%s %s fps %.2d active %.3d',
        set.APPNAME,
        set.VER,
        love.timer.getFPS(),
        Root.getActiveObjects()
    )
    love.window.setTitle(title)
    Root.active.update(dt)

    if Root.active.tag == Game.tag and Root.active.stop then
        Root.activate(End.tag)
    end
end

function Root.draw()
    Root.active.draw()
end

function Root.keypressed(key, unicode, isrepeat) end

function Root.keyreleased(key, unicode)
    if Root.active.tag == Start.tag then
        if key=='space' then
            Root.activate(Game.tag)
        end
    elseif Root.active.tag == Game.tag then
        local tnt = Root.active.tnt
        if key == 'space' and not tnt.dead then
            tnt:destroy()
        end
    elseif Root.active.tag == End.tag then
        if key == 'space' then
            Root.activate(Start.tag)
        end
    end
end

function Root.mousepressed(x, y, button, istouch) end
function Root.mousereleased(x, y, button, istouch) end
function Root.mousemoved(x, y, dx, dy, istouch) end
function Root.wheelmoved(x, y) end
function Root.focus(f) end
function Root.mousefocus(f) end
function Root.resize(w, h) end
function Root.textedited(t, start, length) end
function Root.textinput(t) end
function Root.filedropped(file) end
function Root.visible(v) end
function Root.quit() end

return Root

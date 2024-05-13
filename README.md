# Lovhot

v1.1

Lovhot is a Hot Swap System.

System allows hot reload.

User have to save objects state in the `_state` table with function `Hot.state`.

System tested in MacOS and use shell commands "ls" and "stat".

Made with LÖVE

To run source code: clone repository, download & install [LÖVE 11.5](https://love2d.org) for your system.

Engine: [LÖVE Development Team](https://love2d.org/)

Code: [Aliaksandr Veledzimovich](https://twitter.com/veledzimovich)

# Example

Copy lovhot.lua to the project dir.

main.lua

``` lua
io.stdout:setvbuf('no')

local hot = require('lovhot')

-- Entry point to load Hot Swap System
function love.load()
    love.window.setPosition(0,0)
    -- By default hot swap disabled for main.lua and conf.lua
    -- After root.lua you can provide files to disable hot swap
    hot.load('root.lua')
end
```

Create root.lua as entry point for hot reload and game logic.

In this example root.lua used as scene manager.

root.lua
``` lua
local hot = require('lib/lovhot')
-- Use dofile for all files which you want to hot swap
local Game = dofile('game.lua')

local Root = {
    tag='Root', models={}, activetag=nil, active=nil
}
-- Called by Hot Swap System
function Root.load()
    Root.addModel(Game)

    -- Tag to track state
    Root.activetag = Game.tag
    -- Track state of the Root object
    hot.state(Root.tag, Root, 'activetag')

    Root.activate(Root.activetag)
end

function Root.addModel(mod) Root.models[mod.tag] = mod end

function Root.activate(tag)
    Root.acttag = tag
    Root.active = Root.models[tag]
    Root.active.new()
end
-- Called by Hot Swap System
function Root.update(dt)
    love.window.setTitle(Root.tag)
    Root.active.update(dt)
end
-- Called by Hot Swap System
function Root.draw()
    Root.active.draw()
end

function Root.keyreleased(key, unicode)
   if Root.active == Game then
        local ball = Root.active.ball
        if key == 'space' then
            ball.speed = 10
        end
    end
end

return Root
```

game.lua
``` lua
local Ball = dofile('ball.lua')

local Game = {
    tag='Game', objects={}
}
function Game.new()
    Game.ball = Ball
    Game.addObject(Ball)
end

function Game.addObject(obj) Game.objects[obj] = obj end

function Game.update(dt)
    for object in pairs(Game.objects) do
        object.update(dt)
    end

end

function Game.draw()
    for object in pairs(Game.objects) do
        object.draw()
    end
end

return Game
```

ball.lua
``` lua
local hot = require('lovhot')

local Ball = {
    tag='Ball', x=400, y=300, speed=100, color={1, 0, 0, 1}
}
-- Track state of the Ball object
hot.state(Ball.tag, Ball, 'x', 'y')

function Ball.update(dt)
    Ball.x = Ball.x - Ball.speed * dt
end

function Ball.draw()
    love.graphics.setColor(Ball.color)
    love.graphics.circle('fill', Ball.x, Ball.y, 10)
end

return Ball
```

# Warning

Check game structure in the `example` dir.

![Screenshot](screenshot/screenshot1.png)

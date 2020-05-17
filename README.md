# LOVHOT-LÖVE

Hot Swap System for Love2d.

v0.55

# Example

Copy lovhot.lua to the project folder

main.lua

``` lua
io.stdout:setvbuf('no')

local Hot = require('lovhot')

function love.load()
    love.window.setPosition(0,0)
    -- create root.lua as entry point for hot reload and for all game logic
    -- after root.lua provide excluded files except main.lua and conf.lua (opt)
    Hot.load('game/root.lua')
end

```
root.lua

``` lua
-- use dofile for all files which you want to hotswap
local Game = dofile('game.lua')

local Root = {tag='Root', models={}, active=nil}
function Root.load()
    Root.addModel(Game)
    Root.activate('Game')
end

function Root.addModel(mod) Root.models[mod.tag] = mod end

function Root.activate(tag)
    Root.active = Root.models[tag]
    Root.active.new()
end

function Root.update(dt)
    love.window.setTitle(Root.tag)
    Root.active.update(dt)
end

function Root.draw()
    Root.active.draw()
end

function Root.keyreleased(key,unicode)
   if Root.active == Game then
        local ball = Root.active.ball
        if key=='space' then
            ball.speed=0
        end
    end
end

return Root
```
game.lua
``` lua
local Ball = dofile('ball.lua')

local Game = {tag='Game', objects={}}
function Game.new()
    Game.ball = Ball
    Game.addObject(Game.ball)
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

local Ball = {tag='Ball',x=400,y=300,speed=100,color={1,0,0,1}}
-- save state to the table that never hotswaped
Ball.hd = hot.data(Ball.tag)
Ball.x=Ball.hd.x or Ball.x
Ball.y=Ball.hd.y or Ball.y

function Ball.update(dt)
    Ball.x = Ball.x+Ball.speed*dt
    -- update saved state
    Ball.hd.x = Ball.x
    Ball.hd.y = Ball.y

end
function Ball.draw()
    love.graphics.setColor(Ball.color)
    love.graphics.circle('fill',Ball.x,Ball.y,10)
end

return Ball
```

# Warning

See complex example in example dir
For perfect result use same structure for your project as provided in example

![Screenshot](screenshot/screenshot1.png)


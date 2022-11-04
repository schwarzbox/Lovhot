#!/usr/bin/env love
-- HOT
-- 1.0
-- Game (love2d)

-- main.lua

-- MIT License
-- Copyright (c) 2020 Alexander Veledzimovich veledz@gmail.com

-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

io.stdout:setvbuf('no')

local Hot = require('lib/lovhot')

function love.load()
    love.window.setPosition(0,0)
    -- create game/root.lua as entry point for hot reload
    -- after game/root.lua provide excluded files except main.lua and conf.lua
    Hot.load('game/root.lua')
end

function love.update(dt)
    -- fix temporary bug with cloned title in root.lua
    love.window.setTitle('')

end
function love.draw()
end

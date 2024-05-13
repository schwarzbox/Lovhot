#!/usr/bin/env love
-- LOVHOT
-- 1.1
-- Hot Swap System (love2d)
-- lovhot.lua

-- MIT License
-- Copyright (c) 2024 Aliaksandr Veledzimovich veledz@gmail.com

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

-- 1.2
-- use love filesystem


if arg[1] then print('1.0 LOVHOT Hot Swap System (love2d)', arg[1]) end

-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

-- constants
local WHITE = {1, 1, 1, 1}
local SYNTAXCLR = {0.1, 1, 0.1, 1}
local RUNTIMECLR = {1, 0.1, 0.1, 1}
local TRACECLR = {0.9, 1, 0.1, 1}
local FUNC = function(...) end
local EVENTS = {
    'update',
    'draw',
    'keypressed',
    'keyreleased',
    'mousepressed',
    'mousereleased',
    'mousemoved',
    'wheelmoved',
    'focus',
    'mousefocus',
    'resize',
    'textedited',
    'textinput',
    'filedropped',
    'visible',
    'quit'
}

-- settings
love.filesystem.setSymlinksEnabled(true)

-- private functions
local function ext(path)
    return path:match('[^.]+$')
end

local function name(path)
    return path:match('[^/]+$')
end

local function allfiles(dir, except, array)
    dir = dir or ''
    except = except or {}
    array = array or {}

    local out = io.popen('ls '..dir, 'r')
    local files = out:read('*a'):gmatch('[%w._]+')
    out:close()

    for path in files do
        if #dir > 0 then
            path = dir..'/'..path
        end

        local info = love.filesystem.getInfo(path)
        if info and info.type == 'file' and not except[path] then
            if ext(path) == 'lua' and name(path) ~= 'lovhot.lua' then
                array[#array + 1] = path
            end
        elseif info and info.type == 'directory' then
            allfiles(path, except, array)
        end
    end
    return array
end

local function label(text, x, y, clr, px, py, size)
    px = px or 0
    py = py or 0
    size = size or 14
    local wid = love.graphics.newFont(size):getWidth(text)
    local hei = love.graphics.newFont(size):getHeight()
    love.graphics.setFont(love.graphics.newFont(size))
    love.graphics.setColor(clr)
    love.graphics.print(text, x - wid * px, y - hei * py)
    love.graphics.setColor({1, 1, 1, 1})
end

-- hot
-- if use weak values system sometimes delete objects
local meta = {}
-- local meta = {__mode='k'}
-- local meta = {__mode='v'}
local Hot = {
    swap=false,
    swaptime=0,
    root={},
    rootfile='',
    _exclude={},
    _statcmd='',
    _calls={},
    _catch={syntax=false},
    _runtimetrace={},
    _syntaxtrace='',
    -- _state is a singleton used for save state
    _state=setmetatable({}, meta)
}
function Hot.load(rootfile, ...)
    Hot.rootfile = rootfile
    Hot.root = dofile(Hot.rootfile)
    Hot.root.load()

    local argf = {...}
    Hot._exclude = {
        ['main.lua']='main.lua',
        ['conf.lua']='conf.lua'
    }

    for i=1, #argf do
        local file = argf[i]
        Hot._exclude[file] = file
    end

    Hot._statcmd = Hot.statcmd()

    Hot._calls = {}
    Hot.callbacks()
    Hot.savecalls()
end


function Hot.state(tag, tab, ...)
    local argf = {...}
    local saved = Hot._state[tag]
    if saved then
        for i=1, #argf do
            local key = argf[i]
            tab[key] = saved[key]
        end
    end
    Hot._state[tag] = tab
end

function Hot.statcmd()
    local filetree = allfiles('', Hot._exclude)
    local cmd = 'stat -f "%m%n" '

    for _, path in pairs(filetree) do
        cmd = cmd..' '..path
    end
        cmd = cmd..' 2>&1'

    return cmd
end

function Hot.callbacks()
    local default = {}
    for _, event in pairs(EVENTS) do

        if event ~= 'update' and event ~= 'draw' then
            Hot[event] = function(...)
                Hot.root[event] = Hot.root[event] or FUNC
                Hot.root[event](...)
            end
        end

        default[event] = love[event] or FUNC
        love[event] = function(...)
            local output = {default[event](...)}

            if #output > 0 then
                local xcall, xout = xpcall(
                    Hot[event], Hot.runtimetrace, unpack(output)
                )
                if not xcall then
                    if not Hot._catch[event] then
                        io.write(xout..'\n')
                    end
                    Hot._catch[event] = true
                    Hot.loadcalls(event)
                end
            else
                local xcall, xout = xpcall(
                    Hot[event], Hot.runtimetrace, ...
                )
                if not xcall then
                    if not Hot._catch[event] then
                        io.write(xout..'\n')
                    end
                    Hot._catch[event] = true
                    Hot.loadcalls(event)
                end
            end
        end
    end
end

function Hot.update(dt)
    Hot.hotswap()
    Hot.root.update(dt)
end

function Hot.draw()
    Hot.warning()
    Hot.root.draw()
end

function Hot.runtimetrace(err)
    Hot._runtimetrace[#Hot._runtimetrace + 1] = err
    return debug.traceback(err)
end

function Hot.syntaxtrace(err)
    Hot._syntaxtrace = err
    return debug.traceback(err)
end

function Hot.savecalls()
    for _, event in pairs(EVENTS) do
        Hot._calls[event] = love[event]
        Hot._catch[event] = false
    end
end

function Hot.loadcalls(ev)
    if ev then
        love[ev] = Hot._calls[ev]
    else
        for _, event in pairs(EVENTS) do
            love[event] = Hot._calls[event]
        end
    end
end

function Hot.restore(file, oldroot)
    io.write('LOVHOT: '..file..'\n')

    Hot.savecalls()

    local xcall, xout = xpcall(dofile, Hot.syntaxtrace, file)

    if xcall then
        Hot._catch.syntax = false
        return xout
    else
        Hot._catch.syntax = true
        io.write(xout..'\n')
        Hot.loadcalls()
        return oldroot
    end
end

function Hot.hotswap()
    local now = os.time()

    if now <= Hot.swaptime then return end

    Hot.swap = false

    local out = io.popen(Hot._statcmd, 'r')
    local modtime = out:read('*a')
    out:close()

    modtime:gsub('(%w+)',
        function(w)
            local ctime = tonumber(w)
            if now == ctime and not Hot.swap then
                Hot.swaptime = now
                Hot.swap = true
            end
            return
        end
    )

    if Hot.swap then
        Hot._statcmd = Hot.statcmd()
        Hot.root = Hot.restore(Hot.rootfile, Hot.root)
        Hot.root.load()
    end
end

function Hot.warning()
    local row = 0
    local hei = 16

    for key, err in pairs(Hot._catch) do
        local clr
        local lab
        local message
        if err then
            if key == 'syntax' then
                clr = SYNTAXCLR
                lab = 'Syntax'
                message = Hot._syntaxtrace
            else
                clr = RUNTIMECLR
                lab = 'Runtime'
                message = table.remove(Hot._runtimetrace, 1)
            end

             if message then
                love.graphics.setColor(clr)
                love.graphics.circle('fill', 8, row * hei + 8, 4)
                label(lab..' Error: ', 16, row * hei, clr)
                row = row + 1
                label(message, 16, row * hei, TRACECLR, 0, 0, 12)
                row = row + 1
            end
        end
    end
    love.graphics.setColor(WHITE)
end


return Hot

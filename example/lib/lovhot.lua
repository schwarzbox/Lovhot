#!/usr/bin/env love
-- LOVHOT
-- 0.55
-- Hot Swap System (love2d)
-- lovhot.lua

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

-- 0.6
-- look for new file try with require lovhot

-- title bug
-- initial errors

-- 0.7
-- fennel?
-- require get all locals
-- reg pack (__index)

if arg[1] then print('0.55 LOVHOT Hot Swap System (love2d)', arg[1]) end

-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local WHITE = {1,1,1,1}
local SYNTAXCLR = {0.1,1,0.1,1}
local RUNCLR = {1,0.1,0.1,1}
local TRACECLR = {0.9,1,0.1,1}
local FN = function(...) end

-- private functions
local function ext(path)
    return path:match('[^.]+$')
end

local function name(path)
    return path:match('[^/]+$')
end

local function allfiles(dir,except,arr)
    dir = dir or ''
    except = except or {}
    arr = arr or {}
    local files = love.filesystem.getDirectoryItems(dir)
    for i=1, #files do
        local path = files[i]
        if #dir>0 then
            path = dir..'/'..files[i]
        end
        if love.filesystem.getInfo(path).type=='file' and not except[path] then
            if ext(path)=='lua' and name(path)~='lovhot.lua' then
                arr[#arr+1] = path
            end
        elseif love.filesystem.getInfo(path).type=='directory' then
            allfiles(path,except,arr)
        end
    end
    return arr
end

local function label(text, x, y, clr, px, py, size)
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

-- if use weak values system sometime delete objects
-- local meta = {__mode = 'k'}
-- local meta = {__mode = 'v'}

-- datatab table(singleton) used for hot data
local meta = {}
local Hot = {swap=false, swaptime=0,
            root={}, rootfile='', exclude={}, command='',
            catch = {syntax=false}, trace="",
            datatab = setmetatable({}, meta)}

local events = {
    'update', 'draw',
    'keypressed', 'keyreleased', 'mousepressed', 'mousereleased',
    'mousemoved', 'wheelmoved', 'focus', 'mousefocus',
    'resize', 'textedited', 'textinput', 'filedropped', 'visible', 'quit'
}

function Hot.load(rootfile, ...)
    Hot.rootfile = rootfile
    Hot.root = dofile(Hot.rootfile)
    Hot.root.load()

    local argf = {...}
    Hot.exclude = {['main.lua']='main.lua', ['conf.lua']='conf.lua'}

    for i=1,#argf do
        local file = argf[i]
        Hot.exclude[file] = file
    end
    Hot.command = Hot.search()

    Hot.calls = {}
    Hot.callbacks()
    Hot.savecalls()
end

function Hot.data(key)
        print(Hot.datatab[key])
    Hot.datatab[key] = Hot.datatab[key] or {}

    return  Hot.datatab[key]
end

function Hot.search()
    local filetree = allfiles('', Hot.exclude)
    local command = 'stat -f "%m%n" '
    for _,v in pairs(filetree) do
        command=command..' '..v
    end
    command=command..' 2>&1'
    return command
end

function Hot.callbacks()
    local default = {}
    for _,event in pairs(events) do

        if event~='update' and event~='draw' then
            Hot[event] = function(...)
                Hot.root[event]=Hot.root[event] or FN
                Hot.root[event](...)
            end
        end

        default[event] = love[event] or FN
        love[event] = function(...)
            local output = {default[event](...)}

            if #output>0 then
                local xcall, xout = xpcall(Hot[event],
                                           Hot.traceback, unpack(output))
                if not xcall then
                    if not Hot.catch[event] then
                        io.write(xout..'\n')
                    end
                    Hot.catch[event] = true
                    Hot.loadcalls(event)
                end
                return unpack(output)
            else
                local xcall, xout = xpcall(Hot[event],
                                           Hot.traceback,...)
                if not xcall then
                    if not Hot.catch[event] then
                        io.write(xout..'\n')
                    end
                    Hot.catch[event] = true
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

function Hot.traceback(err)
    Hot.trace = err
    return debug.traceback(err)
end


function Hot.savecalls()
    for _, event in pairs(events) do
        Hot.calls[event]=love[event]
        Hot.catch[event]=false
    end
end

function Hot.loadcalls(ev)
    if ev then
        love[ev]=Hot.calls[ev]
    else
        for _, event in pairs(events) do
            love[event]=Hot.calls[event]
        end
    end
end

function Hot.restore(file, oldroot)
    io.write('LOVHOT: '..file..'\n')

    Hot.savecalls()

    local xcall, xout = xpcall(dofile, Hot.traceback, file)

    if (xcall) then
        Hot.catch.syntax = false
        return xout
    else
        Hot.catch.syntax = true
        io.write(xout..'\n')
        Hot.loadcalls()
        return oldroot
    end
end

function Hot.hotswap()
    local now = os.time()

    if now <= Hot.swaptime then return end

    Hot.swap = false

    local out = io.popen(Hot.command,'r')
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
                end)

    if Hot.swap then
        Hot.root = Hot.restore(Hot.rootfile, Hot.root)
        Hot.root.load()
    end
end

function Hot.warning()
    for k,err in pairs(Hot.catch) do
        local clr
        local lab
        if err then
            if k=='syntax' then
                clr = SYNTAXCLR
                lab = 'Syntax'
            else
                clr = RUNCLR
                lab = 'Runtime'
            end
            love.graphics.setColor(clr)
            love.graphics.circle('fill', 8,8,4)
            label(lab..' Error: ',16,0,clr)
            label(Hot.trace,16,16,TRACECLR,0,0,12)
        end
    end
    love.graphics.setColor(WHITE)
end

return Hot

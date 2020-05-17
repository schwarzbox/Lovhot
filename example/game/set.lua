-- Fri Apr 24 21:09:39 2020
-- (c) Alexander Veledzimovich

-- set HOT

-- lua<5.3
local utf8 = require('utf8')
local unpack = table.unpack or unpack

local SET = {
    APPNAME = love.window.getTitle(),
    VER = '0.55',
    SAVE = 'hotsave.lua',
    FULLSCR = love.window.getFullscreen(),
    WID = love.graphics.getWidth(),
    HEI = love.graphics.getHeight(),
    MIDWID = love.graphics.getWidth() / 2,
    MIDHEI = love.graphics.getHeight() / 2,
    SCALE = {1,1},
    DELAY = 0.3,
    BOX2D = false,

    EMPTY = {0,0,0,0},

    WHITE = {1,1,1,1},
    WHITE64 = {1,1,1,64/255},
    WHITE32 = {1,1,1,32/255},
    WHITE16 = {1,1,1,16/255},
    WHITE0 = {1,1,1,0},

    BLACK = {0,0,0,1},
    RED = {1,0,0,1},
    RED0 = {1,0,0,0},
    YELLOW = {1,1,0,1},
    YELLOW0 = {1,1,0,0},
    GREEN = {0,1,0,1},
    GREEN0 = {0,1,0,0},
    BLUE = {0,0,1,1},
    BLUE0 = {0,0,1,0},

    DARKGRAY = {32/255,32/255,32/255,1},
    DARKGRAY0 = {32/255,32/255,32/255,0},
    GRAY = {0.5,0.5,0.5,1},
    GRAY64 = {0.5,0.5,0.5,64/255},
    GRAY32 = {0.5,0.5,0.5,32/255},
    GRAY16 = {0.5,0.5,0.5,16/255},
    GRAY0 = {0.5,0.5,0.5,0},
    LIGHTGRAY = {192/255,192/255,192/255,1},
    LIGHTGRAY0 = {192/255,192/255,192/255,0},

    DARKRED = {128/255,0,0,1},
    DARKRED0 = {128/255,0,0,0},
    ORANGE = {1,0.5,0,0.5},
    ORANGE0 = {1,0.5,0,0},

    -- Vera Sans
    MAINFNT = nil
}

SET.CANWID = SET.WID
SET.CANHEI = SET.HEI
SET.CANMIDWID = SET.CANWID/2
SET.CANMIDHEI = SET.CANHEI/2

SET.TITLEFNT = {SET.MAINFNT,64}
SET.MENUFNT = {SET.MAINFNT,32}
SET.GAMEFNT = {SET.MAINFNT,16}
SET.UIFNT = {SET.MAINFNT,8}

SET.BGCLR =  SET.BLACK
SET.TXTCLR = SET.WHITE
return SET

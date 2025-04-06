-- Below is a small example program where you can move a circle
-- around with the crank. You can delete everything in this file,
-- but make sure to add back in a playdate.update function since
-- one is required for every Playdate game!
-- =============================================================

-- Importing libraries used for drawCircleAtPoint and crankIndicator
import "CoreLibs/graphics"
import "CoreLibs/ui"

import "patterns"


-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics

local CENTER = 200
local GLOBAL_ANGLE = 0
local GLOBAL_HEIGHT = 0


myInputHandlers = {
    upButtonDown = function()
        moveUp = true
    end,
    upButtonUp = function()
        moveUp = false
    end,
    downButtonDown = function()
        moveDown = true
    end,
    downButtonUp = function()
        moveDown = false
    end,
    leftButtonDown = function()
        moveLeft = true
    end,
    leftButtonUp = function()
        moveLeft = false
    end,
    rightButtonDown = function()
        moveRight = true
    end,
    rightButtonUp = function()
        moveRight = false
    end,
    AButtonDown = function()
    end,
    AButtonUp = function()
    end,
    BButtonDown = function()
        
    end,
    BButtonUp = function()
    end,
    cranked = function(change, acceleratedChange)
        crankChange = change
        delta = crankChange
        print(math.floor(delta))
    end
}
playdate.inputHandlers.push(myInputHandlers)

-- Defining player variables
local playerSize = 10
local halfPlayerSize = playerSize/2
local playerVelocity = 1
local playerX, playerY = 200, 120

-- Defining platform size
local platformWidth = 20
local halfPlatformWidth = platformWidth/2
local platformHeight = 10

local sin, cos, pi, rad, floor  = math.sin, math.cos, math.pi, math.rad, math.floor

-- Drawing player image
local playerImage = gfx.image.new(playerSize, playerSize)
gfx.pushContext(playerImage)
    -- -- Draw outline
    -- gfx.drawRoundRect(4, 3, 24, 26, 1)
    -- -- Draw screen
    -- gfx.drawRect(7, 6, 18, 12)
    -- -- Draw eyes
    -- gfx.drawLine(10, 12, 12, 10)
    -- gfx.drawLine(12, 10, 14, 12)
    -- gfx.drawLine(17, 12, 19, 10)
    -- gfx.drawLine(19, 10, 21, 12)
    -- -- Draw crank
    -- gfx.drawRect(27, 15, 3, 9)
    -- -- Draw A/B buttons
    -- gfx.drawCircleInRect(16, 20, 4, 4)
    -- gfx.drawCircleInRect(21, 20, 4, 4)
    -- -- Draw D-Pad
    -- gfx.drawRect(8, 22, 6, 2)
    -- gfx.drawRect(10, 20, 2, 6)

    gfx.drawCircleAtPoint(halfPlayerSize,halfPlayerSize,halfPlayerSize)
gfx.popContext()

-- Drawing platform image
local platformFrontImage = gfx.image.new(platformWidth, platformWidth)
gfx.pushContext(platformFrontImage)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(0, 0, platformWidth, platformHeight, 1)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 1, platformWidth, 1)
gfx.popContext()

-- Defining helper functions
local function ring(value, min, max)
	if (min > max) then
		min, max = max, min
	end
	return min + (value - min) % (max - min)
end

local function isFront(value)
    return cos(rad(value * 12 + GLOBAL_ANGLE )) > 0
end

local function map(tbl, func)
    local t = {}
    for key,value in pairs(tbl) do
        t[key] = func(value)
    end
    return t
end

local platformsArray = {
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,1,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,1,1,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1},
    {1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0},
    {1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1},
    {0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, -- 1 screen
    {0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    
}
 

-- playdate.update function is required in every project!
function playdate.update()
    -- Clear screen
    gfx.clear()
    -- Draw crank indicator if crank is docked
    if pd.isCrankDocked() then
        pd.ui.crankIndicator:draw()
    else
        -- Calculate velocity from crank angle 
        local crankPosition = pd.getCrankPosition()
        local xVelocity = math.cos(rad(crankPosition)) * playerVelocity
        -- local yVelocity = math.sin(rad(crankPosition)) * playerVelocity
        -- Move player
        GLOBAL_ANGLE += xVelocity
        -- playerY += yVelocity
        -- Loop player position
        -- playerX = ring(playerX, -playerSize, 400 + playerSize)
        -- playerY = ring(playerY, -playerSize, 240 + playerSize)
    end
    -- GLOBAL_ANGLE += 1
    -- GLOBAL_HEIGHT += 1
    if GLOBAL_ANGLE == 360 then GLOBAL_ANGLE = 0 end
    if GLOBAL_HEIGHT == 300 then GLOBAL_HEIGHT = 0 end

    -- Draw text
    gfx.drawTextAligned(floor(GLOBAL_ANGLE % 8), 200, 30, kTextAlignment.center)
    -- Draw player

    

    gfx.setPattern(patterns['bricks'..floor(GLOBAL_ANGLE%8 )])
    gfx.fillRect(0, 0, 400, 240)

    
    gfx.setPattern(patterns['grayscale5'])
    gfx.fillEllipseInRect(200, 0, 50, 100)
    

    for i, row in ipairs(platformsArray) do
        for ii, platform in ipairs(row) do 
            if (platform == 1 ) then 
                local xPos = CENTER + (sin(rad(ii * 12 + GLOBAL_ANGLE )) * 100)
                local front = isFront(ii)
                
                if( front ) then
                    platformFrontImage:drawAnchored(xPos , 250 - i * 10 + GLOBAL_HEIGHT, 0.5, 0.5)                    
                end
            end
        end    
    end

    playerImage:drawAnchored(playerX, playerY, 0.5, 0.5)

    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 110, 240)
    gfx.fillRect(290, 0, 110, 240)


end
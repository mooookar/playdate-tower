-- Below is a small example program where you can move a circle
-- around with the crank. You can delete everything in this file,
-- but make sure to add back in a playdate.update function since
-- one is required for every Playdate game!
-- =============================================================

-- Importing libraries used for drawCircleAtPoint and crankIndicator
import "CoreLibs/graphics"
import "CoreLibs/ui"

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics

local CENTER = 200
local GLOBAL_ANGLE = 0

-- Defining player variables
local playerSize = 10
local halfPlayerSize = playerSize/2
local playerVelocity = 1
local playerX, playerY = 200, 120

-- Defining platform size
local platformWidth = 24
local halfPlatformWidth = platformWidth/2
local platformHeight = 10

local sin, cos, pi, rad  = math.sin, math.cos, math.pi, math.rad

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
gfx.popContext()

local platformBackImage = gfx.image.new(platformWidth, platformWidth)
gfx.pushContext(platformBackImage)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRoundRect(0, 0, platformWidth, platformHeight, 1)
gfx.popContext()

local platformsArray = {
   {1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1},
   {1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1},
}


-- Defining helper function
local function ring(value, min, max)
	if (min > max) then
		min, max = max, min
	end
	return min + (value - min) % (max - min)
end

local function isFront(value)
    return cos(rad(value * 12 + GLOBAL_ANGLE )) > 0
end

local function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

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
    GLOBAL_ANGLE += 1
    if GLOBAL_ANGLE == 360 then GLOBAL_ANGLE = 0 end

    -- Draw text
    -- gfx.drawTextAligned("Template configured!", 200, 30, kTextAlignment.center)
    -- Draw player
    playerImage:drawAnchored(playerX, playerY, 0.5, 0.5)
    
    for i, row in ipairs(platformsArray) do
        for ii, platform in ipairs(row) do 
            if (platform == 1 ) then 
                local xPos = CENTER + (sin(rad(ii * 12 + GLOBAL_ANGLE )) * 100)
                local front = isFront(ii)
                
                if( front ) then
                    platformBackImage:drawAnchored(xPos , 250 - i * 10, 0.5, 0.5)
                else
                    platformFrontImage:drawAnchored(xPos , 250 - i * 10, 0.5, 0.5)
                end
            end
        end    
    end


end
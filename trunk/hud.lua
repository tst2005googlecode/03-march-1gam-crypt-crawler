HUD = class("HUD")

HUD_WIDTH = 800
HUD_HEIGHT = 64

function HUD:initialize(hudFont)
	self.hudFont = hudFont
	self.curScore = 0
end

function HUD:reset()
	self.curScore = 0
end

function HUD:draw(playerHealth, curLevel)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, 0, HUD_WIDTH, HUD_HEIGHT)
	
	-- Draw Items
	
	-- Draw Health
	love.graphics.setColor(85, 0, 0)
	love.graphics.rectangle("fill", 32, 32, 200, 16)
	love.graphics.setColor(0, 90, 0)
	love.graphics.rectangle("fill", 32, 32, playerHealth, 16)
	
	-- Draw Level
	love.graphics.setFont(self.hudFont)
	love.graphics.setColor(185, 100, 0)
	love.graphics.print("Level " .. curLevel, 340, 18)
	
	-- Draw Score
	love.graphics.setColor(0, 130, 255)
	love.graphics.print("Score " .. self.curScore, 550, 18)
end
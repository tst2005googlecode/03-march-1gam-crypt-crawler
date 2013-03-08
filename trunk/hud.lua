HUD = class("HUD")

HUD_WIDTH = 800
HUD_HEIGHT = 64

function HUD:initialize(hudFont)
	self.hudFont = hudFont
	self.curScore = 0
end

function HUD:draw(x, y, playerHealth, curLevel)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", x, y, HUD_WIDTH, HUD_HEIGHT)
	
	-- Draw Items
	
	-- Draw Health
	love.graphics.setColor(85, 0, 0)
	love.graphics.rectangle("fill", x + 32, y + 32, 200, 16)
	love.graphics.setColor(0, 90, 0)
	love.graphics.rectangle("fill", x + 32, y + 32, playerHealth, 16)
	
	-- Draw Level
	love.graphics.setFont(self.hudFont)
	love.graphics.setColor(185, 100, 0)
	love.graphics.print("Level " .. curLevel, x + 340, y + 18)
	
	-- Draw Score
	love.graphics.setColor(0, 130, 255)
	love.graphics.print("Score " .. self.curScore, x + 550, y + 18)
end
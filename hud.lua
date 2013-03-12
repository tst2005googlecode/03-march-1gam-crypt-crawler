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

function HUD:draw(playerHealth, playerNumKeys, curLevel)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, 0, HUD_WIDTH, HUD_HEIGHT)
	
	-- Draw Items
	
	-- Draw Keys
	love.graphics.setColor(255, 255, 255)
	for i = 0, playerNumKeys - 1 do
		love.graphics.draw(KEY_IMAGE, 32 + i * 40, 14)
	end
	
	-- Draw Health
	love.graphics.setColor(85, 0, 0)
	love.graphics.rectangle("fill", 31, 31, 202, 18)
	love.graphics.setColor(0, 90, 0)
	love.graphics.rectangle("fill", 32, 32, playerHealth * 2, 16)
	
	-- Draw Level
	love.graphics.setFont(self.hudFont)
	love.graphics.setColor(185, 100, 0)
	love.graphics.print("Level " .. curLevel, 340, 18)
	
	-- Draw Score
	love.graphics.setColor(0, 130, 255)
	love.graphics.print("Score " .. self.curScore, 550, 18)
end
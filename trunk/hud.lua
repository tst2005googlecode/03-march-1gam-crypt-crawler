HUD = class("HUD")

HUD_WIDTH = 800
HUD_HEIGHT = 96

function HUD:draw(x, y, playerHealth, curLevel, score)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", x, y, HUD_WIDTH, HUD_HEIGHT)
	
	-- Draw Health
	-- Draw Level
	-- Draw Score
end
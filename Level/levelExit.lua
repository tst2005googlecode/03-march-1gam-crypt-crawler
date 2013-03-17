LevelExit = class("LevelExit")

LEVEL_EXIT_WIDTH = 32
LEVEL_EXIT_HEIGHT = 13

LEVEL_EXIT_IMAGE = love.graphics.newImage("Asset/Graphic/LevelExit.png")

function LevelExit:initialize()
	self.boundedBox = {
		x = 0,
		y = 0,
		width = KEY_WIDTH,
		height = KEY_HEIGHT,
		parent = self
	}
end

function LevelExit:onCollision(dt, other, dx, dy)
	
end

function LevelExit:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(LEVEL_EXIT_IMAGE, self.boundedBox.x, self.boundedBox.y)
end
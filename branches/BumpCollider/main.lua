BUMP = require "lib/bump"
require "lib/middleclass"
require "lib/general"
require "player"
require "wallManager"

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
TILE_SIZE = 32

function love.load()
	BUMP.initialize(32)
	
	player = Player:new()
	wallManager = WallManager:new()
end

function BUMP.collision(shapeA, shapeB, dx, dy)
	if shapeA.parent and shapeB.parent then
		shapeA.parent:onCollision(dt, shapeB.parent, dx, dy)
		shapeB.parent:onCollision(dt, shapeA.parent, -dx, -dy)
	end
end

function BUMP.getBBox(item)
	return item.x, item.y, item.width, item.height
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("quit")
	end
	
	if key == "left" then
		player.leftPressed = true
	end
	
	if key == "right" then
		player.rightPressed = true
	end
	
	if key == "up" then
		player.upPressed = true
	end
	
	if key == "down" then
		player.downPressed = true
	end
end

function love.keyreleased(key, unicode)
	if key == "left" then
		player.leftPressed = false
	end
	
	if key == "right" then
		player.rightPressed = false
	end
	
	if key == "up" then
		player.upPressed = false
	end
	
	if key == "down" then
		player.downPressed = false
	end
end

function love.update(dt)
	player:update(dt)
	wallManager:update(dt)
	
	BUMP.collide()
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	player:draw()
	wallManager:draw()
end

function love.quit()
	
end
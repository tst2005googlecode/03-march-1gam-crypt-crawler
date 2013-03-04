bump = require "lib/bump"
require "lib/middleclass"
require "lib/general"
require "player"
require "bullet"
require "wallManager"
require "camera"

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
TILE_SIZE = 32

function love.load()
	bump.initialize(32)
	
	player = Player:new()
	wallManager = WallManager:new()
	camera = Camera:new(wallManager.width, wallManager.height)
	bullets = {}
	bulletImage = love.graphics.newImage("Graphic/Bullet.png")
	
	bulletPressed = false;
end

function bump.collision(shapeA, shapeB, dx, dy)
	if shapeA.parent and shapeB.parent then
		shapeA.parent:onCollision(dt, shapeB.parent, dx, dy)
		shapeB.parent:onCollision(dt, shapeA.parent, -dx, -dy)
	end
end

function bump.getBBox(item)
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
	
	if key == " " then
		bulletPressed = true
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
	
	if key == " " then
		bulletPressed = false
	end
end

function love.update(dt)
	player:update(dt)
	camera:update(player.boundedBox.x, player.boundedBox.y)
	
	for index, bullet in ipairs(bullets) do
		bullet:update(dt)
		
		if not bullet.alive then
			bump.remove(bullet.boundedBox)
			table.remove(bullets, index)
		end
	end
	
	if bulletPressed then
		fireBullet()
	end
	
	bump.collide()
end

function fireBullet()
	if #bullets == 0 then
		table.insert(bullets, Bullet:new(player.boundedBox.x + PLAYER_WIDTH / 2, player.boundedBox.y + PLAYER_HEIGHT / 2, player.rotation, bulletImage))
	end
end

function love.draw()
	camera:set()
	
	love.graphics.setColor(255, 255, 255)
	player:draw()
	wallManager:draw()
	for index, bullet in pairs(bullets) do
		bullet:draw()
	end
	
	camera:unset()
end

function love.quit()
	
end
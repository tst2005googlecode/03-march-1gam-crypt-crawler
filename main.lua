bump = require "lib/bump"
require "lib/middleclass"
require "lib/general"
require "player"
require "bulletManager"
require "wallManager"
require "enemyManager"
require "camera"
require "hud"

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
TILE_SIZE = 32

function love.load()
	bump.initialize(32)
	defaultFont = love.graphics.newFont(12)
	
	player = Player:new()
	wallManager = WallManager:new()
	bulletManager = BulletManager:new()
	enemyManager = EnemyManager:new()
	hud = HUD:new(love.graphics.newFont("Font/8bitlim.ttf", 32))
	
	camera = Camera:new(wallManager.width, wallManager.height)
	
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
	local cameraBox = { x = camera.x, y = camera.y, width = SCREEN_WIDTH, height = SCREEN_HEIGHT }
	
	player:update(dt)
	camera:update(player.boundedBox.x, player.boundedBox.y)
	bulletManager:update(dt, camera.x, camera.y, SCREEN_WIDTH, SCREEN_HEIGHT)
	enemyManager:update(
		dt,
		cameraBox,
		{ x = player.boundedBox.x, y = player.boundedBox.y }
	)
	
	if bulletPressed then
		bulletManager:fireBullet(player.boundedBox.x + PLAYER_WIDTH / 2, player.boundedBox.y + PLAYER_HEIGHT / 2, player.rotation)
	end
	
	bump.collide()
	
	player:updateSolidCollisions(dt)
	enemyManager:updateSolidCollisions(dt, cameraBox)
end

function love.draw()
	camera:set()
	
	love.graphics.setColor(255, 255, 255)
	player:draw()
	wallManager:draw()
	bulletManager:draw()
	enemyManager:draw({ x = camera.x, y = camera.y, width = SCREEN_WIDTH, height = SCREEN_HEIGHT })
	hud:draw(camera.x, camera.y, player.curHealth, "A")
	
	-- Debug Stuff
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(defaultFont)
	love.graphics.print(love.mouse.getX() .. ", " .. love.mouse.getY(), 0, 0)
	
	camera:unset()
end

function love.quit()
	
end
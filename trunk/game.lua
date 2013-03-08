Game = class("Game")

require "player"
require "bulletManager"
require "wallManager"
require "enemyManager"
require "camera"
require "hud"

function Game:initialize()
	self.player = Player:new()
	self.wallManager = WallManager:new()
	self.bulletManager = BulletManager:new()
	self.enemyManager = EnemyManager:new()
	self.hud = HUD:new(love.graphics.newFont("Font/8bitlim.ttf", 32))
	
	self.camera = Camera:new(self.wallManager.width, self.wallManager.height)
	
	self.bulletPressed = false;
end

function Game:reset()
	
end

function Game:getNextState()
	if self.player.curHealth <= 0 then
		return 2
	else
		return nil
	end
end

function Game:keyPressed(key)
	if key == "left" then
		self.player.leftPressed = true
	end
	
	if key == "right" then
		self.player.rightPressed = true
	end
	
	if key == "up" then
		self.player.upPressed = true
	end
	
	if key == "down" then
		self.player.downPressed = true
	end
	
	if key == " " then
		self.bulletPressed = true
	end
end

function Game:keyReleased(key)
	if key == "left" then
		self.player.leftPressed = false
	end
	
	if key == "right" then
		self.player.rightPressed = false
	end
	
	if key == "up" then
		self.player.upPressed = false
	end
	
	if key == "down" then
		self.player.downPressed = false
	end
	
	if key == " " then
		self.bulletPressed = false
	end
end

function Game:update(dt)
	local cameraBox = {
		x = self.camera.x,
		y = self.camera.y,
		width = SCREEN_WIDTH,
		height = SCREEN_HEIGHT
	}
	
	self.player:update(dt)
	self.camera:update(self.player.boundedBox.x, self.player.boundedBox.y)
	self.bulletManager:update(dt, self.camera.x, self.camera.y, SCREEN_WIDTH, SCREEN_HEIGHT)
	self.enemyManager:update(
		dt,
		cameraBox,
		{ x = self.player.boundedBox.x, y = self.player.boundedBox.y }
	)
	
	if self.bulletPressed then
		self.bulletManager:fireBullet(
			self.player.boundedBox.x + PLAYER_WIDTH / 2,
			self.player.boundedBox.y + PLAYER_HEIGHT / 2,
			self.player.rotation
		)
	end
	
	bump.collide()
	
	self.player:updateSolidCollisions(dt)
	self.enemyManager:updateSolidCollisions(dt, cameraBox)
end

function Game:draw()
	self.camera:set()
	
	love.graphics.setColor(255, 255, 255)
	self.player:draw()
	self.wallManager:draw()
	self.bulletManager:draw()
	self.enemyManager:draw({ x = self.camera.x, y = self.camera.y, width = SCREEN_WIDTH, height = SCREEN_HEIGHT })
	
	self.camera:unset()
	
	self.hud:draw(self.player.curHealth, "A")
end
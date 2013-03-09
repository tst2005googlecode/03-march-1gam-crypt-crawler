Game = class("Game")

require "player"
require "bulletManager"
require "wallManager"
require "lockedDoor"
require "key"
require "enemyManager"
require "camera"
require "hud"

function Game:initialize()
	self.levelNames = { "A", "B", "C", "D", "E" }
	self.player = Player:new()
	self.wallManager = WallManager:new()
	self.lockedDoors = {}
	self.keys = {}
	self.bulletManager = BulletManager:new()
	self.enemyManager = EnemyManager:new()
	self.hud = HUD:new(love.graphics.newFont("Font/8bitlim.ttf", 32))
	
	self.camera = Camera:new()
	self.curLevel = ""
	
	self.bulletPressed = false;
end

function Game:reset()
	self.player:reset()
	self.wallManager:reset()
	self.lockedDoors = {}
	self.keys = {}
	self.bulletManager:reset()
	self.enemyManager:reset()
	self.hud:reset()
	self.camera:reset()
	self.curLevel = ""
	
	bump.reset()
	
	self.bulletPressed = false;
end

function Game:loadLevel(levelNum)
	self.curLevel = self.levelNames[levelNum]
	levelFile = love.filesystem.newFile("Data/Level" .. levelNum .. ".csv")
	levelFile:open('r')
	fileContents = levelFile:read()
	
	local lineData = string.explode(fileContents:sub(0, string.len(fileContents) - 2), "\r\n")
	self.height = #lineData
	
	for y, line in ipairs(lineData) do
		local data = string.explode(line, ",")
		self.width = #data
		for x, value in ipairs(data) do
			local sx = (x - 1) * TILE_SIZE
			local sy = (y - 1) * TILE_SIZE
			
			if string.find(value, "P") ~= nil then
				self.player.boundedBox.x = sx
				self.player.boundedBox.y = sy
			end
			
			if string.find(value, "W") ~= nil then
				self.wallManager:addWall(sx, sy)
			end
			
			if string.find(value, "L") ~= nil then
				table.insert(self.lockedDoors, LockedDoor:new(sx, sy))
			end
			
			if string.find(value, "K") ~= nil then
				table.insert(self.keys, Key:new(sx, sy))
			end
			
			if string.find(value, "E1") ~= nil then
				self.enemyManager:addEnemy(sx, sy, 1)
			end
			if string.find(value, "E2") ~= nil then
				self.enemyManager:addEnemy(sx, sy, 2)
			end
			if string.find(value, "E3") ~= nil then
				self.enemyManager:addEnemy(sx, sy, 3)
			end
			if string.find(value, "E4") ~= nil then
				self.enemyManager:addEnemy(sx, sy, 4)
			end
			if string.find(value, "E5") ~= nil then
				self.enemyManager:addEnemy(sx, sy, 5)
			end
			if string.find(value, "E6") ~= nil then
				self.enemyManager:addEnemy(sx, sy, 6)
			end
			if string.find(value, "E7") ~= nil then
				self.enemyManager:addEnemy(sx, sy, 7)
			end
			if string.find(value, "E8") ~= nil then
				self.enemyManager:addEnemy(sx, sy, 8)
			end
			if string.find(value, "E9") ~= nil then
				self.enemyManager:addEnemy(sx, sy, 9)
			end
			if string.find(value, "E10") ~= nil then
				self.enemyManager:addEnemy(sx, sy, 10)
			end
			
			if string.find(value, "S1") ~= nil then
				self.enemyManager:addSpawner(sx, sy, 1)
			end
			if string.find(value, "S2") ~= nil then
				self.enemyManager:addSpawner(sx, sy, 2)
			end
			if string.find(value, "S3") ~= nil then
				self.enemyManager:addSpawner(sx, sy, 3)
			end
			if string.find(value, "S4") ~= nil then
				self.enemyManager:addSpawner(sx, sy, 4)
			end
			if string.find(value, "S5") ~= nil then
				self.enemyManager:addSpawner(sx, sy, 5)
			end
			if string.find(value, "S6") ~= nil then
				self.enemyManager:addSpawner(sx, sy, 6)
			end
			if string.find(value, "S7") ~= nil then
				self.enemyManager:addSpawner(sx, sy, 7)
			end
			if string.find(value, "S8") ~= nil then
				self.enemyManager:addSpawner(sx, sy, 8)
			end
			if string.find(value, "S9") ~= nil then
				self.enemyManager:addSpawner(sx, sy, 9)
			end
			if string.find(value, "S10") ~= nil then
				self.enemyManager:addSpawner(sx, sy, 10)
			end
		end
	end
	
	self.camera:setBounds(self.width, self.height)
	
	levelFile:close()
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
	
	for i, lockedDoor in ipairs(self.lockedDoors) do
		lockedDoor:draw()
	end
	
	for i, key in ipairs(self.keys) do
		key:draw()
	end
	
	self.camera:unset()
	
	self.hud:draw(self.player.curHealth, self.curLevel)
end
Game = class("Game")

require "player"
require "bulletManager"
require "wallManager"
require "lockedDoor"
require "key"
require "riceBall"
require "poisonRiceBall"
require "enemyManager"
require "levelExit"
require "levelTiles"
require "camera"
require "hud"

LAST_LEVEL = 5

function Game:initialize()
	self.levelNames = { "A", "B", "C", "D", "E" }
	self.player = Player:new()
	self.wallManager = WallManager:new()
	self.lockedDoors = {}
	self.keys = {}
	self.riceBalls = {}
	self.poisonRiceBalls = {}
	self.bulletManager = BulletManager:new()
	self.enemyManager = EnemyManager:new()
	self.levelExit = LevelExit:new()
	
	self.levelTiles = LevelTiles:new()
	self.hud = HUD:new(love.graphics.newFont("Font/8bitlim.ttf", 32))
	self.camera = Camera:new()
	
	self.gameBeaten = false
	self.curLevel = 1
	
	self.bulletPressed = false;
end

function Game:reset()
	for i, key in ipairs(self.keys) do
		bump.remove(key.boundedBox)
	end
	
	for i, riceBall in ipairs(self.riceBalls) do
		bump.remove(riceBall.boundedBox)
	end
	
	for i, poisonRiceBall in ipairs(self.riceBalls) do
		bump.remove(poisonRiceBall.boundedBox)
	end
	
	self.player:reset()
	self.wallManager:reset()
	self.lockedDoors = {}
	self.keys = {}
	self.riceBalls = {}
	self.poisonRiceBalls = {}
	self.bulletManager:reset()
	self.enemyManager:reset()
	self.levelExit.boundedBox.x = 0
	self.levelExit.boundedBox.y = 0
	bump.remove(self.levelExit.boundedBox)
	
	self.levelTiles:reset()
	self.hud:reset()
	self.camera:reset()
	self.gameBeaten = false
	self.curLevel = 1
	
	bump.reset()
	
	self.bulletPressed = false;
end

function Game:loadLevel(levelNum)
	self.curLevel = levelNum
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
			
			-- Player
			if string.find(value, "P") ~= nil then
				self.player.boundedBox.x = sx + PLAYER_SPRITE_OFFSET
				self.player.boundedBox.y = sy + PLAYER_SPRITE_OFFSET
			end
			
			-- Solid Wall
			if string.find(value, "W") ~= nil then
				self.wallManager:addWall(sx, sy)
			end
			
			-- Locked Door
			if string.find(value, "L") ~= nil then
				table.insert(self.lockedDoors, LockedDoor:new(sx, sy))
			end
			
			-- Key
			if string.find(value, "K") ~= nil then
				table.insert(self.keys, Key:new(sx, sy))
			end
			
			-- Health
			if string.find(value, "H") ~= nil then
				table.insert(self.riceBalls, RiceBall:new(sx, sy))
			end
			
			-- Poison
			if string.find(value, "O") ~= nil then
				table.insert(self.poisonRiceBalls, PoisonRiceBall:new(sx, sy))
			end
			
			-- Enemy
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
			
			-- Spawner
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
			
			-- Exit
			if string.find(value, "X") ~= nil then
				self.levelExit.boundedBox.x = sx
				self.levelExit.boundedBox.y = sy
				bump.add(self.levelExit.boundedBox)
			end
			
			-- Tiles
			self.levelTiles:addTile(sx, sy, value)
		end
	end
	
	self.levelTiles:update(0, 0)
	self.camera:setBounds(self.width, self.height)
	
	levelFile:close()
end

function Game:getNextState()
	if self.player.curHealth <= 0 then
		return 2
	elseif self.gameBeaten then
		return 3
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
			self.player.rotation,
			self.hud
		)
	end
	
	bump.collide()
	
	self.player:updateSolidCollisions(dt)
	self.enemyManager:updateSolidCollisions(dt, cameraBox)
	
	local cameraMoved = self.camera:update(self.player.boundedBox.x, self.player.boundedBox.y)
	if cameraMoved then
		self.levelTiles:update(self.camera.x, self.camera.y)
	end
	
	if self.player.goToNextLevel then
		local nextLevel = self.curLevel + 1
		
		if nextLevel > LAST_LEVEL then
			self.gameBeaten = true
		else
			local playerHealth = self.player.curHealth
			local playerScore = self.hud.curScore
			
			self:reset()
			self:loadLevel(nextLevel)
			
			self.player.curHealth = playerHealth
			self.hud.curScore = playerScore
		end
	end
end

function Game:draw()
	self.levelTiles:draw()
	
	self.camera:set()
	
	self.player:draw()
	-- self.wallManager:draw()
	self.levelExit:draw()
	self.enemyManager:draw({ x = self.camera.x, y = self.camera.y, width = SCREEN_WIDTH, height = SCREEN_HEIGHT })
	
	for i, lockedDoor in ipairs(self.lockedDoors) do
		lockedDoor:draw()
	end
	
	for i, key in ipairs(self.keys) do
		key:draw()
	end
	
	for i, riceBall in ipairs(self.riceBalls) do
		riceBall:draw()
	end
	
	for i, poisonRiceBall in ipairs(self.poisonRiceBalls) do
		poisonRiceBall:draw()
	end
	
	self.bulletManager:draw()
	
	self.camera:unset()
	
	self.hud:draw(self.player.curHealth, self.player.numKeys, self.levelNames[self.curLevel])
end
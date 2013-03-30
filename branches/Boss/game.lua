Game = class("Game")

require "player"
require "Bullet/bulletManager"
require "Level/wallManager"
require "Level/lockedDoor"
require "Level/key"
require "Level/healthPickup"
require "Level/poisonPickup"
require "Level/treasurePickup"
require "Enemy/enemyManager"
require "Enemy/boss"
require "Level/levelExit"
require "Level/levelTiles"
require "camera"
require "hud"

LAST_LEVEL = 6
TRANSITION_TIMER = 0.2

CAMERA_HMARGIN = 250
CAMERA_VMARGIN = 175
CAMERA_SCALE = 0.8

function Game:initialize(musicTrack)
	self.musicTrack = musicTrack
	self.levelNames = {
		"Mistfall Castle",
		"Vinespire Jungle",
		"Crest Dungeon",
		"Headless Temple",
		"The Last Crypt",
		"Dark Chamber"
	}
	
	self.transitionImage = love.graphics.newImage("Asset/Graphic/Screen/TransitionScreen.png")
	self.gameFont = love.graphics.newFont("Asset/Font/8bitlim.ttf", 32)
	
	self.wallManager = WallManager:new()
	self.lockedDoors = {}
	self.keys = {}
	self.healthPickups = {}
	self.poisonPickups = {}
	self.treasurePickups = {}
	self.bulletManager = BulletManager:new()
	self.enemyManager = EnemyManager:new()
	self.levelExit = LevelExit:new()
	
	self.levelTiles = LevelTiles:new()
	self.hud = HUD:new(love.graphics.newFont("Asset/Font/8bitlim.ttf", 32))
	self.player = Player:new(self.hud)
	self.boss = Boss:new(self.enemyManager)
	self.camera = Camera:new()
	
	self.camera:setScale(CAMERA_SCALE, CAMERA_SCALE)
	
	self.gameBeaten = false
	self.curLevel = 1
	self.transitionTimer = TRANSITION_TIMER
	
	self.bulletPressed = false;
end

function Game:reset()
	for i, key in ipairs(self.keys) do
		bump.remove(key.boundedBox)
	end
	
	for i, healthPickup in ipairs(self.healthPickups) do
		bump.remove(healthPickup.boundedBox)
	end
	
	for i, poisonPickup in ipairs(self.poisonPickups) do
		bump.remove(poisonPickup.boundedBox)
	end
	
	for i, treasurePickup in ipairs(self.treasurePickups) do
		bump.remove(treasurePickup.boundedBox)
	end
	
	self.player:reset()
	self.wallManager:reset()
	self.lockedDoors = {}
	self.keys = {}
	self.healthPickups = {}
	self.poisonPickups = {}
	self.treasurePickups = {}
	self.bulletManager:reset()
	self.enemyManager:reset()
	self.boss:reset()
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
	self.transitionTimer = TRANSITION_TIMER
	
	if levelNum == LAST_LEVEL then
		self.boss:activate()
	end
	
	levelFile = love.filesystem.newFile("Asset/Data/Level" .. levelNum .. ".csv")
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
			
			-- Treasure
			if string.find(value, "R0") ~= nil then
				table.insert(self.treasurePickups, TreasurePickup:new(sx, sy, 0))
			end
			if string.find(value, "R1") ~= nil then
				table.insert(self.treasurePickups, TreasurePickup:new(sx, sy, 1))
			end
			
			-- Health
			if string.find(value, "H0") ~= nil then
				table.insert(self.healthPickups, HealthPickup:new(sx, sy, 0))
			end
			if string.find(value, "H1") ~= nil then
				table.insert(self.healthPickups, HealthPickup:new(sx, sy, 1))
			end
			if string.find(value, "H2") ~= nil then
				table.insert(self.healthPickups, HealthPickup:new(sx, sy, 2))
			end
			
			-- Poison
			if string.find(value, "O0") ~= nil then
				table.insert(self.poisonPickups, PoisonPickup:new(sx, sy, 0))
			end
			if string.find(value, "O1") ~= nil then
				table.insert(self.poisonPickups, PoisonPickup:new(sx, sy, 1))
			end
			if string.find(value, "O2") ~= nil then
				table.insert(self.poisonPickups, PoisonPickup:new(sx, sy, 2))
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
	
	self.camera:setBounds(self.width, self.height)
	self.camera:setX(self.player.boundedBox.x - SCREEN_WIDTH / 2)
	self.camera:setY(self.player.boundedBox.y - SCREEN_HEIGHT / 2)
	
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
	if self.transitionTimer > 0 then
		self.transitionTimer = self.transitionTimer - dt
	else
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
		
		if self.boss.active then
			self.boss:update(dt, self.player.boundedBox.x, self.player.boundedBox.y)
		end
		
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
		
		BULLET_SPARK_SYSTEM:update(dt)
		
		if not BULLET_SPARK_SYSTEM:isActive() then
			BULLET_SPARK_SYSTEM:reset()
		end
		
		self.camera:update(self.player.boundedBox.x, self.player.boundedBox.y)
		
		if self.player.goToNextLevel or (self.boss.active and not self.boss.alive) then
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
end

function Game:draw()
	if self.transitionTimer > 0 then
		love.graphics.draw(self.transitionImage, 0, 0)
		love.graphics.setColor(0, 0, 0)
		love.graphics.setFont(self.gameFont)
		love.graphics.print(self.levelNames[self.curLevel], 520, 80)
	else
		self.camera:set()
	
		self.levelTiles:draw()
		self.player:draw()
		-- self.wallManager:draw()
		self.levelExit:draw()
		self.enemyManager:draw({ x = self.camera.x, y = self.camera.y, width = SCREEN_WIDTH, height = SCREEN_HEIGHT })
		
		if self.boss.active then
			self.boss:draw()
		end
		
		for i, lockedDoor in ipairs(self.lockedDoors) do
			lockedDoor:draw()
		end
		
		for i, key in ipairs(self.keys) do
			key:draw()
		end
		
		for i, healthPickup in ipairs(self.healthPickups) do
			healthPickup:draw()
		end
		
		for i, poisonPickup in ipairs(self.poisonPickups) do
			poisonPickup:draw()
		end
		
		for i, treasurePickup in ipairs(self.treasurePickups) do
			treasurePickup:draw()
		end
		
		self.bulletManager:draw()
		love.graphics.draw(BULLET_SPARK_SYSTEM)
		
		self.camera:unset()
		
		self.hud:draw(self.player.curHealth, self.player.numKeys, self.levelNames[self.curLevel])
	end
end
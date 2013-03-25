require "Lib/AnAL"
require "soundLibrary"

Player = class("Player")

PLAYER_WIDTH = 26
PLAYER_HEIGHT = 26
PLAYER_SPRITE_OFFSET = 3
PLAYER_SPEED = 100

PLAYER_HEALTH_TIMER = 10
PLAYER_HEALTH_DRAIN = 3
PLAYER_HEALTH_MAX = 100
PLAYER_HEALTH_START = 75

PLAYER_ANIMATION_DELAY = 0.2

function Player:initialize(hudObj)
	self.hudObj = hudObj
	self.boundedBox = {
		x = 100,
		y = 150,
		width = PLAYER_WIDTH,
		height = PLAYER_HEIGHT,
		parent = self
	}
	bump.add(self.boundedBox)
	
	self.image = love.graphics.newImage("Asset/Graphic/PlayerAnimation.png")
	self.animations = {}
	self.animations[0] = newAnimation(self.image, 0, 32 * 0, 32, 32, PLAYER_ANIMATION_DELAY, 4)
	self.animations[45] = newAnimation(self.image, 0, 32 * 1, 32, 32, PLAYER_ANIMATION_DELAY, 4)
	self.animations[90] = newAnimation(self.image, 0, 32 * 2, 32, 32, PLAYER_ANIMATION_DELAY, 4)
	self.animations[135] = newAnimation(self.image, 0, 32 * 3, 32, 32, PLAYER_ANIMATION_DELAY, 4)
	self.animations[180] = newAnimation(self.image, 0, 32 * 4, 32, 32, PLAYER_ANIMATION_DELAY, 4)
	self.animations[225] = newAnimation(self.image, 0, 32 * 5, 32, 32, PLAYER_ANIMATION_DELAY, 4)
	self.animations[270] = newAnimation(self.image, 0, 32 * 6, 32, 32, PLAYER_ANIMATION_DELAY, 4)
	self.animations[315] = newAnimation(self.image, 0, 32 * 7, 32, 32, PLAYER_ANIMATION_DELAY, 4)
	self.animations[360] = newAnimation(self.image, 0, 32 * 0, 32, 32, PLAYER_ANIMATION_DELAY, 4)
	
	self:initializeParticles()
	
	self:reset()
end

function Player:initializeParticles()
	-- Damage Effect
	local bloodImage = love.graphics.newImage("Asset/Particle/PlayerBlood.png")
	local pD = love.graphics.newParticleSystem(bloodImage, 30)
	
	pD:setEmissionRate(2000)
	pD:setLifetime(0.5)
	pD:setParticleLife(0.5)
	pD:setSpread(2 * math.pi)
	pD:setSpeed(10, 150)
	pD:setSizes(0.1, 0.2)
	pD:setGravity(400)
	pD:setColors(
		255, 0, 0, 255,
		255, 0, 0, 0
	)
	pD:stop()
	self.bloodParticleSystem = pD
	
	-- Health Pickup Effect
	local healthImage = love.graphics.newImage("Asset/Graphic/Item/HealthPickup1.png")
	local pH = love.graphics.newParticleSystem(healthImage, 1)
	
	pH:setEmissionRate(2000)
	pH:setLifetime(0.75)
	pH:setParticleLife(0.75)
	pH:setDirection(math.pi * 1.5) -- Straight Up
	pH:setSpeed(100)
	pH:setSizes(1)
	pH:setColors(
		255, 255, 255, 255,
		255, 255, 255, 0
	)
	pH:stop()
	self.healthParticleSystem = pH
	
	-- Poison Pickup Effect
	local poisonImage = love.graphics.newImage("Asset/Particle/PoisonPickup.png")
	local pP = love.graphics.newParticleSystem(poisonImage, 1)
	
	pP:setEmissionRate(2000)
	pP:setLifetime(0.75)
	pP:setParticleLife(0.75)
	pP:setDirection(math.pi * 1.5) -- Straight Up
	pP:setSpeed(100)
	pP:setSizes(0.75)
	pP:setColors(
		255, 255, 255, 255,
		255, 255, 255, 0
	)
	pP:stop()
	self.poisonParticleSystem = pP
	
	-- Key Pickup Effect
	local keyPickupImage = love.graphics.newImage("Asset/Particle/KeyPickup.png")
	local pK = love.graphics.newParticleSystem(keyPickupImage, 1)
	
	pK:setEmissionRate(2000)
	pK:setLifetime(0.75)
	pK:setParticleLife(0.75)
	pK:setDirection(math.pi * 1.5) -- Straight Up
	pK:setSpeed(100)
	pK:setSizes(1)
	pK:setColors(
		255, 255, 255, 255,
		255, 255, 255, 0
	)
	pK:stop()
	self.keyParticleSystem = pK
	
	-- Treasure Pickup Effect
	local treasurePickupImage = love.graphics.newImage("Asset/Graphic/Item/TreasurePickup1.png")
	local pT = love.graphics.newParticleSystem(treasurePickupImage, 1)
	
	pT:setEmissionRate(2000)
	pT:setLifetime(0.75)
	pT:setParticleLife(0.75)
	pT:setDirection(math.pi * 1.5) -- Straight Up
	pT:setSpeed(100)
	pT:setSizes(1)
	pT:setColors(
		255, 255, 255, 255,
		255, 255, 255, 0
	)
	pT:stop()
	self.treasureParticleSystem = pT
	
	-- Door Unlock Effect
	local doorUnlockImage = love.graphics.newImage("Asset/Particle/DoorUnlock.png")
	local pU = love.graphics.newParticleSystem(doorUnlockImage, 1)
	
	pU:setEmissionRate(2000)
	pU:setLifetime(0.3)
	pU:setParticleLife(0.3)
	pU:setSpeed(0)
	pU:setSizes(1)
	pU:setColors(
		255, 255, 255, 255,
		255, 255, 255, 0
	)
	pU:stop()
	self.doorUnlockParticleSystem = pU
end

function Player:reset()
	self.boundedBox.x = 100
	self.boundedBox.y = 150
	self.velocity = { x = 0, y = 0 }
	self.rotation = 0
	self.curHealth = PLAYER_HEALTH_START
	self.healthTimer = PLAYER_HEALTH_TIMER
	self.numKeys = 0
	self.goToNextLevel = false
	
	self.leftPressed = false
	self.rightPressed = false
	self.upPressed = false
	self.downPressed = false
	self.doAnimation = false
	
	self.solidCollisions = {}
	
	bump.add(self.boundedBox)
end

function Player:onCollision(dt, other, dx, dy)
	if instanceOf(Wall, other) or instanceOf(EnemySpawner, other) then
		table.insert(self.solidCollisions, other.boundedBox)
	elseif instanceOf(LockedDoor, other) then
		if self.numKeys > 0 then
			SFX_DOOR_UNLOCK:rewind()
			SFX_DOOR_UNLOCK:play()
			self.numKeys = self.numKeys - 1
			other:unlock()
			
			self.doorUnlockParticleSystem:setPosition(other.boundedBox.x + LOCKED_DOOR_WIDTH / 2, other.boundedBox.y + LOCKED_DOOR_HEIGHT / 2)
			self.doorUnlockParticleSystem:start()
		else
			table.insert(self.solidCollisions, other.boundedBox)
		end
	elseif instanceOf(Key, other) then
		SFX_KEY_PICKUP:rewind()
		SFX_KEY_PICKUP:play()
		self.numKeys = self.numKeys + 1
		other:pickup()
		
		self.keyParticleSystem:setPosition(other.boundedBox.x + KEY_WIDTH / 2, other.boundedBox.y + KEY_HEIGHT / 2)
		self.keyParticleSystem:start()
	elseif instanceOf(HealthPickup, other) and self.curHealth < PLAYER_HEALTH_MAX then
		SFX_HEALTH_PICKUP:rewind()
		SFX_HEALTH_PICKUP:play()
		self:setHealth(self.curHealth + HEALTH_PICKUP_HEALTH_VALUE)
		other:pickup()
		
		self.healthParticleSystem:setSprite(other.image)
		self.healthParticleSystem:setPosition(other.boundedBox.x + HEALTH_PICKUP_WIDTH / 2, other.boundedBox.y + HEALTH_PICKUP_HEIGHT / 2)
		self.healthParticleSystem:start()
	elseif instanceOf(PoisonPickup, other) then
		SFX_POISON_PICKUP:rewind()
		SFX_POISON_PICKUP:play()
		self:setHealth(self.curHealth - POISON_PICKUP_HEALTH_VALUE)
		other:pickup()
		
		self.poisonParticleSystem:setPosition(self.boundedBox.x + PLAYER_WIDTH / 2, self.boundedBox.y + PLAYER_HEIGHT / 2)
		self.poisonParticleSystem:start()
	elseif instanceOf(TreasurePickup, other) then
		SFX_TREASURE_PICKUP:rewind()
		SFX_TREASURE_PICKUP:play()
		self.hudObj.curScore = self.hudObj.curScore + TREASURE_PICKUP_POINT_VALUE
		
		other:pickup()
		
		self.treasureParticleSystem:setSprite(other.image)
		self.treasureParticleSystem:setPosition(other.boundedBox.x + TREASURE_PICKUP_WIDTH / 2, other.boundedBox.y + TREASURE_PICKUP_HEIGHT / 2)
		self.treasureParticleSystem:start()
	elseif instanceOf(LevelExit, other) then
		SFX_LEVEL_PROGRESS:rewind()
		SFX_LEVEL_PROGRESS:play()
		self.goToNextLevel = true
	end
end

function Player:hitByEnemy()
	self:setHealth(self.curHealth - ENEMY_HEALTH_DRAIN_VALUE)
	
	self.bloodParticleSystem:setPosition(self.boundedBox.x + PLAYER_WIDTH / 2, self.boundedBox.y + PLAYER_HEIGHT / 2)
	self.bloodParticleSystem:start()
end

function Player:setHealth(newHealth)
	self.curHealth = math.clamp(newHealth, 0, PLAYER_HEALTH_MAX)
end

function Player:update(dt)
	self.doAnimation = false
	self.solidCollisions = {}
	self:updateVelocity()
	self:updateRotation()
	self:updatePosition(dt)
	self:updateHealthDrain(dt)
	
	if self.doAnimation then
		self.animations[self.rotation]:play()
		self.animations[self.rotation]:update(dt)
	end
	
	-- Particle Effects
	self.bloodParticleSystem:update(dt)
	if not self.bloodParticleSystem:isActive() then
		self.bloodParticleSystem:reset()
	end
	
	self.healthParticleSystem:update(dt)
	if not self.healthParticleSystem:isActive() then
		self.healthParticleSystem:reset()
	end
	
	self.poisonParticleSystem:update(dt)
	if not self.poisonParticleSystem:isActive() then
		self.poisonParticleSystem:reset()
	end
	
	self.treasureParticleSystem:update(dt)
	if not self.treasureParticleSystem:isActive() then
		self.treasureParticleSystem:reset()
	end
	
	self.keyParticleSystem:update(dt)
	if not self.keyParticleSystem:isActive() then
		self.keyParticleSystem:reset()
	end
	
	self.doorUnlockParticleSystem:update(dt)
	if not self.doorUnlockParticleSystem:isActive() then
		self.doorUnlockParticleSystem:reset()
	end
end

function Player:updateVelocity()
	local vx = 0
	local vy = 0
	
	if self.leftPressed then
		vx = vx - 1
	end
	
	if self.rightPressed then
		vx = vx + 1
	end
	
	if self.upPressed then
		vy = vy - 1
	end
	
	if self.downPressed then
		vy = vy + 1
	end
	
	if vx ~= 0 or vy ~= 0 then
		vx, vy = math.normalize(vx, vy)
	end
		
	self.velocity.x = vx * PLAYER_SPEED
	self.velocity.y = vy * PLAYER_SPEED
end

function Player:updateRotation()
	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
		self.doAnimation = true
		self.rotation = math.ceil(math.deg(math.atan2(self.velocity.y, self.velocity.x)))
		if self.rotation < 0 then
			self.rotation = self.rotation + 360
		end
	end
end

function Player:updatePosition(dt)
	self.boundedBox.x = self.boundedBox.x + self.velocity.x * dt
	self.boundedBox.y = self.boundedBox.y + self.velocity.y * dt
end

function Player:updateHealthDrain(dt)
	self.healthTimer = self.healthTimer - dt
	if self.healthTimer <= 0 then
		self:setHealth(self.curHealth - PLAYER_HEALTH_DRAIN)
		self.healthTimer = PLAYER_HEALTH_TIMER
	end
end

function Player:updateSolidCollisions(dt)
	if #self.solidCollisions > 0 then
		self.boundedBox.x = self.boundedBox.x - self.velocity.x * dt
		self.boundedBox.y = self.boundedBox.y - self.velocity.y * dt
		
		local x = self.boundedBox.x
		local y = self.boundedBox.y
		local otherCollision = nil
		
		-- Check X Direction
		self.boundedBox.x = self.boundedBox.x + self.velocity.x * dt
		for index, solidCollision in ipairs(self.solidCollisions) do
			if bump.doesCollide(self.boundedBox, solidCollision) then
				otherCollision = solidCollision
				break
			end
		end
		
		if otherCollision ~= nil then
			if self.velocity.x > 0 then --Moving Right
				self.boundedBox.x = otherCollision.x - PLAYER_WIDTH
			elseif self.velocity.x < 0 then --Moving Left
				self.boundedBox.x = otherCollision.x + otherCollision.width
			end
			
			self.velocity.x = 0
		end
		
		-- Check Y Direction
		otherCollision = nil
		
		self.boundedBox.y = self.boundedBox.y + self.velocity.y * dt
		for index, solidCollision in ipairs(self.solidCollisions) do
			if bump.doesCollide(self.boundedBox, solidCollision) then
				otherCollision = solidCollision
				break
			end
		end
		
		if otherCollision ~= nil then
			if self.velocity.y > 0 then --Moving Right
				self.boundedBox.y = otherCollision.y - PLAYER_HEIGHT
			elseif self.velocity.y < 0 then --Moving Left
				self.boundedBox.y = otherCollision.y + otherCollision.height
			end
			
			self.velocity.y = 0
		end
	end
end

function Player:draw()
	-- love.graphics.setColor(255, 255, 255)
	-- love.graphics.rectangle("fill", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
	
	self.animations[self.rotation]:draw(self.boundedBox.x - PLAYER_SPRITE_OFFSET, self.boundedBox.y - PLAYER_SPRITE_OFFSET)
	
	love.graphics.draw(self.bloodParticleSystem)
	love.graphics.draw(self.healthParticleSystem)
	love.graphics.draw(self.poisonParticleSystem)
	love.graphics.draw(self.treasureParticleSystem)
	love.graphics.draw(self.keyParticleSystem)
	love.graphics.draw(self.doorUnlockParticleSystem)
end
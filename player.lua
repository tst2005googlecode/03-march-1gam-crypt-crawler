require "Lib/AnAL"
require "soundLibrary"

Player = class("Player")

PLAYER_WIDTH = 26
PLAYER_HEIGHT = 26
PLAYER_SPRITE_OFFSET = 3
PLAYER_SPEED = 100

PLAYER_HEALTH_TIMER = 7
PLAYER_HEALTH_DRAIN = 3
PLAYER_HEALTH_MAX = 100

PLAYER_ANIMATION_DELAY = 0.2

function Player:initialize()
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
	
	local p = love.graphics.newParticleSystem(bloodImage, 30)
	p:setEmissionRate(2000)
	p:setLifetime(0.5)
	p:setParticleLife(0.5)
	p:setSpread(2 * math.pi)
	p:setSpeed(10, 150)
	p:setSizes(0.1, 0.2)
	p:setGravity(400)
	p:setColors(
		255, 0, 0, 255,
		255, 0, 0, 0
	)
	p:stop()
	
	self.bloodParticleSystem = p
	
	-- Poison Pickup Effect
	local poisonImage = love.graphics.newImage("Asset/Particle/PoisonPickup.png")
	
	local p2 = love.graphics.newParticleSystem(poisonImage, 1)
	
	p2:setEmissionRate(2000)
	p2:setLifetime(0.75)
	p2:setParticleLife(0.75)
	p2:setDirection(math.pi * 1.5) -- Straight Up
	p2:setSpeed(100)
	p2:setSizes(0.75)
	p2:setColors(
		255, 255, 255, 255,
		255, 255, 255, 0
	)
	p2:stop()
	
	self.poisonParticleSystem = p2
end

function Player:reset()
	self.boundedBox.x = 100
	self.boundedBox.y = 150
	self.velocity = { x = 0, y = 0 }
	self.rotation = 0
	self.curHealth = PLAYER_HEALTH_MAX
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
		self.bloodParticleSystem:start()
	elseif instanceOf(LockedDoor, other) then
		if self.numKeys > 0 then
			SFX_DOOR_UNLOCK:rewind()
			SFX_DOOR_UNLOCK:play()
			self.numKeys = self.numKeys - 1
			other:unlock()
		else
			table.insert(self.solidCollisions, other.boundedBox)
		end
	elseif instanceOf(Key, other) then
		SFX_KEY_PICKUP:rewind()
		SFX_KEY_PICKUP:play()
		self.numKeys = self.numKeys + 1
		other:pickup()
	elseif instanceOf(RiceBall, other) and self.curHealth < PLAYER_HEALTH_MAX then
		SFX_HEALTH_PICKUP:rewind()
		SFX_HEALTH_PICKUP:play()
		self:setHealth(self.curHealth + RICE_BALL_HEALTH_VALUE)
		other:pickup()
	elseif instanceOf(PoisonRiceBall, other) then
		SFX_POISON_PICKUP:rewind()
		SFX_POISON_PICKUP:play()
		self:setHealth(self.curHealth - POISON_RICE_BALL_HEALTH_VALUE)
		other:pickup()
		
		self.poisonParticleSystem:setPosition(self.boundedBox.x + PLAYER_WIDTH / 2, self.boundedBox.y + PLAYER_HEIGHT / 2)
		self.poisonParticleSystem:start()
	elseif instanceOf(Enemy, other) then
		self:setHealth(self.curHealth - ENEMY_HEALTH_DRAIN_VALUE)
		
		self.bloodParticleSystem:setPosition(self.boundedBox.x + PLAYER_WIDTH / 2, self.boundedBox.y + PLAYER_HEIGHT / 2)
		self.bloodParticleSystem:start()
	elseif instanceOf(LevelExit, other) then
		SFX_LEVEL_PROGRESS:rewind()
		SFX_LEVEL_PROGRESS:play()
		self.goToNextLevel = true
	end
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
	
	self.poisonParticleSystem:update(dt)
	if not self.poisonParticleSystem:isActive() then
		self.poisonParticleSystem:reset()
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
	love.graphics.setColor(255, 255, 255)
	-- love.graphics.rectangle("fill", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
	
	self.animations[self.rotation]:draw(self.boundedBox.x - PLAYER_SPRITE_OFFSET, self.boundedBox.y - PLAYER_SPRITE_OFFSET)
	
	love.graphics.draw(self.bloodParticleSystem)
	love.graphics.draw(self.poisonParticleSystem)
end
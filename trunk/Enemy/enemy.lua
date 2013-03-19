require "Lib/AnAL"
require "soundLibrary"

Enemy = class("Enemy")

ENEMY_WIDTH = 32
ENEMY_HEIGHT = 32
ENEMY_SPRITE_OFFSET = 0

ENEMY_SPEED = 50
ENEMY_STATE_TIMER_MIN = 1.0
ENEMY_STATE_TIMER_MAX = 1.5
ENEMY_ONSCREEN_TIMER = 4

ENEMY_PURSUE_PLAYER_DISTANCE = 96
ENEMY_HEALTH_DRAIN_VALUE = 2

ENEMY_ANIMATION_DELAY = 0.2

ENEMY_SPRITESHEET = {}
ENEMY_SPRITESHEET[1] = love.graphics.newImage("Asset/Graphic/Enemy/EnemySpriteSheetLevel1.png")
ENEMY_SPRITESHEET[2] = love.graphics.newImage("Asset/Graphic/Enemy/EnemySpriteSheetLevel2.png")
ENEMY_SPRITESHEET[3] = love.graphics.newImage("Asset/Graphic/Enemy/EnemySpriteSheetLevel3.png")
ENEMY_SPRITESHEET[4] = love.graphics.newImage("Asset/Graphic/Enemy/EnemySpriteSheetLevel4.png")
ENEMY_SPRITESHEET[5] = love.graphics.newImage("Asset/Graphic/Enemy/EnemySpriteSheetLevel5.png")

function Enemy:initialize(x, y, level)
	self.boundedBox = {
		x = x + ENEMY_SPRITE_OFFSET,
		y = y + ENEMY_SPRITE_OFFSET,
		width = ENEMY_WIDTH,
		height = ENEMY_HEIGHT,
		parent = self
	}
	bump.add(self.boundedBox)
	
	self.velocity = {
		x = 0,
		y = 0
	}
	self.rotation = 0
	
	self.solidCollisions = {}
	
	self.changeStateTimer = 0
	self.hasBeenSeen = false
	self.onScreenTimer = 0
	self.doAnimation = false
	
	self.level = level
	self.alive = true
	
	self:initializeAnimations()
end

function Enemy:initializeAnimations()
	self.animations = {}
	
	for level = 1, 5 do
		self.animations[level] = {}
		self.animations[level][0] = newAnimation(ENEMY_SPRITESHEET[level], 0, 32 * 0, 32, 32, ENEMY_ANIMATION_DELAY, 4)
		self.animations[level][45] = newAnimation(ENEMY_SPRITESHEET[level], 0, 32 * 1, 32, 32, ENEMY_ANIMATION_DELAY, 4)
		self.animations[level][90] = newAnimation(ENEMY_SPRITESHEET[level], 0, 32 * 2, 32, 32, ENEMY_ANIMATION_DELAY, 4)
		self.animations[level][135] = newAnimation(ENEMY_SPRITESHEET[level], 0, 32 * 3, 32, 32, ENEMY_ANIMATION_DELAY, 4)
		self.animations[level][180] = newAnimation(ENEMY_SPRITESHEET[level], 0, 32 * 4, 32, 32, ENEMY_ANIMATION_DELAY, 4)
		self.animations[level][225] = newAnimation(ENEMY_SPRITESHEET[level], 0, 32 * 5, 32, 32, ENEMY_ANIMATION_DELAY, 4)
		self.animations[level][270] = newAnimation(ENEMY_SPRITESHEET[level], 0, 32 * 6, 32, 32, ENEMY_ANIMATION_DELAY, 4)
		self.animations[level][315] = newAnimation(ENEMY_SPRITESHEET[level], 0, 32 * 7, 32, 32, ENEMY_ANIMATION_DELAY, 4)
		self.animations[level][360] = newAnimation(ENEMY_SPRITESHEET[level], 0, 32 * 0, 32, 32, ENEMY_ANIMATION_DELAY, 4)
	end
end

function Enemy:onCollision(dt, other, dx, dy)
	if instanceOf(Wall, other) or instanceOf(Enemy, other) or instanceOf(EnemySpawner, other) or instanceOf(LockedDoor, other) then
		table.insert(self.solidCollisions, other.boundedBox)
	elseif instanceOf(Bullet, other) or instanceOf(Player, other) then
		SFX_ENEMY_HIT:rewind()
		SFX_ENEMY_HIT:play()
		self.level = self.level - 1
		if self.level <= 0 then
			self.alive = false
		end
	end
end

function Enemy:update(dt, playerPosition, onScreen)
	self.doAnimation = false
	
	self.solidCollisions = {}
	self:updateVelocity(dt, playerPosition)
	self:updateRotation()
	self:updatePosition(dt)
	self:updateOnScreenTimers(dt, onScreen)
	
	if self.doAnimation and self.alive then
		self.animations[self.level][self.rotation]:play()
		self.animations[self.level][self.rotation]:update(dt)
	end
end

function Enemy:updateVelocity(dt, playerPosition)
	local vx = 0
	local vy = 0
	
	if math.dist(playerPosition.x, playerPosition.y, self.boundedBox.x, self.boundedBox.y) > ENEMY_PURSUE_PLAYER_DISTANCE then
		-- Move Randomly
		self.changeStateTimer = self.changeStateTimer - dt
		
		if self.changeStateTimer <= 0 then
			self.changeStateTimer = math.random(ENEMY_STATE_TIMER_MIN, ENEMY_STATE_TIMER_MAX)
			local newState = math.random(3)
			
			if newState == 1  or newState == 2 then --Move
				local newDirection = math.rad(math.random(0, 7) * 45)
			
				vx = math.cos(newDirection)
				vy = math.sin(newDirection)
				
				self.velocity.x = vx * ENEMY_SPEED
				self.velocity.y = vy * ENEMY_SPEED
			elseif newState == 3 then --Wait
				self.velocity.x = 0
				self.velocity.y = 0
			end
		end
	else
		-- Chase Player
		local newDirection = math.atan2(self.boundedBox.y - playerPosition.y, self.boundedBox.x - playerPosition.x) + math.pi
		
		if newDirection < math.pi * 1/8 then
			newDirection = 0
		elseif newDirection < math.pi * 3/8 then
			newDirection = math.pi * 2/8
		elseif newDirection < math.pi * 5/8 then
			newDirection = math.pi * 4/8
		elseif newDirection < math.pi * 7/8 then
			newDirection = math.pi * 6/8
		elseif newDirection < math.pi * 9/8 then
			newDirection = math.pi * 8/8
		elseif newDirection < math.pi * 11/8 then
			newDirection = math.pi * 10/8
		elseif newDirection < math.pi * 13/8 then
			newDirection = math.pi * 12/8
		elseif newDirection < math.pi * 15/8 then
			newDirection = math.pi * 14/8
		else
			newDirection = math.pi * 2
		end
		
		vx = math.cos(newDirection)
		vy = math.sin(newDirection)
		
		self.velocity.x = vx * ENEMY_SPEED
		self.velocity.y = vy * ENEMY_SPEED
	end
end

function Enemy:updateRotation()
	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
		self.doAnimation = true
		self.rotation = math.ceil(math.deg(math.atan2(self.velocity.y, self.velocity.x)))
		if self.rotation < 0 then
			self.rotation = self.rotation + 360
		end
	end
end

function Enemy:updatePosition(dt)
	self.boundedBox.x = self.boundedBox.x + self.velocity.x * dt
	self.boundedBox.y = self.boundedBox.y + self.velocity.y * dt
end

function Enemy:updateSolidCollisions(dt)
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
				self.boundedBox.x = otherCollision.x - ENEMY_WIDTH
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
				self.boundedBox.y = otherCollision.y - ENEMY_HEIGHT
			elseif self.velocity.y < 0 then --Moving Left
				self.boundedBox.y = otherCollision.y + otherCollision.height
			end
			
			self.velocity.y = 0
		end
	end
end

function Enemy:updateOnScreenTimers(dt, onScreen)
	-- The enemy has been seen, get the timer ready
	if onScreen then
		self.onScreenTimer = ENEMY_ONSCREEN_TIMER
		self.hasBeenSeen = true
	-- The enemy has been seen, but is no longer in view. Countdown and despawn
	elseif self.hasBeenSeen then
		self.onScreenTimer = self.onScreenTimer - dt
		if self.onScreenTimer <= 0 then
			self.alive = false;
		end
	end
end

function Enemy:draw()
	love.graphics.setColor(255, 255, 255)
	-- love.graphics.rectangle("fill", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
	
	if self.alive then
		self.animations[self.level][self.rotation]:draw(self.boundedBox.x - ENEMY_SPRITE_OFFSET, self.boundedBox.y - ENEMY_SPRITE_OFFSET)
	end
end
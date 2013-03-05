Enemy = class("Enemy")

ENEMY_WIDTH = 32
ENEMY_HEIGHT = 32

ENEMY_SPEED = 200

ENEMY_SPRITESHEET = love.graphics.newImage("Graphic/EnemySpriteSheet.png")

function Enemy:initialize(x, y, level)
	self.boundedBox = {
		x = x,
		y = y,
		width = PLAYER_WIDTH,
		height = PLAYER_HEIGHT,
		parent = self
	}
	bump.add(self.boundedBox)
	
	self.velocity = {
		x = 0,
		y = 0
	}
	self.rotation = 0
	
	self.solidCollisions = {}
	
	self.level = level
	self.alive = true
end

function Enemy:onCollision(dt, other, dx, dy)
	if instanceOf(Wall, other) then
		table.insert(self.solidCollisions, other.boundedBox)
	end
end

function Enemy:update(dt, playerPosition)
	self.solidCollisions = {}
	self:updateVelocity(playerPosition)
	self:updateRotation()
	self:updatePosition(dt)
end

function Enemy:updateVelocity(playerPosition)
	local vx = 0
	local vy = 0
	
	-- Move around randomly or move towards (playerPosition.x, playerPosition.y)
	
	self.velocity.x = vx * ENEMY_SPEED
	self.velocity.y = vy * ENEMY_SPEED
end

function Enemy:updateRotation()
	if self.velocity.x ~= 0 or self.velocity.y ~= 0 then
		self.rotation = math.atan2(self.velocity.y, self.velocity.x)
	end
end

function Enemy:updatePosition(dt)
	self.boundedBox.x = self.boundedBox.x + self.velocity.x * dt
	self.boundedBox.y = self.boundedBox.y + self.velocity.y * dt
end

function Enemy:draw()
	love.graphics.rectangle("fill", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
	
	local quad = love.graphics.newQuad(
		(self.level - 1) * ENEMY_WIDTH,
		0,
		ENEMY_WIDTH,
		ENEMY_HEIGHT,
		ENEMY_SPRITESHEET:getWidth(),
		ENEMY_SPRITESHEET:getHeight()
	)
	
	love.graphics.drawq(
		ENEMY_SPRITESHEET,
		quad,
		self.boundedBox.x + ENEMY_WIDTH / 2,
		self.boundedBox.y + ENEMY_HEIGHT / 2,
		self.rotation,
		1,
		1,
		ENEMY_WIDTH / 2,
		ENEMY_HEIGHT / 2
	)
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
		end
	end
end
Player = class("Player")

PLAYER_WIDTH = 26
PLAYER_HEIGHT = 26
PLAYER_SPRITE_OFFSET = 3
PLAYER_SPEED = 100

function Player:initialize()
	self.boundedBox = {
		x = 100,
		y = 150,
		width = PLAYER_WIDTH,
		height = PLAYER_HEIGHT,
		parent = self
	}
	bump.add(self.boundedBox)
	
	self.velocity = { x = 0, y = 0 }
	self.rotation = 0
	self.image = love.graphics.newImage("Graphic/Player.png")
	
	self.curHealth = 100
	self.numKeys = 0
	
	self.leftPressed = false;
	self.rightPressed = false;
	self.upPressed = false;
	self.downPressed = false;
	
	self.solidCollisions = {}
end

function Player:reset()
	self.boundedBox.x = 100
	self.boundedBox.y = 150
	self.velocity = { x = 0, y = 0 }
	self.rotation = 0
	self.curHealth = 100
	self.numKeys = 0
	
	self.leftPressed = false;
	self.rightPressed = false;
	self.upPressed = false;
	self.downPressed = false;
	
	self.solidCollisions = {}
	
	bump.add(self.boundedBox)
end

function Player:onCollision(dt, other, dx, dy)
	if instanceOf(Wall, other) or instanceOf(EnemySpawner, other) then
		table.insert(self.solidCollisions, other.boundedBox)
	elseif instanceOf(LockedDoor, other) then
		if self.numKeys > 0 then
			self.numKeys = self.numKeys - 1
			other:unlock()
		else
			table.insert(self.solidCollisions, other.boundedBox)
		end
	elseif instanceOf(Enemy, other) then
		-- Reduce Health
	end
end

function Player:update(dt)
	self.solidCollisions = {}
	self:updateVelocity()
	self:updateRotation()
	self:updatePosition(dt)
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
		self.rotation = math.atan2(self.velocity.y, self.velocity.x)
	end
end

function Player:updatePosition(dt)
	self.boundedBox.x = self.boundedBox.x + self.velocity.x * dt
	self.boundedBox.y = self.boundedBox.y + self.velocity.y * dt
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
		end
	end
end

function Player:draw()
	love.graphics.setColor(255, 255, 255)
	--love.graphics.rectangle("fill", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
	love.graphics.draw(
		self.image,
		self.boundedBox.x + PLAYER_WIDTH / 2,
		self.boundedBox.y + PLAYER_HEIGHT / 2,
		self.rotation,
		1,
		1,
		PLAYER_WIDTH / 2 + PLAYER_SPRITE_OFFSET,
		PLAYER_HEIGHT / 2 + PLAYER_SPRITE_OFFSET
	)
	
	
end
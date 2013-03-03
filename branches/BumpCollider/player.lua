Player = class("Player")

PLAYER_WIDTH = 32
PLAYER_HEIGHT = 32
PLAYER_SPEED = 200

function Player:initialize()
	self.boundedBox = {
		x = 100,
		y = 100,
		width = PLAYER_WIDTH,
		height = PLAYER_HEIGHT,
		parent = self
	}
	BUMP.add(self.boundedBox)
	
	self.velocity = { x = 0, y = 0 }
	
	self.image = love.graphics.newImage("Graphic/Player.png")
	self.rotation = 0
	
	self.leftPressed = false;
	self.rightPressed = false;
	self.upPressed = false;
	self.downPressed = false;
end

function Player:onCollision(dt, other, dx, dy)
	if instanceOf(Wall, other) then
		self.boundedBox.x = self.boundedBox.x + dx
		self.boundedBox.y = self.boundedBox.y + dy
		
		print(dx .. ", " .. dy)
	end
end

function Player:update(dt)
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
		local vectorLength = math.sqrt(vx^2 + vy^2)
		
		vx = vx / vectorLength
		vy = vy / vectorLength
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

function Player:draw()
	love.graphics.rectangle("fill", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
	love.graphics.draw(self.image, self.boundedBox.x + PLAYER_WIDTH / 2, self.boundedBox.y + PLAYER_HEIGHT / 2, self.rotation, 1, 1, PLAYER_WIDTH / 2, PLAYER_HEIGHT / 2)
end
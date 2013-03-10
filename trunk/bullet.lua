Bullet = class("Bullet")

BULLET_WIDTH = 16
BULLET_HEIGHT = 16

BULLET_SPEED = 400
BULLET_ROTATION_SPEED = 10
BULLET_IMAGE = love.graphics.newImage("Graphic/Bullet.png")

function Bullet:initialize(x, y, direction, hudObj)
	self.boundedBox = {
		x = x - BULLET_WIDTH / 2,
		y = y - BULLET_HEIGHT / 2,
		width = BULLET_WIDTH,
		height = BULLET_HEIGHT,
		parent = self
	}
	
	bump.add(self.boundedBox)
	self.alive = true
	
	self.velocity = {
		x = math.cos(direction) * BULLET_SPEED,
		y = math.sin(direction) * BULLET_SPEED
	}
	self.rotation = 0
	
	self.hudObj = hudObj
end

function Bullet:onCollision(dt, other, dx, dy)
	if self.alive then
		if instanceOf(Wall, other) then
			self.alive = false
		elseif instanceOf(Enemy, other) or instanceOf(EnemySpawner, other) then
			self.alive = false
			self.hudObj.curScore = self.hudObj.curScore + 10
		elseif instanceOf(RiceBall, other) then
			self.alive = false
			other:pickup()
		end
	end
end

function Bullet:update(dt, screenX, screenY, screenWidth, screenHeight)
	if self.alive then
		self.boundedBox.x = self.boundedBox.x + self.velocity.x * dt
		self.boundedBox.y = self.boundedBox.y + self.velocity.y * dt
		
		if self.boundedBox.x + BULLET_WIDTH < screenX or self.boundedBox.x > screenX + screenWidth or
		self.boundedBox.y + BULLET_HEIGHT < screenY or self.boundedBox.y > screenY + screenHeight then
			self.alive = false
		end
		
		self.rotation = self.rotation + BULLET_ROTATION_SPEED * dt
		if self.rotation > 360 then
			self.rotation = self.rotation - 360
		end
	end
end

function Bullet:draw()
	love.graphics.setColor(255, 255, 255)
	
	local rotation = math.rad(self.rotation)
	love.graphics.draw(
		BULLET_IMAGE,
		self.boundedBox.x + BULLET_WIDTH / 2,
		self.boundedBox.y + BULLET_HEIGHT / 2,
		self.rotation,
		1,
		1,
		BULLET_WIDTH / 2,
		BULLET_HEIGHT / 2
	)
end
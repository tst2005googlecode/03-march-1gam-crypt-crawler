Bullet = class("Bullet")

BULLET_WIDTH = 16
BULLET_HEIGHT = 16

BULLET_SPEED = 500

function Bullet:initialize(x, y, direction, image)
	self.boundedBox = {
		x = x - BULLET_WIDTH / 2,
		y = y - BULLET_HEIGHT / 2,
		width = BULLET_WIDTH,
		height = BULLET_HEIGHT,
		parent = self
	}
	
	bump.add(self.boundedBox)
	self.image = image
	self.alive = true
	
	self.velocity = {
		x = math.cos(direction) * BULLET_SPEED,
		y = math.sin(direction) * BULLET_SPEED
	}
end

function Bullet:onCollision(dt, other, dx, dy)
	if self.alive then
		if instanceOf(Wall, other) then
			self.alive = false
		end
	end
end

function Bullet:update(dt)
	if self.alive then
		self.boundedBox.x = self.boundedBox.x + self.velocity.x * dt
		self.boundedBox.y = self.boundedBox.y + self.velocity.y * dt
	end
end

function Bullet:draw()
	if self.alive then
		love.graphics.draw(self.image, self.boundedBox.x, self.boundedBox.y)
	end
end
Bullet = class("Bullet")

BULLET_WIDTH = 16
BULLET_HEIGHT = 16

BULLET_SPEED = 500
BULLET_IMAGE = love.graphics.newImage("Graphic/Bullet.png")

function Bullet:initialize(x, y, direction)
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
end

function Bullet:onCollision(dt, other, dx, dy)
	if self.alive then
		if instanceOf(Wall, other) or instanceOf(Enemy, other) or instanceOf(EnemySpawner, other) then
			self.alive = false
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
	end
end

function Bullet:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(BULLET_IMAGE, self.boundedBox.x, self.boundedBox.y)
end
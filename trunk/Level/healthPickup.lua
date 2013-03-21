HealthPickup = class("HealthPickup")

HEALTH_PICKUP_WIDTH = 32
HEALTH_PICKUP_HEIGHT = 32

HEALTH_PICKUP_HEALTH_VALUE = 15

HEALTH_PICKUP_IMAGE = love.graphics.newImage("Asset/Graphic/HealthPickup.png")

function HealthPickup:initialize(x, y)
	self.boundedBox = {
		x = x,
		y = y,
		width = HEALTH_PICKUP_WIDTH,
		height = HEALTH_PICKUP_HEIGHT,
		parent = self
	}
	bump.addStatic(self.boundedBox)
	
	self.alive = true
end

function HealthPickup:onCollision(dt, other, dx, dy)
	
end

function HealthPickup:pickup()
	bump.remove(self.boundedBox)
	self.alive = false
end

function HealthPickup:draw()
	if self.alive then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(HEALTH_PICKUP_IMAGE, self.boundedBox.x, self.boundedBox.y)
	end
end
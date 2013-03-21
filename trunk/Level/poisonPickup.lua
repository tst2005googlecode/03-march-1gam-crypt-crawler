PoisonPickup = class("PoisonPickup")

POISON_PICKUP_HEALTH_VALUE = 25

POISON_IMAGE = love.graphics.newImage("Asset/Graphic/PoisonPickup.png")

function PoisonPickup:initialize(x, y)
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

function PoisonPickup:onCollision(dt, other, dx, dy)
	
end

function PoisonPickup:pickup()
	bump.remove(self.boundedBox)
	self.alive = false
end

function PoisonPickup:draw()
	if self.alive then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(POISON_IMAGE, self.boundedBox.x, self.boundedBox.y)
	end
end
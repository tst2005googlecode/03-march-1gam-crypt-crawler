PoisonPickup = class("PoisonPickup")

POISON_PICKUP_HEALTH_VALUE = 25

POISON_IMAGES = {}
POISON_IMAGES[0] = love.graphics.newImage("Asset/Graphic/Item/PoisonPickup1.png")
POISON_IMAGES[1] = love.graphics.newImage("Asset/Graphic/Item/PoisonPickup2.png")

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
		love.graphics.draw(POISON_IMAGES[0], self.boundedBox.x, self.boundedBox.y)
	end
end
TreasurePickup = class("TreasurePickup")

TREASURE_PICKUP_WIDTH = 32
TREASURE_PICKUP_HEIGHT = 32

TREASURE_PICKUP_POINT_VALUE = 25

TREASURE_PICKUP_IMAGES = {}
TREASURE_PICKUP_IMAGES[0] = love.graphics.newImage("Asset/Graphic/Item/TreasurePickup1.png")
TREASURE_PICKUP_IMAGES[1] = love.graphics.newImage("Asset/Graphic/Item/TreasurePickup2.png")

function TreasurePickup:initialize(x, y, imageIndex)
	self.boundedBox = {
		x = x,
		y = y,
		width = TREASURE_PICKUP_WIDTH,
		height = TREASURE_PICKUP_HEIGHT,
		parent = self
	}
	bump.addStatic(self.boundedBox)
	
	self.image = TREASURE_PICKUP_IMAGES[imageIndex]
	self.alive = true
end

function TreasurePickup:onCollision(dt, other, dx, dy)
	
end

function TreasurePickup:pickup()
	bump.remove(self.boundedBox)
	self.alive = false
end

function TreasurePickup:draw()
	if self.alive then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.image, self.boundedBox.x, self.boundedBox.y)
	end
end
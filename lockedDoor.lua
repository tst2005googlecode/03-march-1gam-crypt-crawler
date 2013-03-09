LockedDoor = class("LockedDoor")

LOCKED_DOOR_WIDTH = 32
LOCKED_DOOR_HEIGHT = 32

LOCKED_DOOR_IMAGE = love.graphics.newImage("Graphic/LockedDoor.png")

function LockedDoor:initialize(x, y)
	self.boundedBox = {
		x = x,
		y = y,
		width = LOCKED_DOOR_WIDTH,
		height = LOCKED_DOOR_HEIGHT,
		parent = self
	}
	
	bump.addStatic(self.boundedBox)
	
	self.alive = true
end

function LockedDoor:onCollision(dt, other, dx, dy)
	
end

function LockedDoor:unlock()
	bump.remove(self.boundedBox)
	self.alive = false
end

function LockedDoor:draw()
	if self.alive then
		love.graphics.draw(LOCKED_DOOR_IMAGE, self.boundedBox.x, self.boundedBox.y)
	end
end
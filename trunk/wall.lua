Wall = class("Wall")

function Wall:initialize(x, y, w, h)
	self.boundedBox = Collider:addRectangle(x, y, w, h)
	Collider:setPassive(self.boundedBox)
	self.boundedBox.parent = self
	
	self.colliding = false;
end

function Wall:onCollision(dt, other, dx, dy)
	self.colliding = true
end

function Wall:update(dt)
	self.colliding = false
end

function Wall:draw()
	love.graphics.setColor(255, 255, 255)
	
	if self.colliding then
		love.graphics.setColor(255, 0, 0)
	end
	
	self.boundedBox:draw("line")
end
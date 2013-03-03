Wall = class("Wall")

function Wall:initialize(x, y, w, h)
	self.boundedBox = {
		x = x,
		y = y,
		width = w,
		height = h,
		parent = self
	}
	BUMP.add(self.boundedBox)
	
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
	
	love.graphics.rectangle("line", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
end
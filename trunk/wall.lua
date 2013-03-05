Wall = class("Wall")

function Wall:initialize(x, y, w, h)
	self.boundedBox = {
		x = x,
		y = y,
		width = w,
		height = h,
		parent = self
	}
	bump.addStatic(self.boundedBox)
end

function Wall:onCollision(dt, other, dx, dy)
	
end

function Wall:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
end
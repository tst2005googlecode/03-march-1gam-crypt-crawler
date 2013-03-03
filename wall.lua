Wall = class("Wall")

function Wall:initialize(x, y, w, h)
	self.boundedBox = Collider:addRectangle(x, y, w, h)
	self.boundedBox.parent = self
end

function Wall:onCollision(other, dx, dy, isFirst)

end

function Wall:draw()
	love.graphics.setColor(255, 255, 255)
	self.boundedBox:draw("fill")
end
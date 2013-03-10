RiceBall = class("RiceBall")

RICE_BALL_WIDTH = 32
RICE_BALL_HEIGHT = 32

RICE_BALL_HEALTH_VALUE = 15

RICE_BALL_IMAGE = love.graphics.newImage("Graphic/RiceBall.png")

function RiceBall:initialize(x, y)
	self.boundedBox = {
		x = x,
		y = y,
		width = RICE_BALL_WIDTH,
		height = RICE_BALL_HEIGHT,
		parent = self
	}
	bump.addStatic(self.boundedBox)
	
	self.alive = true
end

function RiceBall:onCollision(dt, other, dx, dy)
	
end

function RiceBall:pickup()
	bump.remove(self.boundedBox)
	self.alive = false
end

function RiceBall:draw()
	if self.alive then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(RICE_BALL_IMAGE, self.boundedBox.x, self.boundedBox.y)
	end
end
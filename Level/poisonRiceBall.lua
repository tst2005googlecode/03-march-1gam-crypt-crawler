PoisonRiceBall = class("PoisonRiceBall")

POISON_RICE_BALL_HEALTH_VALUE = 25

POISON_RICE_BALL_IMAGE = love.graphics.newImage("Asset/Graphic/PoisonRiceBall.png")

function PoisonRiceBall:initialize(x, y)
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

function PoisonRiceBall:onCollision(dt, other, dx, dy)
	
end

function PoisonRiceBall:pickup()
	bump.remove(self.boundedBox)
	self.alive = false
end

function PoisonRiceBall:draw()
	if self.alive then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(POISON_RICE_BALL_IMAGE, self.boundedBox.x, self.boundedBox.y)
	end
end
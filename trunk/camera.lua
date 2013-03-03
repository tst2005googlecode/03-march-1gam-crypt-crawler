Camera = class("Camera")

function Camera:initialize(width, height)
	self.x = 0
	self.y = 0
	self.scaleX = 1
	self.scaleY = 1
	self.rotation = 0
	self.bounds = {
		x1 = 0,
		y1 = 0,
		x2 = width * TILE_SIZE - SCREEN_WIDTH,
		y2 = height * TILE_SIZE - SCREEN_HEIGHT
	}
	
	local followBoxHMargin = 300
	local followBoxVMargin = 250
	
	self.followBox = {
		left = followBoxHMargin,
		top = followBoxVMargin,
		right = SCREEN_WIDTH - followBoxHMargin,
		bottom = SCREEN_HEIGHT - followBoxVMargin
	}
	
	print(self.bounds.x2)
end

function Camera:set()
	love.graphics.push()
	love.graphics.rotate(-self.rotation)
	love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
	love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
	love.graphics.pop()
end

function Camera:move(dx, dy)
	self:setX(self.x + (dx or 0))
	self:setY(self.y + (dy or 0))
end

function Camera:rotate(dr)
	self.rotation = self.rotation + dr
end

function Camera:scale(sx, sy)
	sx = sx or 1
	self.scaleX = self.scaleX * sx
	self.scaleY = self.scaleY * (sy or sx)
end

function Camera:setPosition(x, y)
	if x then self:setX(x) end
	if y then self:setY(y) end
end

function Camera:setRotation(r)
	self.rotation = r
end

function Camera:setScale(sx, sy)
	self.scaleX = sx or self.scaleX
	self.scaleY = sy or self.scaleY
end

function Camera:setX(value)
	if self.bounds then
		self.x = math.clamp(value, self.bounds.x1, self.bounds.x2)
	else
		self.x = value
	end
end

function Camera:setY(value)
	if self.bounds then
		self.y = math.clamp(value, self.bounds.y1, self.bounds.y2)
	else
		self.y = value
	end
end

function Camera:update(followX, followY)
	if self.x + self.followBox.left > followX then --Target is too far left
		self:setX(followX - self.followBox.left)
	end
	
	if self.x + self.followBox.right < followX then --Target is too far right
		self:setX(followX - self.followBox.right)
	end
	
	if self.y + self.followBox.top > followY then --Target is too far up
		self:setY(followY - self.followBox.top)
	end
	
	if self.y + self.followBox.bottom < followY then --Target is too far down
		self:setY(followY - self.followBox.bottom)
	end
end
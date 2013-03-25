Camera = class("Camera")

function Camera:initialize()
	self.x = 0
	self.y = 0
	self.scaleX = 1
	self.scaleY = 1
	self.rotation = 0
	self.bounds = {
		x1 = 0,
		y1 = 0,
		x2 = 0,
		y2 = 0
	}
	
	local followBoxHMargin = CAMERA_HMARGIN
	local followBoxVMargin = CAMERA_VMARGIN
	
	self.followBox = {
		left = followBoxHMargin,
		top = followBoxVMargin,
		right = SCREEN_WIDTH * CAMERA_SCALE - followBoxHMargin,
		bottom = SCREEN_HEIGHT * CAMERA_SCALE - followBoxVMargin
	}
end

function Camera:setBounds(x, y)
	self.bounds.x2 = x * TILE_SIZE - SCREEN_WIDTH * CAMERA_SCALE
	self.bounds.y2 = y * TILE_SIZE - SCREEN_HEIGHT * CAMERA_SCALE
end

function Camera:reset()
	self.x = 0
	self.y = 0
	self.bounds.x2 = 0
	self.bounds.y2 = 0
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
	local cameraMoved = false
	
	if self.x + self.followBox.left > followX then --Target is too far left
		self:setX(followX - self.followBox.left)
		cameraMoved = true
	end
	
	if self.x + self.followBox.right < followX then --Target is too far right
		self:setX(followX - self.followBox.right)
		cameraMoved = true
	end
	
	if self.y + self.followBox.top > followY then --Target is too far up
		self:setY(followY - self.followBox.top)
		cameraMoved = true
	end
	
	if self.y + self.followBox.bottom < followY then --Target is too far down
		self:setY(followY - self.followBox.bottom)
		cameraMoved = true
	end
	
	return cameraMoved
end

function Camera:draw()
	love.graphics.setColor(150, 150, 150)
	love.graphics.rectangle("line", self.x + self.followBox.left, self.y + self.followBox.top, self.followBox.right - self.followBox.left, self.followBox.bottom - self.followBox.top)
end
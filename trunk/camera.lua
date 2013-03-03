Camera = class("Camera")

function Camera:initialize(width, height)
	self.worldWidth = width * TILE_SIZE
	self.worldHeight = height * TILE_SIZE
	
	print(self.worldWidth .. ", " .. self.worldHeight)
end
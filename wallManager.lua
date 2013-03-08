WallManager = class("WallManager")

require "wall"

function WallManager:initialize()
	self.walls = {}
	self.width = 0
	self.height = 0
end

function WallManager:reset()
	self.walls = {}
	self.width = 0
	self.height = 0
end

function WallManager:addWall(x, y)
	table.insert(self.walls, Wall:new((x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE))
end

function WallManager:update(dt)
	for index, wall in ipairs(self.walls) do
		wall:update(dt)
	end
end

function WallManager:draw()
	for index, wall in ipairs(self.walls) do
		wall:draw()
	end
end
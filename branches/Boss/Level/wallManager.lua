WallManager = class("WallManager")

require "Level/wall"

function WallManager:initialize()
	self.walls = {}
	self.width = 0
	self.height = 0
end

function WallManager:reset()
	for index, wall in ipairs(self.walls) do
		bump.remove(wall.boundedBox)
	end
	self.walls = {}
	self.width = 0
	self.height = 0
end

function WallManager:addWall(x, y)
	table.insert(self.walls, Wall:new(x, y, TILE_SIZE, TILE_SIZE))
end

function WallManager:update(dt)
	
end

function WallManager:draw()
	for index, wall in ipairs(self.walls) do
		wall:draw()
	end
end
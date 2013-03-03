WallManager = class("WallManager")

require "wall"

function WallManager:initialize()
	self.walls = {}
	
	table.insert(self.walls, Wall:new(0, 0, SCREEN_WIDTH, TILE_SIZE)) --Top
	table.insert(self.walls, Wall:new(0, SCREEN_HEIGHT - TILE_SIZE, SCREEN_WIDTH, TILE_SIZE)) --Bottom
	table.insert(self.walls, Wall:new(0, 0, TILE_SIZE, SCREEN_HEIGHT)) --Left
	table.insert(self.walls, Wall:new(SCREEN_WIDTH - TILE_SIZE, 0, TILE_SIZE, SCREEN_HEIGHT)) --Right
end

function WallManager:draw()
	for index, wall in ipairs(self.walls) do
		wall:draw()
	end
end
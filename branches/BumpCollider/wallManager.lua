WallManager = class("WallManager")

require "wall"

function WallManager:initialize()
	self.walls = {}
	
	wallFile = love.filesystem.newFile("Data/Level1.csv")
	wallFile:open('r')
	fileContents = wallFile:read()
	
	local lineData = string.explode(fileContents, "\r\n")
	
	for y, line in ipairs(lineData) do
		local data = string.explode(line, ",")
		for x, value in ipairs(data) do
			if string.find(value, "1") ~= nil then
				table.insert(self.walls, Wall:new((x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE))
			end
		end
	end
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
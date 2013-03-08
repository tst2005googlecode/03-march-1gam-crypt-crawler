WallManager = class("WallManager")

require "wall"

function WallManager:initialize()
	self.walls = {}
	self.width = 0
	self.height = 0
	
	wallFile = love.filesystem.newFile("Data/Level1.csv")
	wallFile:open('r')
	fileContents = wallFile:read()
	
	local lineData = string.explode(fileContents:sub(0, string.len(fileContents) - 2), "\r\n")
	self.height = #lineData
	
	for y, line in ipairs(lineData) do
		local data = string.explode(line, ",")
		self.width = #data
		for x, value in ipairs(data) do
			if string.find(value, "1") ~= nil then
				table.insert(self.walls, Wall:new((x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE))
			end
		end
	end
	
	wallFile:close()
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
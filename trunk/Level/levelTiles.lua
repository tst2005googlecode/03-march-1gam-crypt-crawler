LevelTiles = class("LevelTiles")

NUM_TILES_HORIZONTAL = 32
NUM_TILES_VERTICAL = 32

NUM_TILE_SPRITES = NUM_TILES_HORIZONTAL * NUM_TILES_VERTICAL

function LevelTiles:initialize()
	self.tilesetImage = love.graphics.newImage("Asset/Graphic/LevelTiles.png")
	self.tilesetImage:setFilter("nearest", "linear")
	
	self.tileQuads = {}
	
	-- Floor
	self.tileQuads[0] = love.graphics.newQuad(
		0 * TILE_SIZE,
		0 * TILE_SIZE,
		TILE_SIZE + 1,
		TILE_SIZE + 1,
		self.tilesetImage:getWidth(),
		self.tilesetImage:getHeight()
	)
	
	-- Wall
	self.tileQuads[1] = love.graphics.newQuad(
		1 * TILE_SIZE + 2,
		0 * TILE_SIZE,
		TILE_SIZE + 1,
		TILE_SIZE + 1,
		self.tilesetImage:getWidth(),
		self.tilesetImage:getHeight()
	)
	
	self.tilesetBatch = love.graphics.newSpriteBatch(self.tilesetImage, NUM_TILE_SPRITES)
end

function LevelTiles:reset()
	self.tilesetBatch:clear()
end

function LevelTiles:addTile(x, y, value)
	if string.find(value, "T0") ~= nil then
		self.tilesetBatch:addq(self.tileQuads[0], x, y)
	end
	if string.find(value, "T1") ~= nil then
		self.tilesetBatch:addq(self.tileQuads[1], x, y)
	end
end

function LevelTiles:draw()
	love.graphics.draw(self.tilesetBatch, 0, 0)
end
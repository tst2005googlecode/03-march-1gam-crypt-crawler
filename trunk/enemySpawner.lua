EnemySpawner = class("EnemySpawner")

ENEMY_SPAWNER_WIDTH = 32
ENEMY_SPAWNER_HEIGHT = 32

SPAWN_TIMER_MIN = 2.0
SPAWN_TIMER_MAX = 4.0

SPAWNER_IMAGE = love.graphics.newImage("Graphic/Spawner.png")

function EnemySpawner:initialize(x, y, level)
	self.boundedBox = {
		x = x,
		y = y,
		width = ENEMY_SPAWNER_WIDTH,
		height = ENEMY_SPAWNER_HEIGHT,
		parent = self
	}
	bump.add(self.boundedBox)
	
	self.level = level
	self.alive = true
	self.spawnTimer = math.random(SPAWN_TIMER_MIN, SPAWN_TIMER_MAX)
end

function EnemySpawner:onCollision(dt, other, dx, dy)
	if instanceOf(Bullet, other) then
		self.level = self.level - 1
		if self.level <= 0 then
			self.alive = false
		end
	end
end

function EnemySpawner:resetTimer()
	self.spawnTimer = math.random(SPAWN_TIMER_MIN, SPAWN_TIMER_MAX)
end

function EnemySpawner:getRandomSpawnPosition()
	local spawnDirection = math.rad(math.random(0, 3) * 90)
	
	local spawnX = math.round(math.cos(spawnDirection))
	local spawnY = math.round(math.sin(spawnDirection))
	
	spawnX = self.boundedBox.x + spawnX * ENEMY_SPAWNER_WIDTH
	spawnY = self.boundedBox.y + spawnY * ENEMY_SPAWNER_HEIGHT
	
	return spawnX, spawnY
end

function EnemySpawner:update(dt)
	if self.spawnTimer > 0 then
		self.spawnTimer = self.spawnTimer - dt
	end
end

function EnemySpawner:draw()
	love.graphics.setColor(255, 255, 255)
	-- love.graphics.rectangle("fill", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
	
	local quad = love.graphics.newQuad(
		(self.level - 1) * 32,
		0,
		32,
		32,
		SPAWNER_IMAGE:getWidth(),
		SPAWNER_IMAGE:getHeight()
	)
	
	love.graphics.drawq(
		SPAWNER_IMAGE,
		quad,
		self.boundedBox.x,
		self.boundedBox.y
	)
end
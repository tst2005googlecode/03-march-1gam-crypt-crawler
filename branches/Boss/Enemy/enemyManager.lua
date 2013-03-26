require "Enemy/enemySpawner"
require "Enemy/enemy"

EnemyManager = class("EnemyManager")

function EnemyManager:initialize()
	self.enemies = {}
	self.spawners = {}
end

function EnemyManager:reset()
	for i, enemy in ipairs(self.enemies) do
		bump.remove(enemy.boundedBox)
	end
	
	for i, spawner in ipairs(self.spawners) do
		bump.remove(spawner.boundedBox)
	end
	
	self.enemies = {}
	self.spawners = {}
end

function EnemyManager:addEnemy(x, y, level)
	table.insert(self.enemies, Enemy:new(x, y, level))
end

function EnemyManager:addSpawner(x, y, level)
	table.insert(self.spawners, EnemySpawner:new(x, y, level))
end

function EnemyManager:update(dt, cameraBox, playerPosition)
	self:spawnEnemies(dt, cameraBox)
	self:updateEnemies(dt, cameraBox, playerPosition)
end

function EnemyManager:spawnEnemies(dt, cameraBox)
	for index, spawner in ipairs(self.spawners) do
		if bump.doesCollide(spawner.boundedBox, cameraBox) then
			spawner:update(dt)
			
			if spawner.spawnTimer <= 0 then
				local x, y = spawner:getRandomSpawnPosition()
				local testBox = {
					x = x,
					y = y,
					width = ENEMY_WIDTH,
					height = ENEMY_HEIGHT
				}
				local isFree = true
				
				for i, enemy in ipairs(self.enemies) do
					if bump.doesCollide(testBox, enemy.boundedBox) then
						isFree = false
					end
				end
				
				if isFree then
					self:addEnemy(x, y, spawner.level)
				end
				
				spawner:resetTimer()
			end
		end
		
		if not spawner.alive then
			table.remove(self.spawners, index)
			bump.remove(spawner.boundedBox)
		end
	end
end

function EnemyManager:updateEnemies(dt, cameraBox, playerPosition)
	for index, enemy in ipairs(self.enemies) do
		local onScreen = bump.doesCollide(enemy.boundedBox, cameraBox)
		
		if enemy.alive and bump.doesCollide(enemy.boundedBox, cameraBox) then
			enemy:update(dt, playerPosition, onScreen)
		end
		
		if not enemy.alive then
			table.remove(self.enemies, index)
			bump.remove(enemy.boundedBox)
		end
	end
end

function EnemyManager:updateSolidCollisions(dt, cameraBox)
	for index, enemy in ipairs(self.enemies) do
		if bump.doesCollide(enemy.boundedBox, cameraBox) and enemy.alive then
			enemy:updateSolidCollisions(dt)
		end
	end
end

function EnemyManager:draw(cameraBox)
	for index, spawner in ipairs(self.spawners) do
		if spawner.alive and bump.doesCollide(spawner.boundedBox, cameraBox) then
			spawner:draw()
		end
	end
	
	for index, enemy in ipairs(self.enemies) do
		if enemy.alive and bump.doesCollide(enemy.boundedBox, cameraBox) then
			enemy:draw()
		end
	end
end
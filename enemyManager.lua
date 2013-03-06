require "Enemy"

EnemyManager = class("EnemyManager")

function EnemyManager:initialize()
	self.enemies = {}
	self.spawners = {}
	
	table.insert(self.enemies, Enemy:new(200, 200, 1))
end

function EnemyManager:update(dt, cameraBox, playerPosition)
	self:spawnEnemies(dt, cameraBox)
	self:updateEnemies(dt, cameraBox, playerPosition)
end

function EnemyManager:spawnEnemies(dt, cameraBox)
	
end

function EnemyManager:updateEnemies(dt, cameraBox, playerPosition)
	for index, enemy in ipairs(self.enemies) do
		if bump.doesCollide(enemy.boundedBox, cameraBox) then
			enemy:update(dt, playerPosition)
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
	for index, enemy in ipairs(self.enemies) do
		if enemy.alive and bump.doesCollide(enemy.boundedBox, cameraBox) then
			enemy:draw()
		end
	end
end
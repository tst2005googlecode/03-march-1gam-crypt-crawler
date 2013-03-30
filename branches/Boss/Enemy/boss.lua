Boss = class("Boss")

require "Enemy/bossBullet"

BOSS_WIDTH = 128
BOSS_HEIGHT = 128
BOSS_SPRITE_OFFSET_X = 0
BOSS_SPRITE_OFFSET_Y = 0

BOSS_START_X = 100
BOSS_START_Y = 100

BOSS_INVULN_TIMER = 1
BOSS_MAX_HEALTH = 100
BOSS_HEALTH_DECREMENT = 5
BOSS_MOVEMENT_SPEED = 150
BOSS_MIN_DISTANCE_TO_TARGET = 30

BOSS_ATTACK_TIMER_MIN = 1
BOSS_ATTACK_TIMER_MAX = 5

function Boss:initialize(enemyManager)
	self.enemyManager = enemyManager
	self.active = false
	self.alive = true
	
	self.boundedBox = {
		x = -1000,
		y = -1000,
		width = BOSS_WIDTH,
		height = BOSS_HEIGHT,
		parent = self
	}
	
	self.health = BOSS_MAX_HEALTH
	self.invulnTimer = 0
	
	self.targetPoints = {}
	self.targetPoints[1] = { -- Top
		x = 448,
		y = 128,
		nextPoints = { 2, 3, 4 }
	}
	self.targetPoints[2] = { -- Left
		x = 64,
		y = 512,
		nextPoints = { 1, 3, 5 }
	}
	self.targetPoints[3] = { -- Middle
		x = 448,
		y = 512,
		nextPoints = { 1, 2, 4, 5 }
	}
	self.targetPoints[4] = { -- Right
		x = 832,
		y = 512,
		nextPoints = { 1, 3, 5 }
	}
	self.targetPoints[5] = { -- Bottom
		x = 448,
		y = 832,
		nextPoints = { 2, 3, 4 }
	}
	
	self.curTarget = self.targetPoints[1]
	
	self.bossBullets = {}
	self.bossEnemies = {}
	
	self.attackTimer = math.random() * (BOSS_ATTACK_TIMER_MAX - BOSS_ATTACK_TIMER_MIN) + BOSS_ATTACK_TIMER_MIN
end

function Boss:reset()
	self.boundedBox.x = -1000
	self.boundedBox.y = -1000
	
	bump.remove(self.boundedBox)
	self.curTarget = self.targetPoints[1]
	
	for i, bullet in ipairs(self.bossBullets) do
		bump.remove(bullet.boundedBox)
	end
	for i, enemy in ipairs(self.bossEnemies) do
		bump.remove(enemy.boundedBox)
	end
	
	self.bossBullets = {}
	self.bossEnemies = {}
	
	self.active = false
	self.alive = true
end

function Boss:activate()
	self.boundedBox.x = self.curTarget.x
	self.boundedBox.y = self.curTarget.y
	self:checkMovementTarget()
	
	bump.add(self.boundedBox)
	self.active = true
end

function Boss:onCollision(dt, other, dx, dy)
	if self.active then
		if instanceOf(Bullet, other) then
			if self.invulnTimer <= 0 then
				self.health = self.health - BOSS_HEALTH_DECREMENT
				
				if self.health <= 0 then
					self.alive = false
				else
					self.invulnTimer = BOSS_INVULN_TIMER
				end
			end
		elseif instanceOf(Player, other) then
			other:hitByEnemy()
		end
	end
end

function Boss:update(dt, playerX, playerY)
	if self.active then
		if self.invulnTimer > 0 then
			self.invulnTimer = self.invulnTimer - dt
		end
		
		self:updateMovement(dt)
		self:checkMovementTarget()
		
		self:tryAttack(dt, playerX, playerY)
		
		for index, enemy in ipairs(self.bossEnemies) do
			enemy:update(dt, {x = playerX, y = playerY}, true)
			
			if not enemy.alive then
				table.remove(self.bossEnemies, index)
				bump.remove(enemy.boundedBox)
			end
		end
		
		for index, bullet in ipairs(self.bossBullets) do
			bullet:update(dt)
			
			if not bullet.alive then
				table.remove(self.bossBullets, index)
				bump.remove(bullet.boundedBox)
			end
		end
	end
end

function Boss:updateMovement(dt)
	local vx = self.curTarget.x - self.boundedBox.x
	local vy = self.curTarget.y - self.boundedBox.y
	
	vx, vy = math.normalize(vx, vy)
	
	vx = vx * BOSS_MOVEMENT_SPEED * dt
	vy = vy * BOSS_MOVEMENT_SPEED * dt
	
	self.boundedBox.x = self.boundedBox.x + vx
	self.boundedBox.y = self.boundedBox.y + vy
end

function Boss:checkMovementTarget()
	local distanceToTarget = math.dist(self.boundedBox.x, self.boundedBox.y, self.curTarget.x, self.curTarget.y)
	
	if distanceToTarget < BOSS_MIN_DISTANCE_TO_TARGET then
		local nextTarget = math.random(#self.curTarget.nextPoints)
		
		self.curTarget = self.targetPoints[self.curTarget.nextPoints[nextTarget]]
	end
end

function Boss:tryAttack(dt, playerX, playerY)
	self.attackTimer = self.attackTimer - dt
	
	if self.attackTimer <= 0 then
		self.attackTimer = math.random() * (BOSS_ATTACK_TIMER_MAX - BOSS_ATTACK_TIMER_MIN) + BOSS_ATTACK_TIMER_MIN
		
		table.insert(self.bossBullets, BossBullet:new(
			self.boundedBox.x + self.boundedBox.width / 2,
			self.boundedBox.y + self.boundedBox.height / 2,
			playerX,
			playerY
		))
	end
	-- spawn enemy or shoot player
end

function Boss:draw()
	if self.active then
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("fill", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
		
		for index, enemy in ipairs(self.bossEnemies) do
			enemy:draw()
		end
		
		for index, bullet in ipairs(self.bossBullets) do
			bullet:draw()
		end
	end
end
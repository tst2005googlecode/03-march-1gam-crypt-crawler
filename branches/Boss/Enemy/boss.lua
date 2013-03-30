Boss = class("Boss")

BOSS_WIDTH = 192
BOSS_HEIGHT = 192
BOSS_SPRITE_OFFSET_X = 0
BOSS_SPRITE_OFFSET_Y = 0

BOSS_START_X = 100
BOSS_START_Y = 100

BOSS_INVULN_TIMER = 3
BOSS_MAX_HEALTH = 100
BOSS_HEALTH_DECREMENT = 5

BOSS_STATE_IDLING = 0
BOSS_STATE_MOVING = 1
BOSS_STATE_SPAWNING = 2
BOSS_STATE_SHOOTING = 3
BOSS_STATE_DYING = 4

function Boss:initialize(enemyManager)
	self.enemyManager = enemyManager
	self.active = false
	
	self.boundedBox = {
		x = -1000,
		y = -1000,
		width = BOSS_WIDTH,
		height = BOSS_HEIGHT,
		parent = self
	}
	
	self.curState = BOSS_STATE_IDLING
	self.health = BOSS_MAX_HEALTH
	self.invulnTimer = 0
	
	self.solidCollisions = {}
end

function Boss:reset()
	self.boundedBox.x = -1000
	self.boundedBox.y = -1000
	
	bump.remove(self.boundedBox)
	self.active = false
end

function Boss:activate()
	self.boundedBox.x = BOSS_START_X
	self.boundedBox.y = BOSS_START_Y
	
	bump.add(self.boundedBox)
	self.active = true
end

function Boss:onCollision(dt, other, dx, dy)
	if instanceOf(Bullet, other) then
		if self.invulnTimer <= 0 then
			self.health = self.health - BOSS_HEALTH_DECREMENT
			
			if self.health <= 0 then
				-- Die
			else
				self.invulnTimer = BOSS_INVULN_TIMER
			end
		end
	elseif instanceOf(Player, other) then
		other:hitByEnemy()
	end
end

function Boss:update(dt)
	if self.invulnTimer > 0 then
		self.invulnTimer = self.invulnTimer - dt
	end
end

function Boss:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", self.boundedBox.x, self.boundedBox.y, self.boundedBox.width, self.boundedBox.height)
end
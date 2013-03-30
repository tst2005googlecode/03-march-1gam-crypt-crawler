BossBullet = class("BossBullet")

BOSS_BULLET_WIDTH = 64
BOSS_BULLET_HEIGHT = 64
BOSS_BULLET_OFFSET = 0

BOSS_BULLET_SPEED = 300
BOSS_BULLET_HEALTH_DRAIN_VALUE = 10

BOSS_BULLET_IMAGE = love.graphics.newImage("Asset/Graphic/Enemy/BossBullet.png")

function BossBullet:initialize(startX, startY, targetX, targetY)
	self.boundedBox = {
		x = startX,
		y = startY,
		width = BOSS_BULLET_WIDTH,
		height = BOSS_BULLET_HEIGHT,
		parent = self
	}
	bump.add(self.boundedBox)
	
	local vx = targetX + PLAYER_WIDTH / 2 - startX
	local vy = targetY + PLAYER_HEIGHT / 2 - startY
	vx, vy = math.normalize(vx, vy)
	
	self.velocity = {
		x = vx * BOSS_BULLET_SPEED,
		y = vy * BOSS_BULLET_SPEED
	}
	
	self.rotation = math.atan2(self.velocity.y, self.velocity.x)
	
	self.alive = true
end

function BossBullet:onCollision(dt, other, dx, dy)
	if instanceOf(Wall, other) or instanceOf(Player, other) then
		self.alive = false
		
		if instanceOf(Player, other) then
			other:hitByEnemy(BOSS_BULLET_HEALTH_DRAIN_VALUE)
		end
	end
end

function BossBullet:update(dt)
	if self.alive then
		self.boundedBox.x = self.boundedBox.x + self.velocity.x * dt
		self.boundedBox.y = self.boundedBox.y + self.velocity.y * dt
	end
end

function BossBullet:draw()
	if self.alive then
		love.graphics.draw(
			BOSS_BULLET_IMAGE,
			self.boundedBox.x - BOSS_BULLET_OFFSET,
			self.boundedBox.y - BOSS_BULLET_OFFSET,
			self.rotation,
			1,
			1,
			BOSS_BULLET_WIDTH / 2,
			BOSS_BULLET_HEIGHT / 2
		)
	end
end
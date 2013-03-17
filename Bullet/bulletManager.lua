require "Bullet/bullet"
require "soundLibrary"

BulletManager = class("BulletManager")

function initializeBulletParticleSystem()
	BULLET_SPARK_IMAGE = love.graphics.newImage("Asset/Particle/BulletSpark.png")
	local p = love.graphics.newParticleSystem(BULLET_SPARK_IMAGE, 50)
	
	p:setEmissionRate(500)
	p:setLifetime(0.1)
	p:setParticleLife(0, 0.1)
	p:setSpread(2 * math.pi)
	p:setSpeed(200, 100)
	p:setSizes(3)
	p:setColors(
		255, 110, 110, 255,
		255, 255, 0, 0
	)
	p:stop()
	
	BULLET_SPARK_SYSTEM = p
end

function BulletManager:initialize()
	self.bullets = {}
	
	initializeBulletParticleSystem()
end

function BulletManager:reset()
	self.bullets = {}
end

function BulletManager:fireBullet(x, y, direction, hudObj)
	if #self.bullets == 0 then
		SFX_BULLET_FIRE:rewind()
		SFX_BULLET_FIRE:play()
		table.insert(self.bullets, Bullet:new(x, y, math.rad(direction), hudObj))
	end
end

function BulletManager:update(dt, cameraX, cameraY, cameraWidth, cameraHeight)
	for index, bullet in ipairs(self.bullets) do
		bullet:update(dt, cameraX, cameraY, cameraWidth, cameraHeight)
		
		if not bullet.alive then
			table.remove(self.bullets, index)
			bump.remove(bullet.boundedBox)
		end
	end
end

function BulletManager:draw()
	for index, bullet in ipairs(self.bullets) do
		if bullet.alive then
			bullet:draw()
		end
	end
end
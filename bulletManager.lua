require "bullet"
require "soundLibrary"

BulletManager = class("BulletManager")

function BulletManager:initialize()
	self.bullets = {}
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
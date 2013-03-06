require "bullet"

BulletManager = class("BulletManager")

function BulletManager:initialize()
	bullets = {}
end

function BulletManager:fireBullet(x, y, direction)
	if #bullets == 0 then
		table.insert(bullets, Bullet:new(x, y, direction))
	end
end

function BulletManager:update(dt, cameraX, cameraY, cameraWidth, cameraHeight)
	for index, bullet in ipairs(bullets) do
		bullet:update(dt, cameraX, cameraY, cameraWidth, cameraHeight)
		
		if not bullet.alive then
			table.remove(bullets, index)
			bump.remove(bullet.boundedBox)
		end
	end
end

function BulletManager:draw()
	for index, bullet in ipairs(bullets) do
		if bullet.alive then
			bullet:draw()
		end
	end
end
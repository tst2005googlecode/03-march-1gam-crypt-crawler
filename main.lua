require "lib/hardoncollider"
require "lib/middleclass"
require "player"

function love.load()
	player = Player:new()
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("quit")
	end
	
	if key == "left" then
		player.leftPressed = true
	end
	
	if key == "right" then
		player.rightPressed = true
	end
	
	if key == "up" then
		player.upPressed = true
	end
	
	if key == "down" then
		player.downPressed = true
	end
end

function love.keyreleased(key, unicode)
	if key == "left" then
		player.leftPressed = false
	end
	
	if key == "right" then
		player.rightPressed = false
	end
	
	if key == "up" then
		player.upPressed = false
	end
	
	if key == "down" then
		player.downPressed = false
	end
end

function love.update(dt)
	player:update(dt)
end

function love.draw()
	player:draw()
end

function love.quit()
	
end
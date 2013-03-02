function love.load()
	-- Load content
end

function love.mousepressed(x, y, button)
	-- Mouse button pressed
end

function love.mousereleased(x, y, button)
	-- Mouse button released
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("quit")
	end
end

function love.keyreleased(key, unicode)
	-- Key released
end

function love.update(dt)
	-- Update Game
	-- dt = Delta Time. Time elapsed since last update in seconds
end

function love.draw()
	-- Draw game
end

function love.quit()
	-- Called when game is quit
end
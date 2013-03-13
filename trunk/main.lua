bump = require "Lib/bump"
require "Lib/middleclass"
require "Lib/general"
require "gameState"
require "game"

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
TILE_SIZE = 32

function love.load()
	bump.initialize(32)
	defaultFont = love.graphics.newFont(12)
	
	gameStates = {}
	gameStates[1] = GameState:new(love.graphics.newImage("Graphic/Screen/TitleScreen.png"), 0)
	gameStates[2] = GameState:new(love.graphics.newImage("Graphic/Screen/GameOverScreen.png"), 3)
	gameStates[3] = GameState:new(love.graphics.newImage("Graphic/Screen/CreditsScreen.png"), 1)
	
	game = Game:new()
	
	currentState = gameStates[1]
end

function bump.collision(shapeA, shapeB, dx, dy)
	if shapeA.parent and shapeB.parent then
		shapeA.parent:onCollision(dt, shapeB.parent, dx, dy)
		shapeB.parent:onCollision(dt, shapeA.parent, -dx, -dy)
	end
end

function bump.getBBox(item)
	return item.x, item.y, item.width, item.height
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("quit")
	end
	
	currentState:keyPressed(key)
end

function love.keyreleased(key, unicode)
	currentState:keyReleased(key)
end

function love.update(dt)
	currentState:update(dt)
	
	local nextState = currentState:getNextState()
	if nextState ~= nil then
		if nextState == 0 then
			currentState = game
			game:reset()
			game:loadLevel(1)
		else
			currentState = gameStates[nextState]
			currentState:reset()
		end
	end
end

function love.draw()
	currentState:draw()
	
	-- Debug Stuff
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(defaultFont)
	love.graphics.print(love.mouse.getX() .. ", " .. love.mouse.getY(), 0, 0)
end
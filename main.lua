bump = require "Lib/bump"
require "Lib/middleclass"
require "Lib/general"
require "gameState"
require "game"
require "soundLibrary"

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
TILE_SIZE = 32

DRAW_DEBUG = true

function love.load()
	bump.initialize(32)
	defaultFont = love.graphics.newFont(12)
	
	local titleMusic = love.audio.newSource("Asset/Music/TitleMusic.mp3")
	local gamePlayMusic = love.audio.newSource("Asset/Music/GamePlayMusic.mp3")
	local gameOverMusic = love.audio.newSource("Asset/Music/GameOverMusic.mp3")
	local gameBeatenMusic = love.audio.newSource("Asset/Music/GameBeatenMusic.mp3")
	
	titleMusic:setLooping(true)
	gamePlayMusic:setLooping(true)
	gameOverMusic:setLooping(true)
	gameBeatenMusic:setLooping(true)
	
	titleMusic:setVolume(0.7)
	gamePlayMusic:setVolume(0.7)
	gameOverMusic:setVolume(0.7)
	gameBeatenMusic:setVolume(0.7)
	
	gameStates = {}
	gameStates[1] = GameState:new(love.graphics.newImage("Asset/Graphic/Screen/TitleScreen.png"), titleMusic, 0)
	gameStates[2] = GameState:new(love.graphics.newImage("Asset/Graphic/Screen/GameOverScreen.png"), gameOverMusic, 3)
	gameStates[3] = GameState:new(love.graphics.newImage("Asset/Graphic/Screen/CreditsScreen.png"), gameBeatenMusic, 1)
	
	game = Game:new(gamePlayMusic)
	
	currentState = gameStates[1]
	currentMusic = currentState.musicTrack
	currentMusic:play()
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
		currentMusic:stop()
		if nextState == 0 then
			currentState = game
			game:reset()
			game:loadLevel(1)
		else
			currentState = gameStates[nextState]
			currentState:reset()
		end
		
		currentMusic = currentState.musicTrack
		currentMusic:play()
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	currentState:draw()
	
	-- Debug Stuff
	if DRAW_DEBUG then
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(defaultFont)
		love.graphics.print(love.mouse.getX() .. ", " .. love.mouse.getY(), 0, 0)
		love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 90, 0)
	end
end
GameState = class("GameState")

function GameState:initialize(image, nextState)
	self.image = image
	self.nextState = nextState
	
	self.doProgress = false;
end

function GameState:reset()
	self.doProgress = false
end

function GameState:keyPressed(key)
	self.doProgress = true
end

function GameState:keyReleased(key)
	
end

function GameState:getNextState()
	if self.doProgress then
		return self.nextState
	else
		return nil
	end
end

function GameState:update(dt)
	
end

function GameState:draw()
	love.graphics.draw(self.image, 0, 0)
end
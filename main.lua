-- to do:
-- finish game loop
-- simplify
-- comment
-- send to jake
--
-- world variable
local ground = { x = 0, y = 1000, w = 2100, h = 200 }
local destroyer = -200
local spawner = 2000
-- object variables
local player = {}
local cactuses = {}
-- other variables
local gameOver = false
local score = 0
local cactus_speed = -250
-- for resetting
local function reset()
	player = { x = 400, y = 400, w = 100, h = 200, delta_y = 0 }
	cactuses = {
		{ x = 0, y = 600, w = 100, h = 400, active = false },
		{ x = 0, y = 600, w = 100, h = 400, active = false },
		{ x = 0, y = 600, w = 100, h = 400, active = false },
		{ x = 0, y = 600, w = 200, h = 100, active = false },
	}
end

-- timer
local timer = { time = 0 }
function timer:timerUpdate(dt)
	self.time = self.time + dt
end

-- loading function
function love.load()
	love.window.setMode(1920, 1080)
	love.window.setVSync(0)
	reset()
end

-- collision functions
local function withinRange(number, first, last)
	return number >= first and number <= last
end
local function pointBoxCollide(point, box)
	return withinRange(point.x, box.x, box.x + box.w) and withinRange(point.y, box.y, box.y + box.h)
end
local function checkCollide(first, second)
	return pointBoxCollide({ x = first.x, y = first.y }, second)
		or pointBoxCollide({ x = first.x + first.w, y = first.y }, second)
		or pointBoxCollide({ x = first.x, y = first.y + first.h }, second)
		or pointBoxCollide({ x = first.x + first.w, y = first.y + first.h }, second)
end
-- player update functions
local function playerUpdate(dt)
	if checkCollide(player, ground) then
		player.delta_y = 0
		-- if you are on ground you can jump
		if love.keyboard.isDown("w") then
			player.delta_y = -1600
		end
	else
		-- if you hold w while in air you fall slower
		if love.keyboard.isDown("w") then
			player.delta_y = player.delta_y + 2
		else
			player.delta_y = player.delta_y + 8
		end
	end
	-- player move up or down
	player.y = player.y + player.delta_y * dt
	-- collision check
	for i = 1, #cactuses do
		if checkCollide(player, cactuses[i]) then
			gameOver = true
		end
	end
end
local function cactusSpawn() end
local function cactusUpdate(dt)
	cactusSpawn()
	for i = 1, #cactuses do
		if cactuses[i].active then
			cactuses[i].x = cactuses[i].x + cactus_speed * dt
			if checkCollide(cactuses[i], destroyer) then
				score = score + 1
				cactuses[i].active = false
				cactus_speed = cactus_speed - 10
			end
		end
	end
end

function love.update(dt)
	-- only make game go forward if it isnt game over
	if not gameOver then
		cactusUpdate(dt)
		playerUpdate(dt)
	else --game Over
		-- to reset after you lose
		if love.keyboard.isDown("w") then
			gameOver = false
			score = 0
			reset()
		end
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0.1, 0.1, 0.2)
	love.graphics.setColor(0.7, 0.7, 0.7, 1)
	love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
	for i = 1, #cactuses do
		if cactuses[i].active then
			love.graphics.setColor(0.5, 0.9, 0.4, 1)
			love.graphics.rectangle("fill", cactuses[i].x, cactuses[i].y, cactuses[i].w, cactuses[i].h)
		end
	end
	-- draw ground
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("fill", ground.x, ground.y, ground.w, ground.h)
	-- draw score
	love.graphics.print(score, 100, 100)
end

local ground = { x = 0, y = 1000, w = 2100, h = 200 }
local destroyer = { x = -400, y = 0, w = 200, h = 1000 }
-- for resetting
local function player_proto()
	return { x = 400, y = 400, w = 100, h = 200, delta_y = 0 }
end
local function cactus_proto(x)
	if x == nil then
		x = 2000
	end
	return { x = x, y = 600, w = 100, h = 400, delta_x = -250 }
end
local function cactuses_proto()
	return { cactus_proto(), cactus_proto(3000), cactus_proto(3500) }
end
-- object variables
local player = player_proto()
local cactuses = cactuses_proto()
-- other variables
local gameOver = false
local score = 0

-- loading function
function love.load()
	love.window.setMode(1920, 1080)
	love.window.setVSync(0)
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
			player.delta_y = player.delta_y + 5
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
local function cactusUpdate(dt)
	for i = 1, #cactuses do
		cactuses[i].x = cactuses[i].x + cactuses[i].delta_x * dt
		if checkCollide(cactuses[i], destroyer) then
			score = score + 1
			cactuses[i] = cactus_proto()
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
			player = player_proto()
			cactuses = cactuses_proto()
		end
	end
end
-- to make drawing easier
local function colorRectDraw(r, g, b, obj)
	love.graphics.setColor(r, g, b, 1)
	love.graphics.rectangle("fill", obj.x, obj.y, obj.w, obj.h)
end

function love.draw()
	--game Over
	colorRectDraw(0.9, 0.5, 0.9, player)
	for i = 1, #cactuses do
		colorRectDraw(0.6, 0.5, 0.9, cactuses[i])
	end
	colorRectDraw(0.8, 0.9, 0.9, ground)
	-- draw score
	love.graphics.print(score, 100, 100)
end

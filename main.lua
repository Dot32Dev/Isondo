local intro = require("intro")

local camera = {x=0, y=0, z=0, dir=0, scale = 1}
camera.screenShake = {x=0, y=0, xV=0, yV=0}
local direction = 0 -- (north = 0, east = 1, south = 2, west = 3)

local player = require('entities.player')
player = player.new(camera)
local tree = require('entities.tree')
local water = require('entities.water')

local grid = {tileSize = 50, w=32, h=32}
local entities = {} 
local flooring = {}
table.insert(entities, player)

local seed = 8147 -- math.random(1000, 9999)
for x=-math.floor(grid.w/2), grid.w do
	grid[x+math.floor(grid.w/2)] = {}
	for y=-math.floor(grid.h/2), grid.h do
		grid[x+math.floor(grid.w/2)][y+math.floor(grid.h/2)] = {}
		local value = love.math.noise(x*0.6, y*0.6, seed)
		if value > 0.7 then--math.random(1,15) == 1 then
			local entity = tree.new(camera, x*grid.tileSize, y*grid.tileSize, math.random(40,60))
			grid[x+math.floor(grid.w/2)][y+math.floor(grid.h/2)][1] = entity
			table.insert(entities, entity)
		end
	end
end

local sword = love.graphics.newImage('items/sword.png')

--local tree = tree.new()
local shadowMap = love.graphics.newCanvas()

local function pprint(stringg, x, y)
	local r,g,b,a = love.graphics.getColour() 
	if type(stringg) == "number" then
		stringg = math.floor(stringg*1000)/1000
	end
	love.graphics.setColour(0,0,0)
	love.graphics.print(stringg, x, y)
	love.graphics.setColour(r,g,b,a)
end

local function p3d(p, rotation)
	rotation = rotation or player.dir -- rotation is a scalar that rotates around the y axis

	local x = math.sin(rotation)*p.x   + 0   +  math.sin(rotation+math.pi/2)*p.z
	local y = math.cos(rotation)*p.x/2 + p.y +  math.cos(rotation+math.pi/2)*p.z/2

	local z = math.cos(rotation)*p.x   - p.y +  math.cos(rotation+math.pi/2)*p.z

	return x,y,z --it is possible that i have messed up the x/z directions ¯\_(ツ)_/¯
end

function love.load()
	intro:init()
	love.graphics.setBackgroundColour(142/255,183/255,130/255)
end

function love.update(dt)
	intro:update(dt)

	camera.x = camera.x + (-player.x-camera.x)*0.3
	camera.z = camera.z + (-player.z-camera.z)*0.3

	for i=#entities, 1, -1 do
		entities[i]:update(dt)
		if entities[i].dead then
			if entities[i].onDeath then 
				entities[i]:onDeath(entities, player) 
			end
			table.remove(entities, i)
		end
	end

	if player.attack then
		for i=1, #entities do
			if entities[i].damage then
				entities[i]:damage(player.x, player.z, player.dir)
			end
		end
		player.attack = false
	end

	camera.dir = camera.dir + (direction*math.pi/2 - camera.dir)*60*dt *(1 / (1 + (dt*60*1/ 0.2)))

	camera.screenShake.xV = camera.screenShake.xV + (0-camera.screenShake.x)*0.2
	camera.screenShake.yV = camera.screenShake.yV + (0-camera.screenShake.y)*0.2
	camera.screenShake.yV = camera.screenShake.yV*0.7
	camera.screenShake.xV = camera.screenShake.xV*0.7

	camera.screenShake.x = camera.screenShake.x + camera.screenShake.xV
	camera.screenShake.y = camera.screenShake.y + camera.screenShake.yV
end

function love.draw()
	love.graphics.push()
	local tx, ty = p3d({z = camera.x+camera.screenShake.x, y=0, x=camera.z+camera.screenShake.y/2}, camera.dir)
	--love.graphics.translate(camera.x+camera.screenShake.x+love.graphics.getWidth()/2, camera.z/2+camera.screenShake.y/2+love.graphics.getHeight()/2)-- Camera +
	love.graphics.translate(tx+love.graphics.getWidth()/2, ty+love.graphics.getHeight()/2)

	for i=1, #flooring do
		flooring[i]:draw()
	end

	do love.graphics.setCanvas(shadowMap)
		love.graphics.clear()
		love.graphics.setColour(0,0.2,0.1,1)

		--love.graphics.ellipse("fill", love.mouse.getX(), love.mouse.getY(), 20, 10)

		-- love.graphics.ellipse("line", 0, 0, 20, 10)

		love.graphics.setColour(0,0.2,0.1,1)
		for i=1, #entities do
			love.graphics.push()
			local tx, ty = p3d({x=entities[i].z, y=0, z=entities[i].x}, camera.dir)
			love.graphics.translate(tx, ty)
			love.graphics.ellipse("fill", 0, 0, entities[i].shadow, entities[i].shadow/2)
			love.graphics.pop()
		end
	end
	love.graphics.setCanvas()
	love.graphics.setColour(1,1,1,0.1)
	tx, ty = p3d({z = camera.x+camera.screenShake.x, y=0, x=camera.z+camera.screenShake.y/2}, camera.dir)
	love.graphics.draw(shadowMap, -tx-love.graphics.getWidth()/2, -ty-love.graphics.getHeight()/2)
	
	table.sort(entities, function(a,b)
		local _, _, az = p3d({x=a.z, y=0, z=a.x}, camera.dir)
		local _, _, bz = p3d({x=b.z, y=0, z=b.x}, camera.dir)
		return (az < bz)
	end)
	for i=1, #entities do
		entities[i]:draw()
	end

	love.graphics.setColour(1,1,1)
	local mousePos = {love.mouse.getX()-love.graphics.getWidth()/2-tx, love.mouse.getY()*2-love.graphics.getHeight()-ty*2}
	local mouseGrid = {math.floor(mousePos[1]/grid.tileSize+0.5), math.floor(mousePos[2]/grid.tileSize+0.5)}
	if love.keyboard.isDown('`') then
		love.graphics.circle('fill', mouseGrid[1]*grid.tileSize, mouseGrid[2]*grid.tileSize/2, 5)
		
		if grid[mouseGrid[1]+math.floor(32/2)][mouseGrid[2]+math.floor(32/2)][1] then
			love.graphics.print(grid[mouseGrid[1]+math.floor(32/2)][mouseGrid[2]+math.floor(32/2)][1].id, mouseGrid[1]*grid.tileSize, mouseGrid[2]*grid.tileSize/2, 0)
		end
	end

	love.graphics.pop()

	local f = love.graphics.getFont()

	do local compass = {size=30, x=love.graphics.getWidth()-80, y=80}
		love.graphics.setLineWidth(2)
		love.graphics.setColour(1,1,1, 0.3)
		love.graphics.circle('line', compass.x, compass.y, compass.size)
		love.graphics.setColour(1,1,1)
		love.graphics.circle('fill', compass.x, compass.y, 3)
		love.graphics.line(compass.x, compass.y-compass.size/3, compass.x, compass.y+compass.size/3)

		love.graphics.print('N', compass.x + math.cos(-camera.dir-math.pi/2)*compass.size-f:getWidth('N')/2, compass.y + math.sin(-camera.dir-math.pi/2)*compass.size-f:getHeight()/2)
		love.graphics.print('E', compass.x + math.cos(-camera.dir)*compass.size-f:getWidth('E')/2, compass.y + math.sin(-camera.dir)*compass.size-f:getHeight()/2)
		love.graphics.print('S', compass.x + math.cos(-camera.dir+math.pi/2)*compass.size-f:getWidth('S')/2, compass.y + math.sin(-camera.dir+math.pi/2)*compass.size-f:getHeight()/2)
		love.graphics.print('W', compass.x + math.cos(-camera.dir-math.pi)*compass.size-f:getWidth('W')/2, compass.y + math.sin(-camera.dir-math.pi)*compass.size-f:getHeight()/2)
	end

	-- pprint(camera.x)
	-- pprint(seed)
	-- pprint(x..y, 0, 20)
	-- pprint(#entities)
	-- pprint(intro.varToString(grid))--intro.varToString()
	if love.keyboard.isDown('`') then
		pprint(intro.varToString(player))
	end

	player.inventory:draw()

	intro:draw()
end

function love.resize()
	shadowMap = love.graphics.newCanvas()
end

function love.keypressed(k)
	if k == 'e' then
		direction = direction - 1
	end
	if k == 'q' then
		direction = direction + 1
	end

	player:keypressed(k)
end

function autoTile(x, y, e)
	local value = 0

	for i=1, #grid[x][y-1] do
		if grid[x][y-1][i].id == e.id then
			value = value + 1
			grid[x][y-1][i].autoTile = grid[x][y-1][i].autoTile + 4
			break
		end
	end
	for i=1, #grid[x+1][y] do
		if grid[x+1][y][i].id == e.id then
			value = value + 2
			grid[x+1][y][i].autoTile = grid[x+1][y][i].autoTile + 8
			break
		end
	end
	for i=1, #grid[x][y+1] do
		if grid[x][y+1][i].id == e.id then
			value = value + 4
			grid[x][y+1][i].autoTile = grid[x][y+1][i].autoTile + 1
			break
		end
	end
	for i=1, #grid[x-1][y] do
		if grid[x-1][y][i].id == e.id then
			value = value + 8
			grid[x-1][y][i].autoTile = grid[x-1][y][i].autoTile + 2
			break
		end
	end

	e.autoTile = value
end

function love.mousepressed(b)
	tx, ty = p3d({z = camera.x+camera.screenShake.x, y=0, x=camera.z+camera.screenShake.y/2}, camera.dir)
	local mousePos = {love.mouse.getX()-love.graphics.getWidth()/2-tx, love.mouse.getY()*2-love.graphics.getHeight()-ty*2}
	local mouseGrid = {math.floor(mousePos[1]/grid.tileSize+0.5), math.floor(mousePos[2]/grid.tileSize+0.5)}
	local entity = water.new(camera, mouseGrid[1]*grid.tileSize, mouseGrid[2]*grid.tileSize)
	table.insert(grid[mouseGrid[1]+math.floor(32/2)][mouseGrid[2]+math.floor(32/2)], entity)
	table.insert(flooring, entity)
	autoTile(mouseGrid[1]+math.floor(32/2), mouseGrid[2]+math.floor(32/2), entity)
end


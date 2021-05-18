local intro = require("intro")

local camera = {x=love.graphics.getWidth()/2, y=0, z=love.graphics.getHeight()/2, dir=0}
camera.screenShake = {x=0, y=0, xV=0, yV=0}
local direction = 0 -- (north = 0, east = 1, south = 2, west = 3)

local tree = require('blocks/tree')
local grid = {tileSize = 60, countX = 25, countY = 25}
grid.oX, grid.oY = grid.countY/2*grid.tileSize, grid.countY/2*grid.tileSize
for x=1, grid.countX do
  grid[x] = {}
  for y=1, grid.countY do
    grid[x][y] = false
    if love.math.random(1,20) == 1 then
      grid[x][y] = tree.new()
    end
  end
end

local player = require('player')
local tree = require('tree')
local entities = {}
table.insert(entities, player.new(camera))

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
  --love.graphics.setBackgroundColour(142/255*intro.globals.water.r,183/255*intro.globals.water.g,130/255*intro.globals.water.b)
  love.graphics.setBackgroundColour(142/255,183/255,130/255)
end

function love.update(dt)
	intro:update(dt)

  for i=1, #entities do
    entities[i]:update(dt)
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
  do love.graphics.setCanvas(shadowMap)
    love.graphics.clear()
    love.graphics.setColour(0,0.2,0.1,1)

    love.graphics.ellipse("fill", love.mouse.getX(), love.mouse.getY(), 20, 10)

    love.graphics.translate(camera.x+camera.screenShake.x, camera.z+camera.screenShake.y)-- Camera +

    love.graphics.setColour(0,0.2,0.1,1)
    for i=1, #entities do
      local tx, ty = p3d({x=entities[i].z, y=entities[i].y, z=entities[i].x}, camera.dir)
      love.graphics.translate(tx, ty)
      love.graphics.ellipse("fill", 0, 0, entities[i].shadow, entities[i].shadow/2)
      love.graphics.translate(-tx, -ty)
    end
  end
  love.graphics.setCanvas()
  love.graphics.setColour(1,1,1,0.1)
  love.graphics.draw(shadowMap, -camera.x-camera.screenShake.x, -camera.z-camera.screenShake.y)


  -- draw grid 
  
  --love.graphics.translate(-grid.oX, -grid.oY/2)
  local f1, f2, f3 = 0,0,0
  if direction%4 == 0 or direction%4 == 3 then
    f1 = 1
    f2 = grid.countX
    f3 = 1
  else
    f1 = grid.countX
    f2 = 1
    f3 = -1
  end

  for x=f1, f2, f3 do
    for y=f1, f2, f3 do
      love.graphics.setLineWidth(3)
      local tx, ty = p3d({z=grid.tileSize*x-grid.oX, y=0, x=grid.tileSize*y-grid.oY}, camera.dir)
      if love.keyboard.isDown('`') then
        love.graphics.rectangle('line', tx, ty, grid.tileSize, grid.tileSize/2)
      end
      love.graphics.translate(tx, ty)
      if grid[x][y] then
        grid[x][y]:draw()
      end
      love.graphics.translate(-tx, -ty)
    end
  end
  --love.graphics.translate(grid.oX, grid.oY/2)
  

  table.sort(entities, function(a,b)
    local _, _, az = p3d({x=a.z, y=0, z=a.x}, camera.dir)
    local _, _, bz = p3d({x=b.z, y=0, z=b.x}, camera.dir)
    return (az < bz)
  end)
  for i=1, #entities do
    entities[i]:draw()
  end
  ----love.graphics.polygon('fill',0,0, 5,-5, 10,-5, 10,-10, 15,-15, 20,-10, 20,-5, 50,-5, 55,0, 50,5, 20,5, 20,10, 15,15, 10,10, 10,5, 5,5)
  --love.graphics.polygon('fill', 0,0, 5,-5, 50,-5, 55,0, 50,5, 5,5)
  --love.graphics.polygon('fill', 15,-15, 20,-10, 20,10, 15,15, 10,10, 10,-10)
  --love.graphics.draw(sword, entities[1].x, entities[1].y, nil, 0.5)

  love.graphics.translate(-camera.x-camera.screenShake.x, -camera.z-camera.screenShake.y)-- Camera -
  local f = love.graphics.getFont()

  do local compass = {size=30, x=love.graphics.getWidth()-80, y=love.graphics.getHeight()-80}
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
  -- pprint(camera.z, 0, 20)
  pprint(direction%4)

  intro:draw()
end

function love.resize()
  camera.x = love.graphics.getWidth()/2
  camera.z = love.graphics.getHeight()/2
  shadowMap = love.graphics.newCanvas()
end

function love.keypressed(k)
  if k == 'e' then
    direction = direction - 1
  end
  if k == 'q' then
    direction = direction + 1
  end
end
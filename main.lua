local intro = require("intro")

local camera = {x=0, y=0, z=0, dir=0, scale = 1}
camera.screenShake = {x=0, y=0, xV=0, yV=0}
local direction = 0 -- (north = 0, east = 1, south = 2, west = 3)

local grid = {tileSize = 50}

local player = require('player')
      player = player.new(camera)

local tree = require('tree')
local entities = {}
table.insert(entities, player)
-- for i=1, 60 do
--   table.insert(entities, tree.new(camera, math.floor(love.math.random(0, 1600)/grid.tileSize)*grid.tileSize-800, math.floor(love.math.random(0, 1600)/grid.tileSize)*grid.tileSize-800))
--   -- for j=1, #entities do
--   --   if entities[i].x == entities[j].x and entities[i].y == entities[j].y and i ~= j then
--   --     entities[i].dead = true
--   --     --entities[i].drops = false
--   --   end
--   -- end
-- end
for x=-math.floor(25/2), 25 do
  for y=-math.floor(25/2), 25 do
    if math.random(1,15) == 1 then
      table.insert(entities, tree.new(camera, x*64, y*64))
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
  --love.graphics.setBackgroundColour(142/255*intro.globals.water.r,183/255*intro.globals.water.g,130/255*intro.globals.water.b)
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
  do love.graphics.setCanvas(shadowMap)
    love.graphics.clear()
    love.graphics.setColour(0,0.2,0.1,1)

    --love.graphics.ellipse("fill", love.mouse.getX(), love.mouse.getY(), 20, 10)

    love.graphics.push()
    local tx, ty = p3d({z = camera.x+camera.screenShake.x, y=0, x=camera.z+camera.screenShake.y/2}, camera.dir)
    --love.graphics.translate(camera.x+camera.screenShake.x+love.graphics.getWidth()/2, camera.z/2+camera.screenShake.y/2+love.graphics.getHeight()/2)-- Camera +
    love.graphics.translate(tx+love.graphics.getWidth()/2, ty+love.graphics.getHeight()/2)

    love.graphics.ellipse("fill", 0, 0, 20, 10)

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


  ----love.graphics.polygon('fill',0,0, 5,-5, 10,-5, 10,-10, 15,-15, 20,-10, 20,-5, 50,-5, 55,0, 50,5, 20,5, 20,10, 15,15, 10,10, 10,5, 5,5)
  --love.graphics.polygon('fill', 0,0, 5,-5, 50,-5, 55,0, 50,5, 5,5)
  --love.graphics.polygon('fill', 15,-15, 20,-10, 20,10, 15,15, 10,10, 10,-10)
  --love.graphics.draw(sword, entities[1].x, entities[1].y, nil, 0.5)

  love.graphics.pop()
  --love.graphics.translate( -camera.x-camera.screenShake.x-love.graphics.getWidth()/2, -camera.z/2-camera.screenShake.y/2-love.graphics.getHeight()/2)-- Camera -

  local f = love.graphics.getFont()

  do local compass = {size=30, x=love.graphics.getWidth()-80, y=80}--{size=30, x=love.graphics.getWidth()-80, y=love.graphics.getHeight()-80}
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
  --pprint(#entities)
  --pprint(intro.varToString(player.inventory.recipes))--intro.varToString()
  if love.keyboard.isDown('`') then
    pprint(intro.varToString(player))
  end

  player.inventory.draw()

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
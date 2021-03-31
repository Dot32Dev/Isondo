local player = {dir = 0, x = 0, y = 0}
local camera = {x=love.graphics.getWidth()/2, y=love.graphics.getHeight()/2}
local shadowMap = love.graphics.newCanvas()

local function p3d(p, rotation)
  rotation = rotation or player.dir

  local x = math.sin(rotation)*p
  local y = math.cos(rotation)*p/2

  local f = math.cos(rotation)*p

  return x,y,f
end

local function pprint(stringg, x, y)
  local r,g,b,a = love.graphics.getColour() 
  if type(stringg) == "number" then
    stringg = math.floor(stringg*10)/10
  end
  love.graphics.setColour(0,0,0)
  love.graphics.print(stringg, x, y)
  love.graphics.setColour(r,g,b,a)
end

function love.load()
  require("Intro")
  introInitialise("Games")

  love.graphics.setBackgroundColour(142/255,183/255,130/255)
end

function love.update(dt)
	introUpdate(dt)
  player.dir = math.atan2((love.mouse.getX()-camera.x), (love.mouse.getY()-camera.y-24)*2)
end

function love.draw()
  local x,y,f = p3d(0, player.dir)

  love.graphics.setCanvas(shadowMap)
    love.graphics.clear()
    love.graphics.setColour(0,0.2,0.1,1)
    love.graphics.ellipse("fill", love.mouse.getX(), love.mouse.getY(), 20, 10)

    love.graphics.translate(camera.x, camera.y)-- Camera 

    love.graphics.setColour(0,0.2,0.1,1)
    love.graphics.ellipse("fill", 0, 24, 20, 10)
  love.graphics.setCanvas()
  love.graphics.setColour(1,1,1,0.1)
  love.graphics.draw(shadowMap, -camera.x, -camera.y)

  --[[ Legs ]]
  love.graphics.setColour(0.8*0.8,0.6*0.8,0.3*0.8)
  x,y,f = p3d(6, player.dir+math.pi/2)
  love.graphics.rectangle("fill", x-4, y+12, 8, 12)
  x,y,f = p3d(6, player.dir-math.pi/2)
  love.graphics.rectangle("fill", x-4, y+12, 8, 12)


  --[[ Back Arm ]]
  love.graphics.setColour(0.3*0.9,0.6*0.9,0.8*0.9)
  x,y,f = p3d(20, (player.dir % math.pi)+math.pi/2)
  love.graphics.rectangle("fill", x-4, y, 8, 12)

 
  --[[ Body ]]
  love.graphics.setColour(0.3,0.6,0.8)
  love.graphics.ellipse("fill", 0, 0, 20, 19)


  --[[ Front Arm ]]
  love.graphics.setColour(0.3*0.9,0.6*0.9,0.8*0.9)
  x,y,f = p3d(20, (player.dir % math.pi)-math.pi/2)
  love.graphics.rectangle("fill", x-4, y, 8, 12)
  pprint(f,x,y)


  --[[ Eyes ]]
  love.graphics.setColour(0.13,0.13,0.13)
  x,y,f = p3d(16, (player.dir)-14/180*math.pi)
  love.graphics.ellipse("fill", x, y-20, 2.5, 5)
  x,y,f = p3d(16, (player.dir)+14/180*math.pi)
  love.graphics.ellipse("fill", x, y-20, 2.5, 5)


  --[[ Head ]]
  love.graphics.setColour(0.9,0.7,0.6)
  love.graphics.ellipse("fill", 0, 0-20, 20/1.2, 19/1.2)


  --[[ Eyes ]]
  love.graphics.setColour(0.13,0.13,0.13)
  if player.dir-14/180*math.pi < math.pi/2 and player.dir-14/180*math.pi > -math.pi/2 then
    x,y,f = p3d(16, (player.dir)-14/180*math.pi)
    love.graphics.ellipse("fill", x, y-20, 2.5, 5)
  end
  if player.dir+14/180*math.pi < math.pi/2 and player.dir+14/180*math.pi > -math.pi/2 then
    x,y,f = p3d(16, (player.dir)+14/180*math.pi)
    love.graphics.ellipse("fill", x, y-20, 2.5, 5)
  end
  

  love.graphics.translate(-camera.x, -camera.y)-- Camera


  introDraw()-- Intro 
end

function point(xin, yin, zin, xrot, yrot, fov)
  xrot = xrot or 0
  yrot = yrot or 0
  fov = fov or 150
  local x = math.cos(xrot)*xin-math.sin(xrot)*yin --*fov/(math.cos(xrot)*yin+math.sin(xrot)*xin*math.sin(yrot)+fov-math.cos(yrot)*zin)
  local y = math.cos(yrot)*(math.cos(xrot)*yin+math.sin(xrot)*xin)+math.sin(yrot)*zin --*fov/(math.cos(xrot)*yin+math.sin(xrot)*xin*math.sin(yrot)+fov-math.cos(yrot)*zin)

  return x, y
end
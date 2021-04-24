local intro = require("Intro")
local player = require("player")
local camera = {x=love.graphics.getWidth()/2, y=love.graphics.getHeight()/2}
local shadowMap = love.graphics.newCanvas()

local walkFrame = 0

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
  intro.init("Games")
  love.graphics.setBackgroundColour(142/255,183/255,130/255)
end

function love.update(dt)
	intro.update(dt)

  player.dir = math.atan2((love.mouse.getX()-camera.x-player.x), (love.mouse.getY()-camera.y-player.z)*2)
  player.update()

  walkFrame = walkFrame + 0.1
end

function love.draw()
  love.graphics.setCanvas(shadowMap)
    love.graphics.clear()
    love.graphics.setColour(0,0.2,0.1,1)

    love.graphics.ellipse("fill", love.mouse.getX(), love.mouse.getY(), 20, 10)

    love.graphics.translate(camera.x, camera.y)-- Camera +

    love.graphics.setColour(0,0.2,0.1,1)
    love.graphics.ellipse("fill", player.x, player.z, 20, 10)
  love.graphics.setCanvas()
  love.graphics.setColour(1,1,1,0.1)
  love.graphics.draw(shadowMap, -camera.x, -camera.y)

  player.draw()

  local vLength = math.sqrt(player.xV^2 + player.zV^2) -- length of the x/z velocity
  love.graphics.print(vLength)

  -- love.graphics.translate(0,-math.abs(math.sin(walkFrame)*10))
  -- love.graphics.line(0,0,math.sin(math.sin(walkFrame)*math.pi/2)*20, math.cos(math.sin(walkFrame)*math.pi/2)*20)
  -- love.graphics.line(0,0,math.sin(math.sin(-walkFrame)*math.pi/2)*20, math.cos(math.sin(-walkFrame)*math.pi/2)*20)
  love.graphics.setLineWidth(8)
  love.graphics.setColour(0.8*0.8,0.6*0.8,0.3*0.8)
  love.graphics.translate(0,-math.abs(math.sin(player.animFrame)*math.pi/2*10))
  --love.graphics.line(0,0,math.sin(math.sin(player.animFrame)*math.pi/2)*12, math.cos(math.sin(player.animFrame)*math.pi/2)*12)
  love.graphics.line(0,0,math.sin(-math.sin(player.animFrame)*math.pi/2)*12, math.cos(-math.sin(player.animFrame)*math.pi/2)*12)

  love.graphics.translate(-camera.x, -camera.y)-- Camera -

  intro.draw()
end

function point(xin, yin, zin, xrot, yrot, fov)
  xrot = xrot or 0
  yrot = yrot or 0
  fov = fov or 150
  local x = math.cos(xrot)*xin-math.sin(xrot)*yin --*fov/(math.cos(xrot)*yin+math.sin(xrot)*xin*math.sin(yrot)+fov-math.cos(yrot)*zin)
  local y = math.cos(yrot)*(math.cos(xrot)*yin+math.sin(xrot)*xin)+math.sin(yrot)*zin --*fov/(math.cos(xrot)*yin+math.sin(xrot)*xin*math.sin(yrot)+fov-math.cos(yrot)*zin)

  return x, y
end
local player = require("player")
local intro = require("Intro")
local camera = {x=love.graphics.getWidth()/2, y=love.graphics.getHeight()/2}
local shadowMap = love.graphics.newCanvas()

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

  player.dir = math.atan2((love.mouse.getX()-camera.x-player.x), (love.mouse.getY()-camera.y-player.z/2)*2)
  player.update()
end

function love.draw()
  love.graphics.setCanvas(shadowMap)
    love.graphics.clear()
    love.graphics.setColour(0,0.2,0.1,1)

    love.graphics.ellipse("fill", love.mouse.getX(), love.mouse.getY(), 20, 10)

    love.graphics.translate(camera.x, camera.y)-- Camera +

    love.graphics.setColour(0,0.2,0.1,1)
    love.graphics.ellipse("fill", player.x, player.z/2, 20, 10)
  love.graphics.setCanvas()
  love.graphics.setColour(1,1,1,0.1)
  love.graphics.draw(shadowMap, -camera.x, -camera.y)

  player.draw()

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
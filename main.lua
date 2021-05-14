local intro = require("intro")
local player = require("player")
local player = player.new()
local tree = require("tree")
local tree = tree.new()
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
  intro:init()
  --love.graphics.setBackgroundColour(142/255*intro.globals.water.r,183/255*intro.globals.water.g,130/255*intro.globals.water.b)
  love.graphics.setBackgroundColour(142/255,183/255,130/255)
end

function love.update(dt)
	intro:update(dt)

  player:update(camera.x, camera.y)
end

function love.draw()
  love.graphics.setCanvas(shadowMap)
    love.graphics.clear()
    love.graphics.setColour(0,0.2,0.1,1)

    love.graphics.ellipse("fill", love.mouse.getX(), love.mouse.getY(), 20, 10)

    love.graphics.translate(camera.x, camera.y)-- Camera +

    love.graphics.setColour(0,0.2,0.1,1)
    love.graphics.ellipse("fill", player.x, player.z/2, 20, 10)
    love.graphics.ellipse("fill", tree.x, tree.z/2, 20*1.3, 20*0.65)
  love.graphics.setCanvas()
  love.graphics.setColour(1,1,1,0.1)
  love.graphics.draw(shadowMap, -camera.x, -camera.y)

  player:draw()

  tree:draw()

  --local vLength = math.sqrt(player.xV^2 + player.zV^2) -- length of the x/z velocity
  --pprint(vLength)

  --love.graphics.setLineWidth(8)
  --love.graphics.setColour(0.8*0.8,0.6*0.8,0.3*0.8)
  --love.graphics.translate(0,-math.abs(math.sin(player.animFrame)*math.pi/2*10))
  --love.graphics.line(0,0,math.sin(math.sin(player.animFrame)*math.pi/2)*12, math.cos(math.sin(player.animFrame)*math.pi/2)*12)
  --love.graphics.line(0,0,math.sin(-math.sin(player.animFrame)*math.pi/2)*12, math.cos(-math.sin(player.animFrame)*math.pi/2)*12)

  --love.graphics.setColour(1,1,1)
  --love.graphics.polygon('fill',0,0, 5,-5, 10,-5, 10,-10, 15,-15, 20,-10, 20,-5, 50,-5, 55,0, 50,5, 20,5, 20,10, 15,15, 10,10, 10,5, 5,5)

  love.graphics.translate(-camera.x, -camera.y)-- Camera

  --pprint(tree.x)

  intro:draw()
end

function love.resize()
  camera = {x=love.graphics.getWidth()/2, y=love.graphics.getHeight()/2}
  shadowMap = love.graphics.newCanvas()
end
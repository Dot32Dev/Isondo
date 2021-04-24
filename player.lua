intro = require('Intro') -- require intro for access to timer
local player = {dir = 0, x = 0, y = 0, z = 0, xV = 0, yV = 0, zV = 0, animFrame = 0}

local function p3d(p, rotation)
  rotation = rotation or player.dir -- rotation is a scalar that rotates around the y axis

  local x = math.sin(rotation)*p.x 	 + 0   +	math.sin(rotation+math.pi/2)*p.z
  local y = math.cos(rotation)*p.x/2 + p.y +	math.cos(rotation+math.pi/2)*p.z/2

  local z = math.cos(rotation)*p.x 	 + p.y +	math.cos(rotation+math.pi/2)*p.z

  return x,y,z
end

function player.draw()
	local x,y,z, x1,y1,z1 = 0,0,0, 0,0,0 -- creates the local variables, outputs dont get used
	love.graphics.translate(player.x, player.z-24+player.y)

	--[[ Legs ]]
  love.graphics.setColour(0.8*0.8,0.6*0.8,0.3*0.8)
  love.graphics.setLineWidth(8)
  x,y,z = p3d({x=0, y=12, z=6})
  x1,y1,z1 = p3d({x=math.sin(math.sin(player.animFrame)*math.pi/2)*12, y=12+math.cos(math.sin(player.animFrame)*math.pi/2)*12, z=6})
  love.graphics.line(x, y, x1, y1) -- left leg
  x,y,z = p3d({x=0, y=12, z=-6})
  x1,y1,z1 = p3d({x=math.sin(-math.sin(player.animFrame)*math.pi/2)*12, y=12+math.cos(math.sin(player.animFrame)*math.pi/2)*12, z=-6})
  love.graphics.line(x, y, x1, y1) -- right leg

  --[[ Back Arm ]]
  love.graphics.setColour(0.3*0.9,0.6*0.9,0.8*0.9)
  x,y,z = p3d({x=20, y=0, z=0}, (player.dir % math.pi)+math.pi/2)
  love.graphics.rectangle("fill", x-4, y, 8, 12)
 
  --[[ Body ]]
  love.graphics.setColour(0.3,0.6,0.8)
  love.graphics.ellipse("fill", 0, 0, 20, 19)

  --[[ Front Arm ]]
  love.graphics.setColour(0.3*0.9,0.6*0.9,0.8*0.9)
  x,y,z = p3d({x=20, y=0, z=0}, (player.dir % math.pi)-math.pi/2)
  love.graphics.rectangle("fill", x-4, y, 8, 12)
  --pprint(f,x,y)

  --[[ Back Eyes ]]
  love.graphics.setColour(0.13,0.13,0.13)
  x,y,z = p3d({x=16, y=-20, z=0}, (player.dir)-14/180*math.pi)
  love.graphics.ellipse("fill", x, y, 2.5, 5)
  x,y,z = p3d({x=16, y=-20, z=0}, (player.dir)+14/180*math.pi)
  love.graphics.ellipse("fill", x, y, 2.5, 5)

  --[[ Head ]]
  love.graphics.setColour(0.9,0.7,0.6)
  love.graphics.ellipse("fill", 0, 0-20, 20/1.2, 19/1.2)

  --[[ Front Eyes ]]
  love.graphics.setColour(0.13,0.13,0.13)
  if player.dir-14/180*math.pi < math.pi/2 and player.dir-14/180*math.pi > -math.pi/2 then
    x,y,z = p3d({x=16, y=-20, z=0}, (player.dir)-14/180*math.pi)
    love.graphics.ellipse("fill", x, y, 2.5, 5)
  end
  if player.dir+14/180*math.pi < math.pi/2 and player.dir+14/180*math.pi > -math.pi/2 then
    x,y,z = p3d({x=16, y=-20, z=0}, (player.dir)+14/180*math.pi)
    love.graphics.ellipse("fill", x, y, 2.5, 5)
  end
  
  love.graphics.translate(-player.x, -(player.z-24+player.y))
end

function player.update()
  local acceleration = 2
  local moved = false
  if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
    player.xV = player.xV - acceleration
    moved = true
  end
  if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
    player.xV = player.xV + acceleration
    moved = true
  end
  if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
    player.zV = player.zV - acceleration
    moved = true
  end
  if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
    player.zV = player.zV + acceleration
    moved = true
  end
  
  local damping = 0.81
  local vLength = math.sqrt(player.xV^2 + player.zV^2) -- length of the x/z velocity
  local maxSpeed = (acceleration / (1 - damping)) - acceleration -- calculates terminal velocity given acceleration and damping
  local multiplier = maxSpeed/math.max(maxSpeed, vLength) -- normalises the speed at which the player can move
  player.xV, 
  player.zV = -- *damping*multiplier
  player.xV * damping*multiplier, 
  player.zV * damping*multiplier

  player.x, 
  player.z = -- +Velocity
  player.x + player.xV, 
  player.z + player.zV

  player.animFrame = (moved and (player.animFrame + vLength/50)) or (player.animFrame % math.pi + (0-player.animFrame % math.pi)*0.3)
  player.y = -math.abs(math.sin(player.animFrame)*math.pi/2*10)
end

return player
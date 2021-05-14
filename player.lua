intro = require('intro') -- require intro for access to dependencies (intro.globals)
local entity = {}

function entity.new()
  local player = {id = 'player', dir = 0, x = 0, y = 0, z = 0, xV = 0, yV = 0, zV = 0, animFrame = 0, wet = -0}

  local function p3d(p, rotation)
    rotation = rotation or player.dir -- rotation is a scalar that rotates around the y axis

    local x = math.sin(rotation)*p.x 	 + 0   +	math.sin(rotation+math.pi/2)*p.z
    local y = math.cos(rotation)*p.x/2 + p.y +	math.cos(rotation+math.pi/2)*p.z/2

    local z = math.cos(rotation)*p.x 	 - p.y +	math.cos(rotation+math.pi/2)*p.z

    return x,y,z
  end

  local x,y,z, x1,y1,z1 = 0,0,0, 0,0,0 -- creates the local variables, outputs dont get used
  player.objects = { -- table of every body part in the player (automatically gets sorted by z each frame)
    {
      id='legs',
      z=1,
      draw = function(self)
        love.graphics.setColour(0.8*0.8,0.6*0.8,0.3*0.8)
        if player.wet < 0 then
          love.graphics.setColour(0.8*0.8*intro.globals.water.r, 0.6*0.8*intro.globals.water.g, 0.3*0.8*intro.globals.water.b)
        end
        love.graphics.setLineWidth(8)
        x,y,z = p3d({x=0, y=-12, z=6})
        x1,y1,z1 = p3d({x=math.sin(math.sin(player.animFrame)*math.pi/2)*12, y=-12+math.cos(math.sin(player.animFrame)*math.pi/2)*12, z=6})
        love.graphics.line(x, y, x1, y1) -- left leg
        x,y,z = p3d({x=0, y=-12, z=-6})
        x1,y1,z1 = p3d({x=math.sin(-math.sin(player.animFrame)*math.pi/2)*12, y=-12+math.cos(math.sin(player.animFrame)*math.pi/2)*12, z=-6})
        love.graphics.line(x, y, x1, y1)

        _, _, self.z = p3d({x=0, y=-12, z=0})
      end 
    },
    {
      id='left arm',
      z=2,
      draw = function(self)
        love.graphics.setColour(0.3*0.9,0.6*0.9,0.8*0.9)
        if player.wet < -23 then
          love.graphics.setColour(0.3*0.9*intro.globals.water.r, 0.6*0.9*intro.globals.water.g, 0.8*0.9*intro.globals.water.b)
        end
        x,y,z = p3d({x=0, y=-24, z=20})
        x1,y1,z1 = p3d({x=math.sin(-math.sin(player.animFrame)*math.pi/2)*12, y=-24+math.cos(math.sin(player.animFrame)*math.pi/2)*12, z=20})
        love.graphics.line(x, y, x1, y1)

        _, _, self.z = p3d({x=0, y=-24, z=20})
      end 
    },
    {
      id='right arm',
      z=3,
      draw = function(self)
        love.graphics.setColour(0.3*0.9,0.6*0.9,0.8*0.9)
        if player.wet < -23 then
          love.graphics.setColour(0.3*0.9*intro.globals.water.r, 0.6*0.9*intro.globals.water.g, 0.8*0.9*intro.globals.water.b)
        end
        x,y,z = p3d({x=0, y=-24, z=-20})
        x1,y1,z1 = p3d({x=math.sin(math.sin(player.animFrame)*math.pi/2)*12, y=-24+math.cos(math.sin(player.animFrame)*math.pi/2)*12, z=-20})
        love.graphics.line(x, y, x1, y1)

        _, _, self.z = p3d({x=0, y=-24, z=-20})
      end 
    },
    {
      id='body',
      z=4,
      vertices = function(self, point)
        local vertices = {}
        table.insert(vertices, {0, 0, 0.5, 0.5})

        for i=0, 30 do
          local angle = (i / 30)*math.pi*2

          local x = math.cos(angle)
          local y = math.sin(angle)

          local multiply = 19/20
          if y > point then
            multiply = math.sqrt(1^2 - point^2)
            x = x* multiply
            y = y* multiply* 0.5 +point
            
            local len = math.sqrt(x^2 + y^2)
            if len > 1 then
              x = x / len
              y = y / len
            end
          end

          table.insert(vertices, {x*20, y*20})
        end
        return vertices
      end,
      draw = function(self)
        local wet = false
        if player.wet < -24+19 then -- hieght from player to ground minus radious of body
          wet = true
        end

        love.graphics.setColour(0.3,0.6,0.8)
        if wet then
          love.graphics.setColour(0.3*intro.globals.water.r, 0.6*intro.globals.water.g, 0.8*intro.globals.water.b)
        end
        love.graphics.ellipse("fill", 0, -24, 20, 19)

        if wet then 
          local normWet = (player.wet+24)/19
          if not self.mesh then
            self.mesh = love.graphics.newMesh(self:vertices(math.max(normWet, -1)), "fan", "stream")
          else
            local vertices = self:vertices(math.max(normWet, -1))
            self.mesh:setVertices(vertices, 1, #vertices)
          end
          love.graphics.setColour(0.3,0.6,0.8)
          love.graphics.draw(self.mesh, 0, -24)
        end

        _, _, self.z = p3d({x=0, y=-24, z=0})
      end 
    },
    {
      id='left eye',
      z=5,
      draw = function(self)
        love.graphics.setColour(0.13,0.13,0.13)
        x,y,z = p3d({x=16, y=-44, z=0}, (player.dir)+14/180*math.pi)
        love.graphics.ellipse("fill", x, y, 2.5, 5)

        _, _, self.z = p3d({x=16, y=-44, z=0}, (player.dir)+14/180*math.pi)
      end 
    },
    {
      id='right eye',
      z=6,
      draw = function(self)
        love.graphics.setColour(0.13,0.13,0.13)
        x,y,z = p3d({x=16, y=-44, z=0}, (player.dir)-14/180*math.pi)
        love.graphics.ellipse("fill", x, y, 2.5, 5)

        _, _, self.z = p3d({x=16, y=-44, z=0}, (player.dir)-14/180*math.pi)
      end 
    },
    {
      id='head',
      z=7,
      draw = function(self)
        love.graphics.setColour(0.9,0.7,0.6)
        love.graphics.ellipse("fill", 0, -44, 20/1.2, 19/1.2)

        _, _, self.z = p3d({x=0, y=-44, z=0})
      end 
    }
  }

  function player:draw()
  	love.graphics.translate(self.x, self.z/2+self.y)

    table.sort(self.objects, function(a,b) 
      return (a.z < b.z)
    end)
    for i=1, #self.objects do
      self.objects[i]:draw()
    end
    
    love.graphics.translate(-self.x, -(self.z/2+self.y))
  end

  function player:update(cameraX, cameraY)
    cameraX = cameraX or love.graphics.getWidth()/2
    cameraY = cameraY or love.graphics.getHeight()/2
    self.dir = math.atan2((love.mouse.getX()-cameraX-self.x), (love.mouse.getY()-cameraY-self.z/2)*2)

    if love.keyboard.isDown("r") then
      self.x = 0
      self.y = 0
      self.z = 0
    end

    local acceleration = 2
    local moved = false
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
      self.xV = self.xV - acceleration
      moved = true
    end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
      self.xV = self.xV + acceleration
      moved = true
    end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
      self.zV = self.zV - acceleration
      moved = true
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
      self.zV = self.zV + acceleration
      moved = true
    end
    
    local damping = 0.81
    if self.wet < 0 then
      damping = 0.7
    end
    local vLength = math.sqrt(self.xV^2 + self.zV^2) -- length of the x/z velocity
    local maxSpeed = (acceleration / (1 - damping)) - acceleration -- calculates terminal velocity given acceleration and damping
    local multiplier = maxSpeed/math.max(maxSpeed, vLength) -- normalises the speed at which the player can move
    self.xV, 
    self.zV = -- *damping*multiplier
    self.xV * damping*multiplier, 
    self.zV * damping*multiplier

    self.x, 
    self.z = -- +Velocity
    self.x + self.xV, 
    self.z + self.zV

    local fall = 0.3
    if self.wet < 0 then
      fall = 0.1
    end
    self.animFrame = (moved and (self.animFrame + vLength/50)) or (self.animFrame % math.pi + (0-self.animFrame % math.pi)*fall)
    self.y = -math.abs(math.sin(self.animFrame)*math.pi/2*10)
    self.wet = -0-self.y
  end

  return player
end
return entity
local item = require('item')
local entity = {}

function entity.new(camera, treeX, treeZ, height)
  local tree = {id = 'tree', camera = camera, x = treeX or 60, y = 0, z = treeZ or 30, shadow = 20*1.3, health = 3, dir = 0, wobble = 0, wobbleV = 0, dead = false, drops = true, height = height or 50}
  
  tree.colour = {0.38, 0.65, 0.42}

  local rng = math.random()
  if rng > 0.7 then
    tree.colour = {0.34, 0.59, 0.43}
    if rng > 0.95 then
      tree.colour = {0.78, 0.66, 0.85}
    end
  end

  local function p3d(p, rotation)
    rotation = rotation or 0 -- rotation is a scalar that rotates around the y axis

    local x = math.sin(rotation)*p.x   + 0   +  math.sin(rotation+math.pi/2)*p.z
    local y = math.cos(rotation)*p.x/2 + p.y +  math.cos(rotation+math.pi/2)*p.z/2

    local z = math.cos(rotation)*p.x   - p.y +  math.cos(rotation+math.pi/2)*p.z

    return x,y,z
  end

  local function subSphere(point, perspective)
    local perspective = perspective or 0
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
        y = y* multiply* perspective +point
        
        local len = math.sqrt(x^2 + y^2)
        if len > 1 then
          x = x / len
          y = y / len
        end
      end

      table.insert(vertices, {x*20*1.3, y*19*1.3})
    end
    return vertices
  end

  tree.mesh = love.graphics.newMesh(subSphere(0, 0.8))

  function tree:draw()
    local tx, ty = p3d({x=self.z*self.camera.scale, y=self.y*self.camera.scale, z=self.x*self.camera.scale}, self.camera.dir)
    love.graphics.translate(tx, ty)

    local size = self.height/50
    -- stump
    love.graphics.setColour(0.6, 0.44, 0.33)
    if tree.colour[1] == 0.78 then
      love.graphics.setColour(0.49, 0.39, 0.35)
    end
    love.graphics.ellipse("fill", 0, 0, 10*size, 5*size)

    -- trunk
    local height = self.height
    love.graphics.setLineWidth(20*size)
    local x,y = p3d({x=self.wobble, y=-height, z=0}, self.dir)
    love.graphics.line(0,0, x,y)

    --shadowTrunk
    if love.keyboard.isDown('/') then
      love.graphics.setColour(0.53, 0.33, 0.29)
      love.graphics.ellipse("fill", x/height*20, y/height*20, 10*size, 5*size)
    end

    -- leaves
    -- love.graphics.setColour(0.38, 0.65, 0.42)
    love.graphics.setColour(tree.colour)
    if love.keyboard.isDown('/') then
      love.graphics.setColour(0.3, 0.54, 0.4)
    end
    love.graphics.ellipse("fill", x, y+6, 20*1.3*size, 19*1.3*size) --1.3
    if love.keyboard.isDown('/') then
      love.graphics.setColour(0.38, 0.65, 0.42)
      love.graphics.draw(tree.mesh, x, y+6)
      love.graphics.setColour(0.47, 0.69, 0.45)
      love.graphics.ellipse("fill", x, y-12, 6, 3)
    end

    --love.graphics.print(self.wobbleV)
    
    love.graphics.translate(-tx, -ty)
  end

  function tree:update(dt)
    self.wobbleV = self.wobbleV + (0-self.wobble)*0.2
    self.wobbleV = self.wobbleV*0.7
    self.wobble = self.wobble + self.wobbleV

    if self.health < 1 then
      self.dead = true
    end
  end

  local function distance(x1,y1, x2,y2)
    return math.sqrt((y2-y1)^2 + (x2-x1)^2)
  end

  local function angleDifference(a, b)
    local difference = (a - b + math.pi) % (math.pi * 2) - math.pi
    return (difference < -math.pi) and (difference + math.pi * 2) or difference
  end

  function tree:damage(x, z, plrdir)
    local dist = distance(x,z, self.x,self.z)
    if dist < 100 and dist > 1 then
      local dir = math.atan2(self.x-x, self.z-z)
      if math.abs(angleDifference(dir, plrdir-self.camera.dir)) < math.pi/2 then
        --self.x = self.x + 50 * (self.x-x)/dist
        --self.z = self.z + 50 * (self.z-z)/dist
        self.dir = dir
        self.wobbleV = 15
        self.health = self.health - 1
      end
    end
  end

  function tree:onDeath(entities, player)
    if self.drops then
      for i=1, love.math.random(2,3) do
        local dir = self.dir+(love.math.random()*4-2)/5*math.pi
        local xV = math.sin(dir)*5
        local zV = math.cos(dir)*5
        table.insert(entities, item.new(self.camera, player, 2, {x=self.x, z=self.z, xV=xV, zV=zV}))
      end
    end
  end

  return tree
end
return entity
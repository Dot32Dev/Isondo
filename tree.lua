local entity = {}

function entity.new(camera, treeX, treeZ)
  local tree = {id = 'tree', camera = camera, x = treeX or 60, y = 0, z = treeZ or 30, shadow = 20*1.3, health = 3, dir = 0, wobble = 0, wobbleV = 0, dead = false}

  local function p3d(p, rotation)
    rotation = rotation or 0 -- rotation is a scalar that rotates around the y axis

    local x = math.sin(rotation)*p.x   + 0   +  math.sin(rotation+math.pi/2)*p.z
    local y = math.cos(rotation)*p.x/2 + p.y +  math.cos(rotation+math.pi/2)*p.z/2

    local z = math.cos(rotation)*p.x   - p.y +  math.cos(rotation+math.pi/2)*p.z

    return x,y,z
  end

  function tree:draw()
    local tx, ty = p3d({x=self.z, y=self.y, z=self.x}, self.camera.dir)
    love.graphics.translate(tx, ty)

    -- stump
    love.graphics.setColour(0.6, 0.44, 0.33)
    love.graphics.ellipse("fill", 0, 0, 10, 5)

    -- trunk
    local height = 50
    love.graphics.setLineWidth(20)
    local x,y = p3d({x=self.wobble, y=-height, z=0}, self.dir)
    love.graphics.line(0,0, x,y)

    -- leaves
    love.graphics.setColour(0.38, 0.65, 0.42)
    love.graphics.ellipse("fill", x, y+6, 20*1.3, 19*1.3) --1.3

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
      if math.abs(angleDifference(dir, plrdir)) < math.pi/2 then
        --self.x = self.x + 50 * (self.x-x)/dist
        --self.z = self.z + 50 * (self.z-z)/dist
        self.dir = dir
        self.wobbleV = 15
        self.health = self.health - 1
      end
    end
  end

  return tree
end
return entity
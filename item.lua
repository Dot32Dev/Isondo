local intro = require('intro')
local items = require('items')
local entity = {}

function entity.new(camera, player, itemIndex, point)
  local item = {id = 'item', camera = camera, x = point.x or 0, y = -20, z = point.z or 0, shadow = 10, dead = false, index = itemIndex, player = player, xV = point.xV or 0, yV = 0, zV = point.zV or 0}

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

  item.mesh = love.graphics.newMesh(subSphere(0, 0.8))

  function item:draw()
    local tx, ty = p3d({x=self.z*self.camera.scale, y=self.y*self.camera.scale, z=self.x*self.camera.scale}, self.camera.dir)
    love.graphics.translate(tx, ty)

    love.graphics.setColour(1,1,1)
    local img = items[self.index].img
    love.graphics.draw(img, 0,0, 0,0.25, 0.25, img:getWidth()/2, img:getHeight())
    --love.graphics.print(intro.varToString(point))
    
    love.graphics.translate(-tx, -ty)
  end

  local function distance(x1,y1, x2,y2)
    return math.sqrt((y2-y1)^2 + (x2-x1)^2)
  end

  function item:update(dt)
    self.y = self.y + self.yV
    self.yV = self.yV + 1

    if self.y > 0 then
      self.yV = 0
      self.y = 0

      local distance = distance(self.x, self.z, player.x, player.z)
      if distance < 300 then
        self.xV = self.xV + (player.x-self.x)*0.1
        self.zV = self.zV + (player.z-self.z)*0.1

        if distance < 50 then
          --player.inventory.add(sef.index)
          self.dead = true
        end
      end
      self.xV = self.xV*0.5
      self.zV = self.zV*0.5
    end

    self.y = self.y + self.yV
    self.x = self.x + self.xV
    self.z = self.z + self.zV
  end

  function item:onDeath(entities)
    player.inventory:add(self.index)
  end

  return item
end
return entity
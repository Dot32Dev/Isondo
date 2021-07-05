local item = require('entities.item')
local entity = {}

function entity.new(camera, x, y)
  local water = {id = 'water', camera = camera, x = x or 60, y = 12.5, z = y or 30, shadow = 1, dir = 0}
  

  local function p3d(p, rotation)
    rotation = rotation or water.camera.dir -- rotation is a scalar that rotates around the y axis

    local x = math.sin(rotation)*p.x   + 0   +  math.sin(rotation+math.pi/2)*p.z
    local y = math.cos(rotation)*p.x/2 + p.y +  math.cos(rotation+math.pi/2)*p.z/2

    local z = math.cos(rotation)*p.x   - p.y +  math.cos(rotation+math.pi/2)*p.z

    return x,y,z
  end

  function water:draw()
    local tx, ty = p3d({x=self.z*self.camera.scale, y=self.y*self.camera.scale, z=self.x*self.camera.scale}, self.camera.dir)
    love.graphics.translate(tx, ty)

    love.graphics.setColour(0.25,0.63,0.73)
    -- love.graphics.rectangle("fill", -25, -25, 50, 25)
    local x,y = p3d({x=0-25, y=0, z=0-25})
    local x1,y1 = p3d({x=0+25, y=0, z=0-25})
    local x2,y2 = p3d({x=0+25, y=0, z=0+25})
    local x3,y3 = p3d({x=0-25, y=0, z=0+25})
    love.graphics.polygon("fill", x,y,x1,y1,x2,y2,x3,y3)


    love.graphics.translate(-tx, -ty)
  end

  function water:update(dt)
    
  end

  return water
end
return entity
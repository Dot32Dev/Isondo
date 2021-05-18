intro = require('intro') -- require intro for access to dependencies 
local entity = {}

function entity.new(camera, treeX, treeZ)
  local tree = {id = 'tree', camera = camera, x = treeX or 60, y = 0, z = treeZ or 30, shadow = 20*1.3}

  function tree:draw()
    --local tx, ty = p3d({x=self.z, y=self.y, z=self.x}, self.camera.dir)
    --love.graphics.translate(tx, ty)

    -- stump
    love.graphics.setColour(0.6, 0.44, 0.33)
    love.graphics.ellipse("fill", 0, 0, 10, 5)

    -- trunk
    local height = 50
    love.graphics.rectangle("fill", -10, -height, 20, height)

    -- leaves
    love.graphics.setColour(0.38, 0.65, 0.42)
    love.graphics.ellipse("fill", 0, -height+6, 20*1.3, 19*1.3) --1.3
    
    --love.graphics.translate(-tx, -ty)
  end

  function tree:update(dt)

  end

  return tree
end
return entity
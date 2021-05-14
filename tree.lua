intro = require('intro') -- require intro for access to dependencies 
local entity = {}

function entity.new(treeX, treeZ)
  local tree = {id = 'tree', x = treeX or 60, y = 00, z = treeY or 30}

  tree.objects = { -- table of every body part in the tree (automatically gets sorted by z each frame)
    {
      id='stump',
      z=1,
      draw = function(self)
        love.graphics.setColour(0.6, 0.44, 0.33)
        love.graphics.ellipse("fill", 0, 0, 10, 5)

        self.z = 0
      end 
    },
    {
      id='trunk',
      z=2,
      draw = function(self)
        love.graphics.setColour(0.6, 0.44, 0.33)
        love.graphics.rectangle("fill", -10, -50, 20, 50)

        self.z = 0
      end 
    },
    {
      id='leaves',
      z=3,
      draw = function(self)
        love.graphics.setColour(0.38, 0.65, 0.42)
        love.graphics.ellipse("fill", 0, -44, 20*1.3, 19*1.3)

        self.z = 44
      end 
    },
    {
      id='shadowStump',
      z=4,
      draw = function(self)
        love.graphics.setColour(0.53, 0.33, 0.29)
        love.graphics.ellipse("fill", 0, -19, 10, 5)

        self.z = 19
      end 
    },
    {
      id='shadowTrunk',
      z=5,
      draw = function(self)
        love.graphics.setColour(0.53, 0.33, 0.29)
        love.graphics.rectangle("fill", -10, -29, 20, 10)

        self.z = 19
      end 
    },
  }

  function tree:draw()
  	love.graphics.translate(self.x, self.z/2+self.y)

    table.sort(self.objects, function(a,b) 
      return (a.z < b.z)
    end)
    for i=1, #self.objects do
      self.objects[i]:draw()
    end
    
    love.graphics.translate(-self.x, -(self.z/2+self.y))
  end

  function tree:update()

  end

  return tree
end
return entity
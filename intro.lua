local intro = {length = 0.5, sustain = 0.2}

intro.project = {}
intro.project.font = love.graphics.newFont("fonts/Public_Sans/static/PublicSans-Black.ttf", 20)

intro.cursor = love.mouse.getSystemCursor("hand")

function intro.easeOutElastic(x)
  local c4 = (2 * math.pi) / 2.3 -- edit "2.3" for effect
  return math.pow(2, -18 * x) * math.sin((x * 10 - 0.75) * c4) + 1 -- edit "-18" for effect
end

function intro:init(subtext)
  self.dot32 = {}
  self.dot32.font = love.graphics.newFont("fonts/PT_Sans/PTSans-Bold.ttf", 100)
  self.dot32.x = love.graphics.getWidth()/2
  self.dot32.y = 0

  self.sub = {}
  self.sub.font = love.graphics.newFont("fonts/PT_Sans/PTSans-Regular.ttf", 45)
  self.sub.text = subtext or "Games"
  self.sub.x = 0
  self.sub.y = love.graphics.getHeight()/1.65

  self.timer = 0
  self.phase = 1
  self.ghost = 1

  --[[Creates Australian-English translations of the colour functions]]
  love.graphics.getBackgroundColour = love.graphics.getBackgroundColor
  love.graphics.getColour           = love.graphics.getColor
  love.graphics.getColourMask       = love.graphics.getColorMask
  love.graphics.getColourMode       = love.graphics.getColorMode
  love.graphics.setBackgroundColour = love.graphics.setBackgroundColor
  love.graphics.setColour           = love.graphics.setColor
  love.graphics.setColourMask       = love.graphics.setColorMask
  love.graphics.setColourMode       = love.graphics.setColorMode
end

function intro:update(dt)
  if not dt then
    error("dt is required for intro.update(dt)")
  end

  self.dot32.y = self.easeOutElastic(self.timer)*love.graphics.getHeight()/2
  self.sub.x = self.easeOutElastic(self.timer)*love.graphics.getWidth()/2

  self.timer = self.timer + dt
  
  if self.timer > self.length then
    self.phase = 2
    love.graphics.setFont(self.project.font)
  end
  if self.phase == 2 then
    self.ghost = self.ghost -dt/self.sustain
  end
  if self.timer > self.length + self.sustain then
    self.phase = 3
  end
end

function intro:draw()
  if self.phase < 3 then
    local r,g,b,a = love.graphics.getColour()
    local font = love.graphics.getFont()

    love.graphics.setColor(0.17, 0.17, 0.17, self.ghost)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1, self.ghost)
    love.graphics.setFont(self.dot32.font)
    love.graphics.print("Dot32", self.dot32.x - self.dot32.font:getWidth("Dot32")/2, self.dot32.y - self.dot32.font:getHeight()/2)
    love.graphics.setFont(self.sub.font)
    love.graphics.print(self.sub.text, self.sub.x - self.sub.font:getWidth(self.sub.text)/2, self.sub.y - self.sub.font:getHeight()/2)

    love.graphics.setColor(0.2, 0.2, 0.2, self.ghost)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight()-5, love.graphics.getWidth()-(love.graphics.getWidth()/self.length)*self.timer, 5)

    love.graphics.setColour(r,g,b,a)
    love.graphics.setFont(font)
    -- love.graphics.setColor(1, 1, 1, self.ghost)
    -- love.graphics.rectangle("fill", 0, love.graphics.getHeight()-5, ((love.graphics.getWidth())/self.length*self.timer), 5)
  end
end

function intro.HSL(h, s, l, a)
  if s<=0 then return l,l,l,a end
  h, s, l = h*6, s, l
  local c = (1-math.abs(2*l-1))*s
  local x = (1-math.abs(h%2-1))*c
  local m,r,g,b = (l-.5*c), 0,0,0
  if h < 1     then r,g,b = c,x,0
  elseif h < 2 then r,g,b = x,c,0
  elseif h < 3 then r,g,b = 0,c,x
  elseif h < 4 then r,g,b = 0,x,c
  elseif h < 5 then r,g,b = x,0,c
  else              r,g,b = c,0,x
  end return (r+m),(g+m),(b+m),a
end

function intro.pprint(stringg, x, y)
  local r,g,b,a = love.graphics.getColour() 
  if type(stringg) == "number" then
    stringg = math.floor(stringg*10)/10
  end
  love.graphics.setColour(0,0,0)
  love.graphics.print(stringg, x, y)
  love.graphics.setColour(r,g,b,a)
end

function intro.varToString(var) -- thank you so much HugoBDesigner! (https://love2d.org/forums/viewtopic.php?t=82877)
  if type(var) == "string" then
    return "\"" .. var .. "\""
  elseif type(var) ~= "table" then
    return tostring(var)
  else
    local ret = "{ "
    local ts = {}
    local ti = {}
    for i, v in pairs(var) do
      if type(i) == "string" then
        table.insert(ts, i)
      else
        table.insert(ti, i)
      end
    end
    table.sort(ti)
    table.sort(ts)
    
    local comma = ""
    if #ti >= 1 then
      for i, v in ipairs(ti) do
        ret = ret .. comma .. intro.varToString(var[v])
        comma = ", \n"
      end
    end
    
    if #ts >= 1 then
      for i, v in ipairs(ts) do
        ret = ret .. comma .. "" .. v .. " = " .. intro.varToString(var[v])
        comma = ", \n"
      end
    end
    
    return ret .. "}"
  end
end

return intro
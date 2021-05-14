local intro = {length = 0.5, sustain = 0.2}

intro.globals = {
  water = {r=0.81,g=0.83,b=1}
}

local project = {}
project.font = love.graphics.newFont("Public_Sans/static/PublicSans-Black.ttf", 20)

function intro:init(subtext)
  self.dot32 = {}
  self.dot32.font = love.graphics.newFont("intro/PT_Sans/PTSans-Bold.ttf", 100)
  self.dot32.x = love.graphics.getWidth()/2
  self.dot32.y = 0
  self.dot32.yV = 0

  self.sub = {}
  self.sub.font = love.graphics.newFont("intro/PT_Sans/PTSans-Regular.ttf", 45)
  self.sub.text = subtext or "Games"
  self.sub.x = 0
  self.sub.y = love.graphics.getHeight()/1.65
  self.sub.xV = 0

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
  self.dot32.yV = self.dot32.yV + ((self.phase == 1 and (love.graphics.getHeight()/2 - self.dot32.y)*0.5) or 0)
  self.dot32.y = self.dot32.y + self.dot32.yV/2
  self.dot32.yV = self.dot32.yV * 0.6

  self.sub.xV = self.sub.xV + (love.graphics.getWidth()/2 - self.sub.x)*0.5
  self.sub.x = self.sub.x + self.sub.xV/2
  self.sub.xV = self.sub.xV * 0.6

  self.timer = self.timer + dt
  
  if self.timer > self.length then
    self.phase = 2
    love.graphics.setFont(project.font)
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
    love.graphics.setColor(0.17, 0.17, 0.17, self.ghost)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1, self.ghost)
    love.graphics.setFont(self.dot32.font)
    love.graphics.print("Dot32", self.dot32.x - self.dot32.font:getWidth("Dot32")/2, self.dot32.y - self.dot32.font:getHeight()/2)
    love.graphics.setFont(self.sub.font)
    love.graphics.print(self.sub.text, self.sub.x - self.sub.font:getWidth(self.sub.text)/2, self.sub.y - self.sub.font:getHeight()/2)

    love.graphics.setColor(0.2, 0.2, 0.2, self.ghost)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight()-5, love.graphics.getWidth()-(love.graphics.getWidth()/self.length)*self.timer, 5)

    --love.graphics.setColor(1, 1, 1, self.ghost)
    --love.graphics.rectangle("fill", 50, love.graphics.getHeight()-5-100, ((love.graphics.getWidth()-100)/self.length*self.timer, 5)
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

-- function love.keypressed(key)
  -- if key == "f" and love.keyboard.isDown("lgui") and love.keyboard.isDown("lctrl") and operatingSystem == "OS X" then
  --     love.window.setFullscreen(true)
  -- end
  -- if key == "f11" and operatingSystem == "Windows" then
  --     love.window.setFullscreen(true)
  -- end
-- end
return intro
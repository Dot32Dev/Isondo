intro = {}

function introInitialise(subtext)
  intro.dot32 = {}
  intro.dot32.font = love.graphics.newFont("Intro/PT_Sans/PTSans-Bold.ttf", 100)
  intro.dot32.x = love.graphics.getWidth()/2
  intro.dot32.y = 0
  intro.dot32.yV = 0

  intro.sub = {}
  intro.sub.font = love.graphics.newFont("Intro/PT_Sans/PTSans-Regular.ttf", 45)
  intro.sub.text = subtext
  intro.sub.x = 0--love.graphics.getWidth()/2
  intro.sub.y = love.graphics.getHeight()/1.65
  intro.sub.xV = 0

  intro.timer = 0
  intro.time = 0.5
  intro.sustain = 0.2
  intro.phase = 1
  intro.ghost = 1

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

function introUpdate(dt)
  intro.dot32.yV = intro.dot32.yV + ((love.graphics.getHeight()/2 - intro.dot32.y)*0.5)*fuckBoolean(intro.phase == 1)
  intro.dot32.y = intro.dot32.y + intro.dot32.yV/2
  intro.dot32.yV = intro.dot32.yV * 0.6

  intro.sub.xV = intro.sub.xV + (love.graphics.getWidth()/2 - intro.sub.x)*0.5
  intro.sub.x = intro.sub.x + intro.sub.xV/2
  intro.sub.xV = intro.sub.xV * 0.6

  intro.timer = intro.timer + dt
  
  if intro.timer > intro.time then
    intro.phase = 2
    love.graphics.setFont(screen.font)
  end
  if intro.phase == 2 then
    intro.ghost = intro.ghost -dt/intro.sustain
  end
  if intro.timer > intro.time + intro.sustain then
    intro.phase = 3
  end
end

function introDraw()
  if intro.phase < 3 then
    love.graphics.setColor(0.17, 0.17, 0.17, intro.ghost)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1, intro.ghost)
    love.graphics.setFont(intro.dot32.font)
    love.graphics.print("Dot32", intro.dot32.x - intro.dot32.font:getWidth("Dot32")/2, intro.dot32.y - intro.dot32.font:getHeight()/2)
    love.graphics.setFont(intro.sub.font)
    love.graphics.print(intro.sub.text, intro.sub.x - intro.sub.font:getWidth(intro.sub.text)/2, intro.sub.y - intro.sub.font:getHeight()/2)

    love.graphics.setColor(0.2, 0.2, 0.2, intro.ghost)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight()-5, love.graphics.getWidth()-(love.graphics.getWidth()/intro.time)*intro.timer, 5)

    --love.graphics.setColor(1, 1, 1, intro.ghost)
    --love.graphics.rectangle("fill", 50, love.graphics.getHeight()-5-100, ((love.graphics.getWidth()-100)/intro.time)*intro.timer, 5)
  end
end

function fuckBoolean(boolean)
  if boolean == true then
    return 1
  else
    return 0
  end
end

function HSL(h, s, l, a)
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

-- function love.keypressed(key)
  -- if key == "f" and love.keyboard.isDown("lgui") and love.keyboard.isDown("lctrl") and operatingSystem == "OS X" then
  --     love.window.setFullscreen(true)
  -- end
  -- if key == "f11" and operatingSystem == "Windows" then
  --     love.window.setFullscreen(true)
  -- end
-- end
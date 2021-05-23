local intro = require('intro') -- require intro for access to dependencies (intro.globals)
local items = require('items')
local entity = {}

function entity.new(camera, x, z)
	local bush = {
		id = 'bush', 
		
		dir = 0, 
		x = x or 0, 
		y = 0, 
		z = z or 0, 
	
		shadow = 25, 
	}
	bush.camera = camera or {x=love.graphics.getWidth()/2, y=0, z=love.graphics.getHeight()/2, dir=0}

	local function p3d(p, rotation, dontProject) -- p = {x= , y= , z= } (x/z may be swapped around (?))
		rotation = rotation or bush.dir -- rotation is a scalar that rotates around the y axis

		local squish = 0.5
		if dontProject then
			squish = 1
		end

		local x = math.sin(rotation)*p.x 	        + 0   +	math.sin(rotation+math.pi/2)*p.z
		local y = math.cos(rotation)*p.x*squish   + p.y +	math.cos(rotation+math.pi/2)*p.z*squish 

		local z = math.cos(rotation)*p.x 	        - p.y +	math.cos(rotation+math.pi/2)*p.z -- z is used for depth sorting

		return x,y,z
	end
	
	local x,y,z, x1,y1,z1 = 0,0,0, 0,0,0 -- creates the local variables, outputs dont get used
	bush.objects = { -- table of every body part in the bush (automatically gets sorted by z each frame)
		-- {
		-- 	id='legs',
		-- 	z=1,
		-- 	draw = function(self)
		-- 		love.graphics.setColour(0.8*0.8,0.6*0.8,0.3*0.8)
		-- 		love.graphics.setLineWidth(8)
		-- 		x,y,z = p3d({x=0, y=-12, z=6})
		-- 		x1,y1,z1 = p3d({x=math.sin(math.sin(0)*math.pi/2-0/2)*12, y=-12+math.cos(math.sin(0)*math.pi/2-0/2)*12, z=6})
		-- 		love.graphics.line(x, y, x1, y1) -- left leg
		-- 		love.graphics.ellipse('fill', x1, y1, 5, 2.5)
		-- 		x,y,z = p3d({x=0, y=-12, z=-6})
		-- 		x1,y1,z1 = p3d({x=math.sin(-math.sin(0)*math.pi/2+0/2)*12, y=-12+math.cos(math.sin(0)*math.pi/2+0/2)*12, z=-6})
		-- 		love.graphics.line(x, y, x1, y1)
		-- 		love.graphics.ellipse('fill', x1, y1, 5, 2.5)

		-- 		_, _, self.z = p3d({x=0, y=-12, z=0})
		-- 	end 
		-- },
		-- {
		-- 	id='left arm',
		-- 	z=2,
		-- 	draw = function(self)
		-- 		love.graphics.setColour(0.3*0.9,0.6*0.9,0.8*0.9)
		-- 		x,y,z = p3d({x=0, y=-24, z=20})
		-- 		local dir = -math.sin(0)*math.pi/2
		-- 		if 0 < 0 then
		-- 			dir = -0
		-- 		end
		-- 		x1,y1 = p3d({x=math.sin(dir)*12, y=-24+math.cos(math.sin(dir))*12, z=20})

		-- 		love.graphics.line(x, y, x1, y1)

		-- 		love.graphics.circle('fill', x, y, 5)
		-- 		love.graphics.setColour(0.9,0.7,0.6)
		-- 		love.graphics.circle('fill', x1, y1, 5)

		-- 		_, _, self.z = p3d({x=0, y=-24, z=20})
		-- 	end 
		-- },
		-- {
		-- 	id='right arm',
		-- 	z=3,
		-- 	draw = function(self)
		-- 		love.graphics.setColour(0.3*0.9,0.6*0.9,0.8*0.9)
		-- 		x,y,z = p3d({x=0, y=-24, z=-20})
		-- 		local dir = math.sin(0)*math.pi/2
		-- 		if 0 < 0 then
		-- 			dir = 0
		-- 		end
		-- 		x1,y1 = p3d({x=math.sin(dir)*12, y=-24+math.cos(math.sin(dir))*12, z=-20})
		-- 		love.graphics.line(x, y, x1, y1)

		-- 		love.graphics.circle('fill', x, y, 5)
		-- 		love.graphics.setColour(0.9,0.7,0.6)
		-- 		love.graphics.circle('fill', x1, y1, 5)

		-- 		_, _, self.z = p3d({x=0, y=-24, z=-20})
		-- 	end 
		-- },
		-- {
		-- 	id='body',
		-- 	z=4,
		-- 	vertices = function(self, point, perspective)
		-- 		local perspective = perspective or 0
		-- 		local vertices = {}
		-- 		table.insert(vertices, {0, 0, 0.5, 0.5})

		-- 		for i=0, 30 do
		-- 			local angle = (i / 30)*math.pi*2

		-- 			local x = math.cos(angle)
		-- 			local y = math.sin(angle)

		-- 			local multiply = 19/20
		-- 			if y > point then
		-- 				multiply = math.sqrt(1^2 - point^2)
		-- 				x = x* multiply
		-- 				y = y* multiply* perspective +point
						
		-- 				local len = math.sqrt(x^2 + y^2)
		-- 				if len > 1 then
		-- 					x = x / len
		-- 					y = y / len
		-- 				end
		-- 			end

		-- 			table.insert(vertices, {x*20, y*20})
		-- 		end
		-- 		return vertices
		-- 	end,
		-- 	draw = function(self)
		-- 		local wet = false

		-- 		love.graphics.setColour(0.3,0.6,0.8)
		-- 		if wet then
		-- 			love.graphics.setColour(0.3*intro.globals.water.r, 0.6*intro.globals.water.g, 0.8*intro.globals.water.b)
		-- 		end
		-- 		love.graphics.ellipse("fill", 0, -24, 20, 19)

		-- 		if wet then 
		-- 			local normWet = (bush.wet+24)/19
		-- 			if not self.mesh then
		-- 				self.mesh = love.graphics.newMesh(self:vertices(math.max(normWet, -1)), "fan", "stream")
		-- 			else
		-- 				local vertices = self:vertices(math.max(normWet, -1))
		-- 				self.mesh:setVertices(vertices, 1, #vertices)
		-- 			end
		-- 			love.graphics.setColour(0.3,0.6,0.8)
		-- 			love.graphics.draw(self.mesh, 0, -24)
		-- 		end

		-- 		_, _, self.z = p3d({x=0, y=-24, z=0})
		-- 	end 
		-- },
		-- {
		-- 	id='left eye',
		-- 	z=5,
		-- 	draw = function(self)
		-- 		love.graphics.setColour(0.13,0.13,0.13)
		-- 		x,y,z = p3d({x=16, y=-44, z=0}, (bush.dir)+14/180*math.pi)
		-- 		love.graphics.ellipse("fill", x, y, 2.5, 5)

		-- 		_, _, self.z = p3d({x=16, y=-44, z=0}, (bush.dir)+14/180*math.pi)
		-- 	end 
		-- },
		-- {
		-- 	id='right eye',
		-- 	z=6,
		-- 	draw = function(self)
		-- 		love.graphics.setColour(0.13,0.13,0.13)
		-- 		x,y,z = p3d({x=16, y=-44, z=0}, (bush.dir)-14/180*math.pi)
		-- 		love.graphics.ellipse("fill", x, y, 2.5, 5)

		-- 		_, _, self.z = p3d({x=16, y=-44, z=0}, (bush.dir)-14/180*math.pi)
		-- 	end 
		-- },
		-- {
		-- 	id='head',
		-- 	z=7,
		-- 	draw = function(self)
		-- 		love.graphics.setColour(0.9,0.7,0.6)
		-- 		love.graphics.ellipse("fill", 0, -44, 20/1.2, 19/1.2)

		-- 		self.z = 44
		-- 	end 
		-- },
	}
	for i=1, 15 do
		table.insert(bush.objects, {
			id='head',
			z=i,
			x = love.math.random(-15,15),
			y = love.math.random(-15,0),
			zz = love.math.random(-15,15),
			draw = function(self)
				x,y,z = p3d({x=self.x, y=self.y, z=self.zz})
				love.graphics.setColour(0.48, 0.64, 0.43)
				love.graphics.circle('fill', x,y, 10)

				self.z = z
			end 
		})
	end

	function bush:update(dt)
		self.dir = self.camera.dir
	end

	function bush:draw()
		local tx, ty = p3d({x=self.z, y=self.y, z=self.x}, self.camera.dir)
		love.graphics.translate(tx, ty)

		table.sort(self.objects, function(a,b) 
			return (a.z < b.z)
		end)
		for i=1, #self.objects do
			self.objects[i]:draw()
		end

		love.graphics.translate(-tx, -ty)
	end

	local function distance(x1,y1, x2,y2)
		return math.sqrt((y2-y1)^2 + (x2-x1)^2)
	end

	local function angleDifference(a, b)
		local difference = (a - b + math.pi) % (math.pi * 2) - math.pi
		return (difference < -math.pi) and (difference + math.pi * 2) or difference
	end

	function bush:damage(x, z, plrdir)
    local dist = distance(x,z, self.x,self.z)
    if dist < 100 and dist > 1 then
      local dir = math.atan2(self.x-x, self.z-z)
      if math.abs(angleDifference(dir, plrdir-self.camera.dir)) < math.pi/2 then
        self.dead = true
      end
    end
  end

	return bush
end
return entity
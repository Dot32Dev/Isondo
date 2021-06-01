local intro = require('intro')
local items = require('items')

local inventory = {
	selected = 1, 
	mouse = {}, 

	{1}, -- adds sword to first slot of inventory

	openMenus = {
		"Quit", 
		"Options", 
		"Crafting", -- index 3
	},
	openMenuSelected = 3, -- sets the current menu to the crafting menu

	recipes = {
		{
			item = {1,0}, -- item to be crafted {item index, 0}
			materials = {
				{index = 2, amount = 5}, -- {index = item index, amount = amount to be crafted}
			}, 
		},
	},
}

for i=1, 40-#inventory do -- ensures 40 items
	table.insert(inventory, {}) -- insert empty table
end

inventory.add = function(self, index)
	local added = false
	for i=1, #self do
		if self[i][1] == index and not added then
			self[i][2] = 1 -- bounce
			self[i][3] = (self[i][3] and self[i][3]+1) or 2 -- amount in stack
			added = true
			break
		end
	end
	for i=1, #self do
		if not self[i][1] and not added  then
			self[i][1] = index
			self[i][2] = 1
			added = true
			break
		end
	end
end

function inventory:update(dt)
	love.mouse.setCursor()
	for i=1, #self do 
		if self[i][2] then
			self[i][2] = self[i][2] * 0.7
		end
		if self[i][3] and self[i][3] == 1 then 
			self[i][3] = nil
		end
	end
	for i=1, #self.recipes do
		self.recipes[i].item[2] = self.recipes[i].item[2] * 0.7
	end

	self.hover = false
	-- detect mouse hovering over hotbar
	if self.open then
		local scale = 1

		local tSize = 40*scale
		local aSize = 30*scale
		local tx = -10*tSize/2

		local x = love.mouse.getX()
		local y = love.mouse.getY() 
		for i=1, 10 do
			if x > (tx+tSize*i+love.graphics.getWidth()/2-tSize/2) - tSize/2 and x < (tx+tSize*i+love.graphics.getWidth()/2-tSize/2) + tSize/2 
			and y > (love.graphics.getHeight()-35) - tSize/2 and y < (love.graphics.getHeight()-35) + tSize/2 then
				self.hover = i
				if self[i][1] and #self.mouse == 0 then
					love.mouse.setCursor(intro.cursor)
				end

				if self[i][2] then
					self[i][2] = self[i][2] + (0.5-self[i][2]) * 0.7
				elseif  self[i][1] then
					self[i][2] = 0
				end
			end
		end
		if not self.hover then
			local i = 10
			for iy=1, 3 do
				for ix=1, 10 do
					i = i + 1
					if x > (tx+tSize*ix+love.graphics.getWidth()/2-tSize/2) - tSize/2 and x < (tx+tSize*ix+love.graphics.getWidth()/2-tSize/2) + tSize/2 
					and y > (love.graphics.getHeight()-35-tSize*(3+2)+iy*tSize) - tSize/2 and y < (love.graphics.getHeight()-35-tSize*(3+2)+iy*tSize) + tSize/2 then
						self.hover = i
						if self[i][1] and #self.mouse == 0 then
							love.mouse.setCursor(intro.cursor)
						end

						if self[i][2] then
							self[i][2] = self[i][2] + (0.5-self[i][2]) * 0.7
						elseif  self[i][1] then
							self[i][2] = 0
						end
					end
				end
			end
		end
		if self.mouse[3] and self.mouse[3] == 1 then 
			self.mouse[3] = nil
		end
		local f = love.graphics.getFont()
		local tx = tSize-(tSize-aSize)/2-10*tSize/2 +love.graphics.getWidth()/2-tSize/2
		local ty = love.graphics.getHeight()-35-tSize*(3+2+3+1)
		for i=#self.openMenus, 1, -1 do
			if i ~= self.openMenuSelected then
				if x > tx and x < tx+f:getWidth(self.openMenus[i])*0.7
				and y > ty and y < ty+f:getHeight()*0.7 then
					love.mouse.setCursor(intro.cursor)
					if love.mouse.isDown(1) then
						self.openMenuSelected = i
					end
				end
			end

			tx = tx + f:getWidth(self.openMenus[i])*0.7+(tSize-aSize)
		end

		tx = -10*tSize/2
		if self.openMenus[self.openMenuSelected] == "Crafting" then

			local i = 0
			for iy=1, 3 do
				for ix=1, 10 do
					i = i + 1
					if i > #self.recipes then
						break
					end
					if x > (tx+tSize*ix+love.graphics.getWidth()/2-tSize/2) - tSize/2 and x < (tx+tSize*ix+love.graphics.getWidth()/2-tSize/2) + tSize/2 
					and y > (love.graphics.getHeight()-35-tSize*(3+2+3+1)+iy*tSize) - tSize/2 and y < (love.graphics.getHeight()-35-tSize*(3+2+3+1)+iy*tSize) + tSize/2 then
						if #self.mouse == 0 and self.recipes[i].craftable then
							love.mouse.setCursor(intro.cursor)--self.recipes[i].item[1]
						end

						if self.recipes[i].item[2] then
							self.recipes[i].item[2] = self.recipes[i].item[2] + (0.5-self.recipes[i].item[2]) * 0.7
						elseif  self.recipes[i].item[1] then
							self.recipes[i].item[2] = 0
						end
					end
				end
			end
		end
	end
end

function inventory:draw(scale)
	local scale = scale or 1--1.2

	local x = love.graphics.getWidth()/2-40*scale/2
	local y = love.graphics.getHeight()-35
	--love.graphics.circle('fill', x, y, 10)

	love.graphics.translate(x,y)

	local tSize = 40*scale  -- translate size
	local aSize = 30*scale  -- light square tile size
	local bSize = tSize     -- background tile size
	local count = 10
	local tx = -count*tSize/2--*scale

	love.graphics.setColour(0.2,0.25,0.3, 1)
	love.graphics.rectangle('fill', tx+bSize/2-(tSize-aSize)/2, -bSize/2-(tSize-aSize)/2, tSize*count+(tSize-aSize), tSize+(tSize-aSize)+50, 15*scale)

	love.graphics.translate(tx, 0)
	for i=1, count do
		love.graphics.setLineWidth(2*scale)
		love.graphics.translate(tSize, 0)
		tx = tx + tSize

		love.graphics.setColour(0.2,0.25,0.3, 1)
		love.graphics.rectangle('fill', -bSize/2, -bSize/2, bSize, bSize, 25*scale)
		love.graphics.setColour(1,1,1, 0.3)
		if self.selected == i then
			love.graphics.setLineWidth(3*scale)
			love.graphics.setColour(1,1,1)
		end
		love.graphics.rectangle('line', -aSize/2, -aSize/2, aSize, aSize, 5*scale)

		local img = (self[i][1] and items[self[i][1]].img) or false
		-- local itemType = (self[i][1] and items[self[i][1]].type) or false
		local imgScale = 1 + (self[i][2] and self[i][2] or 0)*0.5
		if img then
			love.graphics.setColour(1,1,1)
			love.graphics.draw(img, 0,0, -math.pi/4,0.25*scale*imgScale, 0.25*scale*imgScale, img:getWidth()/2, img:getHeight()/2)
		end

		if self[i][3] then
			love.graphics.print(self[i][3], 3, nil, nil, 0.7)
		end
	end
	love.graphics.translate(-x-tx,-y)
	if self.open then
		self:drawCrafting(scale)
		self:drawExtended(scale)
	end
end

function inventory:drawExtended(scale)
	local tSize = 40*scale  -- translate size
	local aSize = 30*scale  -- light square tile size
	local bSize = tSize     -- background tile size
	local countX, countY = 10, 3

	local x = love.graphics.getWidth()/2-tSize/2
	local y = love.graphics.getHeight()-35-tSize*(countY+2)
	love.graphics.translate(x,y)

	local f = love.graphics.getFont()
	love.graphics.setColour(0.2,0.25,0.3, 1)
	-- love.graphics.setColour(0.3,0.25,0.2, 1)
	-- love.graphics.rectangle('fill', bSize/2-(tSize-aSize)/2-countX*tSize/2, -(tSize-aSize)/2+tSize/2-30, f:getWidth('Inventory')+(tSize-aSize), 60, 15*scale)
	love.graphics.rectangle('fill', bSize/2-(tSize-aSize)/2-countX*tSize/2, -(tSize-aSize)/2+tSize/2-30, tSize*countX+(tSize-aSize), 60)
	love.graphics.rectangle('fill', bSize/2-(tSize-aSize)/2-countX*tSize/2, -(tSize-aSize)/2+tSize/2, tSize*countX+(tSize-aSize), 3*tSize+(tSize-aSize), 15*scale)

	love.graphics.setColour(1,1,1)
	love.graphics.print('Inventory', tSize-(tSize-aSize)/2-countX*tSize/2, tSize/2-f:getHeight()-(tSize-aSize)/2, nil, 0.7)

	local i = countX
	for y=1, countY do
		for x=1, countX do
			i = i + 1
			love.graphics.translate(-countX*tSize/2 + x*tSize, y*tSize)

			love.graphics.setColour(1,1,1, 0.3)
			love.graphics.rectangle('line', -aSize/2, -aSize/2, aSize, aSize, 5*scale)

			love.graphics.setColour(1,1,1)
			--local img = (inventory[i][1] and items[inventory[i][1]].img) or false
			--if x*y*i % 3 == 0 then love.graphics.print(i-10, 3, nil, nil, 0.7) end

			local img = (self[i][1] and items[self[i][1]].img) or false
			-- local itemType = (self[i][1] and items[self[i][1]].type) or false
			local imgScale = 1 + (self[i][2] and self[i][2] or 0)*0.5
			if img then
				love.graphics.setColour(1,1,1)
				love.graphics.draw(img, 0,0, -math.pi/4,0.25*scale*imgScale, 0.25*scale*imgScale, img:getWidth()/2, img:getHeight()/2)
			end

			if self[i][3] then
				love.graphics.print(self[i][3], 3, nil, nil, 0.7)
			end
			love.graphics.translate(countX*tSize/2 - x*tSize, -y*tSize)
		end
	end
	love.graphics.translate(-x,-y)

	if self.mouse[1] then
		love.graphics.translate(love.mouse.getX(), love.mouse.getY())
		local img = items[self.mouse[1]].img
		-- local itemType = (self[i][1] and items[self[i][1]].type) or false
		local imgScale = 1.5
		if img then
			love.graphics.setColour(1,1,1)
			love.graphics.draw(img, 0,0, -math.pi/4,0.25*scale*imgScale, 0.25*scale*imgScale, img:getWidth()/2, img:getHeight()/2)
		end

		if self.mouse[3] then
			love.graphics.print(self.mouse[3], 3, nil, nil, 0.7)
		end
		love.graphics.translate(-love.mouse.getX(), -love.mouse.getY())
	end

	if self.hover and self[self.hover][1] then
		local _, count = items[self[self.hover][1]].desc:gsub('\n', '\n')
		local padding = 5
		love.graphics.setColour(0,0,0)
		love.graphics.rectangle('fill', love.mouse.getX()+20-padding, love.mouse.getY()-padding, math.max(f:getWidth(items[self[self.hover][1]].name)*0.7, f:getWidth(items[self[self.hover][1]].desc)*0.6)+padding*2, f:getHeight()*(0.7+0.6*(1+count))+padding*2, padding)
		love.graphics.setColour(1,1,1)
		love.graphics.print(items[self[self.hover][1]].name, love.mouse.getX()+20, love.mouse.getY(), nil, 0.7) -- ..'\n'..items[self[self.hover][1]].desc
		love.graphics.setColour(1,1,1, 0.7)
		love.graphics.print(items[self[self.hover][1]].desc, love.mouse.getX()+20, love.mouse.getY()+f:getHeight()*0.7, nil, 0.6)
	end
end

function inventory:drawCrafting(scale)
	local tSize = 40*scale  -- translate size
	local aSize = 30*scale  -- light square tile size
	local bSize = tSize     -- background tile size
	local countX, countY = 10, 3

	local x = love.graphics.getWidth()/2-tSize/2
	local y = love.graphics.getHeight()-35-tSize*(countY+2+3+1)
	love.graphics.translate(x,y)

	local f = love.graphics.getFont()
	love.graphics.setColour(0.3,0.25,0.2, 1)
	-- love.graphics.setColour(0.3,0.25,0.2, 1)
	love.graphics.rectangle('fill', bSize/2-(tSize-aSize)/2-countX*tSize/2, -(tSize-aSize)/2+tSize/2-30, tSize*countX+(tSize-aSize), 60, 15*scale)
	love.graphics.rectangle('fill', bSize/2-(tSize-aSize)/2-countX*tSize/2, -(tSize-aSize)/2+tSize/2, tSize*countX+(tSize-aSize), 5*tSize+(tSize-aSize), 15*scale)

	-- love.graphics.setColour(1,1,1)
	-- love.graphics.print('Crafting', bSize/2-countX*tSize/2+(f:getWidth('Crafting')-f:getWidth('Crafting')*0.7)/2, tSize/2-f:getHeight()-(tSize-aSize)/2, nil, 0.7)
	-- love.graphics.setColour(1,1,1, 0.3)
	-- love.graphics.print('Chest', bSize/2-countX*tSize/2+(f:getWidth('Crafting')+f:getWidth('Crafting')*0.7)/2+(tSize-aSize), tSize/2-f:getHeight()-(tSize-aSize)/2, nil, 0.7)

	love.graphics.push()
	love.graphics.translate(tSize-(tSize-aSize)/2-countX*tSize/2, 0)
	for i=#self.openMenus, 1, -1 do
		if i == self.openMenuSelected then
			love.graphics.setColour(1,1,1)
		else
			love.graphics.setColour(1,1,1, 0.3)
		end

		love.graphics.print(self.openMenus[i], 0, 0, nil, 0.7)

		love.graphics.translate(f:getWidth(self.openMenus[i])*0.7+(tSize-aSize),0)
	end
	love.graphics.pop()

	-- optionally run in differen menus
	if self.openMenus[self.openMenuSelected] == "Crafting" then
		local countI = #self.recipes
		local i = 0
		for y=1, countY do
			for x=1, countX do
				i = i + 1
				love.graphics.translate(-countX*tSize/2 + x*tSize, y*tSize)
				if i <= countI then

					love.graphics.setColour(1,1,1, 0.3)
					love.graphics.rectangle('line', -aSize/2, -aSize/2, aSize, aSize, 5*scale)

					love.graphics.setColour(1,1,1)
					local img = items[self.recipes[i].item[1]].img
					-- local itemType = (self[i][1] and items[self[i][1]].type) or false
					local imgScale = 1 + self.recipes[i].item[2]*0.5
					if img then
						if self.recipes[i].craftable then 
							love.graphics.setColour(1,1,1)
						else
							love.graphics.setColour(1,1,1,0.5)
							imgScale = 1
						end
						love.graphics.draw(img, 0,0, -math.pi/4,0.25*scale*imgScale, 0.25*scale*imgScale, img:getWidth()/2, img:getHeight()/2)
					end

					if self.recipes[i].item[3] then
						love.graphics.print(self.recipes[i].item[3], 3, nil, nil, 0.7)
					end
				end
				love.graphics.translate(countX*tSize/2 - x*tSize, -y*tSize)
			end
		end
	end
	love.graphics.translate(-x,-y)
end

function inventory:takeItems(recipe)
	print("i was called for")
	for j=1, #recipe do
		print(j)
		local amountFound = 0
		local i = 1
		while amountFound < recipe[j].amount and i < #inventory+1 do
			print(i)
			if self[i][1] == recipe[j].index then
				local stack = self[i][3] or 1
				local tmp = amountFound
				amountFound = amountFound + math.min(self[i][3], (recipe[j].amount-amountFound))
				self[i][3] = self[i][3] - math.min(self[i][3], (recipe[j].amount-tmp))
				if self[i][3] < 1 then
					self[i] = {}
				end
			end

			i=i+1
		end
	end
	self:craftAvailability()
end

function inventory:craftAvailability()
	-- awfully unoptimised, please fix later :blobsweats:
	local itemAmounts = {}
	for i=1, #items do
		table.insert(itemAmounts, 0)
	end
	for i=1, #self do
		if #self[i] > 0 then
			local stack = self[i][3] or 1
			itemAmounts[self[i][1]] = itemAmounts[self[i][1]] + stack
		end
	end

	for i=1, #self.recipes do
		local craftable = false
		for i=1, #self.recipes[i].materials do
			local required = self.recipes[i].materials[i].amount-1
			local itemType = self.recipes[i].materials[i].index
			if itemAmounts[itemType] > required then
				craftable = true
			end
		end
		self.recipes[i].craftable = craftable
	end
end

function inventory:swap()
	local tmp = self[self.hover]
	self[self.hover] = self.mouse
	self.mouse = tmp
end

function inventory:mousepressed(x,y,b)
	if self.hover then
		if b == 1 then
			if self[self.hover][1] == self.mouse[1] and #self.mouse > 0 then
				self[self.hover][3] = self[self.hover][3] or 1
				self.mouse[3] = self.mouse[3] or 1

				self[self.hover][3] = self[self.hover][3] + self.mouse[3]
				self.mouse = {}
			else
				self:swap()
			end
		elseif b == 2 then
			if #self.mouse == 0 then
				if self[self.hover][3] then 
--					self.mouse = self[self.hover]
					self.mouse = {
						self[self.hover][1],
						self[self.hover][2],
					  self[self.hover][3],
					}
					self.mouse[3] = math.ceil(self[self.hover][3]/2)
					self[self.hover][3] = math.floor(self[self.hover][3]/2)
				else
					self:swap()
				end
			else
				if self[self.hover][1] == self.mouse[1] then 
					if self.mouse[3] then
						self[self.hover][3] = self[self.hover][3] or 1
						self[self.hover][3] = self[self.hover][3] + 1
						self.mouse[3] = self.mouse[3] - 1
					else
						self[self.hover][3] = self[self.hover][3] or 1
						self[self.hover][3] = self[self.hover][3] + 1
						self.mouse = {}
					end
				end
				if not self[self.hover][1] then 
					if self.mouse[3] then
						self[self.hover][1] = self.mouse[1]
						self[self.hover][3] = nil
						self.mouse[3] = self.mouse[3] - 1
					else
						self:swap()
					end
				end
			end
		end
	end
	local tSize = 40
	local tx = -10*tSize/2
	if self.openMenus[self.openMenuSelected] == "Crafting" then
		local i = 0
		for iy=1, 3 do
			for ix=1, 10 do
				i = i + 1
				if i > #self.recipes then
					break
				end
				if x > (tx+tSize*ix+love.graphics.getWidth()/2-tSize/2) - tSize/2 and x < (tx+tSize*ix+love.graphics.getWidth()/2-tSize/2) + tSize/2 
				and y > (love.graphics.getHeight()-35-tSize*(3+2+3+1)+iy*tSize) - tSize/2 and y < (love.graphics.getHeight()-35-tSize*(3+2+3+1)+iy*tSize) + tSize/2 then
					if self.recipes[i].craftable then
						if #self.mouse == 0 then
							self.mouse[1] = self.recipes[i].item[1]
							self:takeItems(self.recipes[i].materials)
						elseif self.mouse[1] == self.recipes[i].item[1] then
							self.mouse[3] = (self.mouse[3] or 1) + 1
							self:takeItems(self.recipes[i].materials)
						end
					end
				end
			end
		end
	end
end

function inventory:keypressed(k)
	local n = tonumber(k)
	if n then 
		n = (n and n>0 and n) or 10
		self.selected = n
		if self[self.selected][1] then -- if the selected item isnt pointing to an empty table
			self.mesh:setTexture(items[self[self.selected][1]].img)
		end
		print(self.selected)
	end

	if k == 'escape' then
		self.open = not self.open
		if self.open then 
			self:craftAvailability()
		end
	end
end

function inventory:wheelmoved(x,y)
	self.selected = (self.selected + y -1) % 10 + 1
	if self[self.selected][1] then -- if the selected item isnt pointing to an empty table
		self.mesh:setTexture(items[self[self.selected][1]].img)
	end
	print(self.selected)
end

return inventory

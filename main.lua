local gen2d = require 'poisson'
local newMenu = require 'menu'
local color=require 'color'
local COL=color.COL

local lg=love.graphics
local lm=love.mouse

local taskBar={}

local activeMenu=nil
local bgMenu=nil

local function displaySingleDot() 
	for _,vert in ipairs(vertices) do
		love.graphics.setColor(COL(vert.hue, 255))
		love.graphics.circle("fill", vert.sx, vert.sy, 5)
	end
end

local function displaySingleSquare() 
	for _,vert in ipairs(vertices) do
		love.graphics.setColor(COL(vert.hue, 255))
		love.graphics.rectangle("fill", vert.sx-5, vert.sy-5, 10, 10)
	end
end

local function displayTwoDotsTransparent() 
	-- Color grid
	for _,vert in ipairs(vertices) do
			love.graphics.setColor(COL(vert.hue, 128))
			love.graphics.circle("fill", vert.sx, vert.sy, 10)
	end
	for _,vert in ipairs(vertices) do
		love.graphics.setColor(COL(vert.hue, 128))
		love.graphics.circle("fill", vert.sx, vert.sy, 5)
	end
end

local function displayTwoSquaresTransparent() 
	-- Color grid
	for _,vert in ipairs(vertices) do
			love.graphics.setColor(COL(vert.hue,  128))
			love.graphics.rectangle("fill", vert.sx-10, vert.sy-10, 20,20)
	end
	for _,vert in ipairs(vertices) do
		love.graphics.setColor(COL(vert.hue,  128))
		love.graphics.rectangle("fill", vert.sx-5, vert.sy-5, 10,10)
	end
end

local function displayTwoDotsSolid() 

	-- Color grid
	for _,vert in ipairs(vertices) do
			love.graphics.setColor(COL(vert.hue, 255))
			love.graphics.circle("fill", vert.sx, vert.sy, 10)
	end
	for _,vert in ipairs(vertices) do
		love.graphics.setColor(COL(vert.hue, 255))
		love.graphics.circle("fill", vert.sx, vert.sy, 5)
	end
end

local function displayTwoSquaresSolid() 
	-- Color grid
	for _,vert in ipairs(vertices) do
			love.graphics.setColor(COL(vert.hue, 255))
			love.graphics.rectangle("fill", vert.sx-10, vert.sy-10, 20,20)
	end
	for _,vert in ipairs(vertices) do
		love.graphics.setColor(COL(vert.hue, 255))
		love.graphics.rectangle("fill", vert.sx-5, vert.sy-5, 10,10)
	end
end



local idMode=1
local displayModes = {
	{title="Single dot", f=displaySingleDot},
	{title="Two dots, transparent",f=displayTwoDotsTransparent},
	{title="Two dots, solid",f=displayTwoDotsSolid},
	{title="Single square",f=displaySingleSquare},
	{title="Two squares, transparent",f=displayTwoSquaresTransparent},
	{title="Two squares, solid",f=displayTwoSquaresSolid}
}


local function oneOctave()
	for _,vert in ipairs(vertices) do
		local xx,yy,zz=vert.sx/200,vert.sy/200, cur_time/2
		vert.hue = love.math.noise(xx,yy,zz)
	end
end

local function twoOctaves()
	for _,vert in ipairs(vertices) do
		local xx,yy,zz=vert.sx/200,vert.sy/200, cur_time/2
		vert.hue = (love.math.noise(xx,yy,zz) + love.math.noise(xx*2,yy*2,zz*2)/2)/1.5
	end
end

local function threeOctaves()
	for _,vert in ipairs(vertices) do
		local xx,yy,zz=vert.sx/200,vert.sy/200, cur_time/2
		vert.hue = (love.math.noise(xx,yy,zz) + love.math.noise(xx*2,yy*2,zz*2)/2 + love.math.noise(xx*4,yy*4,zz*4)/4)/1.75
	end
end

local function fourOctaves()
	for _,vert in ipairs(vertices) do
		local xx,yy,zz=vert.sx/200,vert.sy/200, cur_time/2
		vert.hue = (love.math.noise(xx,yy,zz) + love.math.noise(xx*2,yy*2,zz*2)/2 + love.math.noise(xx*4,yy*4,zz*4)/4+ love.math.noise(xx*8,yy*8,zz*8)/8)/1.875
	end
end

local nbOctaves=1
local octaves = {oneOctave,twoOctaves,threeOctaves,fourOctaves}
	
local function setNbColors(nb)
	color.nbColors=nb
	color.genColors()
end

local function setDisplayMode(idx)
	idMode=idx
end

local function initTaskBar(f)
	taskBar.font   = f
	taskBar.height =  f:getHeight() + 15
	taskBar.bg = {0,0,196,196}
	taskBar.fg = {255,255,255,255}
	taskBar.fgi = {0,0,255,255}
	
	taskBar.triggerY = 5
	taskBar.visible=false
	taskBar.Y = 0
	taskBar.Yspeed = 100
	taskBar.Ytarget=taskBar.height
	taskBar.dY=0
	
	taskBar.text1="# OCTAVES : "
	taskBar.xtext1=20
	taskBar.ytext1=math.floor(taskBar.height/2 - f:getHeight()/2)
	
	taskBar.boxH=f:getHeight()+6
	taskBar.boxW=f:getWidth("M")+6
	taskBar.boxY=math.floor(taskBar.height/2 - taskBar.boxH/2)
	local boxX=f:getWidth(taskBar.text1) + taskBar.xtext1
	taskBar.boxX={}
	taskBar.boxX[1]=boxX
	for i=2,#octaves do
		taskBar.boxX[i]=taskBar.boxX[i-1]+taskBar.boxW+5
	end

	taskBar.text2="DISPLAY MODE : "
	taskBar.xtext2=taskBar.boxX[#taskBar.boxX]+taskBar.boxW+10
	taskBar.ytext2=math.floor(taskBar.height/2 - f:getHeight()/2)
	
	local maxW=0
	for _,dm in ipairs(displayModes) do
		local w=f:getWidth(dm.title)
		if w > maxW then maxW = w end
	end
		
	taskBar.choiceH = f:getHeight()+6
	taskBar.choiceW = maxW +6
	taskBar.choiceX = taskBar.xtext2 + f:getWidth(taskBar.text2)
	taskBar.choiceY = math.floor(taskBar.height/2 - taskBar.choiceH/2)
	
	taskBar.lockText = "LOCK"
	taskBar.lockW = f:getWidth(taskBar.lockText)+6
	taskBar.lockH = f:getHeight()+6
	taskBar.lockX = stage.w-taskBar.lockW - 5
	taskBar.lockY = math.floor(taskBar.height/2 - taskBar.lockH/2)

	taskBar.colbX = taskBar.choiceX + taskBar.choiceW + 10
	taskBar.colbY = math.floor(taskBar.height/2 - color.colorBtnImage:getHeight()/2)
	
	taskBar.nbColX = taskBar.colbX + 10 + color.colorBtnImage:getWidth()
	taskBar.nbColH = f:getHeight()+6
	taskBar.nbColW = f:getWidth("MM")+6
	taskBar.nbColY = math.floor(taskBar.height/2 - taskBar.nbColH/2)

	-- menu definition
	taskBar.colorMenu = newMenu(f,{
		{title="2 colors",f=setNbColors,value=2},
		{title="3 colors",f=setNbColors,value=3},
		{title="4 colors",f=setNbColors,value=4},
		{title="5 colors",f=setNbColors,value=5},
		{title="6 colors",f=setNbColors,value=6},
		{title="7 colors",f=setNbColors,value=7},
		{title="8 colors",f=setNbColors,value=8},
		{title="9 colors",f=setNbColors,value=9},
		{title="10 colors",f=setNbColors,value=10},
	})
	
	local itdmodes={}
	for i,dm in ipairs(displayModes) do
		table.insert(itdmodes,{title=dm.title,f=setDisplayMode,value=i})
	end
	taskBar.displayModeMenu=newMenu(f,itdmodes)
	
	taskBar.colorActionMenu = newMenu(f, {
		{title="Reverse colors",f=color.reverseColors},
		{title="Permute colors",f=color.permuteColors},
		{title="Sort by luminence",f=color.sortColors},
		{title="Convert to grey",f=color.greyColors},
		{title="Greyscale",f=color.greyscale},
		{title="Chromatic",f=color.chromatic},
	})
	
end


function taskBar:draw()
	if self.visible then
		lg.setColor(self.bg)
		lg.rectangle('fill',0,self.Y-self.height,stage.w,self.height)
		lg.setFont(self.font)
		lg.setColor(self.fg)
		lg.print(self.text1,self.xtext1,self.ytext1+self.Y-self.height)
		for i=1,#self.boxX do
			lg.setColor(self.fg)
			lg.rectangle((nbOctaves==i and 'fill') or 'line',self.boxX[i],self.boxY+self.Y-self.height,self.boxW,self.boxH)			
			if (nbOctaves==i) then lg.setColor(self.fgi) end
			lg.printf(i,self.boxX[i]+3,self.boxY+self.Y-self.height+3,self.boxW-6,'center')
		end
		lg.setColor(self.fg)
		lg.print(self.text2,self.xtext2,self.ytext2+self.Y-self.height)
		lg.rectangle('line',self.choiceX,self.choiceY+self.Y-self.height,self.choiceW,self.choiceH)
		lg.printf(displayModes[idMode].title,self.choiceX+3,self.choiceY+3+self.Y-self.height,self.choiceW-6,'left')

		lg.rectangle('line',self.nbColX,self.nbColY+self.Y-self.height,self.nbColW,self.nbColH)
		lg.printf(color.nbColors,self.nbColX+3,self.nbColY+3+self.Y-self.height,self.nbColW-6,'center')
		
		lg.rectangle((self.locked and 'fill')or 'line',self.lockX,self.lockY+self.Y-self.height,self.lockW,self.lockH)
		if self.locked then
			lg.setColor(self.fgi)
		end
		lg.printf(self.lockText,self.lockX+3,self.lockY+3+self.Y-self.height,self.lockW-6,'center')
		
		lg.setColor(255,255,255,255)
		lg.draw(color.colorBtnImage,self.colbX,self.colbY+self.Y-self.height)
		
		
	end
end

function taskBar:update(dt)
	if self.locked or (activeMenu and activeMenu==self.currentMenu)then
		return
	end
	if not self.visible and lm.getY() <= self.triggerY then 
		self.visible = true
		self.dY=self.Yspeed
		self.Y=self.triggerY+1
	elseif self.visible then
		if lm.getY()>self.Y then
			self.dY=-self.Yspeed
		elseif self.dY ~= 0 then
			self.dY = self.Yspeed
		end
		if dY ~= 0 then
			self.Y = self.Y + dt * self.dY
			if self.Y >= self.Ytarget then
				self.Y = self.Ytarget
				self.dY=0
			elseif self.Y<0 then
				self.dY=0
				self.visible=false
				self.Y = 0
			end
		end
	end
end

function taskBar:lclick(x,y)
	if x>=self.choiceX and x <= self.choiceX+self.choiceW then
		nextDisplayMode()
	end
	if x>=self.lockX and x<=self.lockX+self.lockW then
		self.locked = not self.locked
	end
	if x>=self.colbX and x <= self.colbX+color.colorBtnImage:getWidth() then
		color.genColors()
	end
	if x>=self.nbColX and x<=self.nbColX+self.nbColW then
		color.nbColors = color.nbColors+1
		if color.nbColors>10 then color.nbColors=2 end
		color.genColors()
	end
	local ux = x-self.boxW
	if x>=self.boxX[1] and ux<=self.boxX[#self.boxX] then
		for i=1,#self.boxX do
			if x>=self.boxX[i] and ux <= self.boxX[i] then
				nbOctaves=i
				break
			end
		end
	end
end

function taskBar:rclick(x,y)
	local ymenu=self.Y+1
	local xmenu=x
	local menu=nil
	if x>=self.choiceX and x <= self.choiceX+self.choiceW then
		xmenu=self.choiceX
		menu=self.displayModeMenu
		menu:select(idMode)
	end
	if x>=self.colbX and x <= self.colbX+color.colorBtnImage:getWidth() then
		xmenu=self.colbX
		menu=self.colorActionMenu
	end
	if x>=self.nbColX and x<=self.nbColX+self.nbColW then
		menu = self.colorMenu
		xmenu=self.nbColX
		menu:select(color.nbColors-1)
	end
	if menu then
		activeMenu = menu
		menu:open(xmenu,ymenu)
		self.currentMenu=menu
	end
end


local function generateDots()
	local points=gen2d(stage.w-20,stage.h-20,10)
	vertices = {}
	for _,p in ipairs(points) do
		table.insert(vertices,{hue=0,sx=math.floor(p.x)+10,sy=math.floor(p.y)+10})
	end
end

local function generateDotsInGrid()
	vertices={}
	local perLine,nbLines = math.floor(stage.w/10),math.floor(stage.h/10)
	for iy=1,nbLines do
		local y = iy*10
		for ix=1,perLine do
			local x = ix*10
			table.insert(vertices,{hue=0,sx=x,sy=y})
		end
	end
end

function love.load()
	math.randomseed(os.time())
	color.genColors()
	stage = {w=lg.getWidth(), h=lg.getHeight()}
	initTaskBar(lg.newFont(18))
	local menuFont = lg.newFont(18)
	bgMenu = newMenu(menuFont,{
		{title="Random dots",f=generateDots},
		{title="Dots in grid",f=generateDotsInGrid},
	})
	spacing = 10
	generateDots()

	cur_time = 0
end

function nextDisplayMode()
	idMode = idMode+1
	if idMode > #displayModes then
		idMode=1
	end
end

function love.keypressed(key)
	if key == "tab" then
		nextDisplayMode()
	end
end

function love.mousepressed( x, y, button ) 
	if activeMenu and activeMenu:hit(x,y) then
		if button=="l" then activeMenu:lclick(x,y) end
		activeMenu=nil
		return
	elseif activeMenu then
		activeMenu=nil
	end
	if taskBar.visible and y < taskBar.Y then
		if button=="l" then taskBar:lclick(x,y) else taskBar:rclick(x,y) end
	elseif button=="r" then
		activeMenu=bgMenu
		activeMenu:open(x,y)
	end
end

function love.update(dt)
	cur_time = cur_time + dt
	octaves[nbOctaves]()
	taskBar:update(dt)
end


function love.draw()
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 0, 0, stage.w, stage.h)
	love.graphics.setColor(255, 255, 255)
	displayModes[idMode].f()
	taskBar:draw()
	if activeMenu then activeMenu:draw() end
end
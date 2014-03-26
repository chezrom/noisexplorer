local methods={}
local lg=love.graphics

function methods:draw()
	lg.setColor(self.bg)
	lg.rectangle('fill',self.x,self.y,self.width,self.height)
	lg.setColor(self.fg)
	lg.setFont(self.font)
	lg.rectangle('line',self.x,self.y,self.width,self.height)
	for i,it in ipairs(self.items) do
		if i==self.selected then
			lg.rectangle('fill',self.x,self.y+(i-1)*self.itemHeight+4,self.width,self.itemHeight)
			lg.setColor(self.fgi)
		end
		local text = it.title
		if text == "-" then
			
		else
			lg.print(text,self.x+4,self.y+(i-1)*self.itemHeight+6)
		end
		if i==self.selected then
			lg.setColor(self.fg)
		end
	end
end

function methods:update(dt)

end

function methods:lclick(x,y)
	local idItem = math.floor((y-self.y-4)/self.itemHeight) + 1
	if idItem <1 then idItem=1 end
	if idItem >#self.items then idItem=#self.items end
	local it=self.items[idItem]
	if it.f then it.f(it.value) end
end

function methods:select(id)
	self.selected=id
end
function methods:open(x,y)
	self.x=x
	self.y=y
end

function methods:hit(x,y)
	return x>=self.x and y>=self.y and x<=self.x+self.width and y<=self.y+self.height
end

local function newMenu(f,items) 
	local m=setmetatable({font=f,items=items,selected=0},{__index=methods})
	m.itemHeight = f:getHeight() +4 
	m.height =  m.itemHeight * #items+ 8
	m.bg = {0,0,196,196}
	m.fg = {255,255,255,255}
	m.fgi = {0,0,255,255}
	local maxw=0
	for _,it in ipairs(items) do
		local w = f:getWidth(it.title)
		if w>maxw then maxw=w end
	end
	m.width=maxw+8
	return m
end

return newMenu
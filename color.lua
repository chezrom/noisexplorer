local gen3d = require 'poisson3d'

local lg=love.graphics
local floor=math.floor

local fcolor={}
local colors={}

fcolor.colorBtnImage={}
fcolor.nbColors=6

local function genColorBtnImage()
	-- generate the 'color button'
	local id = love.image.newImageData(150,20)
	for x=0,149 do
		for y=0,19 do
			id:setPixel(x,y,fcolor.COL(x/150,255))
		end
	end
	fcolor.colorBtnImage = lg.newImage(id)
end

function fcolor.genColors()
	local colDist=1.0
	local points = {}
	colDist = colDist + 0.05
	while #points < fcolor.nbColors do
		colDist = colDist - 0.05
		points=gen3d(1,1,1,colDist)
	end
	colors = {}
	for i=1,fcolor.nbColors do
		local point = table.remove(points,math.random(1,#points))
		colors[i] = {floor(point.x*255),floor(point.y*255),floor(point.z*255)}
	end
	genColorBtnImage()

end

function fcolor.reverseColors()
	local ncol={}
	local j=1
	for i=#colors,1,-1 do
		ncol[j]=colors[i]
		j=j+1
	end
	colors=ncol
	genColorBtnImage()
end

function fcolor.permuteColors()
	local ncol={}
	for i=1,fcolor.nbColors do
		ncol[i]=table.remove(colors,math.random(1,#colors))
	end
	colors=ncol
	genColorBtnImage()
end

function fcolor.sortColors()
	table.sort(colors,function (a,b) 
		return 0.21*a[1]+0.72*a[2]+0.07*a[3] < 0.21*b[1]+0.72*b[2]+0.07*b[3] 
	end)
	genColorBtnImage()
end

function fcolor.greyColors()
	local ncol={}
	for i,c in ipairs(colors) do
		local gv = 0.21*c[1]+0.72*c[2]+0.07*c[3]
		ncol[i] = {gv,gv,gv}
	end
	colors=ncol
	genColorBtnImage()
end

function fcolor.chromatic()
	fcolor.nbColors=7
	colors= {
		{255,0,0},
		{255,255,0},
		{0,255,0},
		{0,255,255},
		{0,0,255},
		{255,0,255},
		{255,0,0},
	}
	genColorBtnImage()
end

function fcolor.greyscale()
	fcolor.nbColors=2
	colors = {{0,0,0},{255,255,255}}
	genColorBtnImage()
end

function fcolor.thermal()
	fcolor.nbColors=4
	colors= {
		{0,0,0},
		{255,0,0},
		{255,255,0},
		{255,255,255},
	}
	genColorBtnImage()
end


function fcolor.COL(v,a)
	if v < 0 then v=0 end
	local u=v*(#colors-1)
	local i=floor(u)
	if i==(#colors-1) then i=i-1 end
	local x=u-i
	local y=1-x
	local c1,c2=colors[i+1],colors[i+2]
	if not c1 then print("i="..i.." v="..v.." #cols="..#colors) end
	return c1[1]*y + c2[1] *x,c1[2]*y + c2[2] *x,c1[3]*y + c2[3] *x,a 	
end

return fcolor
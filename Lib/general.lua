function string.explode(str, div)
	assert(type(str) == "string" and type(div) == "string", "invalid arguments")
	local o = {}
	while true do
		local pos1,pos2 = str:find(div)
		if not pos1 then
			o[#o+1] = str
			break
		end
		o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
	end
	return o
end

function math.clamp(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

function math.dist(x1, y1, x2, y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function math.round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end
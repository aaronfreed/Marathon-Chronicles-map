function Triggers.idle()
	if #Players == 1 then
		mediafog()
	end
end

function mediafog()
	for p in Players() do
		if p.polygon.media then
			if p.polygon.media.type == "water" then
				Level.underwater_fog.color.r = 0
				Level.underwater_fog.color.g = .69
				Level.underwater_fog.color.b = .788
			elseif p.polygon.media.type == "lava" then
				Level.underwater_fog.color.r = 0
				Level.underwater_fog.color.g = .7
				Level.underwater_fog.color.b = 0
			elseif p.polygon.media.type == "goo" then
				Level.underwater_fog.color.r = .7
				Level.underwater_fog.color.g = 0
				Level.underwater_fog.color.b = 0
			else
				Level.underwater_fog.color.r = .7
				Level.underwater_fog.color.g = .7
				Level.underwater_fog.color.b = 0
			end
		end
	end
end

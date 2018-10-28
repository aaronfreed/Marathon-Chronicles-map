function Triggers.idle()
	oxygen()
end

function oxygen()
	for p in Players() do
		if p.polygon.media then
			p:damage (1,"oxygen drain")
		end
	end
end


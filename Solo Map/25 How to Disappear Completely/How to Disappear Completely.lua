suff1 = -6
suff2 = -7

function Triggers.idle()
	suffocate()
end

function suffocate()
	for p in Players() do
		if p.z < suff2 and not p.dead then
			p:damage(4,"suffocation")
		elseif p.z < suff1 and not p.dead then
			p:damage(1,"suffocation")
		end
	end
	for m in Monsters() do
		if not m.player and not m.dead then
			if m.z < suff2 then
				m:damage(12,"suffocation")
			elseif m.z < suff1 then
				m:damage(4,"suffocation")
			end
		end
		if m.z < suff2 and not m.player then
		         m.external_velocity = 0
		end
	end
end
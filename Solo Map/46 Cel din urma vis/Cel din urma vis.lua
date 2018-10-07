function Triggers.idle()
	platforms()
end

function platforms()
	total = 0
	for m in Monsters() do
		if m.active = 0 or m.life = 1 then
			total = total + 1
		end
	end
	if total = 0 then
		for p in Platforms() do
			p.active = 1
		end
	end
end

		
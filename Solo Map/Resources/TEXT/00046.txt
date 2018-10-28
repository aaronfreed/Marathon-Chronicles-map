function Triggers.init()
	finished = 0
	for p in Players() do
		p.items["alien weapon"] = 1
	end
end

function Triggers.idle()
	if finished == 0 then
		platforms()
	end
end

function platforms()
	if Level.calculate_completion_state() == "finished" then
		finished = 1
        Tags[1].active = true
	end
end

		
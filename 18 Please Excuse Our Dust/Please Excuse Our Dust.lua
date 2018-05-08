fogtimer = 420
pitch = .5
red = .2
green = .1
blue = 0
depth = 42
darken = true
suff1 = -5.2
suff2 = -6

function Triggers.init()
	Level.fog.active = true
	Level.fog.present = true
	Level.fog.color.r = red
	Level.fog.color.g = green
	Level.fog.color.b = blue
	Level.fog.depth = depth
	Level.fog.affects_landscapes = false
end

function Triggers.idle()
	suffocate()
	darkness()
end

function suffocate()
	for p in Players() do		if p.z < suff2 and not p.dead then
			p:damage(4,"suffocation")
		elseif p.z < suff1 and not p.dead then			p:damage(1,"suffocation")		end
	end	for m in Monsters() do		if m.z < suff2 and not m.player then			m.external_velocity = 0
			if not m.dead then
				m:damage(12,"suffocation")
			end
		elseif m.z < suff1 and not m.dead and not m.player then			m:damage(4,"suffocation")
		end	end
end

function darkness()
	fogtimer = fogtimer - 1

	if darken then
		if red > .1 then
			red = red - 0.0005
			green = green - 0.00025
			depth = depth - 0.05
		else
			darken = false
		end
	elseif red < .2 then
		red = red + 0.0005
		green = green + 0.00025
		depth = depth + 0.05
	else
		darken = true
	end

	if fogtimer == 42 then
		pitch = (200 + Game.random(200)) / 300
		for p in Players() do
			p:play_sound("juggernaut exploding", pitch)
		end
	end

	if fogtimer > 42 then
		Level.fog.color.r = red
		Level.fog.color.g = green
		Level.fog.color.b = blue
		Level.fog.depth = depth
	else
		mult = 1 + (fogtimer * (300 + Game.random(300)) / 6300)
		Level.fog.color.r = red * mult
		Level.fog.color.g = green * mult
		Level.fog.color.b = blue * mult
		Level.fog.depth = depth
	end

	if fogtimer == 0 then
		fogtimer = 420 + Game.random(666)
	end
end

CollectionsUsed = { 22 }

precipitation_type = "rocks"
precipitation_count = 512
precipitation_phase = 1
precipitation_gravity = 1/4
precipitation_wind = 0
fogtimer = 420
thundertimer = 0 
pitch = .5
fogbrightness = .125
depth = 42
darken = false

scenery_cleared = false

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

function build_pool()
    Level._pool = {}
    
    local count = 0
    for i = 1, precipitation_count do
        local x, y, z, p = uniform.xyz_in_triangle_list(Level._triangles)
        s = Scenery.new(x, y, z, p, precipitation_type)
        if s then
            count = count + 1
            table.insert(Level._pool, s)
        end
    end
    precipitation_count = count
end

function levelfog()
	-- Decrease fog counter
	fogtimer = fogtimer - 1
 
	if thundertimer > 0 then
		-- Decrease thunder counter if greater than 0
		thundertimer = thundertimer - 1
		if thundertimer == 0 then
			-- Play thunder sound ("puzzle switch" slot in Chronicles sounds file)
			pitch = (200 + Game.random(200)) / 300
			for p in Players() do
				p:play_sound("puzzle switch", pitch)
			end
		end
	end
 
	-- Fluctuate fog brightness a bit
	if darken then
		if fogbrightness > .125 then
			fogbrightness = fogbrightness - 0.0005
			depth = depth - 0.05
		else
			darken = false
		end
	elseif fogbrightness < .25 then
		fogbrightness = fogbrightness + 0.0005
		depth = depth + 0.05
	else
		darken = true
	end
 
	Level.fog.depth = depth
 
	if fogtimer > 60 then
		-- Normal fog values
		Level.fog.color.r = 0
		Level.fog.color.g = 0
		Level.fog.color.b = fogbrightness
		Level.underwater_fog.color.r = fogbrightness * 1/3
		Level.underwater_fog.color.g = fogbrightness * 2/3
		Level.underwater_fog.color.b = 0
	else
		-- Fog flicker effect to simulate lightning
		mult = 1 + (fogtimer * (300 + Game.random(300)) / 9000)
		Level.fog.color.r = ((fogbrightness * mult) - fogbrightness) * .7
		Level.fog.color.g = ((fogbrightness * mult) - fogbrightness) * .7
		Level.fog.color.b = fogbrightness * mult
		Level.underwater_fog.color.r = (fogbrightness * mult * 4/5) - (fogbrightness * 7/15)
		Level.underwater_fog.color.g = (fogbrightness * mult * 9/10) - (fogbrightness * 7/30)
		Level.underwater_fog.color.b = ((fogbrightness * mult) - fogbrightness) * .7

		if fogtimer == 60 then
			-- Tag 7 activates/deactivates level lights 24-33 for lightning effect
			Tags[10].active = true
			-- Set interval to thunder sound effect (random from 0 to 2 1/3 seconds)
			thundertimer = Game.random(70)
		elseif fogtimer == 0 then
			-- Set next lightning interval (random from 7 to 21 seconds)
			fogtimer = 210 + Game.random(420)
			-- Deactivate lightning effect
			Tags[10].active = false
		end
	end
end
 
Triggers = {}
 
function Triggers.init(restoring_game)
    local polygon_list = {}
    for p in Polygons() do
        if p.ceiling.transfer_mode == "landscape" then
            table.insert(polygon_list, p)
        end
    end
    Level._triangles = uniform.build_triangle_list(polygon_list)
    if #polygon_list == 0 then
        precipitation_count = 0
    else
        local total_precipitation_area = 0
        for _, t in pairs(Level._triangles) do
            total_precipitation_area = total_precipitation_area + t.area
        end
        precipitation_count = total_precipitation_area * 2
        if precipitation_count > 700 then
            precipitation_count = 700
        end
    end
    
    if restoring then
        Level._pool = {}
        local count = 0
        for s in Scenery() do
            if s.type == precipitation_type then
                count = count + 1
                table.insert(Level._pool, s)
            end
        end
        precipitation_count = count
    else
        build_pool()
    end
end
 
function Triggers.idle()
	if scenery_cleared == true then
		build_pool()
		scenery_cleared = false
	end
	local pool = Level._pool
	local position = pool[1].position
	local phase = precipitation_phase
	local gravity = phase * precipitation_gravity
	local wind = phase * precipitation_wind
	local phase_match = Game.ticks % phase
	for i = 1,precipitation_count do
	   	if i % phase == phase_match then
			local e = pool[i]
			position(e, e.x - wind, e.y - wind, e.z - gravity, e.polygon)
			if e.z < e.polygon.floor.height then
				local x, y, p = uniform.xy_in_triangle_list(Level._triangles)
				e:position(x, y, p.ceiling.height, p)
			elseif e.z > e.polygon.ceiling.height then
				local x, y, p = uniform.xy_in_triangle_list(Level._triangles)
				e:position(x, y, p.floor.height, p)
			end
			if e.polygon.media then
				if e.z < e.polygon.media.height then
					local x, y, p = uniform.xy_in_triangle_list(Level._triangles)
					e:position(x, y, p.ceiling.height, p)
				end
			end
	   	end
	end
 
	levelfog()
end
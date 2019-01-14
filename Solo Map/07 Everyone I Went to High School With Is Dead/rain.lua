CollectionsUsed = { 22  }

precipitation_type = "rocks"
precipitation_count = 512
precipitation_phase = 1
precipitation_gravity = 1/4
precipitation_wind = 0

scenery_cleared = false

function build_pool()
   Level._pool = {}

   for i=1,1024 do
      s = Scenery.new(0, 0, 0, 0, "gun")
      s._fake = true
   end

   for i=1,precipitation_count do
      local x, y, z, p = uniform.xyz_in_triangle_list(Level._triangles)
      table.insert(Level._pool, Scenery.new(x, y, z, p, precipitation_type))
   end

   for s in Scenery() do
      if s._fake then
	 s:delete()
      end
   end
end

Triggers = {}

function Triggers.init(restoring_game)
   for s in Scenery() do
	s:delete()
   end
end

function Triggers.pattern_buffer()
   for s in Scenery() do
	s:delete()
   end
   scenery_cleared = true
end

function Triggers.init()
   local polygon_list = {}
   for p in Polygons() do
      if p.ceiling.transfer_mode == "landscape" then
	 table.insert(polygon_list, p)
      end
   end
   Level._triangles = uniform.build_triangle_list(polygon_list)
   build_pool()
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
      end
   end
end

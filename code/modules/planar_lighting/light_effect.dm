/obj/effect/light

	simulated = 0
	anchored = 1 // It only moves via forceMove(), and this stops conveyors moving the entire light overlay as a blob.
	mouse_opacity = 0
	plane = DARK_PLANE//GAME_PLANE//DARK_PLANE
	luminosity = 1

	layer = 1
	//layer 1 = base plane layer
	//layer 2 = base shadow templates
	//layer 3 = wall lighting overlays
	//layer 4 = light falloff overlay

	appearance_flags = KEEP_TOGETHER
	icon = null
	invisibility = INVISIBILITY_LIGHTING
	pixel_x = -64
	pixel_y = -64
	glide_size = 32
	blend_mode = BLEND_ADD

	alpha = 180

	var/current_power = 1
	var/atom/movable/holder
	var/point_angle
	var/list/affecting_turfs = list()
	var/list/temp_appearance
	var/queued_update = FALSE

/obj/effect/light/New(var/newholder)
	holder = newholder
	if(istype(holder, /atom))
		var/atom/A = holder
		light_range = A.light_range
		light_color = A.light_color
		light_power = A.light_power
		color = light_color
	..(get_turf(holder))

/obj/effect/light/Destroy()
	transform = null
	appearance = null
	overlays = null
	temp_appearance = null

	if(holder)
		if(holder.light_obj == src)
			holder.light_obj = null
		holder = null
	for(var/thing in affecting_turfs)
		var/turf/T = thing
		T.lumcount = -1
		T.affecting_lights -= src
		T.update_luminosity()
	affecting_turfs.Cut()
	. = ..()

/obj/effect/light/atom_init()
	. = ..()
	if(holder)
		follow_holder()

// Applies power value to size (via Scale()) and updates the current rotation (via Turn())
// angle for directional lights. This is only ever called before cast_light() so affected turfs
// are updated elsewhere.
/obj/effect/light/update_transform(var/newrange)
	..()
	if(!isnull(newrange) && current_power != newrange)
		current_power = newrange

// Orients the light to the holder's (or the holder's holder) current dir.
// Also updates rotation for directional lights when appropriate.
/obj/effect/light/proc/follow_holder_dir()
	if(holder.loc.loc && ismob(holder.loc))
		set_dir(holder.loc.dir)
	else
		set_dir(holder.dir)

// Moves the light overlay to the holder's turf and updates bleeding values accordingly.
/obj/effect/light/proc/follow_holder()
	if(holder && holder.loc)
		if(holder.loc.loc && ismob(holder.loc))
			forceMove(holder.loc.loc)
		else
			forceMove(holder.loc)
		follow_holder_dir()
		cast_light()

/obj/effect/light/forceMove(atom/destination)
	if(!destination)
		return FALSE

	if(!isturf(destination))
		loc = null
	else
		loc = destination

	return TRUE

/obj/effect/light/proc/is_directional_light()
	return (holder.light_type == LIGHT_DIRECTIONAL)

/obj/effect/light/set_dir()
	..()
	var/offset = light_range
	if(is_directional_light())
		offset = 2.5
		switch(dir)
			if(NORTHEAST,SOUTHEAST)
				dir = EAST
			if(NORTHWEST,SOUTHWEST)
				dir = WEST
	switch(dir)
		if(NORTH)
			pixel_x = -(world.icon_size * offset) + world.icon_size / 2
			pixel_y = 0
		if(SOUTH)
			pixel_x = -(world.icon_size * offset) + world.icon_size / 2
			pixel_y = -(world.icon_size * offset) - world.icon_size * offset + world.icon_size
		if(EAST)
			pixel_x = 0
			pixel_y = -(world.icon_size * offset) + world.icon_size / 2
		if(WEST)
			pixel_x = -(world.icon_size * offset) - (world.icon_size * offset) + world.icon_size
			pixel_y = -(world.icon_size * offset) + (world.icon_size / 2)

/var/global/list/queued_lights = list()
/proc/update_queued_lights()
	var/static/q_inprogress = FALSE

	if(q_inprogress)
		return
	q_inprogress = TRUE
	while(queued_lights.len)
		var/obj/effect/light/L = queued_lights[queued_lights.len]
		queued_lights.len--
		L.cast_light()
	q_inprogress = FALSE

/obj/effect/light/proc/qupdate()
	if(!queued_update)
		queued_update = TRUE
		queued_lights += src
		addtimer(CALLBACK(GLOBAL_PROC, .proc/update_queued_lights), 1, TIMER_UNIQUE | TIMER_OVERRIDE)

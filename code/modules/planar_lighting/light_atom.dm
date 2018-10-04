/atom
	luminosity = 0

	var/obj/effect/light/light_obj
	var/light_type = LIGHT_SOFT
	var/light_power = 1
	var/light_range = 1
	var/light_color = "#FFFFFF"
	var/light_shadows = TRUE
	var/light_special_on = FALSE // used in certain places like projectiles, saves us from using atom_init with set_light everywhere.

// Used to change hard BYOND opacity; this means a lot of updates are needed.
/atom/proc/set_opacity(var/newopacity)
	opacity = newopacity ? 1 : 0
	var/turf/T = get_turf(src)
	if(istype(T))
		T.blocks_light = -1
		for(var/obj/effect/light/L in range(world.view, T))
			L.cast_light()

/atom/proc/copy_light(var/atom/other)
	light_range = other.light_range
	light_power = other.light_power
	light_color = other.light_color
	set_light()

/atom/proc/update_all_lights()
	spawn()
		if(light_obj && !QDELETED(light_obj))
			light_obj.follow_holder()

/atom/set_dir()
	. = ..()
	update_contained_lights()

/atom/movable/Move()
	var/turf/old_loc = loc
	. = ..()
	update_contained_lights()
	if(opacity && (loc || old_loc))
		var/list/combined_affecting_lights = list()

		if(isturf(old_loc))
			combined_affecting_lights += old_loc.affecting_lights
		old_loc = loc
		if(isturf(old_loc))
			combined_affecting_lights += old_loc.affecting_lights
		if(combined_affecting_lights.len)
			for(var/thing in combined_affecting_lights)
				var/obj/effect/light/L = thing
				L.qupdate()


/atom/movable/forceMove()
	. = ..()
	update_contained_lights()

/atom/proc/update_contained_lights(var/list/specific_contents)
	if(!specific_contents)
		specific_contents = contents
	for(var/thing in (specific_contents + src))
		var/atom/A = thing
		spawn()
			if(A && !QDELETED(A))
				A.update_all_lights()

//Version of view() which ignores darkness, because BYOND doesn't have it.
/proc/dview(range = world.view, center, invis_flags = 0)
	if(!center)
		return

	dview_mob.loc = center

	dview_mob.see_invisible = invis_flags

	. = view(range, dview_mob)
	dview_mob.loc = null

/var/global/mob/dview/dview_mob = new

/mob/dview
	invisibility = 101
	density = 0

	anchored = 1
	simulated = 0

	see_in_dark = 1e6

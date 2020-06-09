#define COB_HINT "Rotate (ALT + LMB)\nCancel (RMB)\nAmount [using_this.get_amount()]"

/client/var/datum/craft_or_build/cob

/datum/craft_or_build
	var/in_building_mode = FALSE
	var/datum/stack_recipe/from_recipe = null
	var/atom/build_this = null
	var/obj/item/stack/using_this = null
	var/turf/over_this = null
	var/busy = FALSE
	var/build_direction = NORTH
	var/image/b_overlay = null
	var/obj/effect/holo_build = null

/datum/craft_or_build/proc/turn_on_build_overlay(client/C, datum/stack_recipe/recipe, using)
	if(!C.cob.in_building_mode)
		from_recipe = recipe
		build_this = recipe.result_type
		using_this = using
		add_build_overlay(C)

/datum/craft_or_build/proc/add_build_overlay(client/C)
	C.show_popup_menus = FALSE
	b_overlay = image(initial(build_this.icon), initial(build_this.icon_state))
	b_overlay.alpha = 185
	b_overlay.dir = build_direction
	b_overlay.maptext = COB_HINT
	b_overlay.maptext_width = 128
	b_overlay.maptext_height = 32
	b_overlay.maptext_y = -32
	b_overlay.maptext_x = -16
	C.images += b_overlay
	C.cob.in_building_mode = TRUE

/datum/craft_or_build/proc/remove_build_overlay(client/C)
	C.cob.in_building_mode = FALSE
	C.show_popup_menus = TRUE
	C.images -= b_overlay
	qdel(b_overlay)
	if(holo_build)
		qdel(holo_build)
		holo_build = null
	b_overlay = null
	from_recipe = null
	build_this = null
	using_this = null
	over_this = null

/datum/craft_or_build/proc/rotate_object()
	switch(build_direction)
		if(NORTH)
			build_direction = WEST
		if(WEST)
			build_direction = SOUTH
		if(SOUTH)
			build_direction = EAST
		if(EAST)
			build_direction = NORTH
	b_overlay.dir = build_direction

/datum/craft_or_build/proc/can_build(mob/M, turf/here, turf/origin)
	. = TRUE
	if(busy || !using_this || !from_recipe)
		return FALSE //return, no need to play red animation.
	else if(using_this.get_amount() < from_recipe.req_amount)
		. = FALSE
		to_chat(M, "<span class='notice'>You haven't got enough [using_this.name] to build \the [from_recipe.title]!</span>")
	else if(from_recipe.one_per_turf && (locate(from_recipe.result_type) in here))
		. = FALSE
		to_chat(M, "<span class='warning'> There is another [from_recipe.title] here!</span>")
	else if(!istype(here, /turf/simulated/floor))
		. = FALSE
		to_chat(M, "<span class='warning'>\The [from_recipe.title] must be constructed on the floor!</span>")
	else if(here.contents.len > 15) //we don't want for() thru tons of atoms.
		. = FALSE
	else if(!(origin.CanPass(null, here, 0, 0) && here.CanPass(null, origin, 0, 0)))
		. = FALSE
	else
		for(var/atom/movable/AM in here)
			if(AM.density)
				. = FALSE
				break
	if(!.)
		b_overlay.color = "red"
		animate(b_overlay, time = 5, color = "white")

/datum/craft_or_build/proc/try_to_build(mob/M)
	if(!can_build(M, over_this, get_turf(M)))
		return

	M.face_atom(over_this)

	var/turf/over_this_saved = over_this
	if(from_recipe.time)
		busy = TRUE
		playsound(M, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
		b_overlay.alpha = 0
		holo_build = new(over_this_saved) //Everyone will see what you trying to build.
		holo_build.anchored = TRUE
		holo_build.unacidable = TRUE
		holo_build.name = "Holo Object"
		holo_build.icon = initial(build_this.icon)
		holo_build.icon_state = initial(build_this.icon_state)
		holo_build.alpha = 160
		holo_build.color = list(-1,0,0,0,-1,0,0,0,-1,1,1,1)
		holo_build.mouse_opacity = FALSE
		to_chat(M, "Building [from_recipe.title] ...")
		var/failed = FALSE
		if(!do_after(M, from_recipe.time, target = M))
			failed = TRUE
		busy = FALSE
		if(!in_building_mode)
			return
		b_overlay.alpha = 185
		qdel(holo_build)
		holo_build = null
		if(failed)
			return

	if(!can_build(M, over_this_saved, get_turf(M)))
		return

	if(over_this_saved && get_dist(M, over_this_saved) <= 1)
		playsound(M, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)//Yes, 2nd time with timed recipe.
		var/atom/A = new from_recipe.result_type(over_this_saved)
		A.dir = build_direction
		using_this.use(from_recipe.req_amount)
		A.add_fingerprint(M)
		b_overlay.maptext = COB_HINT

/turf/MouseEntered(location, control, params)
	if(!usr.client.cob)
		return
	if(usr.client.cob.in_building_mode)
		if(usr.incapacitated() || (usr.get_active_hand() != usr.client.cob.using_this && usr.get_inactive_hand() != usr.client.cob.using_this))
			usr.client.cob.remove_build_overlay(usr.client)
			return
		var/turf/T = src
		if(get_dist(usr, src) > 0)
			var/direction = get_dir(usr, src)
			switch(direction)
				if(NORTHEAST)
					direction = EAST
				if(SOUTHEAST)
					direction = SOUTH
				if(SOUTHWEST)
					direction = WEST
				if(NORTHWEST)
					direction = NORTH

			T = get_step(usr, direction)
			if(!T)
				return

		usr.client.cob.over_this = T
		usr.client.cob.b_overlay.loc = T

#undef COB_HINT

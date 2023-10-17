/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/obj/rune.dmi'
	layer = 2.1
	anchored = TRUE
	var/default_state = TRUE

	beauty = -25

/obj/effect/decal/cleanable/crayon/atom_init(mapload, main = "#ffffff", shade = "#000000", type = "rune", e_name = "rune", override_color = 0)
	. = ..()
	RegisterSignal(src, list(COMSIG_MOVABLE_MOVED), PROC_REF(update_plane))
	if(istype(loc, /atom/movable))
		RegisterSignal(loc, list(COMSIG_MOVABLE_MOVED), PROC_REF(update_plane))
	RegisterSignal(loc, list(COMSIG_PARENT_QDELETING), PROC_REF(destroy_rune))
	update_plane()

	if(!default_state)
		return

	name = e_name
	desc = "It's \a [type]. Somebody's being naughty leaving it here."
	//if(type == "poseur tag")
	//	gang_name() //Generate gang names so they get removed from the pool
	//	type = pick(gang_name_pool)

	icon_state = type

	switch(type)
		if("rune")
			type = "rune[rand(1,6)]"
		if("graffiti")
			type = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa") // (... ,"poseur tag")

	var/icon/mainOverlay = new/icon('icons/effects/crayondecal.dmi',"[type]",2.1)
	var/icon/shadeOverlay = new/icon('icons/effects/crayondecal.dmi',"[type]s",2.1)

	mainOverlay.Blend(main,ICON_ADD)
	shadeOverlay.Blend(shade,ICON_ADD)

	add_overlay(mainOverlay)
	add_overlay(shadeOverlay)

	if(override_color)
		color = main
	add_hiddenprint(usr)

/obj/effect/decal/cleanable/crayon/proc/update_plane()
	if(isfloorturf(loc))
		plane = FLOOR_PLANE
	else
		plane = GAME_PLANE

/obj/effect/decal/cleanable/crayon/proc/destroy_rune()
	qdel(src)

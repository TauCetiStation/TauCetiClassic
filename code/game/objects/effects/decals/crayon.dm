/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/obj/rune.dmi'
	layer = 2.1
	anchored = 1

/obj/effect/decal/cleanable/crayon/atom_init(mapload, main = "#ffffff", shade = "#000000", type = "rune", e_name = "rune", override_color = 0)
	. = ..()
	RegisterSignal(src, list(COMSIG_MOVABLE_MOVED), .proc/update_plane)
	if(istype(loc, /atom/movable))
		RegisterSignal(loc, list(COMSIG_MOVABLE_MOVED), .proc/update_plane)
	RegisterSignal(loc, list(COMSIG_PARENT_QDELETED), .proc/destroy_rune)
	update_plane()

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

/obj/effect/decal/cleanable/crayon/gang
	layer = 3.6 //Harder to hide
	var/gang

/obj/effect/decal/cleanable/crayon/gang/atom_init(mapload, type, e_name = "gang tag")
	var/area/territory = get_area(loc)
	var/color

	if(type == "A")
		gang = type
		color = "#00b7ef"
		icon_state = gang_name("A")
		SSticker.mode.A_territory_new |= list(territory.type = territory.name)
		SSticker.mode.A_territory_lost -= territory.type
	else if(type == "B")
		gang = type
		color = "#da0000"
		icon_state = gang_name("B")
		SSticker.mode.B_territory_new |= list(territory.type = territory.name)
		SSticker.mode.B_territory_lost -= territory.type

	. = ..(mapload, color, color, icon_state, e_name)

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	var/area/territory = get_area(src)

	if(gang == "A")
		SSticker.mode.A_territory_new -= territory.type
		SSticker.mode.A_territory_lost |= list(territory.type = territory.name)
	if(gang == "B")
		SSticker.mode.B_territory_new -= territory.type
		SSticker.mode.B_territory_lost |= list(territory.type = territory.name)

	return ..()

/obj/effect/decal/cleanable/crayon/proc/update_plane()
  if(istype(loc, /turf/simulated/floor))
    plane = FLOOR_PLANE
  else
    plane = GAME_PLANE

/obj/effect/decal/cleanable/crayon/proc/destroy_rune()
  qdel(src)

#define HOLOMAP_WALKABLE_TILE "#66666699"
#define HOLOMAP_CONCRETE_TILE "#FFFFFFDD"

/datum/holomap_interface
	var/mob/activator = null
	var/obj/item/holder = null
	var/list/holomap_images = list()
	var/image/holomap_base
	var/static/image/default_holomap

/datum/holomap_interface/New(obj/item/holder)
	src.holder = holder
	..()

/datum/holomap_interface/Destroy()
	holder = null
	activator = null
	QDEL_LIST(holomap_images)
	return ..()

/datum/holomap_interface/process()
	update_holomap()

/datum/holomap_interface/proc/draw_special()
	return

/datum/holomap_interface/proc/draw_special_icon(filter, obj/holomap_holder)
	var/image/indicator = image('icons/holomap_markers.dmi', (filter))
	indicator.plane = ABOVE_HUD_PLANE
	indicator.layer = ABOVE_HUD_LAYER
	indicator.loc = activator.hud_used.holomap_obj
	var/turf/location = get_turf(holomap_holder)
	if(!(location.z == ZLEVEL_STATION))
		indicator.icon_state = "error"
	if(holomap_holder == holder)
		indicator.icon_state = "you"
	if(indicator.icon_state == "error")
		indicator.pixel_x = (rand(6,9)) * PIXEL_MULTIPLIER
		indicator.pixel_y = (rand(6,9)) * PIXEL_MULTIPLIER
	indicator.pixel_x = (location.x - 6) * PIXEL_MULTIPLIER
	indicator.pixel_y = (location.y - 6) * PIXEL_MULTIPLIER
	holomap_images += indicator

/datum/holomap_interface/proc/activate(mob/user, var/role_filter)
	if(activator)
		return
	activator = user
	if(!default_holomap)
		default_holomap = image(generateHoloMap())
	holomap_base = default_holomap
	holomap_base.layer = HUD_LAYER
	holomap_base.plane = HUD_PLANE
	switch(role_filter)
		if("nuclear")
			holomap_base.color = HOLOMAP_NUCLEAR_COLOR
		if("deathsquad")
			holomap_base.color = HOLOMAP_DEATHSQUAD_COLOR
		if("vox")
			holomap_base.color = HOLOMAP_VOX_COLOR
		if("ert")
			holomap_base.color = HOLOMAP_ERT_COLOR
	activator.hud_used.holomap_obj.overlays += holomap_base
	START_PROCESSING(SSobj, src)

/datum/holomap_interface/proc/deactivate_holomap()
	STOP_PROCESSING(SSobj, src)
	if(!activator)
		return
	activator.hud_used.holomap_obj.overlays -= holomap_base
	if(activator.client)
		activator.client.images -= holomap_images
	for(var/i in holomap_images)
		qdel(i)
	holomap_images.Cut()
	activator = null
	STOP_PROCESSING(SSobj, src)

/datum/holomap_interface/proc/update_holomap()
	if(!activator || !activator.client)
		deactivate_holomap()
		return

	if(length(holomap_images))
		activator.client.images -= holomap_images
		QDEL_LIST(holomap_images)
		holomap_images.Cut()

	draw_special()

	activator.client.images |= holomap_images

/datum/holomap_interface/deathsquad/draw_special()
	for(var/obj/item/clothing/head/helmet/space/deathsquad/D in deathsquad_helmets)
		draw_special_icon_mob("deathsquad", D)

/datum/holomap_interface/nuclear/draw_special()
	for(var/S in nuclear_holo)
		if(istype(S, /mob/living/silicon/robot/syndicate))
			draw_special_icon_mob("syborg", S)
		else if(istype(S, /obj/machinery/computer/syndicate_station))
			draw_shuttle_icon("syndishuttle", S)
		else if(istype(S, /obj/item/clothing/head/helmet/space/rig/syndi))
			draw_special_icon_mob("nuclear", S)

/datum/holomap_interface/proc/draw_shuttle_icon(filter, shuttle_loc)
	var/image/indicator = image('icons/holomap_markers_32x32.dmi', (filter))
	indicator.plane = ABOVE_HUD_PLANE
	indicator.layer = ABOVE_HUD_LAYER
	indicator.loc = activator.hud_used.holomap_obj
	var/turf/location = get_turf(shuttle_loc)
	if(!(location.z == ZLEVEL_STATION))
		return
	indicator.pixel_x = (location.x - 6) * PIXEL_MULTIPLIER
	indicator.pixel_y = (location.y - 6) * PIXEL_MULTIPLIER
	holomap_images += indicator

/datum/holomap_interface/vox/draw_special()
	for(var/obj/item/clothing/head/helmet/space/vox/V in vox_helmets)
		var/filter = null
		if(istype(V, /obj/item/clothing/head/helmet/space/vox/pressure))
			filter = "voxp"
		else if(istype(V, /obj/item/clothing/head/helmet/space/vox/carapace))
			filter = "voxc"
		else if(istype(V, /obj/item/clothing/head/helmet/space/vox/stealth))
			filter = "voxs"
		else if(istype(V, /obj/item/clothing/head/helmet/space/vox/medic))
			filter = "voxm"
		if(prob(25))
			draw_special_icon_mob("chick"+pick("a","b","c"), V)
		else
			draw_special_icon_mob(filter, V)

/datum/holomap_interface/ert/draw_special()
	for(var/obj/item/clothing/head/helmet/space/rig/ert/E in ert_helmets)
		var/filter = null
		if(istype(E, /obj/item/clothing/head/helmet/space/rig/ert/commander))
			filter = "ertc"
		else if(istype(E, /obj/item/clothing/head/helmet/space/rig/ert/security))
			filter = "erts"
		else if(istype(E, /obj/item/clothing/head/helmet/space/rig/ert/engineer))
			filter = "erte"
		else if(istype(E, /obj/item/clothing/head/helmet/space/rig/ert/medical))
			filter = "ertm"
		draw_special_icon_mob(filter, E)

/datum/holomap_interface/proc/draw_special_icon_mob(filter, obj/holomap_holder)
	if(!ishuman(holomap_holder.loc))
		return
	var/mob_indicator = null
	var/mob/living/carbon/human/H = holomap_holder.loc
	if(H.head == holomap_holder)
		if(H.stat == DEAD)
			mob_indicator = (filter+"_3")
		else if(H.stat == UNCONSCIOUS || H.restrained())
			mob_indicator = (filter+"_2")
		else
			mob_indicator = (filter+"_1")
	draw_special_icon(mob_indicator, holomap_holder)

/datum/holomap_interface/proc/draw_special_icon_robot(filter, obj/holomap_holder)
	if(!isrobot(holomap_holder))
		return
	var/robot_indicator = null
	var/mob/living/silicon/robot/M = holomap_holder
	if(M.health > 0)
		robot_indicator = (filter+"_1")
	if(M.health <= 0)
		robot_indicator = (filter+"_0")
	draw_special_icon(robot_indicator, holomap_holder)

/datum/holomap_interface/proc/generateHoloMap()
	var/icon/holomap = icon('icons/canvas.dmi', "blank")
	for(var/i = 1 to ((2 * world.view + 1) * 32))
		for(var/r = 1 to ((2 * world.view + 1) * 32))
			var/turf/tile = locate(i, r, 1)
			if(tile)
				if (istype(tile, /turf/simulated/floor) || istype(tile, /turf/unsimulated/floor) || istype(tile, /turf/simulated/shuttle/floor))
					holomap.DrawBox(HOLOMAP_WALKABLE_TILE, i, r)
				if(istype(tile, /turf/simulated/wall) || istype(tile, /turf/unsimulated/wall) || locate(/obj/structure/grille) in tile || locate(/obj/structure/window) in tile)
					holomap.DrawBox(HOLOMAP_CONCRETE_TILE, i, r)
	return holomap


#undef HOLOMAP_WALKABLE_TILE
#undef HOLOMAP_CONCRETE_TILE
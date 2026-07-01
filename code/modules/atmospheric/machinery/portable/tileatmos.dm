/obj/machinery/portable_atmospherics/tile_atmos
	icon = 'icons/obj/tile_atmos.dmi'

	density = TRUE
	plane = GAME_PLANE
	layer = BELOW_CONTAINERS_LAYER

	anchored = TRUE
	state_open = FALSE

	pixel_x = -8
	pixel_y = -8

	interact_offline = TRUE

	can_block_air = TRUE

	volume = 1000

	max_integrity = 100
	armor = list(MELEE = 20, BULLET = 0, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 0, FIRE = 100, ACID = 0)

	var/on = FALSE

	var/icon_state_base
	var/mutable_appearance/door

/obj/machinery/portable_atmospherics/tile_atmos/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if(!config.ghost_interaction && isobserver(usr))
		return
	if(ismouse(usr))
		return
	if(!usr || !isturf(usr.loc))
		return
	if(usr.incapacitated())
		return

	if(anchored)
		return

	set_dir(turn(dir, 90))

/obj/machinery/portable_atmospherics/tile_atmos/atom_init(mapload)
	. = ..()

	if(!mapload)
		anchored = FALSE
		state_open = FALSE

	update_nearby_tiles()

/obj/machinery/portable_atmospherics/tile_atmos/Destroy()
	state_open = TRUE
	update_nearby_tiles()
	..()

/obj/machinery/portable_atmospherics/tile_atmos/update_icon(fire_inside = FALSE)
	cut_overlay(door)
	icon_state = "[icon_state_base]_[state_open ? "open" : "closed"]"

	if(!state_open)
		door = mutable_appearance(icon, "[icon_state_base]_door")
		door.plane = fire_inside ? ABOVE_LIGHTING_PLANE : GAME_PLANE
		door.layer = INFRONT_MOB_LAYER
		add_overlay(door)

/obj/machinery/portable_atmospherics/tile_atmos/c_airblock(turf/other)
	if(other == loc)
		return NONE

	if(!anchored)
		return NONE

	if(state_open && (get_dir(loc, other) == dir))
		return NONE

	return AIR_BLOCKED

/obj/machinery/portable_atmospherics/tile_atmos/CanPass(atom/movable/mover, turf/target, height=0)
	if(get_dir(loc, target) == dir)
		return state_open

	return FALSE

/obj/machinery/portable_atmospherics/tile_atmos/CanAStarPass(ID, to_dir, origin)
	if(dir == to_dir)
		return state_open

	return FALSE

/obj/machinery/portable_atmospherics/tile_atmos/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(get_dir(loc, target) == dir)
		return state_open

	return FALSE

/obj/machinery/portable_atmospherics/tile_atmos/proc/open_door()
	state_open = TRUE
	update_icon()
	update_nearby_tiles()

/obj/machinery/portable_atmospherics/tile_atmos/proc/close_door()
	state_open = FALSE
	update_icon()
	update_nearby_tiles()

/obj/machinery/portable_atmospherics/tile_atmos/oven
	name = "Gas Oven"
	cases = list("газовая печь", "газовой печи", "газовой печи", "газовую печь", "газовой печью", "газовой печи")
	desc = "Печёт газом."

	icon_state = "oven_gas_open"
	icon_state_base = "oven_gas"

	var/inject_moles_per_second = 0.1

/obj/machinery/portable_atmospherics/tile_atmos/oven/atom_init()
	. = ..()

	AddComponent(/datum/component/clickplace)

/obj/machinery/portable_atmospherics/tile_atmos/oven/proc/ignite()
	if(anchored && isturf(loc))
		var/turf/T = loc
		use_power(50)
		T.hotspot_expose(1000, 500)

/obj/machinery/portable_atmospherics/tile_atmos/oven/process_atmos(seconds)
	if((stat & (NOPOWER|BROKEN)))
		return

	if(!on)
		return

	var/datum/gas_mixture/environment = loc.return_air()

	if(environment && air_contents.temperature > 0)
		var/has_fire = locate(/obj/fire) in loc
		if(!has_fire)
			pump_gas_passive(src, air_contents, environment, inject_moles_per_second * seconds)
			ignite()
		update_icon(has_fire)
		update_connected_network()

/obj/machinery/portable_atmospherics/tile_atmos/oven/ui_interact(mob/user, require_near = TRUE)
	if(!Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		return

	var/static/icon/radial_icons = 'icons/hud/radial.dmi'
	var/list/options = list()

	if(on)
		var/static/radial_off = image(icon = radial_icons, icon_state = "radial_off")
		options["Выкл."] = radial_off
	else
		var/static/radial_on = image(icon = radial_icons, icon_state = "radial_on")
		options["Вкл."] = radial_on

	if(state_open)
		var/static/radial_close = image(icon = radial_icons, icon_state = "radial_close")
		options["Закрыть"] = radial_close
	else
		var/static/radial_open = image(icon = radial_icons, icon_state = "radial_open")
		options["Открыть"] = radial_open

	var/choice = show_radial_menu(user, src, options, require_near = require_near, tooltips = TRUE)

	switch(choice)
		if("Открыть")
			open_door()
		if("Закрыть")
			close_door()
		if("Вкл.")
			on = TRUE
		if("Выкл.")
			on = FALSE

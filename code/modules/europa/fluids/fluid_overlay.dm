/obj/effect/fluid
	name = ""
	icon = 'icons/effects/liquids.dmi'
	anchored = 1
	simulated = 0
	opacity = 0
	mouse_opacity = 0
	layer = FLY_LAYER
	alpha = 0
	color = "#66d1ff"

	var/temperature = T20C
	var/fluid_amount = 0     // Declared in stubs/fluid.dm
	var/fluid_type = "water" // Declared in stubs/fluid.dm
	var/turf/start_loc

/obj/effect/fluid/ex_act()
	return

/obj/effect/fluid/proc/lose_fluid(amt = 0, fluidtype)
	if(amt)
		fluid_amount = max(-1, fluid_amount - amt)
		if(SSfluids)
			SSfluids.add_active_fluid(src)

/obj/effect/fluid/proc/add_fluid(amt = -1, fluidtype)
	if(SSfluids)
		SSfluids.add_active_fluid(src)

/obj/effect/fluid/proc/set_depth(amt = -1)
	fluid_amount = min(FLUID_MAX_DEPTH, amt)
	if(SSfluids)
		SSfluids.add_active_fluid(src)

/obj/effect/fluid/atom_init()
	. = ..()
	create_reagents(FLUID_MAX_DEPTH)
	start_loc = get_turf(src)
	if(!istype(start_loc))
		qdel(src)
		return
	forceMove(start_loc)
	update_icon()

/obj/effect/fluid/Destroy()
	start_loc = null
	if(islist(equalizing_fluids))
		equalizing_fluids.Cut()
	if(SSfluids)
		SSfluids.remove_active_fluid(src)
	return ..()

/obj/effect/fluid/mapped
	alpha = 125
	color = "#66d1ff"
	icon_state = "shallow_still"

/obj/effect/fluid/mapped/atom_init()
	. = ..()
	alpha = 0
	color = null
	icon_state = null

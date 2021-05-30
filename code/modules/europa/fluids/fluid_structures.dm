// Cheap, shitty, hacky means of draining water without a proper pipe system.
// TODO: water pipes.
var/list/gurgles = list(
	'sound/effects/gurgle1.ogg',
	'sound/effects/gurgle2.ogg',
	'sound/effects/gurgle3.ogg',
	'sound/effects/gurgle4.ogg'
	)

/obj/structure/drain
	name = "gutter"
	desc = "You probably can't get sucked down the plughole."
	icon = 'icons/obj/structures/drain.dmi'
	icon_state = "drain"
	anchored = 1
	density = 0
	layer = TURF_LAYER+0.1
	var/drainage = 0.5
	var/last_gurgle = 0
	var/welded

/obj/structure/drain/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/drain/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/drain/attackby(obj/item/thing, mob/user)
	if(iswelder(thing))
		var/obj/item/weapon/weldingtool/WT = thing
		if(WT.isOn())
			welded = !welded
			to_chat(user, "<span class='notice'>You weld \the [src] [welded ? "closed" : "open"].</span>")
		else
			to_chat(user, "<span class='warning'>Turn the torch on, first.</span>")
		update_icon()
		return
	return ..()

/obj/structure/drain/update_icon()
	icon_state = "[initial(icon_state)][welded ? "-welded" : ""]"

/obj/structure/drain/process()
	if(welded)
		return
	var/turf/T = get_turf(src)
	if(!istype(T))
		return
	var/fluid_here = T.get_fluid_depth()
	if(fluid_here <= 0)
		return

	T.remove_fluid(CEIL(fluid_here*drainage))
	if(world.time > last_gurgle + 80)
		last_gurgle = world.time
		playsound(T, pick(gurgles), VOL_EFFECTS_MASTER)

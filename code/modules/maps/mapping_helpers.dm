/obj/effect/mapping_helpers
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	var/late = FALSE

/obj/effect/mapping_helpers/atom_init()
	..()
	return late ? INITIALIZE_HINT_LATELOAD : INITIALIZE_HINT_QDEL

//airlock helpers
/obj/effect/mapping_helpers/airlock
	layer = DOOR_HELPER_LAYER

/obj/effect/mapping_helpers/airlock/atom_init(mapload)
	. = ..()
	if(!mapload)
		log_debug("[src] spawned outside of mapload!")
		return
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(!airlock)
		log_debug("[src] failed to find an airlock at [src.loc]")
	else
		payload(airlock)

/obj/effect/mapping_helpers/airlock/proc/payload(obj/machinery/door/airlock/payload)
	return

/obj/effect/mapping_helpers/airlock/bolted
	name = "airlock bolts helper"
	icon_state = "bolts"

/obj/effect/mapping_helpers/airlock/bolted/payload(obj/machinery/door/airlock/airlock)
	if(airlock.locked)
		log_debug("[src] at [src.loc] tried to bolt [airlock] but it's already locked!")
	else
		airlock.locked = TRUE

/obj/effect/mapping_helpers/airlock/unrestricted
	name = "airlock unresctricted side helper"
	icon_state = "unrestricted"

/obj/effect/mapping_helpers/airlock/unrestricted/payload(obj/machinery/door/airlock/airlock)
	airlock.unres_sides ^= dir

/obj/effect/mapping_helpers/airlock/abandoned
	name = "airlock abandoned helper"
	icon_state = "abandoned"

/obj/effect/mapping_helpers/airlock/abandoned/payload(obj/machinery/door/airlock/airlock)
	if(airlock.abandoned)
		log_debug("[src] at [src.loc] tried to make [airlock] abandoned but it's already abandoned!")
	else
		airlock.abandoned = TRUE

/obj/effect/mapping_helpers/airlock/close_other
	name = "airlock closeOther helper"
	icon_state = "close_other"

/obj/effect/mapping_helpers/airlock/close_other/payload(obj/machinery/door/airlock/airlock)
	if(airlock.closeOther)
		log_debug("[src] at [src.loc] tried to set [airlock] closeOtherDir, but it's already set!")
	else
		airlock.closeOtherDir = dir

/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/datum/wires/rnd/wires = null
	var/obj/machinery/computer/rdconsole/linked_console

/obj/machinery/r_n_d/atom_init()
	. = ..()
	wires = new(src)

/obj/machinery/r_n_d/Destroy()
	QDEL_NULL(wires)
	linked_console = null
	return ..()

/obj/machinery/r_n_d/proc/shock(mob/user, prb) // this should be moved into parent from all places where it is.
	if(!shocked || issilicon(user) || isobserver(user))
		return 0
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/r_n_d/attack_hand(mob/user)
	if(!shock(user, 50) && !disabled)
		return ..()

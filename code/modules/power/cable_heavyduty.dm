/obj/item/stack/cable_coil/heavyduty
	name = "heavy cable coil"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire"

/obj/structure/cable/heavyduty
	icon = 'icons/obj/power_cond_heavy.dmi'
	name = "large power cable"
	desc = "This cable is tough. It cannot be cut with simple hand tools."
	layer = POWER_CABLES_HEAVY

/obj/structure/cable/heavyduty/attackby(obj/item/I, mob/user)

	var/turf/T = src.loc
	if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return

	if(I.get_quality(QUALITY_CUTTING))
		to_chat(user, "<span class='notice'>These cables are too tough to be cut with those [I.name].</span>")
		return
	else if(istype(I, /obj/item/stack/cable_coil))
		to_chat(user, "<span class='notice'>You will need heavier cables to connect to these.</span>")
		return
	else
		..()

/obj/machinery/telescience_jammer
	name = "Telescience Jammer"
	desc = "Jammer that interferes with most telescience technologies"

	icon = 'icons/obj/machines/jammer.dmi'
	icon_state = "jammer"

	layer = TURF_LAYER+0.1
	plane = FLOOR_PLANE

	anchored = TRUE

	var/radius = 4
	var/power_per_tile = 10

	var/locked = TRUE

	var/list/teleblocks

/obj/machinery/telescience_jammer/atom_init()

	// lore purpose only
	// no constuction because of balance reasons
	component_parts = list()
	component_parts += new /obj/item/bluespace_crystal/artificial

	..()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/telescience_jammer/atom_init_late()
	update_radius()
	update_affected_zone()
	update_icon()

/obj/machinery/telescience_jammer/proc/update_affected_zone()

	if(teleblocks)
		for(var/datum/component/teleblock/jammer/COMP as anything in teleblocks)
			qdel(COMP)

	if(anchored)
		var/turf/center = get_turf(src)
		for(var/turf/T as anything in RANGE_TURFS(radius, center))
			LAZYADD(teleblocks, T.AddComponent(/datum/component/teleblock/jammer, src))

/obj/machinery/telescience_jammer/proc/update_radius(new_radius)
	if(new_radius)
		radius = new_radius

	idle_power_usage = (radius ** 2) * power_per_tile
	update_power_use()

/obj/machinery/telescience_jammer/is_operational()
	return anchored && ..()

/obj/machinery/telescience_jammer/update_icon()
	if(anchored && !(stat & (NOPOWER | BROKEN | MAINT)))
		icon_state = "jammer_on"
	else
		icon_state = "jammer"

/obj/machinery/telescience_jammer/attackby(obj/item/I, mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>It's too complicated for you.</span>")
		return

	if(istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/card = I
		if(emagged || (access_heads in card.access))
			if(locked)
				locked = FALSE
				stat |= MAINT
				set_power_use(IDLE_POWER_USE)
				to_chat(user, "<span class='notice'>You unlock and turn off [src].</span>")
			else
				locked = TRUE
				stat &= ~MAINT
				set_power_use(NO_POWER_USE)
				to_chat(user, "<span class='notice'>You lock and turn on [src].</span>")

			update_icon()
		else
			to_chat(user, "<span class='warning'>Access Denied.</span>")

		return

	if(!locked)
		if (ispulsing(I))
			var/new_radius = clamp(input(user, "Set new radius in range 1-5", "Radius", radius) as num, 1, 5)

			if(Adjacent(usr))
				update_radius(new_radius)
				update_affected_zone()

			return

		else if(default_unfasten_wrench(user, I))
			update_affected_zone()
			return

/obj/machinery/telescience_jammer/emag_act(mob/user)
	if(emagged)
		return FALSE
	to_chat(user, "<span class='notice'>Looks like you can unlock it with any ID card now.</span>")
	emagged = TRUE

/obj/machinery/telescience_jammer/emp_act(severity)
	if(!is_operational())
		return
	if(prob(80/severity))
		stat |= EMPED
		addtimer(CALLBACK(src, PROC_REF(after_emp)), 10 MINUTES / severity)

/obj/machinery/telescience_jammer/proc/after_emp()
	stat &= ~EMPED

/obj/machinery/telescience_jammer/Destroy()
	for(var/datum/component/teleblock/jammer/COMP as anything in teleblocks)
		qdel(COMP)
	return ..()

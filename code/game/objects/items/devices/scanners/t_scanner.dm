/obj/item/device/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_TINY
	item_state = "electronic"
	m_amt = 150
	origin_tech = "magnets=1;engineering=1"

	var/on = FALSE

/obj/item/device/t_scanner/attack_self(mob/user)

	on = !on
	icon_state = "t-ray[on]"

	if(on)
		START_PROCESSING(SSobj, src)

/obj/item/device/t_scanner/proc/flick_sonar(obj/pipe)
	if(ismob(loc))
		var/mob/M = loc
		var/image/I = new(loc = get_turf(pipe))

		var/mutable_appearance/MA = new(pipe)
		MA.alpha = 128
		MA.dir = pipe.dir

		I.appearance = MA
		if(M.client)
			flick_overlay(I, list(M.client), 8)

/obj/item/device/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan(loc)

/obj/item/device/t_scanner/proc/scan(mob/viewer)
	if(!ismob(viewer) || !viewer.client)
		return

	for(var/turf/T in range(3, viewer))
		if(T.underfloor_accessibility == UNDERFLOOR_VISIBLE) // we can see turf content already
			continue

		for(var/obj/O in T.contents)
			if(HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
				flick_sonar(O)

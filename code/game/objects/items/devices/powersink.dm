// Powersink - used to drain station power

// Drain acceleration, +10 kW per power tick:
#define POWERSINK_RATE 10000
// Max drain acceleration, 10 MW per power tick:
#define POWERSINK_RATE_MAX 10000000
// Drain form APC's cells, ~25 kW per power tick:
#define POWERSINK_APC_DRAIN 50
// Maximum power that can be drained before exploding:
#define POWERSINK_MAX_POWER 4e8


/obj/item/device/powersink
	desc = "A nulling power sink which drains energy from electrical systems."
	name = "power sink"
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = SIZE_NORMAL
	flags = CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	m_amt = 750
	origin_tech = "powerstorage=3;syndicate=5"
	var/drain_rate = 0 // amount of power to drain per tick
	var/power_drained = 0 // has drained this much power
	var/mode = 0 // 0 = off, 1 = clamped (off), 2 = operating
	var/obj/structure/cable/attached // the attached cable

/obj/item/device/powersink/attackby(obj/item/I, mob/user, params)
	if(isscrewing(I))
		if(mode == 0)
			var/turf/T = loc
			if(isturf(T) && T.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE)
				attached = locate() in T
				if(!attached)
					to_chat(user, "No exposed cable here to attach to.")
					return
				else
					anchored = TRUE
					mode = 1
					to_chat(user, "You attach the device to the cable.")
					for(var/mob/M in viewers(user))
						if(M == user) continue
						to_chat(M, "[user] attaches the power sink to the cable.")
					return
			else
				to_chat(user, "Device must be placed over an exposed cable to attach to it.")
				return
		else
			if (mode == 2)
				STOP_PROCESSING(SSobj, src) // Now the power sink actually stops draining the station's power if you unhook it. --NeoFite
			anchored = FALSE
			mode = 0
			to_chat(user, "You detach	the device from the cable.")
			for(var/mob/M in viewers(user))
				if(M == user) continue
				to_chat(M, "[user] detaches the power sink from the cable.")
			set_light(0)
			icon_state = "powersink0"

			return

	else
		return ..()



/obj/item/device/powersink/attack_paw()
	return

/obj/item/device/powersink/attack_ai()
	return

/obj/item/device/powersink/attack_hand(mob/user)
	switch(mode)
		if(0)
			..()

		if(1)
			to_chat(user, "You activate the device!")
			for(var/mob/M in viewers(user))
				if(M == user) continue
				to_chat(M, "[user] activates the power sink!")
			mode = 2
			drain_rate = 0
			icon_state = "powersink1"
			START_PROCESSING(SSobj, src)

		if(2)  //This switch option wasn't originally included. It exists now. --NeoFite
			to_chat(user, "You deactivate the device!")
			for(var/mob/M in viewers(user))
				if(M == user) continue
				to_chat(M, "[user] deactivates the power sink!")
			mode = 1
			set_light(0)
			icon_state = "powersink0"
			STOP_PROCESSING(SSobj, src)

/obj/item/device/powersink/process()
	if(attached)
		var/datum/powernet/PN = attached.get_powernet()
		if(PN)
			set_light(7 + round(10 * power_drained / POWERSINK_MAX_POWER))

			// Found a powernet, so drain up to max power from it:
			drain_rate = min(drain_rate + POWERSINK_RATE, POWERSINK_RATE_MAX)
			var/available = attached.newavail()
			var/drained = min(drain_rate, available)
			attached.add_delayedload(drained)
			power_drained += drained

			// If tried to drain more than available on powernet
			// now look for APCs and drain their cells:
			if(drained >= available)
				for(var/obj/machinery/power/terminal/T in PN.nodes)
					if(istype(T.master, /obj/machinery/power/apc))
						var/obj/machinery/power/apc/A = T.master
						if(A.operating && A.cell)
							power_drained += A.cell.use(POWERSINK_APC_DRAIN) / CELLRATE

		if(power_drained > POWERSINK_MAX_POWER * 0.9)
			playsound(src, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER)
		if(power_drained >= POWERSINK_MAX_POWER)
			STOP_PROCESSING(SSobj, src)
			explosion(src.loc, 3,6,9,12)
			qdel(src)


#undef POWERSINK_MAX_POWER
#undef POWERSINK_APC_DRAIN
#undef POWERSINK_RATE_MAX
#undef POWERSINK_RATE

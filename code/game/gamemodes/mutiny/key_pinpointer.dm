/obj/item/weapon/pinpointer/advpinpointer/auth_key
	name = "\improper Authentication Key Pinpointer"
	desc = "Tracks the positions of the emergency authentication keys."
	var/datum/game_mode/mutiny/mutiny

/obj/item/weapon/pinpointer/advpinpointer/auth_key/New()
	if(ticker.mode && istype(ticker.mode, /datum/game_mode/mutiny))
		mutiny = ticker.mode
	else
		mutiny = null
	..()

/obj/item/weapon/pinpointer/advpinpointer/auth_key/attack_self(mob/user)
	if(!mutiny)
		to_chat(user, "<span class='danger'>[src] buzzes rudely.</span>")
		return
	switch(mode)
		if (0)
			mode = 1
			active = 1
			target = mutiny.captains_key
			START_PROCESSING(SSobj, src)
			to_chat(usr, "<span class='notice'>You calibrate \the [src] to locate the Captain's Authentication Key.</span>")
		if (1)
			mode = 2
			target = mutiny.secondary_key
			to_chat(user, "<span class='notice'>You calibrate \the [src] to locate the Emergency Secondary Authentication Key.</span>")
		else
			mode = 0
			active = 0
			STOP_PROCESSING(SSobj, src)
			icon_state = "pinoff"
			to_chat(user, "<span class='notice'>You switch \the [src] off.</span>")

/obj/item/weapon/pinpointer/advpinpointer/auth_key/examine(mob/user)
	..()
	switch(mode)
		if (1)
			to_chat(user, "Is is calibrated for the Captain's Authentication Key.")
		if (2)
			to_chat(user, "It is calibrated for the Emergency Secondary Authentication Key.")
		else
			to_chat(user, "It is switched off.")

/datum/supply_pack/key_pinpointer
	name = "Authentication Key Pinpointer crate"
	contains = list(/obj/item/weapon/pinpointer/advpinpointer/auth_key)
	cost = 25000
	crate_type = /obj/structure/closet/crate
	crate_name = "Authentication Key Pinpointer crate"
	access = access_heads
	group = "Operations"

/datum/supply_pack/key_pinpointer/New()
	// This crate is only accessible during mutiny rounds
	if (istype(ticker.mode,/datum/game_mode/mutiny))
		..()

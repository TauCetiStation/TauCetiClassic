#define SEARCH_FOR_DISK 0
#define SEARCH_FOR_OBJECT 1
/obj/item/weapon/pinpointer/advpinpointer/auth_key
	name = "Authentication Key Pinpointer"
	desc = "Tracks the positions of the emergency authentication keys."
	var/datum/game_mode/mutiny/mutiny

/obj/item/weapon/pinpointer/advpinpointer/auth_key/atom_init()
	if(SSticker.mode && istype(SSticker.mode, /datum/game_mode/mutiny))
		mutiny = SSticker.mode
	else
		mutiny = null
	. = ..()

/obj/item/weapon/pinpointer/advpinpointer/auth_key/attack_self(mob/user)
	if(!mutiny)
		to_chat(user, "<span class='danger'>[src] buzzes rudely.</span>")
		return
	switch(mode)
		if (SEARCH_FOR_DISK)
			mode = SEARCH_FOR_OBJECT
			active = TRUE
			target = mutiny.captains_key
			START_PROCESSING(SSobj, src)
			to_chat(usr, "<span class='notice'>You calibrate \the [src] to locate the Captain's Authentication Key.</span>")
		if (SEARCH_FOR_OBJECT)
			mode = 2
			target = mutiny.secondary_key
			to_chat(user, "<span class='notice'>You calibrate \the [src] to locate the Emergency Secondary Authentication Key.</span>")
		else
			mode = SEARCH_FOR_DISK
			active = FALSE
			STOP_PROCESSING(SSobj, src)
			icon_state = "pinoff"
			to_chat(user, "<span class='notice'>You switch \the [src] off.</span>")

/obj/item/weapon/pinpointer/advpinpointer/auth_key/examine(mob/user)
	..()
	switch(mode)
		if (SEARCH_FOR_OBJECT)
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
	if (istype(SSticker.mode,/datum/game_mode/mutiny))
		..()

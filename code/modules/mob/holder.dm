// Helper object for picking dionaea (and other creatures) up.
/obj/item/weapon/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	slot_flags = SLOT_FLAGS_HEAD

/obj/item/weapon/holder/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/holder/atom_init_late()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/holder/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/holder/process()
	if(istype(loc,/turf) || !(contents.len))
		for(var/mob/M in contents)
			var/atom/movable/mob_container
			mob_container = M
			mob_container.forceMove(get_turf(src))
			M.reset_view()
		qdel(src)

/obj/item/weapon/holder/pickup(mob/living/user)
	. = ..()
	user.add_status_flags(PASSEMOTES)

/obj/item/weapon/holder/dropped(mob/living/carbon/user)
	..()
	user.remove_passemotes_flag()

/obj/item/weapon/holder/attackby(obj/item/I, mob/user, params)
	for(var/mob/M in contents)
		M.attackby(I, user, params)

// Mob procs and vars for scooping up
/mob/living/var/holder_type

/mob/living/proc/get_scooped(mob/living/carbon/human/grabber)
	if(!istype(grabber))
		return
	if(!holder_type || buckled || anchored)
		return
	var/obj/item/weapon/holder/H = new holder_type(loc)
	forceMove(H)
	H.name = src.name
	H.attack_hand(grabber)

	to_chat(grabber, "You scoop up [src].")
	to_chat(src, "[grabber] scoops you up.")
	LAssailant = grabber

// Mob specific holders.
// todo: need parent holder/mob/* object
/obj/item/weapon/holder/diona
	name = "diona nymph"
	desc = "It's a tiny plant critter."
	icon_state = "nymph"
	origin_tech = "magnets=3;biotech=5"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/diona/podkid
	name = "podkid"
	icon_state = "podkid"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/drone
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"
	origin_tech = "magnets=3;engineering=5"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/syndi_drone
	name = "suspicious drone"
	desc = "It's a small maintenance robot. Why the hell do his eyes glow red?"
	icon_state = "drone_syndi"
	origin_tech = "programming=2;engineering=5;syndicate=5"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/syndi_drone/disguised
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/cat
	name = "cat"
	desc = "It's a cat. Meow."
	icon_state = "cat"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/mouse
	name = "mouse"
	desc = "It's a small rodent."
	icon_state = "mouse_gray"
	w_class = SIZE_MINUSCULE
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/mouse/gray
	icon_state = "mouse_gray"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/mouse/white
	icon_state = "mouse_white"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/mouse/brown
	icon_state = "mouse_brown"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/mouse/nuke
	icon_state = "mouse_nuke"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/lizard
	name = "lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	w_class = SIZE_MINUSCULE
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/monkey
	name = "monkey"
	desc = "It's a monkey. Ook."
	icon_state = "cat"
	icon = 'icons/mob/monkey.dmi'
	icon_state = "monkey1"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/monkey/farwa
	name = "farwa"
	desc = "It's a farwa."
	icon_state = "tajkey1"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/monkey/stok
	name = "stok"
	desc = "It's a stok. stok."
	icon_state = "stokkey1"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/monkey/neaera
	name = "neaera"
	desc = "It's a neaera."
	icon_state = "skrellkey1"
	flags = HEAR_PASS_SAY

/obj/item/weapon/holder/monkey/punpun
	name = "punpun"
	icon_state = "punpun1"
	flags = HEAR_PASS_SAY

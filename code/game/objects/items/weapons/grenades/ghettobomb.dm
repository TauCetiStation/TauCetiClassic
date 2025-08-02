/obj/item/weapon/grenade/cancasing
	name 			 	 = "can explosive"
	desc 				 = "Слабое, самодельное устройство."
	w_class 			 = SIZE_TINY
	icon 				 = 'icons/obj/makeshift.dmi'
	icon_state 			 = "canbomb1"
	item_state_inventory = "canbomb1"
	item_state_world	 = "canbomb1_inworld"
	item_state 			 = "flashbang"
	throw_speed 		 = 4
	throw_range 		 = 20
	flags 				 = CONDUCT
	slot_flags 			 = SLOT_FLAGS_BELT
	active 	 			 = FALSE
	det_time 			 = 50
	activate_sound 		 = 'sound/items/matchstick_light.ogg'
	var/range 			 = 3
	var/list/times

/obj/item/weapon/grenade/cancasing/atom_init()
	. = ..()
	times = list("5" = 10, "-1" = 20, "[rand(30, 80)]" = 50, "[rand(65, 180)]" = 20) // "Premature, Dud, Short Fuse, Long Fuse"=[weighting value]
	det_time = text2num(pickweight(times))
	if(det_time < 0) // checking for 'duds'
		range = 1
		det_time = rand(30, 80)
	else
		range = pick(2,2,2, 3,3,3, 4)

/obj/item/weapon/grenade/cancasing/update_icon()
	. = ..()
	if(active)
		icon_state 			 = "[initial(icon_state)]_activated"
		item_state_inventory = "[initial(item_state_inventory)]_activated"
		item_state_world 	 = "[initial(item_state_world)]_activated"

/obj/item/weapon/grenade/cancasing/attackby(obj/item/I, mob/user, params)
	if(isscrewing(I))
		return

/obj/item/weapon/grenade/cancasing/activate(mob/user)
	if(user)
		msg_admin_attack("[user.name] ([user.ckey]) primed \a [src]", user)
		var/turf/T = get_turf(src)
		if(T)
			log_game("[key_name(usr)] has primed a [name] for detonation at [T.loc] [COORD(T)].")

	active = TRUE
	update_icon()
	playsound(src, activate_sound, VOL_EFFECTS_MASTER)
	addtimer(CALLBACK(src, PROC_REF(prime)), det_time)

/obj/item/weapon/grenade/cancasing/prime() // Blowing that can up
	//update_mob()
	explosion(loc, 0, 0, range)
	qdel(src)

/obj/item/weapon/grenade/cancasing/examine(mob/user)
	..()
	to_chat(user, "Вы не можете сказать, когда она взорвется!")

/obj/item/weapon/grenade/cancasing/rag
	icon_state 			 = "canbomb2"
	item_state_inventory = "canbomb2"
	item_state_world 	 = "canbomb2_inworld"


/obj/item/weapon/grenade/cancasing/rag/attack_self(mob/user)
	return

/obj/item/weapon/grenade/cancasing/rag/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(active)
		return

	var/is_W_lit = FALSE
	if(istype(I, /obj/item/weapon/match))
		var/obj/item/weapon/match/O = I
		if(O.lit)
			is_W_lit = TRUE
	else if(istype(I, /obj/item/weapon/lighter))
		var/obj/item/weapon/lighter/O = I
		if(O.lit)
			is_W_lit = TRUE
	else if(iswelding(I))
		var/obj/item/weapon/weldingtool/O = I
		if(O.isOn())
			is_W_lit = TRUE

	if(!is_W_lit)
		return ..()

	if(!clown_check(user))
		return ..()

	user.visible_message("<span class='warning'>[bicon(src)] [user] Поджигает [CASE(src, ACCUSATIVE_CASE)] при помощи [CASE(I, GENITIVE_CASE)]!</span>", "<span class='warning'>[bicon(src)] Вы поджигаете [CASE(src, ACCUSATIVE_CASE)] при помощи [CASE(I, GENITIVE_CASE)]!</span>")
	activate(user)
	add_fingerprint(user)
	if(iscarbon(user) && istype(user.get_inactive_hand(), src))
		var/mob/living/carbon/C = user
		C.throw_mode_on()

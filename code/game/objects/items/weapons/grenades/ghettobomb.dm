/obj/item/weapon/grenade/cancasing
	name = "can explosive"
	desc = "A weak, improvised incendiary device."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/makeshift.dmi'
	icon_state = "can_grenade_preview"
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	active = 0
	det_time = 50
	activate_sound = 'sound/items/matchstick_light.ogg'
	var/range = 3
	var/list/times

	// Used to visualize can grenade correctly
	var/can_icon
	var/can_icon_state
	var/wire_color

/obj/item/weapon/grenade/cancasing/atom_init()
	. = ..()
	times = list("5" = 10, "-1" = 20, "[rand(30, 80)]" = 50, "[rand(65, 180)]" = 20) // "Premature, Dud, Short Fuse, Long Fuse"=[weighting value]
	det_time = text2num(pickweight(times))
	if(det_time < 0) // checking for 'duds'
		range = 1
		det_time = rand(30, 80)
	else
		range = pick(2,2,2, 3,3,3, 4)

/obj/item/weapon/grenade/cancasing/CheckParts(list/parts_list)
	..()
	for(var/obj/item/I in contents)
		if(istype(I, /obj/item/weapon/reagent_containers/food/drinks/cans))
			can_icon = I.icon
			can_icon_state = I.icon_state
		else if(istype(I, /obj/item/stack/cable_coil))
			wire_color = I.color
	update_icon()

/obj/item/weapon/grenade/cancasing/update_icon()
	if(can_icon && can_icon_state)
		icon = can_icon
		icon_state = can_icon_state

	var/list/overlays_list = list()

	overlays_list += image('icons/obj/makeshift.dmi', "can_grenade_igniter")

	var/mutable_appearance/I = mutable_appearance('icons/obj/makeshift.dmi', "can_grenade_wired")
	if(wire_color)
		I.color = wire_color
	overlays_list += I

	if(active)
		overlays_list += image('icons/obj/makeshift.dmi', "can_grenade_active")

	cut_overlays()
	add_overlay(overlays_list)

/obj/item/weapon/grenade/cancasing/activate(mob/user)
	if(user)
		msg_admin_attack("[user.name] ([user.ckey]) primed \a [src]", user)
		var/turf/T = get_turf(src)
		if(T)
			log_game("[key_name(usr)] has primed a [name] for detonation at [T.loc] [COORD(T)].")

	active = 1
	update_icon()
	playsound(src, activate_sound, VOL_EFFECTS_MASTER)
	addtimer(CALLBACK(src, .proc/prime), det_time)

/obj/item/weapon/grenade/cancasing/prime() // Blowing that can up
	//update_mob()
	explosion(loc, 0, 0, range)
	qdel(src)

/obj/item/weapon/grenade/cancasing/examine(mob/user)
	..()
	to_chat(user, "You can't tell when it will explode!")

/obj/item/weapon/grenade/cancasing/rag
	icon_state = "can_grenade_rag_preview"

/obj/item/weapon/grenade/cancasing/rag/update_icon()
	if(can_icon && can_icon_state)
		icon = can_icon
		icon_state = can_icon_state

	var/list/overlays_list = list()

	var/mutable_appearance/I = mutable_appearance('icons/obj/makeshift.dmi', "can_grenade_rag_wired")
	if(wire_color)
		I.color = wire_color
	overlays_list += I

	overlays_list += image('icons/obj/makeshift.dmi', "can_grenade_rag")

	if(active)
		overlays_list += image('icons/obj/makeshift.dmi', "can_grenade_rag_active")

	cut_overlays()
	add_overlay(overlays_list)

/obj/item/weapon/grenade/cancasing/rag/attack_self(mob/user)
	return

/obj/item/weapon/grenade/cancasing/rag/attackby(obj/item/I, mob/user, params)
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
	else if(iswelder(I))
		var/obj/item/weapon/weldingtool/O = I
		if(O.welding)
			is_W_lit = TRUE

	if(!is_W_lit)
		return ..()

	if(!clown_check(user))
		return ..()

	user.visible_message("<span class='warning'>[bicon(src)] [user] lights up \the [src] with \the [I]!</span>", "<span class='warning'>[bicon(src)] You light \the [name] with \the [I]!</span>")
	activate(user)
	add_fingerprint(user)
	if(iscarbon(user) && istype(user.get_inactive_hand(), src))
		var/mob/living/carbon/C = user
		C.throw_mode_on()

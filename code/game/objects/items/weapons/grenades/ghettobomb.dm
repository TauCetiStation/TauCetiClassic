/obj/item/weapon/grenade/iedcasing
	name = "improvised explosive"
	desc = "A weak, improvised incendiary device."
	w_class = 2.0
	icon = 'icons/obj/makeshift.dmi'
	icon_state = "improvised_grenade"
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	active = 0
	det_time = 50
	var/range = 3
	var/list/times

/obj/item/weapon/grenade/iedcasing/atom_init()
	. = ..()
	overlays += image("improvised_grenade_filled")
	overlays += image("improvised_grenade_wired")
	times = list("5" = 10, "-1" = 20, "[rand(30, 80)]" = 50, "[rand(65, 180)]" = 20) // "Premature, Dud, Short Fuse, Long Fuse"=[weighting value]
	det_time = text2num(pickweight(times))
	if(det_time < 0) // checking for 'duds'
		range = 1
		det_time = rand(30, 80)
	else
		range = pick(2,2,2, 3,3,3, 4, 6)

/obj/item/weapon/grenade/iedcasing/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/reagent_containers/food/drinks/cans/can = locate() in contents
	if(can)
		can.pixel_x = 0 //Reset the sprite's position to make it consistent with the rest of the IED
		can.pixel_y = 0
		underlays += mutable_appearance(can.icon, can.icon_state)

/obj/item/weapon/grenade/iedcasing/attack_self(mob/user)
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='warning'>You light the [name]!</span>")
			active = 1
			overlays -= image("improvised_grenade_filled")
			icon_state = initial(icon_state) + "_active"
			add_fingerprint(user)
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)

			message_admins("[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]).")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			spawn(det_time)
				prime()

/obj/item/weapon/grenade/iedcasing/prime() // Blowing that can up
	//update_mob()
	explosion(loc, 0, 0, range)
	qdel(src)

/obj/item/weapon/grenade/iedcasing/examine(mob/user)
	..()
	to_chat(user, "You can't tell when it will explode!")

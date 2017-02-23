//improvised explosives//

//iedcasing assembly crafting//
/obj/item/weapon/reagent_containers/food/drinks/cans/attackby(obj/item/I, mob/user)
        if(istype(I, /obj/item/device/assembly/igniter))
                var/obj/item/device/assembly/igniter/G = I
                var/obj/item/weapon/grenade/iedcasing/W = new /obj/item/weapon/grenade/iedcasing
                user.remove_from_mob(G)
                user.remove_from_mob(src)
                user.put_in_hands(W)
                to_chat(user, "<span  class='notice'>You stuff the [I] in the [src], emptying the contents beforehand.</span>")
                W.underlays += image(src.icon, icon_state = src.icon_state)
                qdel(I)
                qdel(src)


/obj/item/weapon/grenade/iedcasing
	name = "improvised explosive assembly"
	desc = "An igniter stuffed into an aluminium shell."
	w_class = 2.0
	icon = 'icons/obj/makeshift.dmi'
	icon_state = "improvised_grenade"
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/assembled = 0
	active = 1
	det_time = 50
	var/display_timer = 0



/obj/item/weapon/grenade/iedcasing/afterattack(atom/target, mob/user , flag) //Filling up the can
	if(assembled == 0)
		if(istype(target, /obj/structure/reagent_dispensers/fueltank) && in_range(src, target))
			if(target.reagents.total_volume < 50)
				to_chat(user, "<span  class='notice'>There's not enough fuel left to work with.</span>")
				return
			var/obj/structure/reagent_dispensers/fueltank/F = target
			F.reagents.remove_reagent("fuel", 50, 1)//Deleting 50 fuel from the welding fuel tank,
			assembled = 1
			to_chat(user, "<span  class='notice'>You've filled the makeshift explosive with welding fuel.</span>")
			playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
			desc = "An improvised explosive assembly. Filled to the brim with 'Explosive flavor'."
			overlays += image('icons/obj/makeshift.dmi', icon_state = "improvised_grenade_filled")
			return


/obj/item/weapon/grenade/iedcasing/attackby(obj/item/I, mob/user) //Wiring the can for ignition
	if(istype(I, /obj/item/weapon/cable_coil))
		if(assembled == 1)
			var/obj/item/weapon/cable_coil/C = I
			if(!C.use(1))
				return
			assembled = 2
			to_chat(user, "<span  class='notice'>You wire the igniter to detonate the fuel.</span>")
			desc = "A weak, improvised explosive."
			overlays += image('icons/obj/makeshift.dmi', icon_state = "improvised_grenade_wired")
			name = "improvised explosive"
			active = 0
			det_time = rand(30,80)

/obj/item/weapon/grenade/iedcasing/attack_self(mob/user) //
	if(!active)
		if(clown_check(user))
			to_chat(user, "<span class='warning'>You light the [name]!</span>")
			active = 1
			overlays -= image('icons/obj/makeshift.dmi', icon_state = "improvised_grenade_filled")
			icon_state = initial(icon_state) + "_active"
			assembled = 3
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

/obj/item/weapon/grenade/iedcasing/prime() //Blowing that can up
	//update_mob()
	explosion(src.loc,-1,0,6)
	qdel(src)

/obj/item/weapon/grenade/iedcasing/examine(mob/user)
	..()
	if(src in user && assembled == 3)
		to_chat(user, "You can't tell when it will explode!")

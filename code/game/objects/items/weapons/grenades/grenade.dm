/obj/item/weapon/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	var/active = 0
	var/det_time = 50
	var/activate_sound = 'sound/weapons/armbomb.ogg'

	action_button_name = "Activate Grenade"

/obj/item/weapon/grenade/proc/clown_check(mob/living/user)
	if((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>Huh? How does this thing work?</span>")
		activate(user)
		add_fingerprint(user)
		addtimer(CALLBACK(src, .proc/prime), 5)
		return 0
	return 1

/obj/item/weapon/grenade/examine(mob/user)
	..()
	if(!istype(src, /obj/item/weapon/grenade/cancasing)) // ghetto bomb examine verb: > You can't tell when it will explode!
		to_chat(user, "The timer is set [det_time == 1 ? "for instant detonation" : "to [det_time/10]  seconds"].")

/obj/item/weapon/grenade/attack_self(mob/user)
	if(active)
		return
	if(!clown_check(user))
		return

	to_chat(user, "<span class='warning'>You prime \the [name]![det_time != 1 ? " [det_time/10] seconds!" : ""]</span>")
	activate(user)
	add_fingerprint(user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()

/obj/item/weapon/grenade/proc/activate(mob/user)
	if(active)
		return

	if(user)
		msg_admin_attack("[user.name] ([user.ckey]) primed \a [src]", user)
		var/turf/T = get_turf(src)
		if(T)
			log_game("[key_name(usr)] has primed a [name] for detonation at [T.loc] [COORD(T)].")

	icon_state = initial(icon_state) + "_active"
	active = 1
	playsound(src, activate_sound, VOL_EFFECTS_MASTER, null, null, -3)
	addtimer(CALLBACK(src, .proc/prime), det_time)

/obj/item/weapon/grenade/proc/prime()
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)

/obj/item/weapon/grenade/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		switch(det_time)
			if(1)
				det_time = 1 SECOND
			if(1 SECONDS)
				det_time = 3 SECONDS
			if(3 SECONDS)
				det_time = 5 SECONDS
			if(5 SECONDS)
				det_time = 1
		to_chat(user, "<span class='notice'>You set the [name] for [det_time == 1 ? "instant detonation" : "[det_time * 0.1] second detonation time"].</span>")
		add_fingerprint(user)
		return
	return ..()

/obj/item/weapon/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos."
	name = "syndicate minibomb"
	icon_state = "syndicate"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/grenade/syndieminibomb/prime()
	explosion(src.loc,1,2,4,5)
	qdel(src)

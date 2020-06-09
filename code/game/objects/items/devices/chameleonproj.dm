/obj/item/device/chameleon
	name = "chameleon-projector"
	icon_state = "shield0"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	item_state = "electronic"
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	origin_tech = "syndicate=4;magnets=4"
	var/can_use = TRUE
	var/toggled = FALSE
	var/obj/effect/dummy/chameleon/active_dummy = null
	var/recharge = FALSE
	var/last_used = 0
	var/cooldown = 20

/obj/item/device/chameleon/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/device/chameleon/atom_init_late()
	active_dummy = new
	active_dummy.master = src
	init_disguise()

/obj/item/device/chameleon/Destroy()
	if(active_dummy)
		active_dummy.master = null
		qdel(active_dummy)
		active_dummy = null
	return ..()

/obj/item/device/chameleon/proc/init_disguise()
	var/list/possible_disguise = list(
		/obj/item/weapon/cigbutt,
		/obj/item/trash/chips,
		/obj/item/trash/candy,
		/obj/item/trash/popcorn,
		/obj/item/weapon/caution/cone
		)
	var/random_type = pick(possible_disguise)
	var/obj/O = new random_type(src)
	copy_item(O)
	qdel(O)

/obj/item/device/chameleon/dropped()
	disrupt()

/obj/item/device/chameleon/equipped()
	disrupt()

/obj/item/device/chameleon/attack_self(mob/living/user)
	if(last_used + cooldown < world.time)
		recharge = FALSE
		last_used = world.time

	if(recharge)
		to_chat(user, "<span class='warning'>[src.name] is still recharging. </span>")
	else
		toggle()

/obj/item/device/chameleon/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!active_dummy)
		active_dummy = new
	if(active_dummy.current_type != target.type)
		if(istype(target,/obj/item) && !istype(target, /obj/item/weapon/disk/nuclear))
			playsound(src, 'sound/weapons/flash.ogg', VOL_EFFECTS_MASTER, null, null, -6)
			to_chat(user, "<span class='notice'>\The [target] scanned.</span>")
			copy_item(target)
	else
		to_chat(user, "<span class='notice'>\The [target] already scanned.</span>")

/obj/item/device/chameleon/proc/copy_item(obj/O)
	var/obj/effect/dummy/chameleon/C = active_dummy
	C.name = O.name
	C.desc = O.desc
	C.appearance = O.appearance
	C.dir = O.dir
	C.current_type = O.type
	C.layer = initial(O.layer) // scanning things in your inventory
	C.plane = initial(O.plane)

/obj/item/device/chameleon/proc/toggle()
	if(!can_use || !active_dummy)
		return

	if(toggled)
		deactivate()
	else
		activate(usr)

	play_transform_effect()
	to_chat(usr, "<span class='notice'>You [toggled ? "activate" : "deactivate"] the [src].</span>")

/obj/item/device/chameleon/proc/play_transform_effect()
	playsound(src, 'sound/effects/pop.ogg', VOL_EFFECTS_MASTER, null, null, -6)
	var/obj/effect/overlay/T = new /obj/effect/overlay(get_turf(src))
	T.icon = 'icons/effects/effects.dmi'
	flick("emppulse",T)
	spawn(8)
		qdel(T)

/obj/item/device/chameleon/proc/activate(mob/M)
	var/obj/effect/dummy/chameleon/C = active_dummy
	C.loc = M.loc
	M.forceMove(C)
	toggled = TRUE

/obj/item/device/chameleon/proc/deactivate()
	var/obj/effect/dummy/chameleon/C = active_dummy
	for(var/atom/movable/A in C)
		A.loc = C.loc
		if(ismob(A))
			var/mob/M = A
			M.reset_view(null)
	C.loc = master
	toggled = FALSE
	recharge = TRUE

/obj/item/device/chameleon/proc/disrupt()
	if(toggled)
		for(var/mob/M in active_dummy)
			to_chat(M, "<span class='danger'>Your chameleon-projector deactivates.</span>")
		deactivate()
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start()
		can_use = FALSE
		spawn(50)
			can_use = TRUE


/obj/effect/dummy/chameleon
	name = ""
	desc = ""
	density = FALSE
	anchored = TRUE
	var/can_move = TRUE
	var/current_type = null
	var/obj/item/device/chameleon/master = null

/obj/effect/dummy/chameleon/Destroy()
	if(master)
		master.disrupt()
		master.active_dummy = null
		master = null
	return ..()

/obj/effect/dummy/chameleon/attackby()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_hand()
	master.disrupt()

/obj/effect/dummy/chameleon/ex_act()
	master.disrupt()

/obj/effect/dummy/chameleon/emp_act()
	master.disrupt()

/obj/effect/dummy/chameleon/bullet_act()
	master.disrupt()

/obj/effect/dummy/chameleon/relaymove(mob/user, direction)

	// We can't move when we are in space or inside of an object.
	if(istype(loc, /turf/space) || !isturf(loc))
		return

	if(can_move)
		can_move = FALSE
		switch(user.bodytemperature)
			if(300 to INFINITY)
				spawn(10) can_move = TRUE
			if(295 to 300)
				spawn(13) can_move = TRUE
			if(280 to 295)
				spawn(16) can_move = TRUE
			if(260 to 280)
				spawn(20) can_move = TRUE
			else
				spawn(25) can_move = TRUE
		step(src, direction)
	return

#define ONE_LOG_BURN_TIME 1200

/obj/item/device/flashlight/flare/torch
	name = "torch"
	desc = "A torch fashioned from some rags and a plank."
	w_class = ITEM_SIZE_NORMAL
	icon_state = "torch"
	item_state = "torch"
	light_color = LIGHT_COLOR_FIRE
	on_damage = 10
	slot_flags = null
	action_button_name = null

/obj/item/device/flashlight/flare/torch/attackby(obj/item/I, mob/user, params) // ravioli ravioli here comes stupid copypastoli
	. = ..()
	user.SetNextMove(CLICK_CD_INTERACT)
	if(I.get_current_temperature())
		light(user)

/obj/item/device/flashlight/flare/torch/get_current_temperature()
	if(on)
		return 1500
	else
		return 0

/obj/item/device/flashlight/flare/torch/extinguish()
	turn_off()

/obj/item/device/flashlight/flare/torch/proc/light(mob/user)
	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='notice'>It's out of fuel.</span>")
		return
	if(on)
		return
	playsound(user, 'sound/items/torch.ogg', VOL_EFFECTS_MASTER)
	user.visible_message("<span class='notice'>[user] lits the [src] on.</span>", "<span class='notice'>You had lt on the [src]!</span>")
	src.force = on_damage
	src.damtype = "fire"
	on = !on
	update_brightness(user)
	item_state = icon_state
	if(loc == user)
		user.update_inv_item(src)
	START_PROCESSING(SSobj, src)

/obj/item/device/flashlight/flare/torch/attack_self()
	return

/obj/item/stack/sheet/wood/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/medical/bruise_pack/rags) && use(1))
		new /obj/item/device/flashlight/flare/torch(get_turf(user))
		qdel(I)
		return
	return ..()

/obj/item/stack/medical/bruise_pack/rags
	name = "rags"
	singular_name = "rag"
	desc = "Some rags. May infect your wounds."
	amount = 1
	max_amount = 1
	icon = 'icons/obj/items.dmi'
	icon_state = "gauze"

/obj/item/stack/medical/bruise_pack/rags/atom_init(mapload, new_amount = null, merge = FALSE, old = 0)
	. = ..()
	if(prob(33) || old)
		make_old()

/obj/item/stack/medical/bruise_pack/rags/update_icon()
	return

//////SHITTY BONFIRE PORT///////


/obj/structure/bonfire
	name = "bonfire"
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	icon = 'icons/obj/structures/scrap/bonfire.dmi'
	icon_state = "bonfire"
	light_color = LIGHT_COLOR_FIRE
	density = FALSE
	anchored = TRUE
	buckle_lying = 0
	var/burning = 0
	var/grill = FALSE
	var/fire_stack_strength = 5

/obj/structure/bonfire/dense
	density = TRUE

/obj/structure/bonfire/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	return ..()

/obj/structure/bonfire/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/rods) && !can_buckle && !grill)
		var/obj/item/stack/rods/R = W
		//var/choice = input(user, "What would you like to construct?", "Bonfire") as null|anything in list("Stake","Grill")
		//switch(choice)
			//if("Stake")
		R.use(1)
		can_buckle = TRUE
		buckle_require_restraints = TRUE
		to_chat(user, "<i>You add a rod to \the [src].</i>")
		var/image/stake = image('icons/obj/structures/scrap/bonfire.dmi', "bonfire_rod")
		stake.pixel_y = 16
		stake.layer = 5
		dir = 2
		underlays += stake
			//if("Grill")
			//	R.use(1)
			//	grill = TRUE
			//	to_chat(user, "<i>You add a grill to \the [src].</i>")
			//	add_overlay(image('icons/obj/structures/scrap/bonfire.dmi', "bonfire_grill"))
			//else
			//	return ..()
		return
	if(W.get_current_temperature())
		StartBurning()
		return
/*	if(grill)
		if(user.a_intent != INTENT_HARM && !(W.flags_1 & ABSTRACT_1))
			if(user.temporarilyRemoveItemFromInventory(W))
				W.forceMove(get_turf(src))
				var/list/click_params = params2list(params)
				//Center the icon where the user clicked.
				if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
					return
				//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
				W.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
				W.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
		else */
	return ..()

/obj/structure/bonfire/proc/onDismantle()
	if(can_buckle || grill)
		new /obj/item/stack/rods(loc, 1)


/obj/structure/bonfire/attack_hand(mob/user)
	if(burning)
		to_chat(user, "<span class='warning'>You need to extinguish [src] before removing it!</span>")
		return
	if(!has_buckled_mobs()&& !user.is_busy() && do_after(user, 50, target = src))
		onDismantle()
		qdel(src)
		return
	..()


/obj/structure/bonfire/proc/CheckOxygen()
	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.get_by_flag(XGM_GAS_OXIDIZER) > 1)
		return 1
	return 0

/obj/structure/bonfire/proc/StartBurning()
	if(!burning && CheckOxygen())
		icon_state = "bonfire_on_fire"
		burning = 1
		set_light(6)
		Burn()
		START_PROCESSING(SSobj, src)

/obj/structure/bonfire/fire_act(exposed_temperature, exposed_volume)
	StartBurning()

/obj/structure/bonfire/Crossed(atom/movable/AM)
	. = ..()
	if(burning & !grill)
		Burn()

/obj/structure/bonfire/get_current_temperature()
	if(burning)
		return 1000
	return 0

/obj/structure/bonfire/proc/Burn()
	var/turf/current_location = get_turf(src)
	current_location.hotspot_expose(1000, 500)
	for(var/A in current_location)
		if(A == src)
			continue
		if(isobj(A))
			var/obj/O = A
			O.fire_act(1000, 500)
		else if(isliving(A))
			var/mob/living/L = A
			if(prob(20))
				L.emote("scream")
			L.adjust_fire_stacks(fire_stack_strength)
			L.IgniteMob()

/*
/obj/structure/bonfire/proc/Cook()
	var/turf/current_location = get_turf(src)
	for(var/A in current_location)
		if(A == src)
			continue
		else if(isliving(A)) //It's still a fire, idiot.
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength)
			L.IgniteMob()
		else if(istype(A, /obj/item) && prob(20))
			var/obj/item/O = A
			O.microwave_act()
*/

/obj/structure/bonfire/process()
	if(!CheckOxygen())
		extinguish()
		return
	Burn()
	/*if(!grill)
		Burn()
	else
		Cook()*/
/obj/structure/bonfire/water_act()
	extinguish()

/obj/structure/bonfire/proc/extinguish()
	if(burning)
		icon_state = "bonfire"
		burning = 0
		set_light(0)
		STOP_PROCESSING(SSobj, src)

//obj/structure/bonfire/buckle_mob(mob/living/M)
//	if(..())
//		M.pixel_y += 13


/obj/structure/bonfire/post_buckle_mob(mob/living/M)
	if(buckled_mob == M)
		M.pixel_y = 13
		M.layer = 5.1
	else
		if(M.pixel_y == 13)
			M.pixel_y = 0
		M.layer = initial(M.layer)

/obj/structure/bonfire/dynamic
	desc = "For grilling, broiling, charring, smoking, heating, roasting, toasting, simmering, searing, melting, and occasionally burning things."
	var/last_time_smoke = 0
	var/logs = 10
	var/time_log_burned_out = 0

/obj/structure/bonfire/dynamic/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/G = W
		if(G.amount > 0)
			G.use(1)
			logs++
			to_chat(user, "You have added log to the bonfire. Now it has [logs] logs.")
			if(logs > 0 && burning && icon_state != "bonfire_on_fire")
				icon_state = "bonfire_on_fire"
		return
	return ..()

/obj/structure/bonfire/dynamic/proc/MakeSmoke()
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(1, 0, loc)
	smoke.attach(src)
	smoke.start()
	last_time_smoke = world.time + 100

/obj/structure/bonfire/dynamic/Burn()
	var/turf/current_location = get_turf(src)
	current_location.assume_gas("oxygen", -0.5)
	if (current_location.air.temperature >= 393)
		current_location.assume_gas("carbon_dioxide", 0.5)
	else
		current_location.assume_gas("carbon_dioxide", 0.5, (current_location.air.temperature + 200))
	current_location.hotspot_expose(1000, 500)
	if ((world.time > last_time_smoke) && current_location.air.gas["carbon_dioxide"]) //It's time to make some smoke
		if (current_location.air.gas["carbon_dioxide"] > 5)
			MakeSmoke()
	return ..()

/obj/structure/bonfire/dynamic/onDismantle()
	..()
	new /obj/item/stack/sheet/wood(loc, src.logs)

/obj/structure/bonfire/dynamic/extinguish()
	..()
	if(logs == 0)
		new /obj/effect/decal/cleanable/ash(loc)
		qdel(src)

/obj/structure/bonfire/dynamic/process()
	..()
	if (logs < 1 && icon_state != "bonfire_warm")
		icon_state = "bonfire_warm"
	if (world.time > time_log_burned_out)
		if (logs > 0)
			logs--
			if(prob(40))
				new /obj/effect/decal/cleanable/ash(loc)
			time_log_burned_out = world.time + ONE_LOG_BURN_TIME
		else
			extinguish()

/obj/structure/bonfire/dynamic/examine(mob/user)
	..()
	if (get_dist(src, user) <= 2)
		to_chat(user, "<span class='notice'>There [logs == 1 ? "is" : "are"] [logs] log[logs == 1 ? "" : "s"] in [src]</span>")

#undef ONE_LOG_BURN_TIME

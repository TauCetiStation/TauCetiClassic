#define ONE_LOG_BURN_TIME 1200

/obj/item/device/flashlight/flare/torch
	name = "torch"
	desc = "A torch fashioned from some rags and a plank."
	w_class = SIZE_SMALL
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

/obj/item/torch_holder_frame
	name = "torch holder frame"
	desc = "Used for holder torch."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "torch-holder-item"
	flags = CONDUCT
	var/obj/machinery/light/newlight = null
	var/sheets_refunded = 2

/obj/item/torch_holder_frame/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		new /obj/item/stack/sheet/metal(get_turf(loc), sheets_refunded)
		user.SetNextMove(CLICK_CD_RAPID)
		qdel(src)
		return
	return ..()

/obj/item/torch_holder_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf_loc(usr)
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, "<span class='warning'>[src.name] cannot be placed on this spot.</span>")
		return
	to_chat(usr, "Attaching [src] to the wall.")
	playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER)
	var/constrdir = usr.dir
	var/constrloc = usr.loc
	if (usr.is_busy() || !do_after(usr, 30, target = on_wall))
		return
	new /obj/machinery/torch_holder_construct(constrloc)
	newlight.set_dir(constrdir)
	newlight.fingerprints = src.fingerprints
	newlight.fingerprintshidden = src.fingerprintshidden
	newlight.fingerprintslast = src.fingerprintslast

	usr.visible_message("[usr.name] attaches [src] to the wall.", \
		"You attach [src] to the wall.")
	qdel(src)

/obj/machinery/torch_holder
	name = "torch holder frame"
	desc = "A torch holder under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "torch_holder_construct"
	anchored = TRUE
	layer = 5
	var/stage = 1
	var/on = 0
	var/fuel = 0
	var/empty = TRUE
	var/sheets_refunded = 2

/obj/item/device/flashlight/proc/update_brightness(mob/user = null)
	if(on)
		icon_state = "torch-holder1"
		set_light(4)
	else if fuel == 0
		icon_state = "torch-holder-burned"
		set_light(0)
	else
		icon_state = "torch-holder0"
		set_light(0)

/obj/machinery/torch_holder/examine(mob/user)
	..()
	if (src in view(2, user))
		switch(src.stage)
			if(1)
				to_chat(user, "It's an unscrew frame.")
			if(2)
				to_chat(user, "The casing is closed.")

/obj/machinery/torch_holder/attackby(obj/item/I, mob/user)
	add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	if (iswrench(I))
		if (src.stage == 1)
			if(user.is_busy(src))
				return
			to_chat(user, "You begin deconstructing [src].")
			if(!W.use_tool(src, usr, 30, volume = 75))
				return
			new /obj/item/stack/sheet/metal( get_turf(src.loc), sheets_refunded )
			user.visible_message("[user.name] deconstructs [src].", \
				"You deconstruct [src].", "You hear a noise.")
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			qdel(src)
		if (src.stage == 2)
			to_chat(usr, "You have to unscrew the case first.")
			return

	if(isscrewdriver(I))
		if (src.stage == 1)
			src.icon_state = "torch-holder-empty"
			src.stage = 2
			user.visible_message("[user.name] closes [src]'s casing.", \
				"You close [src]'s casing.", "You hear a noise.")
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			return
		if (src.stage == 2 and empty)
			src.icon_state = "torch-holder-construct"
			src.stage = 1
			user.visible_message("[user.name] opens [src]'s casing.", \
				"You open [src]'s casing.", "You hear a noise.")
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			return
		
	if(istype(I, /obj/item/device/flashlight/flare/torch))
		if (src.stage == 2 and empty)
			var/obj/item/device/flashlight/flare/torch/T = I
			src.icon_state = "torch-holder-empty"
			empty = FALSE
			fuel = T.fuel
			on = T.on
			to_chat(user, "You insert the torch.")
			qdel(T)

/obj/machinery/torch_holder/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_RAPID)

	if(empty)
		to_chat(user, "There is no torch in this holder.")
		return

	to_chat(user, "You remove the torch.")

	var/obj/item/device/flashlight/flare/torch/T = new /obj/item/device/flashlight/flare/torch
	T.on = on
	T.fuel = fuel

	user.SetNextMove(CLICK_CD_INTERACT)

	// light item inherits the switchcount, then zero it
	T.switchcount = switchcount
	switchcount = 0

	T.update()
	T.add_fingerprint(user)

	if(!user.put_in_active_hand(T))	//puts it in our active hand (don't forget check)
		T.loc = get_turf(user)
		
	empty = TRUE


	..()

/obj/machinery/torch_holder/process()
	var/turf/pos = get_turf(src)
	if(pos)
		pos.hotspot_expose(produce_heat, 5)
	fuel = max(fuel - 1, 0)
	if(!fuel || !on)
		turn_off()

/obj/item/device/flashlight/flare/proc/turn_off()
	on = FALSE
	if(ismob(loc))
		var/mob/U = loc
		update_brightness(U)
	else
		update_brightness(null)

	if(!fuel)
		icon_state = "torch-holder-burned"
		item_state = "torch-holder-burned"
		update_inv_mob()
	STOP_PROCESSING(SSobj, src)


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
				if(!click_params || !click_params[ICON_X] || !click_params[ICON_Y])
					return
				//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
				W.pixel_x = clamp(text2num(click_params[ICON_X]) - 16, -(world.icon_size/2), world.icon_size/2)
				W.pixel_y = clamp(text2num(click_params[ICON_Y]) - 16, -(world.icon_size/2), world.icon_size/2)
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
		else if(isitem(A) && prob(20))
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

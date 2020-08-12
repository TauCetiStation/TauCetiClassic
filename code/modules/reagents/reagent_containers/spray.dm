/obj/item/weapon/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = OPENCONTAINER | NOBLUDGEON
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 2
	throw_range = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10) //Set to null instead of list, if there is only one.
	var/spray_size = 3
	var/list/spray_sizes = list(1,3) // When building this list, take into considiration what's written above.
	volume = 250
	var/safety = FALSE
	var/triple_shot = FALSE

	action_button_name = "Switch Spray"

	var/chempuff_dense = TRUE // Whether the chempuff can pass through closets and such(and it should).

	var/spray_sound = 'sound/effects/spray2.ogg'
	var/volume_modifier = -6

	var/spray_cloud_move_delay = 3
	var/spray_cloud_react_delay = 2

/obj/item/weapon/reagent_containers/spray/atom_init()
	. = ..()
	verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT

/obj/item/weapon/reagent_containers/spray/afterattack(atom/target, mob/user, proximity, params)
	if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack) || istype(target, /obj/structure/closet) \
	|| istype(target, /obj/item/weapon/reagent_containers) || istype(target, /obj/structure/sink) || istype(target, /obj/structure/stool/bed/chair/janitorialcart))
		return

	if(istype(target, /obj/effect/proc_holder/spell))
		return

	if(istype(target, /obj/structure/reagent_dispensers) && get_dist(src,target) <= 1) //this block copypasted from reagent_containers/glass, for lack of a better solution
		var/obj/structure/reagent_dispensers/RD = target
		if(!is_open_container())
			to_chat(user, "<span class='notice'>[src] can't be filled right now.</span>")
			return

		if(!RD.reagents.total_volume && RD.reagents)
			to_chat(user, "<span class='notice'>[RD] does not have enough liquids.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return

		var/trans = RD.reagents.trans_to(src, RD.amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill \the [src] with [trans] units of the contents of \the [RD].</span>")
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
		return

	if(safety)
		to_chat(usr, "<span class = 'warning'>The safety is on!</span>")
		return

	playsound(src, spray_sound, VOL_EFFECTS_MASTER, null, null, volume_modifier)

	if(reagents.has_reagent("sacid"))
		message_admins("[key_name_admin(user)] fired sulphuric acid from \a [src]. [ADMIN_JMP(user)]")
		log_game("[key_name(user)] fired sulphuric acid from \a [src].")
	if(reagents.has_reagent("pacid"))
		message_admins("[key_name_admin(user)] fired Polyacid from \a [src]. [ADMIN_JMP(user)]")
		log_game("[key_name(user)] fired Polyacid from \a [src].")
	if(reagents.has_reagent("lube"))
		message_admins("[key_name_admin(user)] fired Space lube from \a [src]. [ADMIN_JMP(user)]")
		log_game("[key_name(user)] fired Space lube from \a [src].")

	user.SetNextMove(CLICK_CD_INTERACT * 2)

	var/turf/T = get_turf(target) // BS12 edit, with the wall spraying.
	var/turf/T_start = get_turf(src)

	if(triple_shot && reagents.total_volume >= amount_per_transfer_from_this * 3) // If it doesn't have triple the amount of reagents, but it passed the previous check, make it shoot just one tiny spray.
		var/direction = get_dir(T_start, T)

		var/turf/T1_start = get_step(T_start, turn(direction, 90))
		var/turf/T2_start = get_step(T_start, turn(direction, -90))

		var/turf/T1 = get_step(T, turn(direction, 90))
		var/turf/T2 = get_step(T, turn(direction, -90))

		INVOKE_ASYNC(src, .proc/Spray_at, T_start, T)
		INVOKE_ASYNC(src, .proc/Spray_at, T1_start, T1)
		INVOKE_ASYNC(src, .proc/Spray_at, T2_start, T2)
	else
		INVOKE_ASYNC(src, .proc/Spray_at, T_start, T)

	INVOKE_ASYNC(src, .proc/on_spray, T, user) // A proc where we do all the dirty chair riding stuff.

/obj/item/weapon/reagent_containers/spray/proc/on_spray(turf/T, mob/user)
	if(!triple_shot) // Currently only the big baddies have this mechanic.
		return

	var/movementdirection = turn(get_dir(get_turf(src), T), 180)
	if(istype(get_turf(src), /turf/simulated) && istype(user.buckled, /obj/structure/stool/bed/chair) && !user.buckled.anchored)
		var/obj/structure/stool/bed/chair/buckled_to = user.buckled
		if(!buckled_to.flipped)
			if(buckled_to)
				buckled_to.propelled = 4
			step(buckled_to, movementdirection)
			sleep(1)
			step(buckled_to, movementdirection)
			if(buckled_to)
				buckled_to.propelled = 3
			sleep(1)
			step(buckled_to, movementdirection)
			sleep(1)
			step(buckled_to, movementdirection)
			if(buckled_to)
				buckled_to.propelled = 2
			sleep(2)
			step(buckled_to, movementdirection)
			if(buckled_to)
				buckled_to.propelled = 1
			sleep(2)
			step(buckled_to, movementdirection)
			if(buckled_to)
				buckled_to.propelled = 0
			sleep(3)
			step(buckled_to, movementdirection)
			sleep(3)
			step(buckled_to, movementdirection)
			sleep(3)
			step(buckled_to, movementdirection)
	else if (loc && istype(loc, /obj/item/mecha_parts/mecha_equipment/tool/extinguisher))
		var/obj/item/mecha_parts/mecha_equipment/tool/extinguisher/ext = loc
		if (ext.chassis)
			ext.chassis.newtonian_move(movementdirection)
	else
		user.newtonian_move(movementdirection)


/obj/item/weapon/reagent_containers/spray/proc/Spray_at(turf/start, turf/target)
	var/spray_size_current = spray_size // This ensures, that a player doesn't switch to another mode mid-fly.
	var/obj/effect/decal/chempuff/D = reagents.create_chempuff(amount_per_transfer_from_this, 1/spray_size, name_from_reagents = FALSE)

	if(!chempuff_dense)
		D.pass_flags |= PASSBLOB | PASSMOB | PASSCRAWL

	step_towards(D, start)
	sleep(spray_cloud_move_delay)

	var/max_steps = spray_size_current
	for(var/i in 1 to max_steps)
		step_towards(D, target)
		var/turf/T = get_turf(D)
		D.reagents.reaction(T)
		var/turf/next_T = get_step(T, get_dir(T, target))
		// When spraying against the wall, also react with the wall, but
		// not its contents. BS12
		if(next_T.density)
			D.reagents.reaction(next_T)
			sleep(spray_cloud_react_delay)
		else
			for(var/atom/A in T)
				D.reagents.reaction(A)
				sleep(spray_cloud_react_delay)
		sleep(spray_cloud_move_delay)
	qdel(D)

/obj/item/weapon/reagent_containers/spray/attack_self(mob/user)
	if(!possible_transfer_amounts)
		return
	amount_per_transfer_from_this = next_in_list(amount_per_transfer_from_this, possible_transfer_amounts)
	spray_size = next_in_list(spray_size, spray_sizes)
	to_chat(user, "<span class='notice'>You adjusted the pressure nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")


/obj/item/weapon/reagent_containers/spray/verb/empty()

	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr

	if (alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", "Yes", "No") != "Yes")
		return
	if(isturf(usr.loc))
		to_chat(usr, "<span class='notice'>You empty \the [src] onto the floor.</span>")
		reagents.reaction(usr.loc)
		sleep(5)
		reagents.clear_reagents()
//hair dyes!
/obj/item/weapon/reagent_containers/spray/hair_color_spray
	name = "hair color spray"
	desc = "Changes hair colour! Don't forget to read the label!"
	icon = 'icons/obj/items.dmi'
	icon_state = "hairspraywhite"
	item_state = "hairspray"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1,5,10)
	spray_size = 1
	spray_sizes = list(1)

/obj/item/weapon/reagent_containers/spray/hair_color_spray/atom_init()
	. = ..()
	name = "white hair color spray"
	icon_state = "hairspraywhite"

/obj/item/weapon/reagent_containers/spray/hair_color_spray/verb/change_label()
	set name = "Change Label"
	set category = "Object"
	set src in usr

	var/colour_spray = input(usr, "Choose desired label colour") as null|anything in list("white", "red", "green", "blue", "black", "brown", "blond")
	if(colour_spray)
		name = "[colour_spray] [initial(name)]"
		icon_state = "[initial(icon_state)][colour_spray]"
	else
		name = "white hair color spray"
		icon_state = "hairspraywhite"
	update_icon()

//thurible
/obj/item/weapon/reagent_containers/spray/thurible
	name = "thurible"
	desc = "Is used to burn incense. Or heretics. Both? Both is good."
	icon = 'icons/obj/items.dmi'
	icon_state = "thurible"
	item_state = "thurible"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = list(1, 5, 10)
	spray_size = 1
	spray_sizes = list(1)
	volume = 100
	var/lit = FALSE
	var/temperature = 0 // At 100, it all evaporates. Yes, even the dense metals. The name doesn't actually imply that this item's temperature is changing.
	var/fuel = 300
	safety = TRUE

/obj/item/weapon/reagent_containers/spray/thurible/examine(mob/user)
	..()
	if(src in view(1, user))
		var/temp_sight
		var/is_fueled
		switch(temperature)
			if(-INFINITY to 0)
				temp_sight = "blue"
			if(0 to 30)
				temp_sight = "normal"
			if(30 to 60)
				temp_sight = "yellow"
			if(60 to 90)
				temp_sight = "orange"
			if(90 to INFINITY)
				temp_sight = "<span class='warning'>boiling red</span>"
		switch(fuel)
			if(0)
				is_fueled = "not fueled at all"
			if(1 to 75)
				is_fueled = "almost not fueled"
			if(75 to 150)
				is_fueled = "slightly fueled"
			if(150 to 225)
				is_fueled = "evenly fueled"
			if(225 to 299)
				is_fueled = "almost fueled"
			if(300 to INFINITY)
				is_fueled = "fully fueled"
		to_chat(user, "The cap is [safety ? "on" : "off"]. The thurbile's surface is [temp_sight]. The canister in [src] is [is_fueled].")

/obj/item/weapon/reagent_containers/spray/thurible/proc/light(mob/user, action_string = "lights up")
	if(!lit)
		icon_state = "thurible_lit"
		update_icon()
		lit = TRUE
		user.visible_message("<span class='notice'>[user] [action_string] \the [src].</span>", "<span class='notice'>You light up \the [src].</span>")

/obj/item/weapon/reagent_containers/spray/thurible/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/reagent_containers/spray/thurible/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/reagent_containers/spray/thurible/process()
	if(lit && safety)
		if(temperature >= 100)
			var/datum/reagents/evaporate = new /datum/reagents
			evaporate.my_atom = src // Important for fingerprint tracking, and etc.
			var/evaporated_volume = 0
			for(var/datum/reagent/A in reagents.reagent_list)
				var/reagent_volume = min(A.volume/reagents.reagent_list.len, amount_per_transfer_from_this/reagents.reagent_list.len)
				reagents.remove_reagent(A.id, reagent_volume) // Basically, we want the thurible to evaporate only amount_per_transfer_from_this cube of reagents total.
				evaporated_volume += reagent_volume/2 // To prevent giant gaseous clouds, we divide the actual volume.
				evaporate.add_reagent(A.id, reagent_volume, A.data, TRUE) // Safety(no reactions) should be TRUE, since "evaporate" is abstract, and not attached to any objects.
			if(evaporate.reagent_list.len)
				var/location = get_turf(src)
				var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
				S.attach(location)
				S.set_up(evaporate, evaporated_volume, 0, location)
				playsound(location, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, null, -3)
				S.start()
				temperature -= rand(evaporated_volume*3,evaporated_volume*6) // Release the "hot" gas, and chill.
		fuel = max(fuel - 1, 0)
		if(fuel == 0)
			temperature = max(0, temperature - 1)
		else
			temperature = min(100, temperature+1)
		if(temperature <=0)
			visible_message("<span class='notice'>The fire in [src] just went out.</span>")
			lit = FALSE
			icon_state = "thurible"
			update_icon()
	else if(!lit)
		if(temperature >= 0)
			temperature = max(0, temperature - 1)
		if(!safety)
			for(var/datum/reagent/A in reagents.reagent_list)
				if(!istype(A, /datum/reagent/toxin/phoron) && !istype(A, /datum/reagent/fuel))
					continue
				else
					fuel += min(round(A.volume*3), 3) // Basically, 1 point of fuel reagent is 3 fuel points of thurible. 100 - is max fuel.
					reagents.remove_reagent(A.id, min(A.volume, 1))

/obj/item/weapon/reagent_containers/spray/thurible/attackby(obj/item/I, mob/user, params)
	if(!lit && safety) // You can't lit the fuel when the cap's off, cause then it wouldn't start to burn.
		if(iswelder(I))
			var/obj/item/weapon/weldingtool/WT = I
			if(WT.isOn())
				light(user, "casually lights")
		else if(istype(I, /obj/item/weapon/lighter))
			var/obj/item/weapon/lighter/L = I
			if(L.lit)
				light(user)
		else if(istype(I, /obj/item/weapon/match))
			var/obj/item/weapon/match/M = I
			if(M.lit)
				light(user)
		else if(istype(I, /obj/item/candle))
			var/obj/item/candle/C = I
			if(C.lit)
				light(user)
	else if(!safety)
		to_chat(user, "<span class='notice'>Put the cap back on.</span>")
	else
		return ..()

/obj/item/weapon/reagent_containers/spray/thurible/attack_self(mob/user)
	if(lit) // You can't switch the spray mode, if the thing's burning.
		user.visible_message("<span class='notice'>[user] extinguishes \the [src].</span>", "<span class='notice'>You extinguish \the [src].</span>")
		lit = FALSE
		icon_state = "thurible"
		update_icon()
	else
		safety = !safety
		to_chat(user, "<span class='notice'>You [safety ? "put on" : "take off"] the cap of [src].</span>")

/obj/item/weapon/reagent_containers/spray/thurible/verb/switch_spray_size()
	set name = "Adjust Nozzle"
	set category = "Object"
	set src in usr

	if(!lit && !safety)
		amount_per_transfer_from_this = next_in_list(amount_per_transfer_from_this, possible_transfer_amounts)
		spray_size = next_in_list(spray_size, spray_sizes)
		to_chat(usr, "<span class='notice'>You adjusted the pressure nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")
	else if(lit)
		to_chat(usr, "<span class='notice'>The nozzle is too hot to the touch.</span>")
	else if(safety)
		to_chat(usr, "<span class='notice'>Take the cap off first.</span>")

//space cleaner
/obj/item/weapon/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"

/obj/item/weapon/reagent_containers/spray/cleaner/drone
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	volume = 50

/obj/item/weapon/reagent_containers/spray/cleaner/atom_init()
	. = ..()
	reagents.add_reagent("cleaner", volume)

//pepperspray
/obj/item/weapon/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	possible_transfer_amounts = null
	volume = 40
	safety = 1


/obj/item/weapon/reagent_containers/spray/pepper/atom_init()
	. = ..()
	reagents.add_reagent("condensedcapsaicin", 40)

/obj/item/weapon/reagent_containers/spray/pepper/examine(mob/user)
	..()
	if(src in view(1, user))
		to_chat(user, "The safety is [safety ? "on" : "off"].")

/obj/item/weapon/reagent_containers/spray/pepper/attack_self(mob/user)
	safety = !safety
	to_chat(usr, "<span class = 'notice'>You switch the safety [safety ? "on" : "off"].</span>")

//water flower
/obj/item/weapon/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 1
	possible_transfer_amounts = null
	volume = 10

/obj/item/weapon/reagent_containers/spray/waterflower/atom_init()
	. = ..()
	reagents.add_reagent("water", 10)

//chemsprayer
/obj/item/weapon/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagent in a given area."
	icon = 'icons/obj/gun.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 3
	w_class = ITEM_SIZE_NORMAL
	possible_transfer_amounts = null
	volume = 600
	origin_tech = "combat=3;materials=3;engineering=3"
	triple_shot = TRUE
	spray_size = 7
	spray_sizes = list(7)

// Plant-B-Gone
/obj/item/weapon/reagent_containers/spray/plantbgone // -- Skie
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 100


/obj/item/weapon/reagent_containers/spray/plantbgone/atom_init()
	. = ..()
	reagents.add_reagent("plantbgone", 100)

//Water Gun
/obj/item/weapon/reagent_containers/spray/watergun
	name = "hyper soaker"
	desc = "A water gun that uses manually-pressurized air to shoot water with great power, range, and accuracy."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "watergun"
	item_state = "watergun"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	volume = 35
	origin_tech = "combat=1;materials=1"
	spray_size = 4
	spray_sizes = list(4)

	spray_cloud_move_delay = 1
	spray_cloud_react_delay = 0

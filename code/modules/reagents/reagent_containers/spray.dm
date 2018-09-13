/obj/item/weapon/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = OPENCONTAINER | NOBLUDGEON
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10) //Set to null instead of list, if there is only one.
	var/spray_size = 3
	var/list/spray_sizes = list(1,3)
	volume = 250
	var/safety = FALSE

	action_button_name = "Switch Spray"


/obj/item/weapon/reagent_containers/spray/atom_init()
	. = ..()
	verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT

/obj/item/weapon/reagent_containers/spray/afterattack(atom/A, mob/user)
	if(istype(A, /obj/structure/table) || istype(A, /obj/structure/rack) || istype(A, /obj/structure/closet) \
	|| istype(A, /obj/item/weapon/reagent_containers) || istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart))
		return

	if(istype(A, /obj/effect/proc_holder/spell))
		return

	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1) //this block copypasted from reagent_containers/glass, for lack of a better solution
		if(!A.reagents.total_volume && A.reagents)
			to_chat(user, "<span class='notice'>\The [A] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return

		var/trans = A.reagents.trans_to(src, A:amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill \the [src] with [trans] units of the contents of \the [A].</span>")
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
		return

	if(safety)
		to_chat(usr, "<span class = 'warning'>The safety is on!</span>")
		return

	Spray_at(A)

	playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)

	if(reagents.has_reagent("sacid"))
		message_admins("[key_name_admin(user)] fired sulphuric acid from \a [src]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		log_game("[key_name(user)] fired sulphuric acid from \a [src].")
	if(reagents.has_reagent("pacid"))
		message_admins("[key_name_admin(user)] fired Polyacid from \a [src]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		log_game("[key_name(user)] fired Polyacid from \a [src].")
	if(reagents.has_reagent("lube"))
		message_admins("[key_name_admin(user)] fired Space lube from \a [src]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		log_game("[key_name(user)] fired Space lube from \a [src].")
	return

/obj/item/weapon/reagent_containers/spray/proc/Spray_at(atom/A)
	var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(src))
	D.create_reagents(amount_per_transfer_from_this)
	reagents.trans_to(D, amount_per_transfer_from_this, 1/spray_size)
	D.icon += mix_color_from_reagents(D.reagents.reagent_list)

	var/turf/A_turf = get_turf(A)//BS12

	spawn(0)
		for(var/i=0, i<spray_size, i++)
			step_towards(D,A)
			D.reagents.reaction(get_turf(D))
			for(var/atom/T in get_turf(D))
				D.reagents.reaction(T)

				// When spraying against the wall, also react with the wall, but
				// not its contents. BS12
				if(get_dist(D, A_turf) == 1 && A_turf.density)
					D.reagents.reaction(A_turf)
				sleep(2)
			sleep(3)
		qdel(D)

	return

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
		spawn(5) src.reagents.clear_reagents()
//hair dyes!
/obj/item/weapon/reagent_containers/spray/hair_color_spray
	name = "hair color spray"
	desc = "Changes hair colour! Don't forget to read the label!"
	icon = 'icons/obj/items.dmi'
	icon_state = "hairspray"
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
	possible_transfer_amounts = list(1)
	spray_size = 1
	spray_sizes = list(1)
	volume = 10 // People shouldn't be able to create giant gas clouds just this easily.
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
			var/evaporated_volume = 0
			for(var/datum/reagent/A in reagents.reagent_list)
				evaporated_volume += A.volume/5
				A.volume -= A.volume/5
			if(evaporated_volume)
				var/location = get_turf(src)
				var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
				S.attach(location)
				S.set_up(reagents, evaporated_volume, 0, location)
				playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
				S.start()
			temperature -= rand(10,30) // Release the "hot" gas, and chill.
		temperature++
		fuel = max(fuel-1, 0)
		if(fuel == 0)
			temperature--
		if(temperature <=0)
			visible_message("<span class='notice'>The fire in [src] just went out.</span>")
			lit = FALSE
	else if(!lit && !safety)
		for(var/datum/reagent/A in reagents.reagent_list)
			if(!istype(A, /datum/reagent/toxin/phoron) && !istype(A, /datum/reagent/fuel))
				continue
			else
				fuel = round(min(fuel + A.volume*0.6, 300)) // Basically, 1 point of fuel reagent is 3 fuel points of thurible. 100 - is max fuel.
				A.volume -= A.volume*0.2

/obj/item/weapon/reagent_containers/spray/thurible/attackby(obj/item/weapon/W, mob/user)
	..()
	if(!lit && safety) // You can't lit the fuel when the cap's off, cause then it wouldn't start to burn.
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.isOn())
				light(user, "casually lights")
				fuel += 7
		else if(istype(W, /obj/item/weapon/lighter))
			var/obj/item/weapon/lighter/L = W
			if(L.lit)
				light(user)
				fuel += 5
		else if(istype(W, /obj/item/weapon/match))
			var/obj/item/weapon/match/M = W
			if(M.lit)
				light(user)
				fuel += 5
		else if(istype(W, /obj/item/candle))
			var/obj/item/candle/C = W
			if(C.lit)
				light(user)
				fuel += 10 // Candles go out, so their "fuel" is the most precious to us.
	else if(!safety)
		to_chat(user, "Put the cap back on.")

/obj/item/weapon/reagent_containers/spray/thurible/attack_self(mob/user)
	if(lit) // You can't switch the cap, if the thing's burning.
		user.visible_message("<span class='notice'>[user] extinguishes \the [src].</span>", "<span class='notice'>You extinguish \the [src].</span>")
		lit = FALSE
	else
		safety = !safety
		to_chat(user, "<span class='notice'>You [safety ? "put on" : "take off"] the cap of [src].</span>")

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

/obj/item/weapon/reagent_containers/spray/pepper/Spray_at(atom/A)
	..()

//water flower
/obj/item/weapon/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/harvest.dmi'
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
	w_class = 3.0
	possible_transfer_amounts = null
	volume = 600
	origin_tech = "combat=3;materials=3;engineering=3"


//this is a big copypasta clusterfuck, but it's still better than it used to be!
/obj/item/weapon/reagent_containers/spray/chemsprayer/Spray_at(atom/A)
	var/Sprays[3]
	for(var/i=1, i<=3, i++) // intialize sprays
		if(src.reagents.total_volume < 1) break
		var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(src))
		D.create_reagents(amount_per_transfer_from_this)
		src.reagents.trans_to(D, amount_per_transfer_from_this)

		D.icon += mix_color_from_reagents(D.reagents.reagent_list)

		Sprays[i] = D

	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=Sprays.len, i++)
		spawn()
			var/obj/effect/decal/chempuff/D = Sprays[i]
			if(!D) continue

			// Spreads the sprays a little bit
			var/turf/my_target = pick(the_targets)
			the_targets -= my_target

			for(var/j=1, j<=rand(6,8), j++)
				step_towards(D, my_target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/t in get_turf(D))
					D.reagents.reaction(t)
				sleep(2)
			qdel(D)

	return

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

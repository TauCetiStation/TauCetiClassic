/obj/item/weapon/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	flags = CONDUCT
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_SMALL
	m_amt = 500
	origin_tech = "combat=1;phorontech=1"
	var/status = 0
	var/throw_amount = 1 // If player turns it up higher, it may be a worldfire.
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weapon/weldingtool/weldtool = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/weapon/tank/phoron/ptank = null

/obj/item/weapon/flamethrower/Destroy()
	if(weldtool)
		qdel(weldtool)
	if(igniter)
		qdel(igniter)
	if(ptank)
		qdel(ptank)
	return ..()

/obj/item/weapon/flamethrower/get_current_temperature()
	if(lit)
		return 1500
	return 0

/obj/item/weapon/flamethrower/process()
	if(!lit)
		STOP_PROCESSING(SSobj, src)
		return

	var/turf/location = loc
	if(istype(location, /mob))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2)

/obj/item/weapon/flamethrower/update_icon()
	cut_overlays()
	if(igniter)
		add_overlay("+igniter[status]")
	if(ptank)
		add_overlay("+ptank")
	if(lit)
		add_overlay("+lit")
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"

/obj/item/weapon/flamethrower/afterattack(atom/target, mob/user, proximity, params)
	if(!can_see(user, target))
		return
	// Make sure our user is still holding us
	if(user && user.get_active_hand() == src)
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/list/turflist = getline(get_turf(src), target_turf)
			flame_turf(turflist)

/obj/item/weapon/flamethrower/attackby(obj/item/I, mob/user, params)
	if(iswrench(I) && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.forceMove(T)
			weldtool = null
		if(igniter)
			igniter.forceMove(T)
			igniter = null
		if(ptank)
			ptank.forceMove(T)
			ptank = null
		new /obj/item/stack/rods(T)
		qdel(src)
		return

	if(isscrewdriver(I) && igniter && !lit)
		status = !status
		to_chat(user, "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>")
		update_icon()
		return

	if(isigniter(I))
		var/obj/item/device/assembly/igniter/IGN = I
		if(IGN.secured)	return
		if(igniter)		return
		user.drop_from_inventory(IGN, src)
		igniter = IGN
		update_icon()
		return

	if(istype(I, /obj/item/weapon/tank/phoron))
		if(ptank)
			to_chat(user, "<span class='notice'>There appears to already be a phoron tank loaded in [src]!</span>")
			return
		user.drop_from_inventory(I, src)
		ptank = I
		update_icon()
		return

	if(istype(I, /obj/item/device/analyzer))
		var/obj/item/device/analyzer/A = I
		A.analyze_gases(src, user)
		return

	return ..()

/obj/item/weapon/flamethrower/attack_self(mob/user)
	user.set_machine(src)
	if(!ptank)
		to_chat(user, "<span class='notice'>Attach a phoron tank first!</span>")
		return
	var/dat = "<TT><B>Flamethrower "
	if(lit)
		dat += "<A class='red' HREF='?src=\ref[src];light=1'>Lit</a>"
	else
		dat += "<A HREF='?src=\ref[src];light=1'>Unlit</a>"

	dat += "</B><BR>\n Tank Pressure: [ptank.air_contents.return_pressure()]<BR>\nAmount to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [throw_amount] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n<A HREF='?src=\ref[src];remove=1'>Remove phorontank</A></TT>"

	var/datum/browser/popup = new(user, "flamethrower", null, 600, 300)
	popup.set_content(dat)
	popup.open()


/obj/item/weapon/flamethrower/Topic(href,href_list[])
	if(usr.incapacitated())	return
	usr.set_machine(src)
	if(href_list["light"])
		if(!ptank)	return
		if(ptank.air_contents.gas["phoron"] < 1)	return
		if(!status)	return
		lit = !lit
		if(lit)
			START_PROCESSING(SSobj, src)
	if(href_list["amount"])
		throw_amount = throw_amount + text2num(href_list["amount"])
		throw_amount = clamp(throw_amount, 1, 10)
	if(href_list["remove"])
		if(!ptank)	return
		usr.put_in_hands(ptank)
		ptank = null
		lit = 0
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")

	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)

	update_icon()

/obj/item/weapon/flamethrower/proc/flame_turf(list/turflist)
	if(!lit || operating)
		return
	if(!ptank.air_contents.total_moles)
		update_icon()
		lit = FALSE
		return

	operating = TRUE

	var/datum/gas_mixture/fuel_transfer = ptank.air_contents.remove(throw_amount)
	var/pressure_range = min(turflist.len - 1, ptank.air_contents.return_pressure() / 75) // Normal pressure of 303.75 results in a fire spread of 4 tiles. We remove 1 from turflist because our own tile doesn't count.
	var/self_turf = get_turf(src)

	if(pressure_range == 0)
		return

	for(var/turf/T in turflist)
		if(T == self_turf || isspaceturf(T))
			continue
		if(get_dist(T, self_turf) > pressure_range)
			break
		var/datum/gas_mixture/fuel_iteration = fuel_transfer.remove_ratio(1 / pressure_range)
		if(fuel_iteration.gas["phoron"] == 0)
			break
		new /obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel(T, fuel_iteration.gas["phoron"], get_dir(self_turf, T))
		fuel_iteration.gas["phoron"] = 0
		sleep(1)
		T.assume_air(fuel_iteration)
		T.hotspot_expose((ptank.air_contents.temperature * 2) + 400, 500)
		sleep(2)

	operating = FALSE

	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)

/obj/item/weapon/flamethrower/full/atom_init()
	. = ..()
	weldtool = new /obj/item/weapon/weldingtool(src)
	igniter = new /obj/item/device/assembly/igniter(src)
	igniter.secured = 0
	status = 1
	update_icon()

/obj/item/weapon/flamethrower_M2
	name = "M2 Flamethrower."
	desc = "Best tool for starting a fire since 1943."
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "M2_Flamethrower"
	item_state = "M2_Flamethrower"
	flags = CONDUCT
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_SMALL
	m_amt = 500
	origin_tech = "combat=2;phorontech=1"
	var/status = 0
	var/throw_amount = 25
	var/thrown_amount = 25
	var/lit = 0	//allways lit
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weapon/weldpack/M2_fuelback/Connected_tank = null

/obj/item/weapon/flamethrower_M2/dropped(mob/user)
	..()
	if(user)
		Connected_tank.unequip(user)
		Connected_tank = null
	return

/obj/item/weapon/flamethrower_M2/process()
	if(!lit)
		STOP_PROCESSING(SSobj, src)
		return
	var/turf/location = loc
	if(istype(location, /mob))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2)
	return

/obj/item/weapon/flamethrower_M2/get_current_temperature()
	if(lit)
		return 1500
	return 0

/obj/item/weapon/flamethrower_M2/proc/unequip(mob/user)
	if(Connected_tank)
		if(lit)
			lit = 0
			if(user)
				to_chat(user, "Flamethrower flame dies out, it is unlit now.")
		Connected_tank = null
	update_icon()

/obj/item/weapon/flamethrower_M2/proc/equip(mob/user, obj/item/W)
	if(!Connected_tank && istype(W, /obj/item/weapon/weldpack/M2_fuelback))
		Connected_tank = W

/obj/item/weapon/flamethrower_M2/update_icon()
	cut_overlays()
	if(lit)
		icon_state = "M2_Flamethrower_lit"
	else
		icon_state = "M2_Flamethrower"
	return

/obj/item/weapon/flamethrower_M2/afterattack(atom/target, mob/user, proximity, params)
	if(!can_see(user, target))
		return
	// Make sure our user is still holding us
	if(user && user.get_active_hand() == src)
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			flame_turf(turflist)

/obj/item/weapon/flamethrower_M2/attack_self(mob/user)
	if(!Connected_tank)
		to_chat(usr, "M2 Flamethrower needs to be connected to fuel backpack first.")
		return
	if(!lit)
		lit = 1
		START_PROCESSING(SSobj, src)
		to_chat(usr, "You had opend fuel intake and lit your M2 Flamethrower!")
	else
		lit = 0
		to_chat(usr, "You had stopped fuel intake and extinguished your M2 Flamethrower.")
	update_icon()
	return



//Called from turf.dm turf/dblclick
/obj/item/weapon/flamethrower_M2/proc/flame_turf(turflist)
	if(!lit || operating)	return

	operating = 1
	for(var/turf/T in turflist)
		if(T.density || isspaceturf(T))
			break
		if(!previousturf && length(turflist)>1)
			previousturf = get_turf(src)
			continue	//so we don't burn the tile we be standin on
		ignite_turf(T)
		sleep(1)
	if(Connected_tank.reagents.total_volume < throw_amount)
		to_chat(src.loc, "Backpack runs out of juice, you have to refill it.")
		lit = 0
		if(ismob(src.loc))
			to_chat(src.loc, "Flamethrower flame dies out, it is unlit now.")
		thrown_amount = Connected_tank.reagents.total_volume
	else
		thrown_amount = throw_amount
	Connected_tank.reagents.remove_reagent("fuel",thrown_amount)
	previousturf = null
	operating = 0

	return


/obj/item/weapon/flamethrower_M2/proc/ignite_turf(turf/target)
	new/obj/effect/decal/cleanable/liquid_fuel/flamethrower_fuel(target,throw_amount/50,get_dir(loc,target))
	return


/obj/item/weapon/makeshift_flamethrower
	name = "makeshift flamethrower"
	desc = "I love the smell of napalm in the morning."
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	flags = CONDUCT
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = SIZE_NORMAL
	m_amt = 500
	origin_tech = "engineering=3"
	var/status = TRUE	//ready to fire or not. Used to deconstruct
	var/lit = FALSE
	var/max_fuel = 20

/obj/item/weapon/makeshift_flamethrower/atom_init()
	. = ..()
	create_reagents(max_fuel)
	reagents.add_reagent("fuel", max_fuel)

/obj/item/weapon/makeshift_flamethrower/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='info'>Devise is [status ? "secured" : "unsecured"]. <br>Contains [reagents.get_reagent_amount("fuel")]/[max_fuel] units of fuel!</span>")

/obj/item/weapon/makeshift_flamethrower/get_current_temperature()
	if(lit)
		return 1500
	return 0

/obj/item/weapon/makeshift_flamethrower/process()
	var/turf/T = get_turf(src)
	T.hotspot_expose(700, 2)

/obj/item/weapon/makeshift_flamethrower/update_icon()
	cut_overlays()
	add_overlay("+igniter[status]")
	if(lit)
		add_overlay("+lit")
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"

/obj/item/weapon/makeshift_flamethrower/proc/suck_fuel_from_weldpack(mob/user, amount = 0)
	if(!iscarbon(user) || !amount)
		return
	var/mob/living/carbon/C = user
	var/obj/item/weapon/weldpack/my_weldpack = C.get_slot_ref(SLOT_BACK)
	if(istype(my_weldpack))
		my_weldpack.reagents.trans_to(src, amount)

/obj/item/weapon/makeshift_flamethrower/afterattack(atom/target, mob/user, proximity, params)
	user.SetNextMove(CLICK_CD_MELEE)
	if(!status)
		to_chat(user, "<span class='warning'>Secure all components first.</span>")
		return
	if(reagents.total_volume == 0)
		to_chat(user, "<span class='warning'>[src] is empty. It can be filled with fuelweldpack.</span>")
		return
	var/turf/target_turf = get_turf(target)
	var/turf/self_turf = get_turf(user)
	var/distance_reached = 0
	if(!target_turf)
		return
	var/list/turflist = getline(self_turf, target_turf)
	//how much needed refill from fuelweldpack
	var/fuel_spent = 0
	for(var/turf/turf_in_line in turflist)
		if(turf_in_line == self_turf || isspaceturf(turf_in_line))
			continue
		//stop fuelthrowing when distance is big. No need fueltrowing with zoom or camera use
		if(distance_reached > 7)
			break
		//check every turf in line for walls/glass/etc
		if(!self_turf.CanPass(null, turf_in_line, 0, 0))
			break
		//don't accidentally set yourself on fire
		var/amount_fuel = 0
		if(get_dist(turf_in_line, user) < 3)
			amount_fuel = 0.5
			flame_turf(turf_in_line, self_turf, amount_fuel)
			fuel_spent += amount_fuel
		else
			amount_fuel = 1
			flame_turf(turf_in_line, self_turf, amount_fuel)
		self_turf = turf_in_line
		distance_reached++
		fuel_spent += amount_fuel
	user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] fired by flamethrower on [target] at [COORD(target)]</font>"
	suck_fuel_from_weldpack(user, fuel_spent)

/obj/item/weapon/makeshift_flamethrower/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		if(!status)
			var/turf/T = get_turf(src)
			new /obj/item/weapon/weldingtool(T)
			new /obj/item/device/assembly/igniter(T)
			new /obj/item/stack/rods(T)
			to_chat(user, "<span class='notice'>You have successfully dismantled [src].</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>Unsecure [src] first.</span>")
		return
	if(isscrewdriver(I))
		if(!status)
			status = TRUE
			to_chat(user, "<span class='notice'>Components of [src] secured.</span>")
			update_icon()
		else
			status = FALSE
			lit = FALSE
			STOP_PROCESSING(SSobj, src)
			to_chat(user, "<span class='notice'>[src] is now unsecured.</span>")
			update_icon()
			user.update_inv_item(src)
		return
	return ..()

/obj/item/weapon/makeshift_flamethrower/attack_self(mob/user)
	if(!status)
		lit = FALSE
		to_chat(user, "<span class='warning'>Components needs securing by screwdriver.</span>")
	else
		lit = !lit
	if(lit)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/item/weapon/makeshift_flamethrower/proc/flame_turf(turf/target, turf/prev_turf, amount = 5)
	if(reagents.total_volume == 0)
		return
	var/obj/effect/decal/chempuff/D = reagents.create_chempuff(amount)
	D.forceMove(prev_turf)
	step_towards(D, target)
	D.reagents.reaction(target)
	for(var/atom/A in target)
		D.reagents.reaction(A)
	if(lit)
		target.hotspot_expose(700, 5)
	QDEL_IN(D, 1 SECOND)

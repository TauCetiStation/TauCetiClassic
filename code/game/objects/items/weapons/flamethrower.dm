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
	w_class = ITEM_SIZE_NORMAL
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
	var/dat = text("<TT><B>Flamethrower (<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\n Tank Pressure: [ptank.air_contents.return_pressure()]<BR>\nAmount to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [throw_amount] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n<A HREF='?src=\ref[src];remove=1'>Remove phorontank</A> - <A HREF='?src=\ref[src];close=1'>Close</A></TT>")
	user << browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")

/obj/item/weapon/flamethrower/Topic(href,href_list[])
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
		return
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
		if(T == self_turf || istype(T, /turf/space))
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
	weldtool.status = 0
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
	w_class = ITEM_SIZE_NORMAL
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
		if(T.density || istype(T, /turf/space))
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
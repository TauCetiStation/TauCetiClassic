/obj/item/weapon/weldpack/M2_fuelback
	name = "M2 Flamethrower backpack."
	desc = "It smells like victory."
	slot_flags = SLOT_BACK

	icon = 'code/game/objects/WalterJ_Items_Pack/M2 FLAMETHROWER/WJ_M2_Flamethrower.dmi'
	icon_custom = 'code/game/objects/WalterJ_Items_Pack/M2 FLAMETHROWER/WJ_M2_Flamethrower.dmi'
	icon_state = "M2_Tank"
	item_state = "M2_Tank"

	var/obj/item/weapon/flamethrower_M2/Connected_Flamethrower = null

/obj/item/weapon/weldpack/M2_fuelback/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/T = W
		if(T.welding)
			message_admins("[key_name_admin(user)] triggered a flamethrower back explosion. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			log_game("[key_name(user)] triggered a flamethrower back explosion.")
			to_chat(user, "\red That was stupid of you.")
		if(Connected_Flamethrower)
			Connected_Flamethrower.unequip(user)
			//explosion(get_turf(src),-1,0,2)
			//NAPALM GRENADE CODE HERE
		src.reagents.reaction(get_turf(src), TOUCH)
		spawn(5)
		src.reagents.clear_reagents()
		if(src)
			qdel(src)
		return

	if(istype(W, /obj/item/weapon/flamethrower_M2))
		if(src.loc == user)
			if(!Connected_Flamethrower)
				to_chat(user, "You connected your M2 flamethrower to fuel backpack.")
				src.equip(user, W)
			else
				to_chat(user, "Flamethrower allready connected.")
		else
			to_chat(user, "Put on your fuel backpack first.")

	return

/obj/item/weapon/weldpack/M2_fuelback/proc/unequip(mob/user)
	if(Connected_Flamethrower)
		Connected_Flamethrower.unequip(user)
		Connected_Flamethrower.update_icon()
		Connected_Flamethrower = null


/obj/item/weapon/weldpack/M2_fuelback/proc/equip(mob/user, obj/item/W)
	if(!Connected_Flamethrower && istype(W, /obj/item/weapon/flamethrower_M2))
		var/obj/item/weapon/flamethrower_M2/time = W
		Connected_Flamethrower = time
		time.equip(user, src)

/obj/item/weapon/weldpack/M2_fuelback/dropped(mob/user)
	if(user)
		if(Connected_Flamethrower)
			Connected_Flamethrower.unequip(user)
			Connected_Flamethrower = null
	return

/obj/item/weapon/flamethrower_M2
	name = "M2 Flamethrower."
	desc = "Best tool for starting a fire since 1943."

	icon = 'code/game/objects/WalterJ_Items_Pack/M2 FLAMETHROWER/WJ_M2_Flamethrower.dmi'
	icon_custom = 'code/game/objects/WalterJ_Items_Pack/M2 FLAMETHROWER/WJ_M2_Flamethrower.dmi'
	icon_state = "M2_Flamethrower"
	item_state = "M2_Flamethrower"


	flags = CONDUCT
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
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
		SSobj.processing.Remove(src)
		return
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2)
	return

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
	overlays.Cut()
	if(lit)
		item_state = "flamethrower_lit"
	else
		item_state = "flamethrower"
	return

/obj/item/weapon/flamethrower_M2/afterattack(atom/target, mob/user, proximity)
	// Make sure our user is still holding us
	if(user && user.get_active_hand() == src)
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			flame_turf(turflist)

/obj/item/weapon/flamethrower_M2/attackby(obj/item/W, mob/user)
	..()
	return


/obj/item/weapon/flamethrower_M2/attack_self(mob/user)
	if(user.stat || user.restrained() || user.lying)	return
	if(!Connected_tank)
		to_chat(usr, "M2 Flamethrower needs to be connected to fuel backpack first.")
		return
	if(!lit)
		lit = 1
		SSobj.processing |= src
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
		if(previousturf && LinkBlocked(previousturf, T))
			break
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

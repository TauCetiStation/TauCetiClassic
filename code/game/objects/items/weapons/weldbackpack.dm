/obj/item/weapon/weldpack
	name = "Welding kit"
	desc = "A heavy-duty, portable welding fluid carrier."
	slot_flags = SLOT_FLAGS_BACK
	icon = 'icons/obj/storage.dmi'
	icon_state = "welderpack"
	w_class = ITEM_SIZE_LARGE
	var/max_fuel = 350

/obj/item/weapon/weldpack/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(max_fuel) //Lotsa refills
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)

/obj/item/weapon/weldpack/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/T = I
		if(T.welding & prob(50))
			message_admins("[key_name_admin(user)] triggered a welding kit explosion. [ADMIN_JMP(user)]")
			log_game("[key_name(user)] triggered a fueltank explosion.")
			to_chat(user, "<span class='warning'>That was stupid of you.</span>")
			explosion(get_turf(src),-1,0,2)
			if(src)
				qdel(src)
			return
		else
			if(T.welding)
				to_chat(user, "<span class='warning'>That was close!</span>")
			reagents.trans_to(I, T.max_fuel)
			to_chat(user, "<span class='notice'>Welder refilled!</span>")
			playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER, null, null, -6)
			return

	to_chat(user, "<span class='notice'>The tank scoffs at your insolence.  It only provides services to welders.</span>")

/obj/item/weapon/weldpack/afterattack(atom/target, mob/user, proximity, params)
	if (istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,target) <= 1 && src.reagents.total_volume < max_fuel)
		target.reagents.trans_to(src, max_fuel)
		to_chat(user, "<span class='notice'>You crack the cap off the top of the pack and fill it back up again from the tank.</span>")
		playsound(src, 'sound/effects/refill.ogg', VOL_EFFECTS_MASTER, null, null, -6)
		return
	else if (istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,target) <= 1 && src.reagents.total_volume == max_fuel)
		to_chat(user, "<span class='notice'>The pack is already full!</span>")
		return

/obj/item/weapon/weldpack/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "[reagents.total_volume] units of fuel left!")

/obj/item/weapon/weldpack/M2_fuelback
	name = "M2 Flamethrower backpack."
	desc = "It smells like victory."
	icon_state = "M2_Tank"
	item_state = "M2_Tank"
	var/obj/item/weapon/flamethrower_M2/Connected_Flamethrower = null

/obj/item/weapon/weldpack/M2_fuelback/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
		var/obj/item/weapon/weldingtool/T = I
		if(T.welding)
			message_admins("[key_name_admin(user)] triggered a flamethrower back explosion. [ADMIN_JMP(user)]")
			log_game("[key_name(user)] triggered a flamethrower back explosion.")
			to_chat(user, "<span class='warning'>That was stupid of you.</span>")
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

	if(istype(I, /obj/item/weapon/flamethrower_M2))
		if(src.loc == user)
			if(!Connected_Flamethrower)
				to_chat(user, "You connected your M2 flamethrower to fuel backpack.")
				src.equip(user, I)
			else
				to_chat(user, "Flamethrower allready connected.")
		else
			to_chat(user, "Put on your fuel backpack first.")
		return

	return ..()

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
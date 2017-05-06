//A storage item intended to be used by other items to provide storage functionality.
//Types that use this should consider overriding emp_act() and hear_talk(), unless they shield their contents somehow.
/obj/item/weapon/storage/internal
	var/obj/item/master_item

/obj/item/weapon/storage/internal/New(obj/item/MI)
	master_item = MI
	loc = master_item
	name = master_item.name
	verbs -= /obj/item/verb/verb_pickup	//make sure this is never picked up.
	..()

/obj/item/weapon/storage/internal/Destroy()
	master_item = null
	return ..()

/obj/item/weapon/storage/internal/attack_hand()
	return		//make sure this is never picked up

/obj/item/weapon/storage/internal/mob_can_equip()
	return 0	//make sure this is never picked up

/obj/item/weapon/storage/internal/ClickAccessible(mob/user, depth=1)
	if(loc)
		return loc.ClickAccessible(user, depth)

/obj/item/weapon/storage/internal/Adjacent(A)
	if(loc)
		return loc.Adjacent(A)

//Helper procs to cleanly implement internal storages - storage items that provide inventory slots for other items.
//These procs are completely optional, it is up to the master item to decide when it's storage get's opened by calling open()
//However they are helpful for allowing the master item to pretend it is a storage item itself.
//If you are using these you will probably want to override attackby() as well.
//See /obj/item/clothing/suit/storage for an example.

//items that use internal storage have the option of calling this to emulate default storage MouseDrop behaviour.
//returns 1 if the master item's parent's MouseDrop() should be called, 0 otherwise. It's strange, but no other way of
//doing it without the ability to call another proc's parent, really.
/obj/item/weapon/storage/internal/proc/handle_mousedrop(mob/user, obj/over_object)
	if(!over_object)
		return FALSE

	if (ishuman(user) || ismonkey(user) || isIAN(user)) //so monkeys can take off their backpacks -- Urist

		if (istype(user.loc, /obj/mecha)) // stops inventory actions in a mech
			return FALSE

		if(user.incapacitated())
			return FALSE

		// this must come before the screen objects only block
		if(over_object == user && (src.ClickAccessible(user, depth = STORAGE_VIEW_DEPTH) || Adjacent(user))) // tgstation if(...)
			src.open(user)
			return FALSE

		if (!( istype(over_object, /obj/screen) ))
			return TRUE

		//makes sure master_item is equipped before putting it in hand, so that we can't drag it into our hand from miles away.
		//there's got to be a better way of doing this...
		if (master_item.loc != user || (master_item.loc && master_item.loc.loc == user))
			return FALSE

		switch(over_object.name)
			if("r_hand", "l_hand")
				var/obj/screen/inventory/S = over_object
				if(master_item.un_equip_time && !do_mob(user, user, master_item.un_equip_time, target_slot = master_item.slot_equipped))
					return
				if(!user.dropItemToGround(master_item))
					return FALSE
				if(!isBODYPART(S.master))
					return FALSE
				if(!user.equip_to_slot_if_possible(master_item, S.slot_id))
					return FALSE
		master_item.add_fingerprint(user)
		return TRUE
	return FALSE

//items that use internal storage have the option of calling this to emulate default storage attack_hand behaviour.
//returns 1 if the master item's parent's attack_hand() should be called, 0 otherwise.
//It's strange, but no other way of doing it without the ability to call another proc's parent, really.
/obj/item/weapon/storage/internal/proc/handle_attack_hand(mob/user)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == master_item && !H.get_active_hand())	//Prevents opening if it's in a pocket.
			H.put_in_hands(master_item)
			H.l_store = null
			return 0
		if(H.r_store == master_item && !H.get_active_hand())
			H.put_in_hands(master_item)
			H.r_store = null
			return 0

	src.add_fingerprint(user)
	if (master_item.loc == user)
		src.open(user)
		return 0

	for(var/mob/M in range(1, master_item.loc))
		if (M.s_active == src)
			src.close(M)
	return 1

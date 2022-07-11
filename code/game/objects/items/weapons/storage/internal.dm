//A storage item intended to be used by other items to provide storage functionality.
//Types that use this should consider overriding emp_act() and hear_talk(), unless they shield their contents somehow.
/obj/item/weapon/storage/internal
	var/obj/item/master_item

/obj/item/weapon/storage/internal/atom_init()
	master_item = loc
	name = master_item.name
	verbs -= /obj/item/verb/verb_pickup	//make sure this is never picked up.
	. = ..()

/obj/item/weapon/storage/internal/Destroy()
	master_item = null
	return ..()

/obj/item/weapon/storage/internal/attack_hand()
	return		//make sure this is never picked up

/obj/item/weapon/storage/internal/mob_can_equip()
	return 0	//make sure this is never picked up

//Helper procs to cleanly implement internal storages - storage items that provide inventory slots for other items.
//These procs are completely optional, it is up to the master item to decide when it's storage get's opened by calling open()
//However they are helpful for allowing the master item to pretend it is a storage item itself.
//If you are using these you will probably want to override attackby() as well.
//See /obj/item/clothing/suit/storage for an example.

//items that use internal storage have the option of calling this to emulate default storage MouseDrop behaviour.
//returns 1 if the master item's parent's MouseDrop() should be called, 0 otherwise. It's strange, but no other way of
//doing it without the ability to call another proc's parent, really.
/obj/item/weapon/storage/internal/proc/handle_mousedrop(mob/user, obj/over_object)
	if (istype(over_object, /atom/movable/screen/inventory/hand))
		over_object.MouseDrop_T(master_item, user)
		return FALSE

	if(over_object == user && (ishuman(user) || ismonkey(user))) //so monkeys can take off their backpacks -- Urist

		if(istype(user.loc, /obj/mecha)) // stops inventory actions in a mech
			return FALSE

		if(try_open(user)) // this must come before the screen objects only block
			return FALSE
		
		return TRUE
	return FALSE

//objects that use internal storage have the option of calling this to emulate default storage attack_hand behaviour.
//returns TRUE if the master item's parent's attack_hand() should be called, FALSE otherwise.
//It's strange, but no other way of doing it without the ability to call another proc's parent, really.
/obj/item/weapon/storage/internal/proc/handle_attack_hand(mob/user)
	if(isitem(master_item))
		if(master_item.loc == user)
			add_fingerprint(user)
			open(user)
			return FALSE

		//Prevents opening if it's in a pocket.
		if(ishuman(user))
			var/mob/living/carbon/human/H = user

			if(H.l_store == master_item && !H.get_active_hand())
				add_fingerprint(H)
				H.put_in_hands(master_item)
				H.l_store = null
				return FALSE

			if(H.r_store == master_item && !H.get_active_hand())
				add_fingerprint(H)
				H.put_in_hands(master_item)
				H.r_store = null
				return TRUE

	if(istype(master_item, /obj/structure))
		add_fingerprint(user)
		open(user)
		return FALSE

	return TRUE

/obj/item/weapon/storage/internal/Adjacent(atom/neighbor)
	return master_item.Adjacent(neighbor)

// Used by webbings, coat pockets, etc
/obj/item/weapon/storage/internal/proc/set_slots(slots, slot_size)
	storage_slots = slots
	max_w_class = slot_size
	max_storage_space = storage_slots * base_storage_cost(max_w_class)

/obj/item/weapon/storage/internal/proc/set_space(storage_space)
	max_storage_space = storage_space

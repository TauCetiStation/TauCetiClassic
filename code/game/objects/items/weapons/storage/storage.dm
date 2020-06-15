// To clarify:
// For use_to_pickup and allow_quick_gather functionality,
// see item/attackby() (/game/objects/items.dm)
// Do not remove this functionality without good reason, cough reagent_containers cough.
// -Sayu


/obj/item/weapon/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = ITEM_SIZE_NORMAL
	var/list/can_hold = new/list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = new/list() //List of objects which this item can't store (in effect only if can_hold isn't set)

	var/max_w_class = ITEM_SIZE_SMALL //Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_storage_space = null //Total storage cost of items this can hold. Will be autoset based on storage_slots if left null.
	var/storage_slots = null //The number of storage slots in this container.

	var/use_to_pickup	//Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/display_contents_with_number	//Set this to make the storage item group contents of the same type and display them as a number.
	var/allow_quick_empty	//Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_gather	//Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/collection_mode = 1  //0 = pick one at a time, 1 = pick all on tile
	var/foldable = null	// BubbleWrap - if set, can be folded (when empty) into a sheet of cardboard
	var/list/use_sound // sound played when used. null for no sound.

	var/storage_ui_path = /datum/storage_ui/default
	var/datum/storage_ui/storage_ui = null
	//initializes the contents of the storage with some items based on an assoc list. The assoc key must be an item path,
	//the assoc value can either be the quantity, or a list whose first value is the quantity and the rest are args.
	var/list/startswith

/obj/item/weapon/storage/atom_init()
	. = ..()
	use_sound = SOUNDIN_RUSTLE

	if(allow_quick_empty)
		verbs += /obj/item/weapon/storage/proc/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/weapon/storage/proc/toggle_gathering_mode

	if(isnull(max_storage_space) && !isnull(storage_slots))
		max_storage_space = storage_slots * base_storage_cost(max_w_class)

	if(startswith)
		for(var/item_path in startswith)
			var/list/data = startswith[item_path]
			if(islist(data))
				var/qty = data[1]
				var/list/argsl = data.Copy()
				argsl[1] = src
				for(var/i in 1 to qty)
					new item_path(arglist(argsl))
			else
				for(var/i in 1 to (isnull(data)? 1 : data))
					new item_path(src)
		update_icon()

/obj/item/weapon/storage/Destroy()
	QDEL_NULL(storage_ui)
	return ..()

/obj/item/weapon/storage/MouseDrop(obj/over_object as obj)
	if (ishuman(usr) || ismonkey(usr) || isIAN(usr)) //so monkeys can take off their backpacks -- Urist
		var/mob/M = usr

		if(!over_object)
			return

		if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
			return

		if(over_object == usr && Adjacent(usr)) // this must come before the screen objects only block
			src.open(usr)
			return

		if (!( istype(over_object, /obj/screen) ))
			return ..()

		//makes sure that the storage is equipped, so that we can't drag it into our hand from miles away.
		//there's got to be a better way of doing this.
		if (!(src.loc == usr) || (src.loc && src.loc.loc == usr))
			return

		if (!usr.incapacitated())
			switch(over_object.name)
				if("r_hand")
					if(!M.unEquip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unEquip(src))
						return
					M.put_in_l_hand(src)
				if("mouth")
					if(!M.unEquip(src))
						return
					M.put_in_active_hand(src)
			src.add_fingerprint(usr)
			return
	return


/obj/item/weapon/storage/proc/return_inv()
	var/list/L = list(  )
	L += contents

	for(var/obj/item/weapon/storage/S in src)
		L += S.return_inv()
	return L

/obj/item/weapon/storage/proc/show_to(mob/user as mob)
	if(storage_ui)
		storage_ui.show_to(user)

/obj/item/weapon/storage/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback)
	if(storage_ui)
		storage_ui.close_all()
	return ..()

/obj/item/weapon/storage/proc/hide_from(mob/user as mob)
	if(storage_ui)
		storage_ui.hide_from(user)

/obj/item/weapon/storage/proc/open(mob/user)
	if (length(use_sound))
		playsound(src, pick(use_sound), VOL_EFFECTS_MASTER, null, null, -5)

	prepare_ui()
	storage_ui.on_open(user)
	show_to(user)

/obj/item/weapon/storage/proc/prepare_ui()
	if(!storage_ui)
		storage_ui = new storage_ui_path(src)

	storage_ui.prepare_ui()

/obj/item/weapon/storage/proc/close(mob/user)
	hide_from(user)
	if(storage_ui)
		storage_ui.after_close(user)

/obj/item/weapon/storage/proc/close_all()
	if(storage_ui)
		return storage_ui.close_all()

/obj/item/weapon/storage/proc/storage_space_used()
	. = 0
	for(var/obj/item/I in contents)
		. += I.get_storage_cost()

/*/obj/item/weapon/storage/proc/can_see_contents()
	var/list/cansee = list()
	for(var/mob/M in is_seeing)
		if(M.s_active == src)
			cansee |= M
		else
			is_seeing -= M
	return cansee*/

//This proc return 1 if the item can be picked up and 0 if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/weapon/storage/proc/can_be_inserted(obj/item/W, stop_messages = FALSE)
	if(!istype(W) || (W.flags & ABSTRACT) || W.anchored)
		return FALSE//Not an item

	if(loc == W)
		return FALSE //Means the item is already in the storage item

	if(storage_slots != null && contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[src] is full, make some space.</span>")
		return FALSE //Storage item is full

	if(can_hold.len)
		var/ok = FALSE
		for(var/A in can_hold)
			if(istype(W, A))
				ok = TRUE
				break
		if(!ok)
			if(!stop_messages)
				if (istype(W, /obj/item/weapon/hand_labeler))
					return FALSE
				to_chat(usr, "<span class='notice'>[src] cannot hold [W].</span>")
			return FALSE

	for(var/A in cant_hold) //Check for specific items which this container can't hold.
		if(istype(W, A))
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>[src] cannot hold [W].</span>")
			return FALSE

	if (max_w_class != null && W.w_class > max_w_class)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>[W] is too big for this [src].</span>")
		return FALSE

	if(W.w_class >= src.w_class && (istype(W, /obj/item/weapon/storage)))
		if(!istype(src, /obj/item/weapon/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>[src] cannot hold [W] as it's a storage item of the same size.</span>")
			return FALSE //To prevent the stacking of same sized storage items.

	var/total_storage_space = W.get_storage_cost()
	if(total_storage_space == ITEM_SIZE_NO_CONTAINER)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>\The [W] cannot be placed in [src].</span>")
		return FALSE

	total_storage_space += storage_space_used() //Adds up the combined w_classes which will be in the storage item if the item is added to it.
	if(total_storage_space > max_storage_space)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>\The [src] is too full, make some space.</span>")
		return FALSE

	return TRUE

//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/weapon/storage/proc/handle_item_insertion(obj/item/W, prevent_warning = FALSE, NoUpdate = FALSE)
	if(!istype(W))
		return FALSE
	if(usr)
		usr.remove_from_mob(W)
		usr.update_icons()	//update our overlays
	W.loc = src
	W.on_enter_storage(src)
	if(usr)
		if (usr.client && usr.s_active != src)
			usr.client.screen -= W
		W.dropped(usr)
		add_fingerprint(usr)

		if(!prevent_warning && !istype(W, /obj/item/weapon/gun/energy/crossbow))
			for(var/mob/M in viewers(usr, null))
				if (M == usr)
					to_chat(usr, "<span class='notice'>You put \the [W] into [src].</span>")
				else if (M in range(1)) //If someone is standing close enough, they can tell what it is...
					M.show_message("<span class='notice'>[usr] puts [W] into [src].</span>", SHOWMSG_VISUAL)
				else if (W && W.w_class >= ITEM_SIZE_NORMAL) //Otherwise they can only see large or normal items from a distance...
					M.show_message("<span class='notice'>[usr] puts [W] into [src].</span>", SHOWMSG_VISUAL)
		if(crit_fail && prob(25))
			remove_from_storage(W, get_turf(src))
		if(!NoUpdate)
			update_ui_after_item_insertion()
	update_icon()
	return TRUE

/obj/item/weapon/storage/proc/update_ui_after_item_insertion()
	prepare_ui()
	if(storage_ui)
		storage_ui.on_insertion(usr)

/obj/item/weapon/storage/proc/update_ui_after_item_removal()
	prepare_ui()
	if(storage_ui)
		storage_ui.on_post_remove(usr)

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/weapon/storage/proc/remove_from_storage(obj/item/W, atom/new_location, NoUpdate = FALSE)
	if(!istype(W))
		return FALSE

	if(istype(src, /obj/item/weapon/storage/fancy))
		var/obj/item/weapon/storage/fancy/F = src
		F.update_icon(1)

	if(storage_ui)
		storage_ui.on_pre_remove(usr, W)

	if(new_location)
		if(ismob(loc))
			var/mob/M = loc
			W.dropped(M)
		if(ismob(new_location))
			W.layer = ABOVE_HUD_LAYER
			W.plane = ABOVE_HUD_PLANE
		else
			W.layer = initial(W.layer)
			W.plane = initial(W.plane)
		W.loc = new_location
	else
		W.loc = get_turf(src)

	if(usr && !NoUpdate)
		update_ui_after_item_removal()
	if(W.maptext)
		W.maptext = ""
	W.on_exit_storage(src)
	if(!NoUpdate)
		update_icon()
	return TRUE

//Run once after using remove_from_storage with NoUpdate = 1
/obj/item/weapon/storage/proc/finish_bulk_removal()
	update_ui_after_item_removal()
	update_icon()

//This proc is called when you want to place an item into the storage item.
/obj/item/weapon/storage/attackby(obj/item/I, mob/user, params)
	if(isrobot(user))
		to_chat(user, "<span class='notice'>You're a robot. No.</span>")
		return //Robots can't interact with storage items. FALSE

	if(!can_be_inserted(I))
		return FALSE

	if(istype(I, /obj/item/weapon/implanter/compressed))
		return FALSE

	if(istype(I, /obj/item/weapon/tray))
		var/obj/item/weapon/tray/T = I
		if(T.calc_carry() > 0)
			if(prob(85))
				to_chat(user, "<span class='warning'>The tray won't fit in [src].</span>")
				return FALSE
			else
				I.forceMove(user.loc)
				if(user.client && user.s_active != src)
					user.client.screen -= I
				I.dropped(user)
				to_chat(user, "<span class='warning'>God damnit!</span>")
			return

	if(istype(I, /obj/item/weapon/packageWrap) && !(src in user)) //prevents package wrap being put inside the backpack when the backpack is not being worn/held (hence being wrappable)
		return FALSE

	I.add_fingerprint(user)
	handle_item_insertion(I)
	return TRUE

/obj/item/weapon/storage/dropped(mob/user)
	return

/obj/item/weapon/storage/attack_hand(mob/user)
	if (src.loc == user)
		src.open(user)
	else
		..()
		if(storage_ui)
			storage_ui.on_hand_attack(user)
	src.add_fingerprint(user)

//Should be merged into attack_hand() later, i mean whole attack_paw() proc, but thats probably a lot of work.
/obj/item/weapon/storage/attack_paw(mob/user) // so monkey, ian or something will open it, istead of unequip from back
	return attack_hand(user)                  // to unequip - there is drag n drop available for this task - same as humans do.

/obj/item/weapon/storage/proc/gather_all(var/turf/T, var/mob/user)
	var/success = 0
	var/failure = 0

	for(var/obj/item/I in T)
		if(!can_be_inserted(I, user, 0))	// Note can_be_inserted still makes noise when the answer is no
			failure = 1
			continue
		success = 1
		handle_item_insertion(I, TRUE, TRUE) // First 1 is no messages, second 1 is no ui updates
	if(success && !failure)
		to_chat(user, "<span class='notice'>You put everything into \the [src].</span>")
		update_ui_after_item_insertion()
	else if(success)
		to_chat(user, "<span class='notice'>You put some things into \the [src].</span>")
		update_ui_after_item_insertion()
	else
		to_chat(user, "<span class='notice'>You fail to pick anything up with \the [src].</span>")

/obj/item/weapon/storage/proc/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	collection_mode = !collection_mode
	switch (collection_mode)
		if(1)
			to_chat(usr, "[src] now picks up all items in a tile at once.")
		if(0)
			to_chat(usr, "[src] now picks up one item at a time.")


/obj/item/weapon/storage/proc/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (src.loc != usr)) || usr.incapacitated())
		return

	var/turf/T = get_turf(src)
	hide_from(usr)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T, NoUpdate = TRUE)
	finish_bulk_removal()

/obj/item/weapon/storage/emp_act(severity)
	if(!istype(src.loc, /mob/living))
		for(var/obj/O in contents)
			O.emplode(severity)
	..()

// BubbleWrap - A box can be folded up to make card
/obj/item/weapon/storage/attack_self(mob/user)

	//Clicking on itself will empty it, if it has the verb to do that.
	if(user.get_active_hand() == src)
		if(src.verbs.Find(/obj/item/weapon/storage/proc/quick_empty))
			src.quick_empty()
			return

	//Otherwise we'll try to fold it.
	if ( contents.len )
		return

	if ( !ispath(src.foldable) )
		return
	var/found = 0
	// Close any open UI windows first
	for(var/mob/M in range(1))
		if (M.s_active == src)
			src.close(M)
		if ( M == user )
			found = 1
	if ( !found )	// User is too far away
		return
	// Now make the cardboard
	to_chat(user, "<span class='notice'>You fold [src] flat.</span>")
	new src.foldable(get_turf(src))
	qdel(src)
//BubbleWrap END

/obj/item/weapon/storage/hear_talk(mob/M, text, verb, datum/language/speaking)
	for (var/atom/A in src)
		if(istype(A,/obj))
			var/obj/O = A
			O.hear_talk(M, text, verb, speaking)

/obj/item/weapon/storage/proc/make_exact_fit(use_slots = FALSE)
	if(use_slots)
		storage_slots = contents.len
	else
		storage_slots = null

	can_hold.Cut()
	max_w_class = 0
	max_storage_space = 0
	for(var/obj/item/I in src)
		var/type_ = I.type
		if(!(type_ in can_hold))
			can_hold += type_
		max_w_class = max(I.w_class, max_w_class)
		max_storage_space += I.get_storage_cost()

//Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area).
//Returns -1 if the atom was not found on container.
/atom/proc/storage_depth(atom/container)
	var/depth = 0
	var/atom/cur_atom = src

	while (cur_atom && !(cur_atom in container.contents))
		if (isarea(cur_atom))
			return -1
		if (istype(cur_atom.loc, /obj/item/weapon/storage))
			depth++
		cur_atom = cur_atom.loc

	if (!cur_atom)
		return -1	//inside something with a null loc.

	return depth

//Like storage depth, but returns the depth to the nearest turf
//Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
/atom/proc/storage_depth_turf()
	var/depth = 0
	var/atom/cur_atom = src

	while (cur_atom && !isturf(cur_atom))
		if (isarea(cur_atom))
			return -1
		if (istype(cur_atom.loc, /obj/item/weapon/storage))
			depth++
		cur_atom = cur_atom.loc

	if (!cur_atom)
		return -1	//inside something with a null loc.

	return depth

/obj/item/weapon/storage/handle_atom_del(atom/A)
	if(A in contents)
		usr = null
		remove_from_storage(A, loc)

/obj/item/proc/get_storage_cost()
	//If you want to prevent stuff above a certain w_class from being stored, use max_w_class
	return base_storage_cost(w_class)

// Useful for spilling the contents of containers all over the floor.
/obj/item/weapon/storage/proc/spill(dist = 2, turf/T = null)
	if (!istype(T))
		T = get_turf(src)

	for(var/obj/O in contents)
		remove_from_storage(O, T)
		INVOKE_ASYNC(O, /obj.proc/tumble_async, 2)

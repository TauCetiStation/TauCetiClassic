// To clarify:
// For use_to_pickup and allow_quick_gather functionality,
// see item/attackby() (/game/objects/items.dm)
// Do not remove this functionality without good reason, cough reagent_containers cough.
// -Sayu


/obj/item/weapon/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	flags = HEAR_TALK
	w_class = SIZE_SMALL
	var/list/can_hold = list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = list() //List of objects which this item can't store (in effect only if can_hold isn't set)

	var/max_w_class = SIZE_TINY //Max size of objects that this object can store (in effect only if can_hold isn't set)
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
			var/quantity = startswith[item_path] || 1
			for(var/num in 1 to quantity)
				new item_path(src)

		update_icon() // todo: some storages that use content as overlays can have problems with world_icons, need to fix it in the furure while adding new world_icons (donut_box and donuts, crayons and crayon box, etc.)

/obj/item/weapon/storage/Destroy()
	QDEL_NULL(storage_ui)
	return ..()

/obj/item/weapon/storage/MouseDrop(obj/over_object, src_location, turf/over_location)
	if(src != over_object)
		remove_outline()
	if(!(ishuman(usr) || ismonkey(usr) || isIAN(usr))) //so monkeys can take off their backpacks -- Urist
		return
	if (istype(usr.loc, /obj/mecha)) // stops inventory actions in a mech
		return

	var/mob/M = usr
	add_fingerprint(M)
	if(isturf(over_location) && over_object != M)
		if(M.incapacitated())
			return
		if(slot_equipped && (slot_equipped != SLOT_L_HAND && slot_equipped != SLOT_R_HAND))
			return
		if(!isturf(M.loc))
			return
		if(istype(src, /obj/item/weapon/storage/lockbox))
			var/obj/item/weapon/storage/lockbox/L = src
			if(L.locked)
				return
		if(istype(loc, /obj/item/weapon/storage)) //Prevent dragging /storage contents from backpack on floor.
			return
		if(M.a_intent == INTENT_HELP)
			var/dir_target = get_dir(M.loc, over_location)
			M.SetNextMove(CLICK_CD_MELEE)
			for(var/obj/item/I in contents)
				if(M.is_busy())
					return
				if(!Adjacent(M) || !over_location.Adjacent(src) || !over_location.Adjacent(M))
					return
				if(!do_after(M, 2, target = M))
					return
				remove_from_storage(I, M.loc)
				I.add_fingerprint(M)
				step(I, dir_target)
		return

	if(!over_object)
		return
	if(over_object == usr) // this must come before the screen objects only block
		try_open(usr)
		return

	return ..()

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
		playsound(src, pick(use_sound), VOL_EFFECTS_MASTER, null, FALSE, null, -5)

	prepare_ui()
	storage_ui.on_open(user)
	show_to(user)

// Returns TRUE if user can open the storage and opens it. Returns FALSE otherwise.
/obj/item/weapon/storage/proc/try_open(mob/user)
	if(!user)
		return FALSE
	if(!user.in_interaction_vicinity(src))
		return FALSE

	open(user)
	return TRUE

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
				if(istagger(W))
					return FALSE
				to_chat(usr, "<span class='notice'>[src] cannot hold [W].</span>")
			return FALSE

	for(var/A in cant_hold) //Check for specific items which this container can't hold.
		if(istype(W, A))
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>[src] cannot hold [W].</span>")
			return FALSE

	if (W.flags_2 & CANT_BE_INSERTED)
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

	// by design SIZE_LARGE can't be placed in storages
	// and now this check works correctly
	if(W.w_class >= SIZE_LARGE)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>\The [W] cannot be placed in [src].</span>")
		return FALSE

	var/total_storage_space = W.get_storage_cost()
	total_storage_space += storage_space_used() //Adds up the combined w_classes which will be in the storage item if the item is added to it.
	if(total_storage_space > max_storage_space)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>\The [src] is too full, make some space.</span>")
		return FALSE

	return TRUE

// low level proc just to handle Move/ForceMove
/obj/item/weapon/storage/Entered(obj/item/mover)
	. = ..()

	if(istype(mover))
		mover.on_enter_storage(src)

// Handles item insertion with related events and user feedback.
// It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
// The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
// such as when picking up all the items on a tile with one click.
/obj/item/weapon/storage/proc/handle_item_insertion(obj/item/W, prevent_warning = FALSE, NoUpdate = FALSE)
	if(!istype(W))
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_STORAGE_ENTERED, W, prevent_warning, NoUpdate) & COMSIG_STORAGE_PROHIBIT)
		return

	if(usr && W.loc == usr)
		usr.remove_from_mob(W, src)
	else
		W.forceMove(src)

	if(usr)
		add_fingerprint(usr)

		if(!(prevent_warning || istype(W, /obj/item/weapon/gun/energy/crossbow)))
			//If someone is standing close enough or item is larger than TINY, they can tell what it is...
			usr.visible_message(
				"<span class='notice'>[usr] puts [W] into [src].</span>",
				"<span class='notice'>You put \the [W] into [src].</span>",
				viewing_distance = (W.w_class > SIZE_TINY ? world.view : 1)
				)
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

	SEND_SIGNAL(src, COMSIG_STORAGE_EXITED, W, new_location, NoUpdate)

	if(new_location)
		if(ismob(loc))
			var/mob/M = loc
			W.dropped(M)
		if(ismob(new_location))
			W.plane = ABOVE_HUD_PLANE
		else
			W.layer = initial(W.layer)
			W.plane = initial(W.plane)
		W.Move(new_location)
	else
		W.Move(get_turf(src))

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

	if((istype(I, /obj/item/weapon/packageWrap) || istagger(I)) && !(src in user)) //prevents package wrap being put inside the backpack when the backpack is not being worn/held (hence being wrappable)
		return FALSE

	I.add_fingerprint(user)
	handle_item_insertion(I)
	return TRUE

/obj/item/weapon/storage/dropped(mob/user)
	..()
	return

/obj/item/weapon/storage/attack_hand(mob/user)
	add_fingerprint(user)
	if(loc == user)
		open(user)
	else
		..()
		if(storage_ui)
			storage_ui.on_hand_attack(user)

/obj/item/weapon/storage/AltClick(mob/user)
	add_fingerprint(user)
	if(try_open(user))
		return
	return ..(user)

//Should be merged into attack_hand() later, i mean whole attack_paw() proc, but thats probably a lot of work.
/obj/item/weapon/storage/attack_paw(mob/user) // so monkey, ian or something will open it, istead of unequip from back
	return attack_hand(user)                  // to unequip - there is drag n drop available for this task - same as humans do.

/obj/item/weapon/storage/proc/gather_all(turf/T, mob/user)
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

	if(HAS_TRAIT(src, TRAIT_UNDERFLOOR) && T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		return

	hide_from(usr)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T, NoUpdate = TRUE)
	finish_bulk_removal()

/obj/item/weapon/storage/emp_act(severity)
	if(!isliving(src.loc))
		for(var/obj/O in contents)
			O.emplode(severity)
	..()

// BubbleWrap - A box can be folded up to make card
/obj/item/weapon/storage/attack_self(mob/user)

	//Clicking on itself will empty it, if it has the verb to do that.
	if(user.get_active_hand() == src)
		if(verbs.Find(/obj/item/weapon/storage/proc/quick_empty))
			quick_empty()
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
			close(M)
		if ( M == user )
			found = 1
	if ( !found )	// User is too far away
		return
	// Now make the cardboard
	to_chat(user, "<span class='notice'>You fold [src] flat.</span>")
	new foldable(get_turf(src))
	qdel(src)
//BubbleWrap END

/obj/item/weapon/storage/hear_talk(mob/M, text, verb, datum/language/speaking)
	for (var/atom/A in src) // todo: we need it? say() should already catch all objects recursively
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
	if(A.loc == src)
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
		INVOKE_ASYNC(O, TYPE_PROC_REF(/obj, tumble_async), 2)

/obj/item/weapon/storage/proc/make_empty(delete = TRUE)
	var/turf/T = get_turf(src)
	for(var/A in contents)
		if(delete)
			qdel(A)
		else
			remove_from_storage(A, T)

//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	if(is_busy(src, slot, TRUE))
		return
	var/obj/item/W = get_active_hand()
	if(istype(W))
		//if(isIAN(src))
		//	switch(slot)
		//		if(slot_head, slot_back)
		//			to_chat(src, "<span class='notice'>You have no idea how humans do this.</span>")
		//			return
		if (istype(W, /obj/item/clothing))
			var/obj/item/clothing/C = W
			if(C.rig_restrict_helmet)
				to_chat(src, "<span class='red'>You must fasten the helmet to a hardsuit first. (Target the head)</span>")// Stop eva helms equipping.
			else
				if(W.un_equip_time && !do_mob(src, src, W.un_equip_time, target_slot = slot))
					return
				//if(C.equip_time > 0)
				//	delay_clothing_equip_to_slot_if_possible(C, slot)
				//else
				//	equip_to_slot_if_possible(C, slot)
				equip_to_slot_if_possible(C, slot)
		else
			equip_to_slot_if_possible(W, slot)
		src.next_move = world.time + 6

/mob/proc/put_in_any_hand_if_possible(obj/item/W, del_on_fail = 0, disable_warning = 1, redraw_mob = 1)
	if(equip_to_slot_if_possible(W, slot_l_hand, del_on_fail, disable_warning, redraw_mob))
		return 1
	else if(equip_to_slot_if_possible(W, slot_r_hand, del_on_fail, disable_warning, redraw_mob))
		return 1
	return 0

//This is a SAFE proc. Use this instead of equip_to_slot()!
//set del_on_fail to have it delete W if it fails to equip
//set disable_warning to disable the 'you are unable to equip that' warning.
//unset redraw_mob to prevent the mob from being redrawn at the end.
/mob/proc/equip_to_slot_if_possible(obj/item/W, slot, del_on_fail = 0, disable_warning = 0, redraw_mob = 1)
	if(!istype(W))
		return FALSE

	return W.equip_to_slot_if_possible(src, get_BP_by_slot(slot), slot, del_on_fail, disable_warning, redraw_mob)

/obj/item/bodypart/equip_to_slot_if_possible(mob/user, obj/item/W, slot, del_on_fail = 0, disable_warning = 0, redraw_mob = 1)
	if(!istype(W))
		return FALSE

	return W.equip_to_slot_if_possible(user, src, slot, del_on_fail, disable_warning, redraw_mob)

/obj/item/proc/equip_to_slot_if_possible(mob/user, obj/item/bodypart/BP, slot, del_on_fail = 0, disable_warning = 0, redraw_mob = 1)
	if(!limb_can_equip(BP, slot, disable_warning))
		if(del_on_fail)
			qdel(src)
		else
			if(!disable_warning && user)
				to_chat(user, "<span class='red'>You are unable to equip that.</span>")//Only print if del_on_fail is false
		return FALSE

	if(slot == slot_in_backpack && user) // Mostly used by datum/job/equip() proc. Also, this slot in reality does not exist, its just a shortcut for special inventory (backpack) manipulation.
		var/obj/item/backpack = user.get_equipped_item(slot_back)
		if(backpack)
			loc = backpack
			return TRUE
		else
			return FALSE

	equip_to_slot(BP, slot, redraw_mob) //This proc should not ever fail.
	return TRUE

//This is an UNSAFE proc. It merely handles the actual job of equipping. All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
//In most cases you will want to use equip_to_slot_if_possible()
/mob/proc/equip_to_slot(obj/item/W, slot)
	return

//This is just a commonly used configuration for the equip_to_slot_if_possible() proc, used to equip people when the rounds tarts and when events happen and such.
/mob/proc/equip_to_slot_or_del(obj/item/W, slot)
	return equip_to_slot_if_possible(W, slot, 1, 1, 0)

//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
var/list/slot_equipment_priority = list( \
		slot_back,\
		slot_wear_id,\
		slot_w_uniform,\
		slot_wear_suit,\
		slot_wear_mask,\
		slot_head,\
		slot_shoes,\
		slot_gloves,\
		slot_l_ear,\
		slot_r_ear,\
		slot_glasses,\
		slot_belt,\
		slot_s_store,\
		slot_l_store,\
		slot_r_store\
	)

//puts the item "W" into an appropriate slot in a human's inventory
//returns 0 if it cannot, 1 if successful
/mob/proc/equip_to_appropriate_slot(obj/item/W)
	if(!istype(W)) return 0

	for(var/slot in slot_equipment_priority)
		if(equip_to_slot_if_possible(W, slot, del_on_fail=0, disable_warning=1, redraw_mob=1))
			return 1

	return 0

// Convinience proc.  Collects crap that fails to equip either onto the mob's back, or drops it.
// Used in job equipping so shit doesn't pile up at the start loc.
/mob/living/carbon/human/proc/equip_or_collect(obj/item/W, slot)
	if(W.mob_can_equip(src, slot, 1))
		//Mob can equip.  Equip it.
		equip_to_slot_or_del(W, slot)
	else
		//Mob can't equip it.  Put it in a bag B.
		// Do I have a backpack?
		var/obj/item/weapon/storage/B
		if(istype(back,/obj/item/weapon/storage))
			//Mob is wearing backpack
			B = back
		else
			//not wearing backpack.  Check if player holding plastic bag
			B=is_in_hands(/obj/item/weapon/storage/bag/plasticbag)
			if(!B) //If not holding plastic bag, give plastic bag
				B=new /obj/item/weapon/storage/bag/plasticbag(null) // Null in case of failed equip.
				if(!put_in_hands(B))
					return // Bag could not be placed in players hands.  I don't know what to do here...
		//Now, B represents a container we can insert W into.
		B.handle_item_insertion(W,1)
		return B


//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting l_hand = ...etc
//as they handle all relevant stuff like adding it to the player's screen and updating their overlays.

//Returns the thing in our active hand


//Returns the thing in our active hand
/mob/proc/get_active_hand()
	return

//Returns the thing in our inactive hand
/mob/proc/get_inactive_hand()
	return

/mob/living/carbon/var/obj/item/bodypart/active_hand = null
/mob/living/carbon/var/list/inactive_hands = list()

/mob/living/carbon/get_active_hand()
	if(active_hand)
		if(active_hand.inv_box_data && active_hand.inv_box_data.len)
			return active_hand.item_in_slot[active_hand.inv_box_data[1]]

//	if(hand)	return l_hand
//	else		return r_hand

/mob/living/carbon/get_inactive_hand()
	if(inactive_hands.len)
		for(var/obj/item/bodypart/BP in inactive_hands)
			if(BP.inv_box_data && BP.inv_box_data.len)
				return BP.item_in_slot[BP.inv_box_data[1]]

//	if(hand)	return r_hand
//	else		return l_hand

//Checks if thing in mob's hands
/mob/living/carbon/proc/is_in_hands(typepath)
	for(var/obj/item/bodypart/BP in bodypart_hands)
		if(BP.item_in_slot.len)
			var/obj/item/I = BP.item_in_slot[BP.item_in_slot[1]]
			if(istype(I, typepath))
				return I
	return null

//Puts the item into our active hand if possible. returns 1 on success.
/mob/proc/put_in_active_hand(obj/item/W)
	return

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/proc/put_in_inactive_hand(obj/item/W)
	return

/mob/living/carbon/put_in_active_hand(obj/item/W)
	if(!active_hand)
		return
	var/obj/item/bodypart/BP = active_hand
	var/slot_hand = BP.inv_slots_data[1]
	return equip_to_slot_if_possible(W, slot_hand)

/mob/living/carbon/put_in_inactive_hand(obj/item/W)
	if(!inactive_hands.len)
		return

	for(var/obj/item/bodypart/BP in inactive_hands)
		if(BP.item_in_slot.len)
			var/obj/item/I = BP.item_in_slot[BP.item_in_slot[1]]
			if(!I)
				return equip_to_slot_if_possible(W, BP.item_in_slot[1])

//Puts the item our active hand if possible. Failing that it tries our inactive hand. Returns 1 on success.
//If both fail it drops it on the floor and returns 0.
//This is probably the main one you need to know :)
/mob/proc/put_in_hands(obj/item/W)
	return

/mob/living/carbon/put_in_hands(obj/item/W)
	if(!W)
		return FALSE
	if(put_in_active_hand(W))
		return TRUE
	else if(put_in_inactive_hand(W))
		return TRUE
	else
		W.forceMove(loc)
		W.layer = initial(W.layer)
		W.plane = initial(W.plane)
		W.appearance_flags = 0
		W.dropped(src)
		return FALSE

//Drops the item in our left hand
/mob/proc/drop_l_hand(atom/Target)
	return

//Drops the item in our right hand
/mob/proc/drop_r_hand(atom/Target)
	return

/mob/living/carbon/drop_l_hand()
	return dropItemToGround(l_hand)

/mob/living/carbon/drop_r_hand()
	return dropItemToGround(r_hand)

//Drops the item in our active hand.
/mob/proc/drop_item(atom/Target)
	return

/mob/living/carbon/drop_item()
	if(!loc)
		return
	return dropItemToGround(get_active_hand())

/*
	Removes the object from any slots the mob might have, calling the appropriate icon update proc.
	Does nothing else.

	DO NOT CALL THIS PROC DIRECTLY. It is meant to be called only by other inventory procs.
	It's probably okay to use it if you are transferring the item between slots on the same mob,
	but chances are you're safer calling remove_from_mob() or drop_from_inventory() anyways.

	As far as I can tell the proc exists so that mobs with different inventory slots can override
	the search through all the slots, without having to duplicate the rest of the item dropping.
*/

/mob/proc/u_equip()
	return

/obj/item/proc/u_equip() // this proc is only for cleaning references and updating mob/bodypart overlays.
	if(!slot_bodypart)
		return

	slot_bodypart.unequip_chain(slot_equipped)
	slot_bodypart.item_in_slot[slot_equipped] = null
	slot_bodypart.update_inv_limb(slot_equipped)
	slot_equipped = null
	slot_bodypart = null
	screen_loc = null

//The following functions are the same save for one small difference

//for when you want the item to end up on the ground
//will force move the item to the ground and call the turf's Entered
/mob/proc/dropItemToGround(obj/item/I, force = FALSE)
	return remove_from_mob(I, force, loc, FALSE)

/mob/proc/dropSlotToGround(slot, force = FALSE)
	return remove_from_mob(get_equipped_item(slot), force, loc, FALSE)

//for when the item will be immediately placed in a loc other than the ground
/mob/proc/transferItemToLoc(obj/item/I, newloc = null, force = FALSE)
	return remove_from_mob(I, force, newloc, FALSE)

//visibly unequips I but it is NOT MOVED AND REMAINS IN SRC
//item MUST BE FORCEMOVE'D OR QDEL'D
/mob/proc/temporarilyRemoveItemFromInventory(obj/item/I, force = FALSE)
	return remove_from_mob(I, force, null, TRUE)

//DO NOT CALL THIS PROC
//use one of the above 3 helper procs
//you may override it, but do not modify the args
/mob/proc/remove_from_mob(obj/item/I, force, newloc, no_move)
	if(!I) // If there's nothing to drop, the drop is automatically successful.
		return TRUE

	return I.remove_from(force, newloc, no_move, src)

/obj/item/proc/remove_from(force, newloc, no_move, mob/user)
	if(!force)
		if(!canremove)
			return FALSE
		if(slot_bodypart)
			var/list/obscured = slot_bodypart.check_obscured_slots()
			if(obscured && obscured[slot_equipped])
				return FALSE

	u_equip()

	if(user && user.client)
		user.client.screen -= src
	layer = initial(layer)
	plane = initial(plane)
	appearance_flags = 0
	if(!no_move && !(flags & DROPDEL)) // item may be moved/qdel'd immedietely, don't bother moving it
		forceMove(newloc)
	dropped(user)
	return TRUE

//Returns the item equipped to the specified slot, if any.
/mob/proc/get_equipped_item(slot)
	return null

/mob/living/carbon/get_equipped_item(slot)
	var/obj/item/bodypart/BP = get_BP_by_slot(slot)
	if(!BP)
		return

	return BP.item_in_slot[slot]

/mob/proc/get_equipped_items()
	return null

/mob/living/carbon/get_equipped_items(include_pockets = TRUE, include_hands = TRUE)
	var/list/items = list()
	var/list/pocket_slots = list(slot_l_store, slot_r_store) // pockets should be moved inside uniform itself.
	var/list/hand_slots = list(slot_l_hand, slot_r_hand)
	if(include_pockets)
		pocket_slots.Cut()
	if(include_hands)
		hand_slots.Cut()

	for(var/obj/item/bodypart/BP in bodyparts)
		for(var/slot in BP.item_in_slot - pocket_slots - hand_slots)
			if(BP.item_in_slot[slot])
				items += BP.item_in_slot[slot]

	if(items.len)
		return items
	else
		return null

/mob/living/carbon/proc/check_obscured_slots()
	var/list/obscured = list()

	var/list/items = get_equipped_items()
	for(var/obj/item/I in items)
		obscured += I.return_obscured_slots()

	if(obscured.len)
		return obscured
	else
		return null

/obj/item/bodypart/proc/check_obscured_slots()
	var/list/obscured = list()

	for(var/slot in item_in_slot)
		var/obj/item/I = item_in_slot[slot]
		if(I)
			obscured += I.return_obscured_slots()

	if(obscured.len)
		return obscured
	else
		return null

/obj/item/proc/return_obscured_slots()
	var/list/obscured = list()

	switch(slot_equipped)
		if(slot_wear_suit)
			if(flags_inv & HIDEGLOVES)
				obscured[slot_gloves] = TRUE
			if(flags_inv & HIDEJUMPSUIT)
				obscured[slot_w_uniform] = TRUE
				obscured[slot_undershirt] = TRUE
				obscured[slot_underwear] = TRUE
			if(flags_inv & HIDESHOES)
				obscured[slot_shoes] = TRUE
				obscured[slot_socks] = TRUE

		if(slot_w_uniform)
			obscured[slot_undershirt] = TRUE
			obscured[slot_underwear] = TRUE

		if(slot_shoes)
			obscured[slot_socks] = TRUE

		if(slot_head)
			if(flags_inv & HIDEMASK)
				obscured[slot_wear_mask] = TRUE
			if(flags_inv & HIDEEYES)
				obscured[slot_glasses] = TRUE
			if(flags_inv & HIDEEARS)
				obscured[slot_l_ear] = TRUE
				obscured[slot_r_ear] = TRUE
			if(flags_inv & HIDEFACE)
				obscured["hideface"] = TRUE

		if(slot_wear_mask)
			if(flags_inv & HIDEMASK)
				obscured[slot_wear_mask] = TRUE
			if(flags_inv & HIDEFACE)
				obscured["hideface"] = TRUE

	if(body_parts_covered)
		obscured["flags"] |= body_parts_covered

	return obscured

/mob/proc/get_item_by_slot(slot_id)
	return

/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null

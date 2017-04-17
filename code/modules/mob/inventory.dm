//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
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
				//if(C.equip_time > 0)
				//	delay_clothing_equip_to_slot_if_possible(C, slot)
				//else
				//	equip_to_slot_if_possible(C, slot)
				equip_to_slot_if_possible(C, slot)
		else
			equip_to_slot_if_possible(W, slot)

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
	if(!istype(W)) return 0

	if(!W.mob_can_equip(src, slot, disable_warning))
		if(del_on_fail)
			qdel(W)
		else
			if(!disable_warning)
				to_chat(src, "<span class='red'>You are unable to equip that.</span>")//Only print if del_on_fail is false
		return 0

	equip_to_slot(W, slot, redraw_mob) //This proc should not ever fail.
	return 1

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
	if(istype(l_hand,typepath))
		return l_hand
	if(istype(r_hand,typepath))
		return r_hand
	return 0

//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(obj/item/W)
	return

//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(obj/item/W)
	return

/*
/mob/living/carbon/put_in_l_hand(obj/item/W)
	if(lying && !(W.flags&ABSTRACT))
		return 0
	if(!istype(W))
		return 0
	if(W.anchored)
		return 0 // Anchored things shouldn't be picked up because they... anchored?!
	if(!iscarbon(src)) // TODO actual hands check?
		return FALSE

	if(!l_hand)
		W.loc = src		//TODO: move to equipped?
		l_hand = W
		W.layer = ABOVE_HUD_LAYER	//TODO: move to equipped?
		W.plane = ABOVE_HUD_PLANE
		W.appearance_flags = APPEARANCE_UI
//		l_hand.screen_loc = ui_lhand
		W.equipped(src,slot_l_hand)
		if(client)	client.screen |= W
		if(pulling == W) stop_pulling()
		update_inv_l_hand()
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
		return 1
	return 0

/mob/living/carbon/put_in_r_hand(obj/item/W)
	if(lying && !(W.flags&ABSTRACT))
		return 0
	if(!istype(W))
		return 0
	if(W.anchored)
		return 0 // Anchored things shouldn't be picked up because they... anchored?!
	if(!iscarbon(src)) // TODO actual hands check?
		return FALSE

	if(!r_hand)
		W.loc = src
		r_hand = W
		W.layer = ABOVE_HUD_LAYER
		W.plane = ABOVE_HUD_PLANE
		W.appearance_flags = APPEARANCE_UI
//		r_hand.screen_loc = ui_rhand
		W.equipped(src,slot_r_hand)
		if(client)	client.screen |= W
		if(pulling == W) stop_pulling()
		update_inv_r_hand()
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
		return 1
	return 0*/

//Puts the item into our active hand if possible. returns 1 on success.
/mob/proc/put_in_active_hand(obj/item/W)
	return

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/proc/put_in_inactive_hand(obj/item/W)
	return

/mob/living/carbon/put_in_active_hand(obj/item/W)
	var/obj/item/bodypart/BP = active_hand
	var/slot_hand = BP.inv_slots_data[1]
	return equip_to_slot_if_possible(W, slot_hand)

	//if(hand)	return put_in_l_hand(W)
	//else		return put_in_r_hand(W)

/mob/living/carbon/put_in_inactive_hand(obj/item/W)
	if(hand)	return put_in_r_hand(W)
	else		return put_in_l_hand(W)

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
/mob/proc/u_equip(obj/W)
	return

/mob/living/carbon/u_equip(obj/W) // this proc is only for cleaning references and updating mob/bodypart overlays.
	if(!W || !W.slot_bodypart)
		return

	var/obj/item/bodypart/BP = get_bodypart(W.slot_bodypart)
	BP.unequip_chain(W.slot_equipped)
	BP.item_in_slot[W.slot_equipped] = null
	BP.update_inv_limb(W.slot_equipped)
	W.slot_equipped = null
	W.slot_bodypart = null
	W.screen_loc = null

//The following functions are the same save for one small difference

//for when you want the item to end up on the ground
//will force move the item to the ground and call the turf's Entered
/mob/proc/dropItemToGround(obj/item/I, force = FALSE)
	return remove_from_mob(I, force, loc, FALSE)

/mob/living/carbon/proc/dropSlotToGround(slot, force = FALSE)
	return remove_from_mob(get_item_in_bodypart_slot(slot), force, loc, FALSE)

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

	if(!I.canremove && !force)
		return FALSE

	u_equip(I)

	if (client)
		client.screen -= I
	I.layer = initial(I.layer)
	I.plane = initial(I.plane)
	I.appearance_flags = 0
	if(!no_move && !(I.flags & DROPDEL)) // item may be moved/qdel'd immedietely, don't bother moving it
		I.forceMove(newloc)
	I.dropped(src)
	return TRUE

//Returns the item equipped to the specified slot, if any.
/mob/proc/get_equipped_item(slot)
	return null

/mob/living/carbon/get_equipped_item(slot)
	switch(slot)
		if(slot_back)       return back
		if(slot_handcuffed) return handcuffed
		if(slot_l_store)    return l_store
		if(slot_r_store)    return r_store
		if(slot_wear_mask)  return wear_mask
		if(slot_l_hand)     return l_hand
		if(slot_r_hand)     return r_hand
		if(slot_wear_id)    return wear_id
		if(slot_glasses)    return glasses
		if(slot_gloves)     return gloves
		if(slot_head)       return head
		if(slot_shoes)      return shoes
		if(slot_belt)       return belt
		if(slot_wear_suit)  return wear_suit
		if(slot_w_uniform)  return w_uniform
		if(slot_s_store)    return s_store
		if(slot_l_ear)      return l_ear
		if(slot_r_ear)      return r_ear
	return null

/mob/proc/get_equipped_items()
	return list()

/mob/living/carbon/get_equipped_items()
	var/list/items = list()

	if(back)      items += back
	if(belt)      items += belt
	if(l_ear)     items += l_ear
	if(r_ear)     items += r_ear
	if(glasses)   items += glasses
	if(gloves)    items += gloves
	if(head)      items += head
	if(shoes)     items += shoes
	if(wear_id)   items += wear_id
	if(wear_mask) items += wear_mask
	if(wear_suit) items += wear_suit
	if(w_uniform) items += w_uniform
	if(l_hand)    items += l_hand
	if(r_hand)    items += r_hand

	return items

//Create delay for equipping
/mob/proc/delay_clothing_u_equip(obj/item/clothing/C) // Bone White - delays unequipping by parameter.  Requires W to be /obj/item/clothing/
	return

/mob/living/carbon/delay_clothing_u_equip(obj/item/clothing/C)
	if(!istype(C)) return 0

	if(C.equipping) return 0 // Item is already being (un)equipped

	var/tempX = usr.x
	var/tempY = usr.y
	to_chat(usr, "<span class='notice'>You start unequipping the [C].</span>")
	C.equipping = 1
	var/equip_time = round(C.equip_time/10)
	var/i
	for(i=1; i<=equip_time; i++)
		sleep (10) // Check if they've moved every 10 time units
		if ((tempX != usr.x) || (tempY != usr.y))
			to_chat(src, "<span class='red'>\The [C] is too fiddly to unequip whilst moving.</span>")
			C.equipping = 0
			return 0
	remove_from_mob(C)
	to_chat(usr, "<span class='notice'>You have finished unequipping the [C].</span>")
	C.equipping = 0

/mob/proc/delay_clothing_equip_to_slot_if_possible(obj/item/clothing/C, slot, del_on_fail = 0, disable_warning = 0, redraw_mob = 1, delay_time = 0)
	return

/mob/living/carbon/delay_clothing_equip_to_slot_if_possible(obj/item/clothing/C, slot, del_on_fail = 0, disable_warning = 0, redraw_mob = 1, delay_time = 0)
	if(!istype(C)) return 0

	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.wear_suit)
			to_chat(H, "<span class='red'>You need to take off [H.wear_suit.name] first.</span>")
			return

	if(C.equipping) return 0 // Item is already being equipped

	var/tempX = usr.x
	var/tempY = usr.y
	to_chat(usr, "<span class='notice'>You start equipping the [C].</span>")
	C.equipping = 1
	var/equip_time = round(C.equip_time/10)
	var/i
	for(i=1; i<=equip_time; i++)
		sleep (10) // Check if they've moved every 10 time units
		if ((tempX != usr.x) || (tempY != usr.y))
			to_chat(src, "<span class='red'>\The [C] is too fiddly to fasten whilst moving.</span>")
			C.equipping = 0
			return 0
	equip_to_slot_if_possible(C, slot)
	to_chat(usr, "<span class='notice'>You have finished equipping the [C].</span>")
	C.equipping = 0

/mob/proc/get_item_by_slot(slot_id)
	return

/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
	return null

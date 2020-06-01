//This proc is called whenever someone clicks an inventory ui slot.
/mob/proc/attack_ui(slot)
	var/obj/item/W = get_active_hand()
	if(istype(W))
		if(isIAN(src))
			switch(slot)
				if(SLOT_HEAD, SLOT_BACK)
					to_chat(src, "<span class='notice'>You have no idea how humans do this.</span>")
					return
		if(iscarbon(src))
			var/mob/living/carbon/C = src
			if(slot in C.check_obscured_slots())
				to_chat(C, "<span class='warning'>You can't reach that! Something is covering it.</span>")
				return
		if (istype(W, /obj/item/clothing))
			var/obj/item/clothing/C = W
			if(C.rig_restrict_helmet)
				to_chat(src, "<span class='red'>You must fasten the helmet to a hardsuit first. (Target the head)</span>")// Stop eva helms equipping.
			else
				if(C.equip_time > 0)
					delay_clothing_equip_to_slot_if_possible(C, slot)
				else
					equip_to_slot_if_possible(C, slot)
		else
			equip_to_slot_if_possible(W, slot)

/mob/proc/put_in_any_hand_if_possible(obj/item/W, del_on_fail = 0, disable_warning = 1, redraw_mob = 1)
	if(equip_to_slot_if_possible(W, SLOT_L_HAND, del_on_fail, disable_warning, redraw_mob))
		return 1
	else if(equip_to_slot_if_possible(W, SLOT_R_HAND, del_on_fail, disable_warning, redraw_mob))
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
var/list/slot_equipment_priority = list(
	SLOT_BACK,
	SLOT_WEAR_ID,
	SLOT_W_UNIFORM,
	SLOT_WEAR_SUIT,
	SLOT_WEAR_MASK,
	SLOT_HEAD,
	SLOT_SHOES,
	SLOT_GLOVES,
	SLOT_L_EAR,
	SLOT_R_EAR,
	SLOT_GLASSES,
	SLOT_BELT,
	SLOT_S_STORE,
	SLOT_TIE,
	SLOT_L_STORE,
	SLOT_R_STORE
	)

//puts the item "W" into an appropriate slot in a human's inventory
//returns 0 if it cannot, 1 if successful
/mob/proc/equip_to_appropriate_slot(obj/item/W, check_obscured = FALSE)
	if(!istype(W))
		return FALSE

	var/list/obscured

	if(check_obscured)
		obscured = check_obscured_slots()

	for(var/slot in slot_equipment_priority)
		if (slot in obscured)
			continue

		if (equip_to_slot_if_possible(W, slot, FALSE, TRUE, TRUE))
			return TRUE

	return FALSE

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
/mob/proc/get_active_hand()
	if(hand)	return l_hand
	else		return r_hand

//Returns the thing in our inactive hand
/mob/proc/get_inactive_hand()
	if(hand)	return r_hand
	else		return l_hand

//Checks if thing in mob's hands
/mob/proc/is_in_hands(typepath)
	return FALSE

/mob/living/carbon/monkey/is_in_hands(typepath)
	if(istype(l_hand, typepath))
		return l_hand
	if(istype(r_hand, typepath))
		return r_hand
	return FALSE

/mob/living/carbon/human/is_in_hands(typepath)
	if(istype(l_hand, typepath))
		return l_hand
	if(istype(r_hand, typepath))
		return r_hand
	return FALSE

/mob/living/carbon/ian/is_in_hands(typepath)
	if(istype(mouth, typepath))
		return mouth
	return FALSE

/mob/living/silicon/robot/is_in_hands(typepath)
	if(istype(module_active, typepath))
		return module_active
	return FALSE

//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(obj/item/W)
	if(lying && !(W.flags&ABSTRACT))	return 0
	if(!istype(W))		return 0
	if(W.anchored)		return 0	//Anchored things shouldn't be picked up because they... anchored?!
	if(!l_hand)
		W.forceMove(src)		//TODO: move to equipped?
		l_hand = W
		W.layer = ABOVE_HUD_LAYER	//TODO: move to equipped?
		W.plane = ABOVE_HUD_PLANE
		W.appearance_flags = APPEARANCE_UI
		W.slot_equipped = SLOT_L_HAND
//		l_hand.screen_loc = ui_lhand
		W.equipped(src,SLOT_L_HAND)
		if(client)	client.screen |= W
		if(pulling == W) stop_pulling()
		update_inv_l_hand()
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
		return 1
	return 0

//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(obj/item/W)
	if(lying && !(W.flags&ABSTRACT))	return 0
	if(!istype(W))		return 0
	if(W.anchored)		return 0	//Anchored things shouldn't be picked up because they... anchored?!
	if(!r_hand)
		W.forceMove(src)
		r_hand = W
		W.layer = ABOVE_HUD_LAYER
		W.plane = ABOVE_HUD_PLANE
		W.appearance_flags = APPEARANCE_UI
		W.slot_equipped = SLOT_R_HAND
//		r_hand.screen_loc = ui_rhand
		W.equipped(src,SLOT_R_HAND)
		if(client)	client.screen |= W
		if(pulling == W) stop_pulling()
		update_inv_r_hand()
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
		return 1
	return 0

//Puts the item into our active hand if possible. returns 1 on success.
/mob/proc/put_in_active_hand(obj/item/W)
	if(hand)	return put_in_l_hand(W)
	else		return put_in_r_hand(W)

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/proc/put_in_inactive_hand(obj/item/W)
	if(hand)	return put_in_r_hand(W)
	else		return put_in_l_hand(W)

//Puts the item our active hand if possible. Failing that it tries our inactive hand. Returns 1 on success.
//If both fail it drops it on the floor and returns 0.
//This is probably the main one you need to know :)
/mob/proc/put_in_hands(obj/item/W)
	if(!W)		return 0
	if(put_in_active_hand(W))
		return 1
	else if(put_in_inactive_hand(W))
		return 1
	else
		W.forceMove(get_turf(src))
		W.layer = initial(W.layer)
		W.plane = initial(W.plane)
		W.appearance_flags = initial(W.appearance_flags)
		W.dropped()
		W.slot_equipped = initial(W.slot_equipped)
		return 0

// Removes an item from inventory and places it in the target atom
/mob/proc/drop_from_inventory(obj/item/W, atom/target = null)
	if(W)
		remove_from_mob(W, target)
		if(!(W && W.loc))
			return 1 // self destroying objects (tk, grabs)
		update_icons()
		return 1
	return 0

//Drops the item in our left hand
/mob/proc/drop_l_hand(atom/Target)
	if(istype(l_hand, /obj/item))
		var/obj/item/W = l_hand
		if(W.flags & NODROP)
			return FALSE
	return drop_from_inventory(l_hand, Target)

//Drops the item in our right hand
/mob/proc/drop_r_hand(atom/Target)
	if(istype(r_hand, /obj/item))
		var/obj/item/W = r_hand
		if(W.flags & NODROP)
			return FALSE
	return drop_from_inventory(r_hand, Target)

//Drops the item in our active hand.
/mob/proc/drop_item(atom/Target)
	if(hand)	return drop_l_hand(Target)
	else		return drop_r_hand(Target)

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
	if (W == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if (W == l_hand)
		l_hand = null
		update_inv_l_hand()
	else if (W == back)
		back = null
		update_inv_back()
	else if (W == wear_mask)
		wear_mask = null
		update_inv_wear_mask()
	return

//This differs from remove_from_mob() in that it checks canremove first.
/mob/proc/unEquip(obj/item/I, force = FALSE) //Force overrides NODROP for things like wizarditis and admin undress.
	if(!I) //If there's nothing to drop, the drop is automatically successful.
		return TRUE

	if(!force)
		if(!I.canremove)
			return FALSE
		if(I.slot_equipped && (I.slot_equipped in check_obscured_slots()))
			to_chat(src, "<span class='warning'>You can't reach that! Something is covering it.</span>")
			return FALSE

	drop_from_inventory(I)
	return TRUE

// Attemps to remove an object on a mob. Will drop item to ground or move into target.
/mob/proc/remove_from_mob(obj/O, atom/target)
	if(!O) return
	src.u_equip(O)
	if (src.client)
		src.client.screen -= O
	O.layer = initial(O.layer)
	O.plane = initial(O.plane)
	O.appearance_flags = initial(O.appearance_flags)
	O.screen_loc = null
	if(istype(O, /obj/item))
		var/obj/item/I = O
		if(target)
			I.forceMove(target)
		else
			I.forceMove(loc)
		I.dropped(src)
		I.slot_equipped = initial(I.slot_equipped)
	return 1

/mob/proc/get_hand_slots()
	return list(l_hand, r_hand)

/mob/living/carbon/ian/get_hand_slots()
	return list(mouth)

//Returns the item equipped to the specified slot, if any.
/mob/proc/get_equipped_item(var/slot)
	return null

/mob/living/carbon/get_equipped_item(var/slot)
	switch(slot)
		if(SLOT_BACK) return back
		if(SLOT_WEAR_MASK) return wear_mask
		if(SLOT_L_HAND) return l_hand
		if(SLOT_R_HAND) return r_hand
	return null

/mob/living/carbon/human/get_equipped_item(var/slot)
	switch(slot)
		if(SLOT_BELT) return belt
		if(SLOT_L_EAR) return l_ear
		if(SLOT_R_EAR) return r_ear
		if(SLOT_GLASSES) return glasses
		if(SLOT_GLOVES) return gloves
		if(SLOT_HEAD) return head
		if(SLOT_SHOES) return shoes
		if(SLOT_WEAR_ID) return wear_id
		if(SLOT_WEAR_SUIT) return wear_suit
		if(SLOT_W_UNIFORM) return w_uniform
		if(SLOT_BACK) return back
		if(SLOT_WEAR_MASK) return wear_mask
		if(SLOT_L_HAND) return l_hand
		if(SLOT_R_HAND) return r_hand
		if(SLOT_S_STORE) return s_store
	return null

/mob/proc/get_equipped_items()
	return null

/mob/living/carbon/get_equipped_items()
	var/list/items = list()

	if(back)
		items += back
	if(wear_mask)
		items += wear_mask
	if(l_hand)
		items += l_hand
	if(r_hand)
		items += r_hand

	return items

/mob/living/carbon/human/get_equipped_items()
	var/list/items = ..()

	if(belt)
		items += belt
	if(l_ear)
		items += l_ear
	if(r_ear)
		items += r_ear
	if(glasses)
		items += glasses
	if(gloves)
		items += gloves
	if(head)
		items += head
	if(shoes)
		items += shoes
	if(wear_id)
		items += wear_id
	if(wear_suit)
		items += wear_suit
	if(w_uniform)
		items += w_uniform

	return items

/mob/proc/check_obscured_slots()
	return

/mob/living/carbon/check_obscured_slots()
	var/list/obscured = list()
	var/hidden_slots = NONE

	for(var/obj/item/I in get_equipped_items() - list(l_hand, r_hand))
		hidden_slots |= I.flags_inv

	if(hidden_slots & HIDEMASK)
		obscured |= SLOT_WEAR_MASK
	if(hidden_slots & HIDEEYES)
		obscured |= SLOT_GLASSES
	if(hidden_slots & HIDEEARS)
		obscured |= SLOT_EARS
		obscured |= SLOT_L_EAR
		obscured |= SLOT_R_EAR
	if(hidden_slots & HIDEGLOVES)
		obscured |= SLOT_GLOVES
	if(hidden_slots & HIDEJUMPSUIT)
		obscured |= SLOT_W_UNIFORM
	if(hidden_slots & HIDESHOES)
		obscured |= SLOT_SHOES
	if(hidden_slots & HIDESUITSTORAGE)
		obscured |= SLOT_S_STORE

	return obscured

/mob/proc/slot_id_to_name(slot)
	switch(slot)
		if(SLOT_BACK)
			return "back"
		if(SLOT_WEAR_MASK)
			return "mask"
		if(SLOT_HANDCUFFED)
			return "hands"
		if(SLOT_L_HAND)
			return "left hand"
		if(SLOT_R_HAND)
			return "right hand"
		if(SLOT_BELT)
			return "belt"
		if(SLOT_WEAR_ID)
			return "suit"
		if(SLOT_L_EAR)
			return "left ear"
		if(SLOT_R_EAR)
			return "right ear"
		if(SLOT_GLASSES)
			return "glasses"
		if(SLOT_GLOVES)
			return "gloves"
		if(SLOT_HEAD)
			return "head"
		if(SLOT_SHOES)
			return "shoes"
		if(SLOT_WEAR_SUIT)
			return "exosuit"
		if(SLOT_W_UNIFORM)
			return "uniform"
		if(SLOT_L_STORE)
			return "left pocket"
		if(SLOT_R_STORE)
			return "right pocket"
		if(SLOT_S_STORE)
			return "suit storage"
		if(SLOT_IN_BACKPACK)
			return "backpack"
		if(SLOT_LEGCUFFED)
			return "legs"
		if(SLOT_TIE)
			return "suit"
		if(SLOT_EARS)
			return "ears"
		else
			return "error=[slot]"

/mob/living/carbon/ian/slot_id_to_name(slot)
	if(slot == SLOT_NECK)
		return "neck"
	else
		return ..()

/mob/proc/CanUseTopicInventory(mob/target)
	if(is_busy() || isdrone(src) || incapacitated() || !isturf(target.loc) || !Adjacent(target))
		return FALSE

	if(ishuman(src) || isrobot(src) || ismonkey(src) || isIAN(src) || isxenoadult(src))
		return TRUE

//Create delay for equipping
/mob/proc/delay_clothing_u_equip(obj/item/clothing/C) // Bone White - delays unequipping by parameter.  Requires W to be /obj/item/clothing/

	if(!istype(C))
		return 0

	if(usr.is_busy())
		return

	if(C.equipping) // Item is already being (un)equipped
		return 0

	to_chat(usr, "<span class='notice'>You start unequipping the [C].</span>")
	C.equipping = 1
	if(do_after(usr, C.equip_time, target = C))
		remove_from_mob(C)
		to_chat(usr, "<span class='notice'>You have finished unequipping the [C].</span>")
	else
		to_chat(src, "<span class='red'>\The [C] is too fiddly to unequip whilst moving.</span>")
	C.equipping = 0

/mob/proc/delay_clothing_equip_to_slot_if_possible(obj/item/clothing/C, slot, del_on_fail = 0, disable_warning = 0, redraw_mob = 1, delay_time = 0)
	if(!istype(C))
		return 0

	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.wear_suit)
			to_chat(H, "<span class='red'>You need to take off [H.wear_suit.name] first.</span>")
			return

	if(usr.is_busy())
		return

	if(C.equipping) // Item is already being equipped
		return 0

	to_chat(usr, "<span class='notice'>You start equipping the [C].</span>")
	C.equipping = 1
	if(do_after(usr, C.equip_time, target = C))
		equip_to_slot_if_possible(C, slot)
		to_chat(usr, "<span class='notice'>You have finished equipping the [C].</span>")
	else
		to_chat(src, "<span class='red'>\The [C] is too fiddly to fasten whilst moving.</span>")
	C.equipping = 0

/mob/proc/get_item_by_slot(slot_id)
	switch(slot_id)
		if(SLOT_L_HAND)
			return l_hand
		if(SLOT_R_HAND)
			return r_hand
	return null

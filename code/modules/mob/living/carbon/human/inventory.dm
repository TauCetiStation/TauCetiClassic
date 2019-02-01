/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = H.get_active_hand()
		var/obj/item/weapon/storage/S = H.get_inactive_hand()
		if(!I)
			to_chat(H, "<span class='notice'>You are not holding anything to equip.</span>")
			return

	//	if(istype(I, /obj/item/clothing/head/helmet/space/rig)) // If the item to be equipped is a rigid suit helmet
	//		src << "\red You must fasten the helmet to a hardsuit first. (Target the head)" // Stop eva helms equipping.
	//		return 0

		if(istype(I, /obj/item/clothing/suit/space)) // If the item to be equipped is a space suit
			if(H.wear_suit)
				to_chat(H, "<span class='warning'>You need to take off [H.wear_suit.name] first.</span>")
				return
			else
				var/obj/item/clothing/suit/space/rig/J = I
				if(J.equip_time > 0)
					delay_clothing_equip_to_slot_if_possible(J, 13)  // 13 = suit slot
					return 0

		if(H.equip_to_appropriate_slot(I))
			if(hand)
				update_inv_l_hand()
			else
				update_inv_r_hand()

		else if(s_active && s_active.can_be_inserted(I,1))	//if storage active insert there
			s_active.handle_item_insertion(I)
		else if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))	//see if we have box in other hand
			S.handle_item_insertion(I)

		else
			S = H.get_item_by_slot(slot_belt)
			if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))		//else we put in belt
				S.handle_item_insertion(I)
			else
				S = H.get_item_by_slot(slot_back)	//else we put in backpack
				if(istype(S, /obj/item/weapon/storage) && S.can_be_inserted(I,1))
					S.handle_item_insertion(I)
				else
					to_chat(H, "<span class='warning'>You are unable to equip that.</span>")



/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slots[slot], del_on_fail = 0))
			return slot
	if (del_on_fail)
		qdel(W)
	return null


/mob/living/carbon/human/proc/has_bodypart(name)
	var/obj/item/organ/external/BP = bodyparts_by_name[name]

	return (BP && !(BP.status & ORGAN_DESTROYED) )

/mob/living/carbon/human/proc/specie_has_slot(slot)
	if(species && slot in species.restricted_inventory_slots)
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/has_bodypart_for_slot(slot)
	switch(slot)
		if(slot_back)
			return has_bodypart(BP_CHEST)
		if(slot_wear_mask)
			return has_bodypart(BP_HEAD)
		if(slot_handcuffed)
			return has_bodypart(BP_L_ARM) && has_bodypart(BP_R_ARM)
		if(slot_legcuffed)
			return has_bodypart(BP_L_LEG) && has_bodypart(BP_R_LEG)
		if(slot_l_hand)
			return has_bodypart(BP_L_ARM)
		if(slot_r_hand)
			return has_bodypart(BP_R_ARM)
		if(slot_belt)
			return has_bodypart(BP_CHEST)
		if(slot_wear_id)
			// the only relevant check for this is the uniform check
			return TRUE
		if(slot_l_ear)
			return has_bodypart(BP_HEAD)
		if(slot_r_ear)
			return has_bodypart(BP_HEAD)
		if(slot_glasses)
			return has_bodypart(BP_HEAD)
		if(slot_gloves)
			return has_bodypart(BP_L_ARM) && has_bodypart(BP_R_ARM)
		if(slot_head)
			return has_bodypart(BP_HEAD)
		if(slot_shoes)
			return has_bodypart(BP_R_LEG) && has_bodypart(BP_L_LEG)
		if(slot_wear_suit)
			return has_bodypart(BP_CHEST)
		if(slot_w_uniform)
			return has_bodypart(BP_CHEST)
		if(slot_l_store)
			return has_bodypart(BP_CHEST)
		if(slot_r_store)
			return has_bodypart(BP_CHEST)
		if(slot_s_store)
			return has_bodypart(BP_CHEST)
		if(slot_in_backpack)
			return TRUE
		if(slot_tie)
			return TRUE

/mob/living/carbon/human/u_equip(obj/W)
	if(!W)	return 0

	if (W == wear_suit)
		if(s_store)
			drop_from_inventory(s_store)
		wear_suit = null
		var/update_hair = 0
		if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
			update_hair = 1
		else if(istype(W, /obj/item))
			var/obj/item/I = W
			if(I.flags_inv & HIDEMASK)
				update_hair = 1
		if(update_hair)
			update_hair()
			update_inv_ears()
			update_inv_wear_mask()
		update_inv_wear_suit()
	else if (W == w_uniform)
		if (r_store)
			drop_from_inventory(r_store)
		if (l_store)
			drop_from_inventory(l_store)
		if (wear_id)
			drop_from_inventory(wear_id)
		if (belt)
			drop_from_inventory(belt)
		w_uniform = null
		update_inv_w_uniform()
	else if (W == gloves)
		gloves = null
		update_inv_gloves()
	else if (W == glasses)
		glasses = null
		update_inv_glasses()
	else if (W == head)
		head = null

		var/update_hair = 0
		if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
			update_hair = 1
		else if(istype(W, /obj/item))
			var/obj/item/I = W
			if(I.flags_inv & HIDEMASK)
				update_hair = 1
		if(update_hair)
			update_hair()
			update_inv_ears()
			update_inv_wear_mask()

		update_inv_head()
	else if (W == l_ear)
		l_ear = null
		update_inv_ears()
	else if (W == r_ear)
		r_ear = null
		update_inv_ears()
	else if (W == shoes)
		shoes = null
		update_inv_shoes()
	else if (W == belt)
		belt = null
		update_inv_belt()
	else if (W == wear_mask)
		wear_mask = null
		if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
			update_hair()	//rebuild hair
		if(internal)
			if(internals)
				internals.icon_state = "internal0"
			internal = null
		update_inv_wear_mask()
	else if (W == wear_id)
		wear_id = null
		update_inv_wear_id()
	else if (W == r_store)
		r_store = null
		update_inv_pockets()
	else if (W == l_store)
		l_store = null
		update_inv_pockets()
	else if (W == s_store)
		s_store = null
		update_inv_s_store()
	else if (W == back)
		back = null
		update_inv_back()
	else if (W == handcuffed)
		handcuffed = null
		update_inv_handcuffed()
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()
	else if (W == legcuffed)
		legcuffed = null
		update_inv_legcuffed()
	else if (W == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if (W == l_hand)
		l_hand = null
		update_inv_l_hand()
	else
		return 0

	return 1



//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W, slot, redraw_mob = 1)
	if(!slot)
		return
	if(!istype(W))
		return
	if(!has_bodypart_for_slot(slot))
		return
	if(!specie_has_slot(slot))
		return

	// I sincerely regret this do not look a line lower or you will too. ~Luduk.
	if(istype(W, /obj/item/nymph_morph_ball))
		var/obj/item/nymph_morph_ball/NM = W
		W = NM.morphed_into
		drop_from_inventory(NM, W)
	// Madness ends here, and that's good.

	W.screen_loc = null // will get moved if inventory is visible

	W.loc = src
	switch(slot)
		if(slot_back)
			src.back = W
			W.equipped(src, slot)
			update_inv_back()
		if(slot_wear_mask)
			src.wear_mask = W
			if((wear_mask.flags & BLOCKHAIR) || (wear_mask.flags & BLOCKHEADHAIR))
				update_hair()
			W.equipped(src, slot)
			update_inv_wear_mask()
		if(slot_handcuffed)
			src.handcuffed = W
			update_inv_handcuffed()
		if(slot_legcuffed)
			src.legcuffed = W
			W.equipped(src, slot)
			update_inv_legcuffed()
		if(slot_l_hand)
			src.l_hand = W
			W.equipped(src, slot)
			update_inv_l_hand()
		if(slot_r_hand)
			src.r_hand = W
			W.equipped(src, slot)
			update_inv_r_hand()
		if(slot_belt)
			src.belt = W
			W.equipped(src, slot)
			update_inv_belt()
		if(slot_wear_id)
			src.wear_id = W
			W.equipped(src, slot)
			update_inv_wear_id()
		if(slot_l_ear)
			src.l_ear = W
			if(l_ear.slot_flags & SLOT_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				src.r_ear = O
				O.layer = ABOVE_HUD_LAYER
				O.plane = ABOVE_HUD_LAYER
				O.appearance_flags = APPEARANCE_UI
			W.equipped(src, slot)
			update_inv_ears()
		if(slot_r_ear)
			src.r_ear = W
			if(r_ear.slot_flags & SLOT_TWOEARS)
				var/obj/item/clothing/ears/offear/O = new(W)
				O.loc = src
				src.l_ear = O
				O.layer = ABOVE_HUD_LAYER
				O.plane = ABOVE_HUD_LAYER
				O.appearance_flags = APPEARANCE_UI
			W.equipped(src, slot)
			update_inv_ears()
		if(slot_glasses)
			src.glasses = W
			W.equipped(src, slot)
			update_inv_glasses()
		if(slot_gloves)
			src.gloves = W
			W.equipped(src, slot)
			update_inv_gloves()
		if(slot_head)
			src.head = W
			if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
				update_hair()	//rebuild hair
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, slot)
			update_inv_head()
		if(slot_shoes)
			src.shoes = W
			W.equipped(src, slot)
			update_inv_shoes()
		if(slot_wear_suit)
			src.wear_suit = W
			if((W.flags & BLOCKHAIR) || (W.flags & BLOCKHEADHAIR))
				update_hair()	//rebuild hair
			W.equipped(src, slot)
			update_inv_wear_suit()
		if(slot_w_uniform)
			src.w_uniform = W
			W.equipped(src, slot)
			update_inv_w_uniform()
		if(slot_l_store)
			src.l_store = W
			W.equipped(src, slot)
			update_inv_pockets()
		if(slot_r_store)
			src.r_store = W
			W.equipped(src, slot)
			update_inv_pockets()
		if(slot_s_store)
			src.s_store = W
			W.equipped(src, slot)
			update_inv_s_store()
		if(slot_in_backpack)
			if(src.get_active_hand() == W)
				src.remove_from_mob(W)
			W.loc = src.back
		if(slot_tie)
			var/obj/item/clothing/under/uniform = w_uniform
			uniform.attackby(W, src)
		else
			to_chat(src, "<span class='warning'>You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	if(W == l_hand && slot != slot_l_hand)
		l_hand = null
		update_inv_l_hand() // So items actually disappear from hands.
	else if(W == r_hand && slot != slot_r_hand)
		r_hand = null
		update_inv_r_hand()

	W.layer = ABOVE_HUD_LAYER
	W.plane = ABOVE_HUD_PLANE
	W.appearance_flags = APPEARANCE_UI

/*
	MouseDrop human inventory menu
*/

/obj/effect/equip_e
	name = "equip e"
	var/mob/source = null
	var/s_loc = null	//source location
	var/t_loc = null	//target location
	var/obj/item/item = null
	var/place = null
	var/obj/item/clothing/holder

/obj/effect/equip_e/human
	name = "human"
	var/mob/living/carbon/human/target = null

/obj/effect/equip_e/monkey
	name = "monkey"
	var/mob/living/carbon/monkey/target = null

/obj/effect/equip_e/process()
	return

/obj/effect/equip_e/proc/done()
	return

/obj/effect/equip_e/atom_init()
	..()
	if (!ticker)
		return INITIALIZE_HINT_QDEL
	return INITIALIZE_HINT_LATELOAD

/obj/effect/equip_e/atom_init_late()
	QDEL_IN(src, 100)

/obj/effect/equip_e/Destroy()
	source = null
	s_loc = null
	t_loc = null
	item = null
	return ..()

/obj/effect/equip_e/human/process()
	if(ismouse(source))
		return
	if (item)
		item.add_fingerprint(source)
	else
		switch(place)
			if("mask")
				if (!( target.wear_mask ))
					qdel(src)
			if("l_hand")
				if (!( target.l_hand ))
					qdel(src)
			if("r_hand")
				if (!( target.r_hand ))
					qdel(src)
			if("suit")
				if (!( target.wear_suit ))
					qdel(src)
			if("uniform")
				if (!( target.w_uniform ))
					qdel(src)
			if("back")
				if (!( target.back ))
					qdel(src)
			if("syringe")
				return
			if("pill")
				return
			if("fuel")
				return
			if("drink")
				return
			if("dnainjector")
				return
			if("handcuff")
				if (!( target.handcuffed ))
					qdel(src)
			if("id")
				if ((!( target.wear_id ) || !( target.w_uniform )))
					qdel(src)
			if("splints")
				var/count = 0
				for(var/bodypart_name in list(BP_L_LEG , BP_R_LEG , BP_L_ARM , BP_R_ARM))
					var/obj/item/organ/external/BP = target.bodyparts_by_name[bodypart_name]
					if(BP.status & ORGAN_SPLINTED)
						count = 1
						break
				if(count == 0)
					qdel(src)
					return
			if("sensor")
				if (! target.w_uniform )
					qdel(src)
			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && (istype(target.back, /obj/item/weapon/tank) || istype(target.belt, /obj/item/weapon/tank) || istype(target.s_store, /obj/item/weapon/tank)) && !( target.internal )) ) && !( target.internal )))
					qdel(src)

	var/list/L = list( "syringe", "pill", "drink", "dnainjector", "fuel", "sensor", "internal", "tie")
	if ((item && !( L.Find(place) )))
		if(isrobot(source)) //#Z2
			if(place != "handcuff")
				qdel(src)
			for(var/mob/O in viewers(target, null))
				O.show_message("<span class='danger'>[source] is trying to put \a [item] on [target]</span>", 1)
		else
			if((place == "handcuff") | (istype(item, /obj/item/weapon/handcuffs)))
				for(var/mob/O in viewers(target, null))
					O.show_message("<span class='danger'>[source] is trying to put \a [item] on [target]</span>", 1)
			else
				if((HULK in target.mutations) && !(HULK in source.mutations))//#Z2 - Hulk is too faking~ scary, so we cant put anything on him using inventory.
					source.show_message("<span class='danger'>[target] is too scary! You dont want to risk your health.</span>", 1)
					return
				else
					for(var/mob/O in viewers(target, null))
						O.show_message("<span class='danger'>[source] is trying to put \a [item] on [target]</span>", 1) //##Z2
	else
		var/message=null
		switch(place)
			if("syringe")
				message = "<span class='danger'>[source] is trying to inject [target]!</span>"
			if("pill")
				message = "<span class='danger'>[source] is trying to force [target] to swallow [item]!</span>"
			if("drink")
				message = "<span class='danger'>[source] is trying to force [target] to swallow a gulp of [item]!</span>"
			if("dnainjector")
				message = "<span class='danger'>[source] is trying to inject [target] with the [item]!</span>"
			if("mask")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had their mask removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) mask</font>")
				if(target.wear_mask && !target.wear_mask.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.wear_mask] from [target]'s head!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off \a [target.wear_mask] from [target]'s head!</span>"
			if("l_hand")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their left hand item ([target.l_hand]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) left hand item ([target.l_hand])</font>")
				if(target.l_hand && !target.l_hand.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.l_hand] from [target]'s left hand!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off \a [target.l_hand] from [target]'s left hand!</span>"
			if("r_hand")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their right hand item ([target.r_hand]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) right hand item ([target.r_hand])</font>")
				if(target.r_hand && !target.r_hand.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.r_hand] from [target]'s right hand!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off \a [target.r_hand] from [target]'s right hand!</span>"
			if("gloves")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their gloves ([target.gloves]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) gloves ([target.gloves])</font>")
				if(target.gloves && !target.gloves.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.gloves] from [target]'s hands!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.gloves] from [target]'s hands!</span>"
			if("eyes")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their eyewear ([target.glasses]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) eyewear ([target.glasses])</font>")
				if(target.glasses && !target.glasses.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.glasses] from [target]'s eyes!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.glasses] from [target]'s eyes!</span>"
			if("l_ear")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their left ear item ([target.l_ear]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) left ear item ([target.l_ear])</font>")
				if(target.l_ear && !target.l_ear.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.l_ear] from [target]'s left ear!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.l_ear] from [target]'s left ear!</span>"
			if("r_ear")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their right ear item ([target.r_ear]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) right ear item ([target.r_ear])</font>")
				if(target.r_ear && !target.r_ear.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.r_ear] from [target]'s right ear!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.r_ear] from [target]'s right ear!</span>"
			if("head")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their hat ([target.head]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) hat ([target.head])</font>")
				if(target.head && !target.head.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.head] from [target]'s head!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.head] from [target]'s head!</span>"
			if("shoes")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their shoes ([target.shoes]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) shoes ([target.shoes])</font>")
				if(target.shoes && !target.shoes.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.shoes] from [target]'s feet!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off the [target.shoes] from [target]'s feet!</span>"
			if("belt")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their belt item ([target.belt]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) belt item ([target.belt])</font>")
				message = "<span class='danger'>[source] is trying to take off the [target.belt] from [target]'s belt!</span>"
			if("suit")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their suit ([target.wear_suit]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) suit ([target.wear_suit])</font>")
				if(target.wear_suit && !target.wear_suit.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.wear_suit] from [target]'s body!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off \a [target.wear_suit] from [target]'s body!</span>"
			if("back")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their back item ([target.back]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) back item ([target.back])</font>")
				message = "<span class='danger'>[source] is trying to take off \a [target.back] from [target]'s back!</span>"
			if("handcuff")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Was unhandcuffed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to unhandcuff [target.name]'s ([target.ckey])</font>")
				message = "<span class='danger'>[source] is trying to unhandcuff [target]!</span>"
			if("legcuff")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Was unlegcuffed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to unlegcuff [target.name]'s ([target.ckey])</font>")
				message = "<span class='danger'>[source] is trying to unlegcuff [target]!</span>"
			if("uniform")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their uniform ([target.w_uniform]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) uniform ([target.w_uniform])</font>")
				for(var/obj/item/I in list(target.l_store, target.r_store))
					if(I.on_found(source))
						return
				if(target.w_uniform && !target.w_uniform.canremove)
					message = "<span class='danger'>[source] fails to take off \a [target.w_uniform] from [target]'s body!</span>"
					return
				else
					message = "<span class='danger'>[source] is trying to take off \a [target.w_uniform] from [target]'s body!</span>"
			if("tie")
				var/obj/item/clothing/under/suit = target.w_uniform
				if(suit.accessories.len)
					var/obj/item/clothing/accessory/A = suit.accessories[1]
					target.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their accessory ([A]) removed by [source.name] ([source.ckey])</font>"
					source.attack_log += "\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) accessory ([A])</font>"
					if(istype(A, /obj/item/clothing/accessory/holobadge) || istype(A, /obj/item/clothing/accessory/medal))
						for(var/mob/M in viewers(target, null))
							M.show_message("\red <B>[source] tears off \the [A] from [target]'s [suit]!</B>" , 1)
						done()
						return
					else
						message = "<span class='danger'>[source] is trying to take off \a [A] from [target]'s [suit]!</span>"
			if("s_store")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their suit storage item ([target.s_store]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) suit storage item ([target.s_store])</font>")
				message = "<span class='danger'>[source] is trying to take off \a [target.s_store] from [target]'s suit!</span>"
			if("pockets")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their pockets emptied by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to empty [target.name]'s ([target.ckey]) pockets</font>")
				for(var/obj/item/I in list(target.l_store, target.r_store))
					if(I.on_found(source))
						return
				message = "<span class='danger'>[source] is trying to empty [target]'s pockets.</span>"
			if("CPR")
				if (!target.cpr_time)
					qdel(src)
				target.cpr_time = 0
				message = "<span class='danger'>[source] is trying perform CPR on [target]!</span>"
			if("id")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their ID ([target.wear_id]) removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) ID ([target.wear_id])</font>")
				message = "<span class='danger'>[source] is trying to take off [target.wear_id] from [target]'s uniform!</span>"
			if("internal")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their internals toggled by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [target.name]'s ([target.ckey]) internals</font>")
				if (target.internal)
					message = "<span class='danger'>[source] is trying to remove [target]'s internals</span>"
				else
					message = "<span class='danger'>[source] is trying to set on [target]'s internals.</span>"
			if("splints")
				message = text("<span class='danger'>[] is trying to remove []'s splints!", source, target)
			if("bandages")
				message = text("<span class='danger'>[] is trying to remove []'s bandages!", source, target)
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their bandages removed by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to remove [target.name]'s ([target.ckey]) bandages</font>")
			if("sensor")
				target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had their sensors toggled by [source.name] ([source.ckey])</font>")
				source.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to toggle [target.name]'s ([target.ckey]) sensors</font>")
				var/obj/item/clothing/under/suit = target.w_uniform
				if (suit.has_sensor >= 2)
					to_chat(source, "The controls are locked.")
					return
				message = "<span class='danger'>[source] is trying to set [target]'s suit sensors!</span>"
		var/obj/item/clothing/gloves/Strip = null
		if(ishuman(source))
			var/mob/living/carbon/human/Striper = source
			Strip = Striper.gloves
		if(istype(Strip, /obj/item/clothing/gloves/black/strip))
			to_chat(source, message)
		else
			source.visible_message(message)
	spawn( HUMAN_STRIP_DELAY )
		done()
		return
	return

/*
This proc equips stuff (or does something else) when removing stuff manually from the character window when you click and drag.
It works in conjuction with the process() above.
This proc works for humans only. Aliens stripping humans and the like will all use this proc. Stripping monkeys or somesuch will use their version of this proc.
The first if statement for "mask" and such refers to items that are already equipped and un-equipping them.
The else statement is for equipping stuff to empty slots.
!canremove refers to variable of /obj/item/clothing which either allows or disallows that item to be removed.
It can still be worn/put on as normal.
*/
/obj/effect/equip_e/human/done()	//TODO: And rewrite this :< ~Carn
	target.cpr_time = 1
	if(isanimal(source)) return //animals cannot strip people, except Ian, hes a cat, cats no no animal!
	if(!source || !target) return		//Target or source no longer exist
	if(source.loc != s_loc) return		//source has moved
	if(target.loc != t_loc) return		//target has moved
	if(!in_range(s_loc, t_loc)) return	//Use a proxi!
	if(item && source.get_active_hand() != item) return	//Swapped hands / removed item from the active one
	if ((source.restrained() || source.stat)) return //Source restrained or unconscious / dead

	var/slot_to_process
	var/strip_item //this will tell us which item we will be stripping - if any.

	switch(place)	//here we go again...
		if("mask")
			slot_to_process = slot_wear_mask
			if (target.wear_mask && target.wear_mask.canremove)
				strip_item = target.wear_mask
		if("gloves")
			slot_to_process = slot_gloves
			if (target.gloves && target.gloves.canremove)
				strip_item = target.gloves
		if("eyes")
			slot_to_process = slot_glasses
			if (target.glasses)
				strip_item = target.glasses
		if("belt")
			slot_to_process = slot_belt
			if (target.belt)
				strip_item = target.belt
		if("s_store")
			slot_to_process = slot_s_store
			if (target.s_store)
				strip_item = target.s_store
		if("head")
			slot_to_process = slot_head
			if (target.head && target.head.canremove)
				strip_item = target.head
		if("l_ear")
			slot_to_process = slot_l_ear
			if (target.l_ear)
				strip_item = target.l_ear
		if("r_ear")
			slot_to_process = slot_r_ear
			if (target.r_ear)
				strip_item = target.r_ear
		if("shoes")
			slot_to_process = slot_shoes
			if (target.shoes && target.shoes.canremove)
				strip_item = target.shoes
		if("l_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				qdel(src)
			slot_to_process = slot_l_hand
			if (target.l_hand)
				strip_item = target.l_hand
		if("r_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				qdel(src)
			slot_to_process = slot_r_hand
			if (target.r_hand)
				strip_item = target.r_hand
		if("uniform")
			slot_to_process = slot_w_uniform
			if(target.w_uniform && target.w_uniform.canremove)
				strip_item = target.w_uniform
		if("suit")
			slot_to_process = slot_wear_suit
			if (target.wear_suit && target.wear_suit.canremove)
				strip_item = target.wear_suit
		if("tie")
			var/obj/item/clothing/under/suit = target.w_uniform
			if(suit && suit.accessories.len)
				var/obj/item/clothing/accessory/A = suit.accessories[1]
				A.on_removed(usr)
				suit.accessories -= A
				target.update_inv_w_uniform()
		if("id")
			slot_to_process = slot_wear_id
			if (target.wear_id)
				strip_item = target.wear_id
		if("back")
			slot_to_process = slot_back
			if (target.back)
				strip_item = target.back
		if("handcuff")
			slot_to_process = slot_handcuffed
			if (target.handcuffed)
				strip_item = target.handcuffed
			else if (source != target && ishuman(source))
				//check that we are still grabbing them
				var/grabbing = 0
				for (var/obj/item/weapon/grab/G in target.grabbed_by)
					if (G.loc == source && G.state >= GRAB_AGGRESSIVE)
						grabbing = 1
				if (!grabbing)
					slot_to_process = null
					to_chat(source, "<span class='warning'>Your grasp was broken before you could restrain [target]!</span>")

		if("legcuff")
			slot_to_process = slot_legcuffed
			if (target.legcuffed)
				strip_item = target.legcuffed
		if("splints")
			for(var/bodypart_name in list(BP_L_LEG , BP_R_LEG , BP_L_ARM , BP_R_ARM))
				var/obj/item/organ/external/BP = target.bodyparts_by_name[bodypart_name]
				if (BP && (BP.status & ORGAN_SPLINTED))
					var/obj/item/W = new /obj/item/stack/medical/splint(target.loc, 1)
					BP.status &= ~ORGAN_SPLINTED
					W.add_fingerprint(source)
		if("bandages")
			for(var/obj/item/organ/external/BP in target.bodyparts)
				for(var/datum/wound/W in BP.wounds)
					if(W.bandaged)
						W.bandaged = 0
			target.update_bandage()
		if("CPR")
			if ((target.health > config.health_threshold_dead && target.health < config.health_threshold_crit))
				var/suff = min(target.getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
				target.adjustOxyLoss(-suff)
				target.updatehealth()
				for(var/mob/O in viewers(source, null))
					O.show_message("<span class='warning'>[source] performs CPR on [target]!</span>", 1)
				to_chat(target, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
				to_chat(source, "<span class='warning'>Repeat at least every 7 seconds.</span>")
		if("dnainjector")
			var/obj/item/weapon/dnainjector/S = item
			if(S)
				S.add_fingerprint(source)
				if (!( istype(S, /obj/item/weapon/dnainjector) ))
					S.inuse = 0
					qdel(src)
				S.inject(target, source)
				if (S.s_time >= world.time + 30)
					S.inuse = 0
					qdel(src)
				S.s_time = world.time
				for(var/mob/O in viewers(source, null))
					O.show_message("<span class='warning'>[source] injects [target] with the DNA Injector!</span>", 1)
				S.inuse = 0
		if("pockets")
			slot_to_process = slot_l_store
			if (target.l_store)
				strip_item = target.l_store
			else if (target.r_store)
				strip_item = target.r_store
		if("sensor")
			var/obj/item/clothing/under/suit = target.w_uniform
			if (suit)
				if(suit.has_sensor >= 2)
					to_chat(source, "<span class='notice'>The controls are locked.</span>")
				else
					suit.set_sensors(source)
		if("internal")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
				if (target.internals)
					target.internals.icon_state = "internal0"
			else
				if (!( istype(target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(target.back, /obj/item/weapon/tank))
						target.internal = target.back
					else if (istype(target.s_store, /obj/item/weapon/tank))
						target.internal = target.s_store
					else if (istype(target.belt, /obj/item/weapon/tank))
						target.internal = target.belt
					if (target.internal)
						for(var/mob/M in viewers(target, 1))
							M.show_message("<span class='notice'>[target] is now running on internals.</span>", 1)
						target.internal.add_fingerprint(source)
						if (target.internals)
							target.internals.icon_state = "internal1"

	if(slot_to_process)
		if(strip_item) //Stripping an item from the mob
			var/obj/item/W = strip_item
			var/obj/item/clothing/gloves/Strip = null
			target.remove_from_mob(W)
			if(ishuman(source))
				var/mob/living/carbon/human/Striper = source
				Strip = Striper.gloves
			if(istype(Strip, /obj/item/clothing/gloves/black/strip) && (!source.l_hand || !source.r_hand))
				source.put_in_hands(W)
			else
				if(slot_to_process == slot_l_store) //pockets! Needs to process the other one too. Snowflake code, wooo! It's not like anyone will rewrite this anytime soon. If I'm wrong then... CONGRATULATIONS! ;)
					if(target.r_store)
						target.remove_from_mob(target.r_store) //At this stage l_store is already processed by the code above, we only need to process r_store.
			W.add_fingerprint(source)
		else
			if(item && target.has_bodypart_for_slot(slot_to_process)) //Placing an item on the mob
				if(item.mob_can_equip(target, slot_to_process, 0))
					source.remove_from_mob(item)
					target.equip_to_slot_if_possible(item, slot_to_process, 0, 1, 1)

	if(source && target)
		if(source.machine == target)
			target.show_inv(source)
	qdel(src)

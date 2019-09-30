/mob/living/carbon/proc/stripPanelUnEquip(mob/living/who, where, obj/item/this_item)
	if(QDELETED(src) || QDELETED(who) || !where || who.is_busy(src))
		return
	if(!who.CanUseTopicInventory(src))
		return

	var/strip_gloves = FALSE
	if(ishuman(who))
		var/mob/living/carbon/human/H = who
		if(istype(H.gloves, /obj/item/clothing/gloves/black/strip))
			strip_gloves = TRUE

	var/obj/item/slot_ref
	var/slot_ref_slot
	var/slot_ref_loc

	if(this_item)
		if(!strip_gloves)
			this_item.add_fingerprint(who)
			who.visible_message("<span class='danger'>[who] is trying to put \a [this_item] on [src].</span>")
		else
			to_chat(who, "<span class='notice'>You silently is trying to put \a [this_item] on [src].</span>")
	else
		slot_ref = get_slot_ref(where)
		if(slot_ref)
			slot_ref_slot = slot_ref.slot_equipped
			slot_ref_loc = slot_ref.loc
			if(!strip_gloves)
				slot_ref.add_fingerprint(who)
				who.visible_message("<span class='danger'>[who] is trying to take off \a [slot_ref] from [src]'s [slot_id_to_name(where)]!</span>")
			else
				to_chat(who, "<span class='notice'>You silently is trying to take off \a [slot_ref] from [src]'s [slot_id_to_name(where)]!</span>")
		else
			return

	if(do_after(who, HUMAN_STRIP_DELAY, target = src))
		if(slot_ref && (slot_ref_slot != slot_ref.slot_equipped || slot_ref_loc != slot_ref.loc))
			to_chat(who, "<span class='notice'>Item you wanted to take off is moved somewhere else!</span>")
			return
		do_stripPanelUnEquip(who, where, this_item, strip_gloves)

/mob/living/carbon/proc/do_stripPanelUnEquip(mob/living/who, where, obj/item/this_item, strip_gloves = FALSE)
	if(QDELETED(src) || QDELETED(who) || !where)
		return
	if(this_item)
		if(QDELETED(this_item) || (this_item.flags & (ABSTRACT | DROPDEL)))
			return
		if(who.get_active_hand() != this_item)
			return
	if(!who.CanUseTopicInventory(src))
		return

	var/obj/item/slot_ref = get_slot_ref(where)
	var/slot_name = slot_id_to_name(where)

	if(slot_ref)
		if(!slot_ref.canremove)
			if(!strip_gloves)
				who.visible_message("<span class='danger'>[who] fails to take off \a [slot_ref] from [src]'s [slot_name]!</span>")
			else
				to_chat(who, "<span class='notice'>You failed to take off \a [slot_ref] from [src]'s [slot_name]!</span>")
			return
		else
			if(!slot_ref.onStripPanelUnEquip(who, strip_gloves))
				return
			remove_from_mob(slot_ref)
			if(strip_gloves)
				who.put_in_hands(slot_ref)
			attack_log += "\[[time_stamp()]\] <font color='orange'>Had their [slot_ref] ([slot_name]) removed by [who.name] ([who.ckey])</font>"
			who.attack_log += "\[[time_stamp()]\] <font color='red'>Removed [name]'s ([ckey]) [slot_ref] ([slot_name])</font>"
	else
		if(!this_item.canremove)
			to_chat(who, "<span class='warning'>You can't put \the [this_item.name] on [src], it's stuck to your hand!</span>")
			return
		if(!this_item.mob_can_equip(src, where))
			to_chat(who, "<span class='warning'>\The [this_item.name] doesn't fit in that place!</span>")
			return

		if(!this_item.onStripPanelUnEquip(who, strip_gloves))
			return

		who.remove_from_mob(this_item)
		equip_to_slot_if_possible(this_item, where)
		attack_log += "\[[time_stamp()]\] <font color='orange'>[who.name] ([who.ckey]) placed on our [slot_name] ([this_item])</font>"
		who.attack_log += "\[[time_stamp()]\] <font color='red'>Placed on [name]'s ([ckey]) [slot_name] ([this_item])</font>"

/mob/living/carbon/proc/get_slot_ref(slot)
	switch(slot)
		if(SLOT_BACK)
			return back
		if(SLOT_WEAR_MASK)
			return wear_mask
		if(SLOT_HANDCUFFED)
			return handcuffed
		if(SLOT_L_HAND)
			return l_hand
		if(SLOT_R_HAND)
			return r_hand

/mob/living/carbon/ian/get_slot_ref(slot)
	switch(slot)
		if(SLOT_HEAD)
			return head
		if(SLOT_MOUTH)
			return mouth
		if(SLOT_NECK)
			return neck
		if(SLOT_BACK)
			return back

/mob/living/carbon/human/get_slot_ref(slot)
	. = ..()
	if(.)
		return

	switch(slot)
		if(SLOT_BELT)
			return belt
		if(SLOT_WEAR_ID)
			return wear_id
		if(SLOT_L_EAR)
			return l_ear
		if(SLOT_R_EAR)
			return r_ear
		if(SLOT_GLASSES)
			return glasses
		if(SLOT_GLOVES)
			return gloves
		if(SLOT_HEAD)
			return head
		if(SLOT_SHOES)
			return shoes
		if(SLOT_WEAR_SUIT)
			return wear_suit
		if(SLOT_W_UNIFORM)
			return w_uniform
		if(SLOT_L_STORE)
			return l_store
		if(SLOT_R_STORE)
			return r_store
		if(SLOT_S_STORE)
			return s_store
		if(SLOT_LEGCUFFED)
			return legcuffed

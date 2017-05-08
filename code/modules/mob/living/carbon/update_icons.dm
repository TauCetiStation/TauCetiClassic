	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*
There are several things that need to be remembered:

>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. user calls attack_self() on item )
	You will need to call update_inv_item proc.

>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		update_bodypart()	//handles updating your mob's icon to reflect their gender/race/complexion etc and
								...damage overlays for brute/burn damage
		update_targeted() // Updates the target overlay when someone points a gun at you

>	If you need to update all overlays you can use regenerate_icons().

*/

/mob/living/carbon
	var/list/overlays_standing[TOTAL_LAYERS]
	var/list/overlays_bodypart = list()
	var/list/overlays_inventory = list()

/mob/living/carbon/proc/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/proc/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null


/mob/living/carbon/proc/apply_inv_overlay(cache_index)
	var/image/I = overlays_inventory[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/proc/remove_inv_overlay(cache_index)
	if(overlays_inventory[cache_index])
		overlays -= overlays_inventory[cache_index]
		overlays_inventory[cache_index] = null


/mob/living/carbon/proc/apply_bodypart_overlay(cache_index)
	var/image/I = overlays_bodypart[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/proc/remove_bodypart_overlay(cache_index)
	if(overlays_bodypart[cache_index])
		overlays -= overlays_bodypart[cache_index]
		overlays_bodypart[cache_index] = null


/mob/living/carbon/update_icons()
	update_hud()		//TODO: remove the need for this


/mob/living/carbon/proc/update_bodypart(body_zone)
	remove_bodypart_overlay(body_zone)

	var/obj/item/bodypart/BP = bodyparts_by_name[body_zone]

	if(!BP)
		return

	BP.update_limb()

	if(!BP.icon_state)
		return

	overlays_bodypart[body_zone] = BP.get_icon()
	apply_bodypart_overlay(body_zone)

/mob/living/carbon/proc/update_bloody_bodypart(body_zone)
	remove_bodypart_overlay(body_zone + "_bld")

	var/obj/item/bodypart/BP = bodyparts_by_name[body_zone]

	if(!BP || !BP.bld_overlay || BP.is_stump())
		return

	overlays_bodypart[body_zone + "_bld"] = BP.bld_overlay
	apply_bodypart_overlay(body_zone + "_bld")


/mob/living/carbon/proc/update_bodyparts()
	for(var/obj/item/bodypart/BP in bodyparts)
		update_bodypart(BP.body_zone)

/mob/living/carbon/proc/update_bloody_bodyparts()
	for(var/obj/item/bodypart/BP in bodyparts)
		update_bloody_bodypart(BP.body_zone)


/mob/living/carbon/update_mutations()
	remove_overlay(MUTATIONS_LAYER)

	var/fat
	if(disabilities & FAT)
		fat = "fat"

	var/list/standing	= list()
	var/g = (gender == FEMALE) ? "f" : "m"

	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			var/image/underlay = image(icon = 'icons/effects/genetics.dmi', icon_state = gene.OnDrawUnderlays(src,g,fat), layer = -MUTATIONS_LAYER) // unified sprites required i think, so it will look good even on slime.
			if(underlay)
				standing += underlay

	if(standing.len)
		overlays_standing[MUTATIONS_LAYER]	= standing
		apply_overlay(MUTATIONS_LAYER)


//Call when target overlay should be added/removed
/mob/living/carbon/update_targeted()
	remove_overlay(TARGETED_LAYER)

	if(targeted_by && target_locked)
		overlays_standing[TARGETED_LAYER]	= image("icon"=target_locked, "layer"=-TARGETED_LAYER)
	else if (!targeted_by && target_locked)
		qdel(target_locked)

	apply_overlay(TARGETED_LAYER)


/mob/living/carbon/update_fire() //TG-stuff, fire layer
	remove_overlay(FIRE_LAYER)

	if(on_fire)
		overlays_standing[FIRE_LAYER]	= image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"=-FIRE_LAYER)

	apply_overlay(FIRE_LAYER)


/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/regenerate_icons()
	..()
	if(monkeyizing)		return
	update_mutations()
	update_bodyparts()
	update_bloody_bodyparts()
	update_icons()
	update_transform()
	//Hud Stuff
	update_hud()


/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

// Don't call this proc directly (i mean, only call it when you exactly know why you need that), update_inv_limb() handles it when needed.
/mob/living/carbon/proc/update_inv_mob(SLOT, multi = FALSE)
	if(multi)
		if(islist(SLOT))
			for(var/slot_to_update in SLOT)
				update_inv_mob(slot_to_update)
		else
			for(var/slot_to_update in bodyparts_slot_by_name)
				update_inv_mob(slot_to_update)
		return

	remove_inv_overlay(SLOT)

	var/obj/item/bodypart/BP = bodyparts_slot_by_name[SLOT]
	if(!BP)
		return

	var/list/standing = BP.inv_overlays[SLOT]
	if(!standing)
		return

	overlays_inventory[SLOT] = standing
	apply_inv_overlay(SLOT)

// If mob/limb is holding this item after item's icon has changed and you wan't to update mob/limb overlays - use this proc.
/obj/item/proc/update_inv_item(SLOT)
	if(!slot_bodypart || !slot_equipped)
		return

	if(SLOT && SLOT != slot_equipped) // if you want to update overlays only while item is equipped in specified slot.
		return

	slot_bodypart.update_inv_limb(slot_equipped)

// multi (TRUE) - pass "nothing or null" in SLOT to rebuild all inventory overlays for this bodypart.
// multi (TRUE) - pass "list of slots" in SLOT to update exact inventory overlays.
//(see code\_DEFINES\inventory.dm for slot names).
/obj/item/bodypart/proc/update_inv_limb(SLOT, multi = FALSE)
	if(!SLOT && !multi)
		return

	if(multi)
		if(islist(SLOT))
			for(var/slot_to_update in SLOT)
				update_inv_limb(slot_to_update)
		else
			for(var/slot_to_update in inv_box_data)
				update_inv_limb(slot_to_update)
		return

	overlays -= inv_overlays[SLOT]
	inv_overlays[SLOT] = null

	if(!inv_box_data.len)
		return

	var/obj/item/O = item_in_slot[SLOT]
	if(O)
		var/i_icon = get_item_icon_for_mob(SLOT, O) // hands uses separate files for mob icons.
		var/i_fat = inv_box_data[SLOT]["support_fat_people"] // only uniforms actually support this, so if possible, its better to to do something about this.

		if(owner)
			if(i_fat && (owner.disabilities & FAT))
				if(O.flags & ONESIZEFITSALL)
					i_icon = 'icons/mob/uniform_fat.dmi'
				else // TODO we should process that else where, maybe even make something like on_gain_disability() proc.
					to_chat(owner, "\red You burst out of \the [O]!")
					owner.dropItemToGround(O)
					return
			update_inv_hud(SLOT)
			if(inv_box_data[SLOT]["no_mob_overlay"])
				return

		var/i_state = inv_box_data[SLOT]["icon_state_as_item_state"] // item_state will be used for mob overlay instead of icon_state.
		var/i_locked_state = inv_box_data[SLOT]["mob_icon_state"] // if set, passed string will be used for mob overlay icon_state (has top priority over other "icon_state" vars).
		var/i_blood = inv_box_data[SLOT]["mob_blood_overlay"] // whenever this item can become bloody.
		var/i_tie = inv_box_data[SLOT]["has_tie"] // again, mostly for uniforms.. accessories like captain medals or holster.
		var/i_simple = inv_box_data[SLOT]["simple_overlays"] // whenever we wan't to check sprite sheets, icon_override or not. used by simple item slots like id, belt, etc.
		var/i_color = inv_box_data[SLOT]["icon_state_as_color"] // some clothes uses icon_color var instead of icon_state.
		var/i_layer = inv_box_data[SLOT]["slot_layer"] // who should be displayer over who.

		var/t_state = O.icon_state
		if(i_locked_state)
			t_state = i_locked_state
		else
			if(i_state && O.item_state)
				t_state = O.item_state
			if(i_color && O.item_color)
				t_state = O.item_color

		var/list/standing = list()

		var/image/I = construct_special_inv_icon(O, SLOT, i_icon, t_state, i_simple)
		if(!I)
			if(!i_simple)
				if(!O.icon_custom || O.icon_override || species.sprite_sheets[SLOT])
					I = image(icon = (O.icon_override ? O.icon_override : (species.sprite_sheets[SLOT] ? species.sprite_sheets[SLOT] : i_icon)), icon_state = t_state)
				else
					I = image(icon = O.icon_custom, icon_state = "[t_state]_mob")
			else
				I = image(icon = i_icon, icon_state = t_state)

		I.layer = i_layer
		I.color = O.color
		standing += I

		if(i_tie)
			var/obj/item/clothing/under/U = O
			if(U.hastie)
				var/tie_color = U.hastie.item_color
				if(!tie_color)
					tie_color = U.hastie.icon_state
				var/image/tie
				if(U.hastie.icon_custom)
					tie = image(icon = U.hastie.icon_custom, icon_state = "[tie_color]_mob", layer = i_layer + 0.1)
				else
					tie = image(icon = 'icons/mob/ties.dmi', icon_state = "[tie_color]", layer = i_layer + 0.1)
				tie.color = U.hastie.color
				standing += tie

		if(i_blood && O.blood_DNA)
			var/image/bloodsies
			if(i_blood == "by_type")
				var/obj/item/clothing/suit/S = O
				bloodsies = image(icon = species.blood_overlays, icon_state = "[S.blood_overlay_type]blood", layer = i_layer + 0.2)
			else
				bloodsies = image(icon = species.blood_overlays, icon_state = i_blood, layer = i_layer + 0.2)
			bloodsies.color = O.blood_color
			standing += bloodsies

		inv_overlays[SLOT] = standing

	if(owner)
		switch(SLOT)
			if(slot_head)
				owner.update_bodypart(BP_HEAD) // hair
			if(slot_wear_suit)
				owner.update_bodypart(BP_GROIN) // tail
		owner.update_inv_mob(SLOT, multi)
	else
		switch(SLOT)
			if(slot_head)
				if(body_zone == BP_HEAD)
					update_limb() // hair
			if(slot_wear_suit)
				if(body_zone == BP_GROIN)
					update_limb() // tail
		if(inv_overlays[SLOT])
			overlays += inv_overlays[SLOT]

/obj/item/bodypart/proc/construct_special_inv_icon()
	return

/obj/item/bodypart/chest/unbreakable/dog/construct_special_inv_icon(obj/item/O, SLOT, i_icon, t_state, i_simple)
	var/image/body_icon
	switch(SLOT)
		if(slot_handcuffed)
			body_icon = image("icon" = i_icon, "icon_state" = "handcuff1")
		if(slot_legcuffed)
			body_icon = image("icon" = i_icon, "icon_state" = "legcuff1")
		if(slot_back)
			var/i_state = "backpack"

			if(istype(O, /obj/item/clothing/suit/armor))
				i_state = "armor"
			else if(istype(O, /obj/item/weapon/storage/backpack/satchel))
				i_state = "satchel"
			else if(istype(O, /obj/item/weapon/storage/backpack/dufflebag))
				i_state = "duffbag"

			body_icon = image("icon" = i_icon, "icon_state" = i_state)

			if(owner)
				if(owner.lying || owner.crawling)
					body_icon.icon_state = i_state + "_lie"
				else if(owner.resting)
					body_icon.icon_state = i_state + "_sit"

	return body_icon

/obj/item/bodypart/head/unbreakable/dog/construct_special_inv_icon(obj/item/O, SLOT, i_icon, t_state, i_simple)
	var/lie
	var/rest
	var/hand
	if(owner)
		hand = SLOT == slot_r_hand
		lie = owner.lying || owner.crawling
		if(!lie)
			rest = owner.resting

	var/list/has_corgi_icons = list(
	/obj/item/clothing/head/helmet,                 /obj/item/clothing/glasses/sunglasses,
	/obj/item/clothing/head/caphat,                 /obj/item/clothing/head/collectable/captain,
	/obj/item/clothing/head/that,                   /obj/item/clothing/head/kitty,
	/obj/item/clothing/head/collectable/kitty,      /obj/item/clothing/head/rabbitears,
	/obj/item/clothing/head/collectable/rabbitears, /obj/item/clothing/head/beret,
	/obj/item/clothing/head/collectable/beret,      /obj/item/clothing/head/det_hat,
	/obj/item/clothing/head/nursehat,               /obj/item/clothing/head/pirate,
	/obj/item/clothing/head/collectable/pirate,     /obj/item/clothing/head/ushanka,
	/obj/item/clothing/head/chefhat,                /obj/item/clothing/head/collectable/chef,
	/obj/item/clothing/head/collectable/police,     /obj/item/clothing/head/wizard/fake,
	/obj/item/clothing/head/wizard,                 /obj/item/clothing/head/collectable/wizard,
	/obj/item/clothing/head/hardhat/yellow,         /obj/item/clothing/head/collectable/hardhat,
	/obj/item/clothing/head/hardhat/white,          /obj/item/clothing/head/helmet/space/santahat,
	/obj/item/clothing/head/collectable/paper,      /obj/item/clothing/head/soft)

	if(!hand && SLOT == slot_head && (O.type in has_corgi_icons))
		return image(icon = 'icons/mob/corgi_head.dmi', icon_state = "[O.icon_state][lie ? "_lie" : ""]")

	var/cache_key = "[O.type]_[hand]_[t_state]_[i_simple]_[lie]_[rest]"
	var/image/body_icon = special_inv_icon[cache_key]
	if(!body_icon)
		var/prepared_icon
		var/prepared_icon_state
		if(!i_simple)
			if(!O.icon_custom || O.icon_override || species.sprite_sheets[SLOT])
				prepared_icon = O.icon_override ? O.icon_override : species.sprite_sheets[SLOT] ? species.sprite_sheets[SLOT] : i_icon
				prepared_icon_state = t_state
			else
				prepared_icon = O.icon_custom
				prepared_icon_state = "[t_state]_mob"
		else
			prepared_icon = i_icon
			prepared_icon_state = t_state

		if(!(prepared_icon_state in icon_states(prepared_icon)))
			return

		body_icon = image(icon = prepared_icon, icon_state = prepared_icon_state)

		var/icon/I = new(body_icon.icon, t_state)

		var/icon/temp_icon
		if(hand)
			var/icon/mask_stand = icon('icons/mob/corgi.dmi', "corgi_mask")

			temp_icon = icon(I, t_state, SOUTH)
			temp_icon.Shift(WEST, 6)
			temp_icon.Shift(NORTH, 3)
			I.Insert(icon(temp_icon, dir = SOUTH), dir = SOUTH)

			temp_icon.Blend(icon(mask_stand, icon_state, dir = NORTH), ICON_MULTIPLY)
			I.Insert(icon(temp_icon, dir = SOUTH), dir = NORTH)

			temp_icon = icon(I, t_state, WEST)
			temp_icon.Shift(EAST, 14)
			temp_icon.Shift(NORTH, 3)
			//temp_icon.Blend(icon(mask_stand, icon_state, dir = EAST), ICON_MULTIPLY)
			I.Insert(icon(temp_icon, dir = WEST), dir = EAST)

			temp_icon.Flip(WEST)
			I.Insert(icon(temp_icon, dir = WEST), dir = WEST)
		else
			temp_icon = icon(I, t_state, EAST)
			temp_icon.Shift(EAST, 5)
			I.Insert(icon(temp_icon, dir = EAST), dir = EAST)

			temp_icon = icon(I, t_state, WEST)
			temp_icon.Shift(WEST, 7)
			I.Insert(icon(temp_icon, dir = WEST), dir = WEST)

			I.Shift(EAST, 1)
			I.Shift(SOUTH, 7)

		if(lie)
			var/icon/mask_lie = icon('icons/mob/corgi.dmi', "corgi_mask_lie")
			temp_icon = icon(I)
			temp_icon.Shift(SOUTH, 13) //lying state
			temp_icon.Blend(icon(mask_lie, icon_state, dir = NORTH), ICON_MULTIPLY)
			I.Insert(icon(temp_icon), t_state)

		//corgi_icons[cached_icon_string] =
		special_inv_icon[cache_key] = image("icon" = I, "icon_state" = t_state)
		body_icon = special_inv_icon[cache_key]

	return body_icon

/obj/item/bodypart/proc/update_inv_hud(SLOT) // Don't call this proc directly (only if you know exactly, why you need that).
	if(!owner)
		return

	if(!SLOT) // if no slot provided, we will update all slots.
		for(var/slot_to_update in inv_box_data)
			update_inv_hud(slot_to_update)
		return

	var/obj/item/O = item_in_slot[SLOT]
	if(O && !inv_box_data[SLOT]["no_hud"] && !inv_box_data[SLOT]["no_item_on_screen"])
		var/i_screen_loc = inv_box_data[SLOT]["screen_loc"] // where we will see this item on our screen.
		var/i_other = inv_box_data[SLOT]["other"] // this is used to determine if we should check hud_shown, because player may minimized hud with equipment (need better name for this var).
		                                          // this var comes from datum/hud and its list\adding and list\other, so if the element is in "other" list, then we do special checks.
		if(owner.client && owner.hud_used)
			if(i_other && owner.hud_used.hud_shown)
				if(owner.hud_used.inventory_shown) // if the inventory is open ...
					O.screen_loc = i_screen_loc    //...draw the item in the inventory screen
				owner.client.screen += O           // Either way, add the item to the HUD
			else
				O.screen_loc = i_screen_loc
				owner.client.screen += O

/obj/item/bodypart/proc/get_item_icon_for_mob(SLOT, obj/item/O) // Should be used only in update_inv_limb() proc.
	if(can_grasp)
		switch(body_zone)
			if(BP_L_ARM)
				return O.lefthand_file
			if(BP_R_ARM)
				return O.righthand_file
			else
				if(SLOT == slot_r_hand) // current creatures that technically has only one hand, uses right hand slot.
					return O.lefthand_file // <- yes, left hand file for right hand slot!
	return inv_box_data[SLOT]["mob_icon_path"]


/mob/living/carbon/update_hud()	//TODO: do away with this if possible
	if(client)
		client.screen |= contents
		if(hud_used)
			hud_used.hidden_inventory_update() 	//Updates the screenloc of the items on the 'other' inventory bar


/mob/living/carbon/proc/get_overlays_copy()
	var/list/out = new
	out = overlays_standing.Copy()
	return out

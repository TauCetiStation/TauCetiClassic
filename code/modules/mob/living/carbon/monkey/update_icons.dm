//Monkey Overlays Indexes////////
//#define M_FIRE_LOWER_LAYER     * // --should be in underlays (underlays bad); or we need to make BODY part as overlays layer too (like humans); or remove
#define M_R_HAND_LAYER           8
#define M_L_HAND_LAYER           7
#define M_HANDCUFF_LAYER         6
#define M_BACK_LAYER             5
#define M_MASK_LAYER             4
#define M_HEAD_LAYER             3
#define M_FIRE_UPPER_LAYER       2
//#define TARGETED_LAYER           1 // For recordkeeping
#define M_TOTAL_LAYERS           8
/////////////////////////////////

/mob/living/carbon/monkey
	overlays_standing = new /list(M_TOTAL_LAYERS)

/mob/living/carbon/monkey/regenerate_icons()
	..()
	update_inv_head()
	update_inv_wear_mask()
	update_inv_back()
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_handcuffed()
	update_icons()
	update_transform()
	//Hud Stuff
	update_hud()
	return

/mob/living/carbon/monkey/update_icons()
	..()
	update_hud()
	//lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again

	update_fire_underlay()


////////
/mob/living/carbon/monkey/update_inv_head()
	remove_standing_overlay(M_HEAD_LAYER)

	if(head)
		var/image/head_layer = image("icon"= 'icons/mob/head.dmi', "icon_state" = "[head.icon_state]", layer = -M_HEAD_LAYER)
		head_layer.pixel_y = -2
		overlays_standing[M_HEAD_LAYER] = head_layer

	apply_standing_overlay(M_HEAD_LAYER)

/mob/living/carbon/monkey/update_inv_wear_mask()
	remove_standing_overlay(M_MASK_LAYER)

	if( wear_mask && istype(wear_mask, /obj/item/clothing/mask) )
		if(wear_mask:icon_custom)
			overlays_standing[M_MASK_LAYER]	= image("icon" = wear_mask:icon_custom, "icon_state" = "[wear_mask.icon_state]_mob", layer = -M_MASK_LAYER)
		else
			overlays_standing[M_MASK_LAYER]	= image("icon" = 'icons/mob/mask.dmi', "icon_state" = "[wear_mask.icon_state]", layer = -M_MASK_LAYER)
		wear_mask.screen_loc = ui_monkey_mask
	else
		overlays_standing[M_MASK_LAYER]	= null

	apply_standing_overlay(M_MASK_LAYER)


/mob/living/carbon/monkey/update_inv_r_hand()
	remove_standing_overlay(M_R_HAND_LAYER)

	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state
		if(r_hand:icon_custom)
			overlays_standing[M_R_HAND_LAYER]	= image("icon" = r_hand:icon_custom, "icon_state" = "[t_state]_r", layer = -M_R_HAND_LAYER)
		else
			overlays_standing[M_R_HAND_LAYER]	= image("icon" = r_hand.righthand_file, "icon_state" = t_state, layer = -M_R_HAND_LAYER)
		r_hand.screen_loc = ui_rhand
		if (handcuffed) drop_r_hand()
	else
		overlays_standing[M_R_HAND_LAYER]	= null

	apply_standing_overlay(M_R_HAND_LAYER)

/mob/living/carbon/monkey/update_inv_l_hand()
	remove_standing_overlay(M_L_HAND_LAYER)

	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)	 t_state = l_hand.icon_state
		if(l_hand:icon_custom)
			overlays_standing[M_L_HAND_LAYER]	= image("icon" = l_hand:icon_custom, "icon_state" = "[t_state]_l", layer = -M_L_HAND_LAYER)
		else
			overlays_standing[M_L_HAND_LAYER]	= image("icon" = l_hand.lefthand_file, "icon_state" = t_state, layer = -M_L_HAND_LAYER)
		l_hand.screen_loc = ui_lhand
		if (handcuffed) drop_l_hand()
	else
		overlays_standing[M_L_HAND_LAYER]	= null

	apply_standing_overlay(M_L_HAND_LAYER)


/mob/living/carbon/monkey/update_inv_back()
	remove_standing_overlay(M_BACK_LAYER)

	if(back)
		if(back:icon_custom)
			overlays_standing[M_BACK_LAYER]	= image("icon" = back:icon_custom, "icon_state" = "[back.icon_state]_mob", layer = -M_BACK_LAYER)
		else
			overlays_standing[M_BACK_LAYER]	= image("icon" = 'icons/mob/back.dmi', "icon_state" = "[back.icon_state]", layer = -M_BACK_LAYER)
		back.screen_loc = ui_monkey_back
	else
		overlays_standing[M_BACK_LAYER]	= null

	apply_standing_overlay(M_BACK_LAYER)

/mob/living/carbon/monkey/diona/update_inv_back()
	remove_standing_overlay(M_BACK_LAYER)

	if(back)
		var/icon_path = 'icons/mob/back.dmi'
		if(istype(back, /obj/item/weapon/storage/backpack) || istype(back, /obj/item/weapon/bedsheet) || istype(back, /obj/item/weapon/tank))
			icon_path = 'icons/mob/diona_back.dmi'
		overlays_standing[M_BACK_LAYER] = image("icon" = icon_path, "icon_state" = "[back.icon_state]", layer = -M_BACK_LAYER)
		back.screen_loc = ui_monkey_back
	else
		overlays_standing[M_BACK_LAYER] = null

	apply_standing_overlay(M_BACK_LAYER)

/mob/living/carbon/monkey/update_inv_handcuffed()
	remove_standing_overlay(M_HANDCUFF_LAYER)

	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()
		overlays_standing[M_HANDCUFF_LAYER]	= image("icon" = 'icons/mob/monkey.dmi', "icon_state" = "handcuff1", layer = -M_HANDCUFF_LAYER)
	else
		overlays_standing[M_HANDCUFF_LAYER]	= null

	apply_standing_overlay(M_HANDCUFF_LAYER)


/mob/living/carbon/monkey/update_hud()
	if (client)
		client.screen |= contents

//Call when target overlay should be added/removed
/mob/living/carbon/monkey/update_targeted()
	remove_standing_overlay(TARGETED_LAYER)

	if (targeted_by && target_locked)
		overlays_standing[TARGETED_LAYER]	= target_locked
	else if (!targeted_by && target_locked)
		qdel(target_locked)

	apply_standing_overlay(TARGETED_LAYER)

/mob/living/carbon/monkey/update_fire()
	remove_standing_overlay(M_FIRE_UPPER_LAYER)

	update_fire_underlay()
	//cut_overlay(overlays_standing[M_FIRE_LOWER_LAYER])
	if(on_fire)
		//overlays_standing[M_FIRE_LOWER_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="generic_underlay", layer = -M_FIRE_LOWER_LAYER)
		var/image/over = image("icon"='icons/mob/OnFire.dmi', "icon_state"="generic_overlay", layer = -M_FIRE_UPPER_LAYER)
		over.plane = LIGHTING_LAMPS_PLANE
		overlays_standing[M_FIRE_UPPER_LAYER] = over
		//add_overlay(overlays_standing[M_FIRE_LOWER_LAYER])
	//else
		//overlays_standing[M_FIRE_LOWER_LAYER] = null

	apply_standing_overlay(M_FIRE_UPPER_LAYER)

/mob/living/carbon/monkey/proc/update_fire_underlay()
	underlays.Cut()

	if(on_fire)
		underlays += image(icon = 'icons/mob/OnFire.dmi', icon_state = "generic_underlay")



//Monkey Overlays Indexes////////
//#undef M_FIRE_LOWER_LAYER
#undef M_R_HAND_LAYER
#undef M_L_HAND_LAYER
#undef M_HANDCUFF_LAYER
#undef M_BACK_LAYER
#undef M_MASK_LAYER
#undef M_HEAD_LAYER
#undef M_FIRE_UPPER_LAYER
#undef M_TOTAL_LAYERS


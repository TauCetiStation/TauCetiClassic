//Xeno Overlays Indexes//////////
//#define X_FIRE_LOWER_LAYER  * // --should be in underlays (underlays bad); or we need to make BODY part as overlays layer too (like humans); or remove
#define X_R_HAND_LAYER        7
#define X_L_HAND_LAYER        6
#define X_SUIT_LAYER          5
#define X_HEAD_LAYER          4
#define X_FIRE_UPPER_LAYER    3
#define X_SHRIEC_LAYER        2
//#define TARGETED_LAYER        1 // For recordkeeping
#define X_TOTAL_LAYERS        7
/////////////////////////////////

/mob/living/carbon/xenomorph
	var/list/overlays_standing[X_TOTAL_LAYERS]
	var/fire_underlay_state // wannabe overlay

/mob/living/carbon/xenomorph/humanoid/update_icons()
	update_hud()		//TODO: remove the need for this to be here
	cut_overlays()
	for(var/image/I in overlays_standing)
		add_overlay(I)

	update_fire_underlay()

	if(stat == DEAD)
		//If we mostly took damage from fire
		if(fireloss > 125)
			icon_state = "alien[caste]_husked"
		else
			icon_state = "alien[caste]_dead"
	else if((stat == UNCONSCIOUS && !IsSleeping()) || weakened)
		icon_state = "alien[caste]_unconscious"
	else if(leap_on_click)
		icon_state = "alien[caste]_pounce"
	else if(lying || crawling)
		icon_state = "alien[caste]_sleep"
	else if(m_intent == MOVE_INTENT_RUN)
		icon_state = "alien[caste]_running"
	else
		icon_state = "alien[caste]_s"

	if(leaping)
		if(alt_icon == initial(alt_icon))
			var/old_icon = icon
			icon = alt_icon
			alt_icon = old_icon
		icon_state = "alien[caste]_leap"
		pixel_x = -32
		pixel_y = -32
	else
		if(alt_icon != initial(alt_icon))
			var/old_icon = icon
			icon = alt_icon
			alt_icon = old_icon

		pixel_x = get_pixel_x_offset()
		pixel_y = get_pixel_y_offset()

		default_pixel_x = pixel_x
		default_pixel_y = pixel_y

/mob/living/carbon/xenomorph/humanoid/regenerate_icons()
	..()
	if (notransform)
		return

	update_inv_head(0)
	update_inv_wear_suit(0)
	update_inv_r_hand(0)
	update_inv_l_hand(0)
	update_inv_pockets(0)
	update_hud()
	update_transform()

/mob/living/carbon/xenomorph/humanoid/update_transform() //The old method of updating lying/standing was update_icons(). Aliens still expect that.
	update_icons()
	..()

/mob/living/carbon/xenomorph/humanoid/get_lying_angle()	//so that the sprite does not unfold
	return

/mob/living/carbon/xenomorph/humanoid/update_hud()
	//TODO
	if(client)
		client.screen |= contents



/mob/living/carbon/xenomorph/humanoid/update_inv_wear_suit(update_icons = TRUE)
	if(wear_suit)
		var/t_state = wear_suit.item_state
		if(!t_state)
			t_state = wear_suit.icon_state
		var/image/standing = image(icon = 'icons/mob/mob.dmi', icon_state = "[t_state]")

		if(wear_suit.blood_DNA)
			var/t_suit = "suit"
			if( istype(wear_suit, /obj/item/clothing/suit/armor) )
				t_suit = "armor"
			standing.overlays += image(icon = 'icons/effects/blood.dmi', icon_state = "[t_suit]blood")

		//TODO
		wear_suit.screen_loc = ui_alien_oclothing
		if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			drop_from_inventory(handcuffed)
			drop_r_hand()
			drop_l_hand()

		standing.layer = -X_SUIT_LAYER
		overlays_standing[X_SUIT_LAYER] = standing
	else
		overlays_standing[X_SUIT_LAYER] = null
	if(update_icons)
		update_icons()


/mob/living/carbon/xenomorph/humanoid/update_inv_head(update_icons = TRUE)
	if (head)
		var/t_state = head.item_state
		if(!t_state)
			t_state = head.icon_state
		var/image/standing = image(icon = 'icons/mob/mob.dmi', icon_state = "[t_state]")
		if(head.blood_DNA)
			standing.overlays += image(icon = 'icons/effects/blood.dmi', icon_state = "helmetblood")
		head.screen_loc = ui_alien_head
		standing.layer = -X_HEAD_LAYER
		overlays_standing[X_HEAD_LAYER] = standing
	else
		overlays_standing[X_HEAD_LAYER] = null
	if(update_icons)
		update_icons()


/mob/living/carbon/xenomorph/humanoid/update_inv_pockets(update_icons = TRUE)
	if(l_store)		l_store.screen_loc = ui_storage1
	if(r_store)		r_store.screen_loc = ui_storage2
	if(update_icons)	update_icons()


/mob/living/carbon/xenomorph/humanoid/update_inv_r_hand(update_icons = TRUE)
	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state
		r_hand.screen_loc = ui_rhand
		overlays_standing[X_R_HAND_LAYER] = image(icon = r_hand.righthand_file, icon_state = t_state, layer = -X_R_HAND_LAYER)
	else
		overlays_standing[X_R_HAND_LAYER] = null
	if(update_icons)
		update_icons()

/mob/living/carbon/xenomorph/humanoid/update_inv_l_hand(update_icons = TRUE)
	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state
		l_hand.screen_loc = ui_lhand
		overlays_standing[X_L_HAND_LAYER] = image(icon = l_hand.lefthand_file, icon_state = t_state, layer = -X_L_HAND_LAYER)
	else
		overlays_standing[X_L_HAND_LAYER] = null
	if(update_icons)
		update_icons()

//Call when target overlay should be added/removed
/mob/living/carbon/xenomorph/humanoid/update_targeted(update_icons = TRUE)
	if(targeted_by && target_locked)
		overlays_standing[TARGETED_LAYER] = image(icon = target_locked, layer = -TARGETED_LAYER)
	else if(!targeted_by && target_locked)
		qdel(target_locked)
	if(!targeted_by)
		overlays_standing[TARGETED_LAYER] = null
	if(update_icons)
		update_icons()

/mob/living/carbon/xenomorph/humanoid/queen
	fire_underlay_state = null

/mob/living/carbon/xenomorph/humanoid/queen/update_fire()
	cut_overlay(overlays_standing[X_FIRE_UPPER_LAYER])
	if(on_fire)
		overlays_standing[X_FIRE_UPPER_LAYER] = image(icon = 'icons/mob/alienqueen.dmi', icon_state = icon_state + "_fire", layer = -X_FIRE_UPPER_LAYER)
		add_overlay(overlays_standing[X_FIRE_UPPER_LAYER])
		return
	overlays_standing[X_FIRE_UPPER_LAYER] = null

/mob/living/carbon/xenomorph/humanoid/queen/large/update_fire()
	cut_overlay(overlays_standing[X_FIRE_UPPER_LAYER])
	if(on_fire)
		overlays_standing[X_FIRE_UPPER_LAYER] = image(icon = 'icons/mob/alienqueen.dmi', icon_state = replacetext(icon_state, "_old", "") + "_fire", layer = -X_FIRE_UPPER_LAYER)
		add_overlay(overlays_standing[X_FIRE_UPPER_LAYER])
		return
	overlays_standing[X_FIRE_UPPER_LAYER] = null

/mob/living/carbon/xenomorph/humanoid
	fire_underlay_state = "human_underlay"

/mob/living/carbon/xenomorph/humanoid/update_fire()
	update_fire_underlay()
	cut_overlay(overlays_standing[X_FIRE_UPPER_LAYER])
	//cut_overlay(overlays_standing[X_FIRE_LOWER_LAYER])
	if(on_fire)
		overlays_standing[X_FIRE_UPPER_LAYER] = image(icon = 'icons/mob/OnFire.dmi', icon_state = "human_overlay", layer = -X_FIRE_UPPER_LAYER)
		//overlays_standing[X_FIRE_LOWER_LAYER] = image(icon = 'icons/mob/OnFire.dmi', icon_state = "human_underlay", layer = -X_FIRE_LOWER_LAYER)
		add_overlay(overlays_standing[X_FIRE_UPPER_LAYER])
		//add_overlay(overlays_standing[X_FIRE_LOWER_LAYER])
		return
	overlays_standing[X_FIRE_UPPER_LAYER] = null
	//overlays_standing[X_FIRE_LOWER_LAYER] = null

/mob/living/carbon/xenomorph
	fire_underlay_state = "generic_underlay"

/mob/living/carbon/xenomorph/update_fire()
	update_fire_underlay()
	cut_overlay(overlays_standing[X_FIRE_UPPER_LAYER])
	//cut_overlay(overlays_standing[X_FIRE_LOWER_LAYER])
	if(on_fire)
		overlays_standing[X_FIRE_UPPER_LAYER] = image(icon = 'icons/mob/OnFire.dmi', icon_state = "generic_overlay", layer = -X_FIRE_UPPER_LAYER)
		//overlays_standing[X_FIRE_LOWER_LAYER] = image(icon = 'icons/mob/OnFire.dmi', icon_state = "generic_underlay", layer = -X_FIRE_LOWER_LAYER)
		add_overlay(overlays_standing[X_FIRE_UPPER_LAYER])
		//add_overlay(overlays_standing[X_FIRE_LOWER_LAYER])
		return
	overlays_standing[X_FIRE_UPPER_LAYER] = null
	//overlays_standing[X_FIRE_LOWER_LAYER] = null

/mob/living/carbon/xenomorph/humanoid/proc/create_shriekwave()
	overlays_standing[X_SHRIEC_LAYER] = image(icon = 'icons/mob/alienqueen.dmi', icon_state = "shriek_waves", layer = -X_SHRIEC_LAYER)
	add_overlay(overlays_standing[X_SHRIEC_LAYER])
	addtimer(CALLBACK(src, .proc/remove_xeno_overlay, X_SHRIEC_LAYER), 30)

/mob/living/carbon/xenomorph/proc/remove_xeno_overlay(cache_index)
	if(overlays_standing[cache_index])
		cut_overlay(overlays_standing[cache_index])
		overlays_standing[cache_index] = null

/mob/living/carbon/xenomorph/proc/update_fire_underlay()
	if(!fire_underlay_state)
		return

	underlays.Cut()

	if(on_fire)
		underlays += image(icon = 'icons/mob/OnFire.dmi', icon_state = fire_underlay_state)


//Xeno Overlays Indexes//////////
//#undef X_FIRE_LOWER_LAYER
#undef X_R_HAND_LAYER
#undef X_L_HAND_LAYER
#undef X_SUIT_LAYER
#undef X_HEAD_LAYER
#undef X_FIRE_UPPER_LAYER
#undef X_SHRIEC_LAYER
#undef X_TOTAL_LAYERS

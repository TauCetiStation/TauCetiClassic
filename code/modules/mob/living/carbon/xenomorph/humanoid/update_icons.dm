//Xeno Overlays Indexes//////////
#define X_R_HAND_LAYER        7
#define X_L_HAND_LAYER        6
#define X_SUIT_LAYER          5
#define X_HEAD_LAYER          4
#define X_FIRE_UPPER_LAYER    3
#define X_TOTAL_LAYERS        7
/////////////////////////////////

/mob/living/carbon/xenomorph
	overlays_standing = new /list(X_TOTAL_LAYERS)
	var/fire_underlay_state // wannabe overlay

/mob/living/carbon/xenomorph/humanoid/update_icons()
	update_hud()		//TODO: remove the need for this to be here
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

	update_inv_head()
	update_inv_wear_suit()
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_pockets()
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



/mob/living/carbon/xenomorph/humanoid/update_inv_wear_suit()
	remove_standing_overlay(X_SUIT_LAYER)

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

	apply_standing_overlay(X_SUIT_LAYER)


/mob/living/carbon/xenomorph/humanoid/update_inv_head()
	remove_standing_overlay(X_HEAD_LAYER)

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

	apply_standing_overlay(X_HEAD_LAYER)


/mob/living/carbon/xenomorph/humanoid/update_inv_pockets()
	if(l_store)
		l_store.screen_loc = ui_storage1
	if(r_store)
		r_store.screen_loc = ui_storage2


/mob/living/carbon/xenomorph/humanoid/update_inv_r_hand()
	remove_standing_overlay(X_R_HAND_LAYER)

	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state
		r_hand.screen_loc = ui_rhand
		overlays_standing[X_R_HAND_LAYER] = image(icon = r_hand.righthand_file, icon_state = t_state, layer = -X_R_HAND_LAYER)

	apply_standing_overlay(X_R_HAND_LAYER)

/mob/living/carbon/xenomorph/humanoid/update_inv_l_hand()
	remove_standing_overlay(X_L_HAND_LAYER)

	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state
		l_hand.screen_loc = ui_lhand
		overlays_standing[X_L_HAND_LAYER] = image(icon = l_hand.lefthand_file, icon_state = t_state, layer = -X_L_HAND_LAYER)
	else
		overlays_standing[X_L_HAND_LAYER] = null

	apply_standing_overlay(X_L_HAND_LAYER)

//Call when target overlay should be added/removed
/mob/living/carbon/xenomorph/humanoid/update_targeted()
	remove_standing_overlay(TARGETED_LAYER)

	if(targeted_by && target_locked)
		overlays_standing[TARGETED_LAYER] = image(icon = target_locked, layer = -TARGETED_LAYER)
	else if(!targeted_by && target_locked)
		qdel(target_locked)

	apply_standing_overlay(TARGETED_LAYER)

/mob/living/carbon/xenomorph/humanoid/queen
	fire_underlay_state = null

/mob/living/carbon/xenomorph/humanoid/queen/update_fire()
	remove_standing_overlay(X_FIRE_UPPER_LAYER)

	if(on_fire)
		var/image/over = image(icon = 'icons/mob/alienqueen.dmi', icon_state = icon_state + "_fire", layer = -X_FIRE_UPPER_LAYER)
		over.plane = LIGHTING_LAMPS_PLANE
		overlays_standing[X_FIRE_UPPER_LAYER] = over

	apply_standing_overlay(X_FIRE_UPPER_LAYER)

/mob/living/carbon/xenomorph/humanoid/queen/large/update_fire()
	remove_standing_overlay(X_FIRE_UPPER_LAYER)

	if(on_fire)
		var/image/over = image(icon = 'icons/mob/alienqueen.dmi', icon_state = replacetext(icon_state, "_old", "") + "_fire", layer = -X_FIRE_UPPER_LAYER)
		over.plane = LIGHTING_LAMPS_PLANE
		overlays_standing[X_FIRE_UPPER_LAYER] = over

	apply_standing_overlay(X_FIRE_UPPER_LAYER)

/mob/living/carbon/xenomorph/humanoid
	fire_underlay_state = "human_underlay"

/mob/living/carbon/xenomorph/humanoid/update_fire()
	remove_standing_overlay(X_FIRE_UPPER_LAYER)

	update_fire_underlay()
	//cut_overlay(overlays_standing[X_FIRE_LOWER_LAYER])
	if(on_fire)
		var/image/over = image(icon = 'icons/mob/OnFire.dmi', icon_state = "human_overlay", layer = -X_FIRE_UPPER_LAYER)
		over.plane = LIGHTING_LAMPS_PLANE
		overlays_standing[X_FIRE_UPPER_LAYER] = over
		//overlays_standing[X_FIRE_LOWER_LAYER] = image(icon = 'icons/mob/OnFire.dmi', icon_state = "human_underlay", layer = -X_FIRE_LOWER_LAYER)
		//add_overlay(overlays_standing[X_FIRE_LOWER_LAYER])
	//overlays_standing[X_FIRE_LOWER_LAYER] = null

	apply_standing_overlay(X_FIRE_UPPER_LAYER)

/mob/living/carbon/xenomorph
	fire_underlay_state = "generic_underlay"

/mob/living/carbon/xenomorph/update_fire()
	remove_standing_overlay(X_FIRE_UPPER_LAYER)

	update_fire_underlay()
	//cut_overlay(overlays_standing[X_FIRE_LOWER_LAYER])
	if(on_fire)
		var/image/over = image(icon = 'icons/mob/OnFire.dmi', icon_state = "generic_overlay", layer = -X_FIRE_UPPER_LAYER)
		over.plane = LIGHTING_LAMPS_PLANE
		overlays_standing[X_FIRE_UPPER_LAYER] = over
		//overlays_standing[X_FIRE_LOWER_LAYER] = image(icon = 'icons/mob/OnFire.dmi', icon_state = "generic_underlay", layer = -X_FIRE_LOWER_LAYER)
		//add_overlay(overlays_standing[X_FIRE_LOWER_LAYER])
	//overlays_standing[X_FIRE_LOWER_LAYER] = null

	apply_standing_overlay(X_FIRE_UPPER_LAYER)

/mob/living/carbon/xenomorph/humanoid/proc/create_shriekwave(shriekwaves_left = 1)
	var/offset_y = 8
	//due to the speed of the shockwaves, it isn't required to be tied to the exact mob movements
	var/stage1_radius = rand(11, 12)
	var/stage2_radius = rand(9, 11)
	var/stage3_radius = rand(8, 10)
	var/stage4_radius = 7.5
	//shockwaves are iterated, counting down once per shriekwave, with the total amount being determined on the respective xeno ability tile
	if(shriekwaves_left > 12)
		shriekwaves_left--
		new /obj/effect/shockwave(get_turf(src), stage1_radius, 0.5, offset_y)
		addtimer(CALLBACK(src, PROC_REF(create_shriekwave), shriekwaves_left), 2)
		return
	if(shriekwaves_left > 8)
		shriekwaves_left--
		new /obj/effect/shockwave(get_turf(src), stage2_radius, 0.5, offset_y)
		addtimer(CALLBACK(src, PROC_REF(create_shriekwave), shriekwaves_left), 3)
		return
	if(shriekwaves_left > 4)
		shriekwaves_left--
		new /obj/effect/shockwave(get_turf(src), stage3_radius, 0.5, offset_y)
		addtimer(CALLBACK(src, PROC_REF(create_shriekwave), shriekwaves_left), 3)
		return
	if(shriekwaves_left > 1)
		shriekwaves_left--
		new /obj/effect/shockwave(get_turf(src), stage4_radius, 0.5, offset_y)
		addtimer(CALLBACK(src, PROC_REF(create_shriekwave), shriekwaves_left), 3)
		return
	if(shriekwaves_left == 1)
		new /obj/effect/shockwave(get_turf(src), 10, 0.6, offset_y)

/mob/living/carbon/xenomorph/proc/update_fire_underlay()
	if(!fire_underlay_state)
		return

	underlays.Cut()

	if(on_fire)
		underlays += image(icon = 'icons/mob/OnFire.dmi', icon_state = fire_underlay_state)


//Xeno Overlays Indexes//////////
#undef X_R_HAND_LAYER
#undef X_L_HAND_LAYER
#undef X_SUIT_LAYER
#undef X_HEAD_LAYER
#undef X_FIRE_UPPER_LAYER
#undef X_TOTAL_LAYERS

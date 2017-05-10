#define LAYERIAN_BACK     6
#define LAYERIAN_MOUTH    5
#define LAYERIAN_HEAD     4
#define LAYERIAN_NECKCUFF 3
#define LAYERIAN_TARGETED 2
#define LAYERIAN_FIRE     1
#define LAYERIANS_TOTAL   6

/mob/living/carbon/human/ian/var/static/list/corgi_icons = list()
/mob/living/carbon/human/ian/var/list/overlays_inv[LAYERIANS_TOTAL]

/mob/living/carbon/human/ian/regenerate_icons()
	update_hud()
	update_transform()

/mob/living/carbon/human/ian/update_hud()
	if(client)
		client.screen |= contents

/*
/mob/living/carbon/human/ian/proc/update_inv_mouth()
	remove_overlay(LAYERIAN_MOUTH)

	if(!mouth)
		return

	mouth.screen_loc = ui_ian_mouth
	if(client && hud_used && hud_used.hud_shown)
		client.screen += mouth

	var/t_state = mouth.item_state
	if(!t_state)
		t_state = mouth.icon_state

	var/skip = FALSE
	if(!(t_state in icon_states(mouth.lefthand_file))) //oh, god, no! plz NO! not those icon_custom, icon_override, icon_graytide, icon_whatever9000namedifferent_icons_with_million_ifs...
		t_state = "uni_item"
		skip = TRUE

	var/image/body_icon
	if(skip)
		body_icon = image("icon" = icon, "icon_state" = t_state, "layer" = -LAYERIAN_MOUTH)
	else
		var/cached_icon_string = "M[mouth.type]_[t_state]"
		if(cached_icon_string in corgi_icons)
			body_icon = corgi_icons[cached_icon_string]
		else
			var/icon/I = new(mouth.lefthand_file, t_state)

			var/icon/mask = icon(icon, "[icon_state]_mask")

			var/icon/temp_icon = icon(I, t_state, SOUTH)
			temp_icon.Shift(WEST, 6)
			temp_icon.Shift(NORTH, 3)
			I.Insert(icon(temp_icon, dir = SOUTH), dir = SOUTH)

			temp_icon.Blend(icon(mask, icon_state, dir = NORTH), ICON_MULTIPLY)
			I.Insert(icon(temp_icon, dir = SOUTH), dir = NORTH)

			temp_icon = icon(I, t_state, WEST)
			temp_icon.Shift(EAST, 14)
			temp_icon.Shift(NORTH, 3)
			//temp_icon.Blend(icon(mask, icon_state, dir = EAST), ICON_MULTIPLY)
			I.Insert(icon(temp_icon, dir = WEST), dir = EAST)

			temp_icon.Flip(WEST)
			I.Insert(icon(temp_icon, dir = WEST), dir = WEST)

			temp_icon = icon(I)
			temp_icon.Shift(SOUTH, 13) //lying state
			I.Insert(icon(temp_icon), t_state + "_lie")

			corgi_icons[cached_icon_string] = image("icon" = I, "icon_state" = t_state, "layer" = -LAYERIAN_MOUTH)
			body_icon = corgi_icons[cached_icon_string]

	body_icon.color = mouth.color
	if(pose_last & (POSE_REST | POSE_STAT))
		body_icon.icon_state = t_state + "_lie"
	else
		body_icon.icon_state = t_state

	overlays_inv[LAYERIAN_MOUTH] = body_icon

	apply_overlay(LAYERIAN_MOUTH)

/mob/living/carbon/human/ian/proc/update_inv_neck()
	//remove_overlay(LAYERIAN_NECKCUFF) incase icons ever will be added.

	if(!neck)
		return

	if(handcuffed)
		dropItemToGround(mouth)

	neck.screen_loc = ui_ian_neck
	if(client && hud_used && hud_used.hud_shown)
		client.screen += neck

	//apply_overlay(LAYERIAN_NECKCUFF)
	*/

/mob/living/carbon/human/ian/update_targeted()
	remove_overlay(LAYERIAN_TARGETED)

	if(targeted_by && target_locked)
		overlays_inv[LAYERIAN_TARGETED] = image("icon"=target_locked, "layer"=-LAYERIAN_TARGETED)
	else if (!targeted_by && target_locked)
		qdel(target_locked)

	apply_overlay(LAYERIAN_TARGETED)

/mob/living/carbon/human/ian/update_fire()
	remove_overlay(LAYERIAN_FIRE)

	if(on_fire)
		overlays_inv[LAYERIAN_FIRE] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Generic_mob_burning", "layer"=-LAYERIAN_FIRE)

	apply_overlay(LAYERIAN_FIRE)

#undef LAYERIAN_BACK
#undef LAYERIAN_MOUTH
#undef LAYERIAN_HEAD
#undef LAYERIAN_NECKCUFF
#undef LAYERIAN_TARGETED
#undef LAYERIAN_FIRE
#undef LAYERIANS_TOTAL

/mob/living/carbon/human/ian/update_transform()
	if(pose_last == pose_prev)
		return
	pose_prev = pose_last

	switch(pose_last)
		if(POSE_NORM)
			icon_state = "corgi"
		if(POSE_SIT)
			icon_state = "corgi_sit"
		if(POSE_REST)
			icon_state = "corgi_rest"
		if(POSE_STAT)
			icon_state = "corgi_stat"

	var/obj/item/bodypart/BP = bodyparts_by_name[BP_HEAD]
	BP.update_inv_limb(multi = TRUE)

	BP = bodyparts_by_name[BP_CHEST]
	BP.update_inv_limb(multi = TRUE)

/mob/living/carbon/human/ian/update_canmove() // uh oh, i have no other idea, except copypaste this proc as edited version for now.
	if(!ismob(src))
		return

	if(buckled)
		if(istype(buckled, /obj/vehicle))
			var/obj/vehicle/V = buckled
			if(incapacitated())
				V.unload(src)
				lying = TRUE
				canmove = FALSE
				pose_last = POSE_STAT
			else
				if(buckled.buckle_lying != -1)
					lying = buckled.buckle_lying
				canmove = TRUE
				pixel_y = V.mob_offset_y
				pose_last = POSE_SIT
		else
			if(buckled.buckle_lying != -1)
				lying = buckled.buckle_lying
			if(istype(buckled, /obj/structure/stool/bed/chair))
				var/obj/structure/stool/bed/chair/C = buckled
				if(C.flipped)
					lying = TRUE
			if(!buckled.buckle_movable)
				anchored = TRUE
				canmove = FALSE
			else
				anchored = FALSE
				canmove = TRUE
			pose_last = POSE_SIT
	else if( stat || weakened || paralysis || sleeping || (status_flags & FAKEDEATH))
		lying = TRUE
		canmove = FALSE
		pose_last = POSE_STAT
	else if(resting)
		lying = FALSE
		canmove = FALSE
		pose_last = POSE_SIT
	else if(stunned)
		canmove = FALSE
		pose_last = POSE_REST
	else if(captured)
		anchored = TRUE
		canmove = FALSE
		lying = FALSE
		pose_last = POSE_NORM
	else if (crawling)
		lying = TRUE
		canmove = TRUE
		pose_last = POSE_REST
	else if(!buckled)
		lying = !can_stand
		canmove = has_limbs
		pose_last = POSE_NORM

	if(lying)
		density = FALSE
		if(mouth && mouth.canremove)
			dropItemToGround(mouth)
	else
		density = TRUE

	for(var/obj/item/weapon/grab/G in grabbed_by)
		if(G.state >= GRAB_AGGRESSIVE)
			canmove = FALSE
			break

	if(pose_last != pose_prev)
		update_transform()
	if(update_icon)
		update_icon = FALSE
		regenerate_icons()
	return canmove

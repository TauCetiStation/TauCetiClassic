#define LAYERIAN_BACK     6
#define LAYERIAN_MOUTH    5
#define LAYERIAN_HEAD     4
#define LAYERIAN_NECKCUFF 3
#define LAYERIAN_TARGETED 2
#define LAYERIAN_FIRE     1
#define LAYERIANS_TOTAL   6

/mob/living/carbon/ian/var/static/list/corgi_icons = list()
/mob/living/carbon/ian/var/list/overlays_inv[LAYERIANS_TOTAL]

/mob/living/carbon/ian/proc/apply_overlay(index)
	var/image/I = overlays_inv[index]
	if(I)
		add_overlay(I)

/mob/living/carbon/ian/proc/remove_overlay(index)
	if(overlays_inv[index])
		cut_overlay(overlays_inv[index])
		overlays_inv[index] = null

/mob/living/carbon/ian/regenerate_icons()
	update_inv_head()
	update_inv_mouth()
	update_inv_neck()
	update_inv_back()
	update_hud()
	update_transform()

/mob/living/carbon/ian/update_hud()
	if(client)
		client.screen |= contents

/mob/living/carbon/ian/update_inv_head()
	remove_overlay(LAYERIAN_HEAD)

	update_corgi_ability()

	if(!head)
		return

	head.screen_loc = ui_ian_head
	if(client && hud_used && hud_used.hud_shown)
		client.screen += head

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

	var/image/body_icon
	if(facehugger)
		drop_from_inventory(mouth)
		body_icon = image("icon" = 'icons/mob/mask.dmi', "icon_state" = "facehugger_corgi", "layer" = -LAYERIAN_HEAD)
	else if(head.type in has_corgi_icons)
		body_icon = image("icon" = 'icons/mob/corgi_head.dmi', "icon_state" = head.icon_state, "layer" = -LAYERIAN_HEAD)
	else
		var/cached_icon_string = "H[head.type]_[head.icon_state]"

		if(head.icon_override)
			cached_icon_string += "_[head.icon_override]"
		else if(head.icon_custom)
			cached_icon_string += "_[head.icon_custom]"

		if(cached_icon_string in corgi_icons)
			body_icon = corgi_icons[cached_icon_string]
		else
			var/icon_path = head.icon_override ? head.icon_override : head.icon_custom ? head.icon_custom : 'icons/mob/head.dmi'

			var/i_state = head.icon_custom ? "[head.icon_state]_mob" : head.icon_state
			var/icon/I = new(icon_path, i_state)

			var/icon/temp_icon = icon(I, i_state, EAST)
			temp_icon.Shift(EAST, 5)
			I.Insert(icon(temp_icon, dir = EAST), dir = EAST)

			temp_icon = icon(I, i_state, WEST)
			temp_icon.Shift(WEST, 7)
			I.Insert(icon(temp_icon, dir = WEST), dir = WEST)

			I.Shift(EAST, 1)
			I.Shift(SOUTH, 7)

			var/icon/mask_lie = icon(icon, "[icon_state]_mask_lie")
			temp_icon = icon(I)
			temp_icon.Shift(SOUTH, 13) //lying state
			temp_icon.Blend(icon(mask_lie, icon_state, dir = NORTH), ICON_MULTIPLY)
			I.Insert(icon(temp_icon), i_state + "_lie")

			corgi_icons[cached_icon_string] = image("icon" = I, "icon_state" = i_state, "layer" = -LAYERIAN_HEAD)
			body_icon = corgi_icons[cached_icon_string]

	body_icon.color = head.color
	if(pose_last & (POSE_REST | POSE_STAT))
		body_icon.icon_state = head.icon_state + "_lie"
	else
		body_icon.icon_state = head.icon_state

	overlays_inv[LAYERIAN_HEAD] = body_icon

	apply_overlay(LAYERIAN_HEAD)

/mob/living/carbon/ian/proc/update_inv_mouth()
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

/mob/living/carbon/ian/proc/update_inv_neck()
	//remove_overlay(LAYERIAN_NECKCUFF) incase icons ever will be added.

	if(!neck)
		return

	if(handcuffed)
		drop_from_inventory(mouth)

	neck.screen_loc = ui_ian_neck
	if(client && hud_used && hud_used.hud_shown)
		client.screen += neck

	//apply_overlay(LAYERIAN_NECKCUFF)

/mob/living/carbon/ian/update_inv_back()
	remove_overlay(LAYERIAN_BACK)

	if(!back)
		return

	back.screen_loc = ui_ian_back
	if(client && hud_used && hud_used.hud_shown)
		client.screen += back

	var/image/body_icon
	var/i_state = "backpack"

	if(back.type == /obj/item/clothing/suit/armor/vest)
		i_state = "armor"
	else if(istype(back, /obj/item/weapon/storage/backpack/satchel))
		i_state = "satchel"
	else if(istype(back, /obj/item/weapon/storage/backpack/dufflebag))
		i_state = "duffbag"

	body_icon = image("icon" = 'icons/mob/corgi_back.dmi', "icon_state" = i_state, "layer" = -LAYERIAN_BACK)
	body_icon.color = back.color

	switch(pose_last)
		if(POSE_SIT)
			body_icon.icon_state = i_state + "_sit"
		if(POSE_REST,POSE_STAT)
			body_icon.icon_state = i_state + "_lie"

	overlays_inv[LAYERIAN_BACK] = body_icon

	apply_overlay(LAYERIAN_BACK)

/mob/living/carbon/ian/update_targeted()
	remove_overlay(LAYERIAN_TARGETED)

	if(targeted_by && target_locked)
		overlays_inv[LAYERIAN_TARGETED] = image("icon"=target_locked, "layer"=-LAYERIAN_TARGETED)
	else if (!targeted_by && target_locked)
		qdel(target_locked)

	apply_overlay(LAYERIAN_TARGETED)

/mob/living/carbon/ian/update_fire()
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

/mob/living/carbon/ian/update_transform()
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

	update_inv_head()
	update_inv_mouth()
	update_inv_back()

/mob/living/carbon/ian/update_canmove()

	. = ..(TRUE)

	if(buckled || resting)
		pose_last = POSE_SIT
	else if(stat || weakened || stunned)
		pose_last = POSE_STAT
	else if(crawling)
		pose_last = POSE_REST
	else
		pose_last = POSE_NORM

	if(lying && mouth && mouth.canremove)
		drop_from_inventory(mouth)

	if(pose_last != pose_prev)
		update_transform()

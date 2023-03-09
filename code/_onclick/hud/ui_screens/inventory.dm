
/atom/movable/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.

/atom/movable/screen/inventory/proc/check_state()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return FALSE
	if(usr.incapacitated())
		return FALSE
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return FALSE
	return TRUE

/atom/movable/screen/inventory/action()
	if(check_state() && usr.attack_ui(slot_id))
		usr.next_move = world.time + 6


/atom/movable/screen/inventory/MouseEntered()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	add_stored_outline()

/atom/movable/screen/inventory/MouseExited()
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	remove_stored_outline()

/atom/movable/screen/inventory/proc/add_stored_outline()
	if(!slot_id || !usr.client.prefs.outline_enabled)
		return
	var/obj/item/inv_item = usr.get_item_by_slot(slot_id)
	if(!inv_item)
		return
	if(usr.incapacitated())
		inv_item.apply_outline(COLOR_RED_LIGHT)
	else
		inv_item.apply_outline()

/atom/movable/screen/inventory/proc/remove_stored_outline()
	if(!slot_id)
		return
	var/obj/item/inv_item = usr.get_item_by_slot(slot_id)
	if(!inv_item)
		return
	inv_item.remove_outline()

/atom/movable/screen/inventory/hand
	var/hand_index

	hud_slot = HUD_SLOT_MAIN

/atom/movable/screen/inventory/hand/action()
	if(check_state() && iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.activate_hand(hand_index)
		usr.next_move = world.time + 2

/atom/movable/screen/inventory/hand/update_icon(mob/mymob)
	icon_state = (mymob.hand == hand_index) ? "[name]_active" : "[name]_inactive"

/atom/movable/screen/inventory/hand/add_to_hud(datum/hud/hud)
	. = ..()
	update_icon(hud.mymob)

/atom/movable/screen/inventory/hand/MouseDrop_T(obj/item/dropping, mob/user)
	if(!istype(dropping) || user.incapacitated())
		return
	dropping.mob_pickup(user, hand_index)

/atom/movable/screen/inventory/hand/r
	name = "hand_r"
	screen_loc = ui_rhand
	slot_id = SLOT_R_HAND
	hand_index = 0

/atom/movable/screen/inventory/hand/r/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.r_hand_hud_object = src

/atom/movable/screen/inventory/hand/l
	name = "hand_l"
	screen_loc = ui_lhand
	slot_id = SLOT_L_HAND
	hand_index = 1

/atom/movable/screen/inventory/hand/l/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.l_hand_hud_object = src

/atom/movable/screen/swap
	name = "hand"

	hud_slot = HUD_SLOT_HOTKEYS

/atom/movable/screen/swap/action()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.swap_hand()

/atom/movable/screen/swap/first
	icon_state = "hand1"
	screen_loc = ui_swaphand1

/atom/movable/screen/swap/second
	icon_state = "hand2"
	screen_loc = ui_swaphand2

/atom/movable/screen/inventory/craft
	name = "crafting menu"
	icon = 'icons/hud/screen1_Midnight.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

	copy_flags = NONE

/atom/movable/screen/inventory/craft/action()
	if(check_state())
		var/mob/living/M = usr
		M.OpenCraftingMenu()
		usr.next_move = world.time + 6

/atom/movable/screen/inventory/mask
	name = "mask"
	icon_state = "mask"
	screen_loc = ui_mask
	slot_id = SLOT_WEAR_MASK

/atom/movable/screen/inventory/mask/monkey
	screen_loc = ui_monkey_mask

/atom/movable/screen/inventory/back
	name = "back"
	icon_state = "back"
	screen_loc = ui_back
	slot_id = SLOT_BACK

/atom/movable/screen/inventory/back/ian
	screen_loc = ui_ian_back

/atom/movable/screen/inventory/head
	name = "head"
	icon_state = "hair"
	screen_loc = ui_head
	slot_id = SLOT_HEAD

/atom/movable/screen/inventory/head/ian
	screen_loc = ui_ian_head

/atom/movable/screen/inventory/uniform
	name = "i_clothing"
	slot_id = SLOT_W_UNIFORM
	icon_state = "center"
	screen_loc = ui_iclothing

/atom/movable/screen/inventory/suit
	name = "o_clothing"
	slot_id = SLOT_WEAR_SUIT
	icon_state = "suit"
	screen_loc = ui_oclothing

/atom/movable/screen/inventory/id
	name = "id"
	icon_state = "id"
	screen_loc = ui_id
	slot_id = SLOT_WEAR_ID

/atom/movable/screen/inventory/pocket1
	name = "storage1"
	icon_state = "pocket"
	screen_loc = ui_storage1
	slot_id = SLOT_L_STORE

/atom/movable/screen/inventory/pocket2
	name = "storage2"
	icon_state = "pocket"
	screen_loc = ui_storage2
	slot_id = SLOT_R_STORE

/atom/movable/screen/inventory/suit_storage
	name = "suit storage"
	icon_state = "suitstorage"
	screen_loc = ui_sstore1
	slot_id = SLOT_S_STORE

/atom/movable/screen/inventory/gloves
	name = "gloves"
	icon_state = "gloves"
	screen_loc = ui_gloves
	slot_id = SLOT_GLOVES

/atom/movable/screen/inventory/eyes
	name = "eyes"
	icon_state = "glasses"
	screen_loc = ui_glasses
	slot_id = SLOT_GLASSES

/atom/movable/screen/inventory/l_ear
	name = "l_ear"
	icon_state = "ears"
	screen_loc = ui_l_ear
	slot_id = SLOT_L_EAR

/atom/movable/screen/inventory/r_ear
	name = "r_ear"
	icon_state = "ears"
	screen_loc = ui_r_ear
	slot_id = SLOT_R_EAR

/atom/movable/screen/inventory/shoes
	name = "shoes"
	icon_state = "shoes"
	screen_loc = ui_shoes
	slot_id = SLOT_SHOES

/atom/movable/screen/inventory/belt
	name = "belt"
	icon_state = "belt"
	screen_loc = ui_belt
	slot_id = SLOT_BELT

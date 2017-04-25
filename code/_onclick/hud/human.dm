/*
	Creates inventory on-screen hud objects, no need to do this more than once per bodypart.
*/
/obj/item/bodypart/proc/generate_hud_data(datum/species/specie) // bodypart/New() uses this.
	if(specie)
		remove_hud_data(TRUE)
		inv_box_data = specie.get_hud_data(body_zone)
	else
		inv_box_data = species.get_hud_data(body_zone)

	if(!inv_box_data || !inv_box_data.len)
		return

	if(inv_slots_data && !specie)
		CRASH("Someone tried to create bodypart hud data again for [src].")
	else
		if(!inv_slots_data)
			inv_slots_data = list()

		for(var/slot_name in inv_box_data)
			if(!inv_box_data[slot_name]["no_hud"])
				var/obj/screen/inventory/inv_box = new() // could be transfered into initialize proc(), so we dont make object hud for mobs that will not get any client.
				inv_box.master = src                     // Also, could be made as a child from inventory objects with all needed code instead of inv_box_data[] list.
				inv_box.name = inv_box_data[slot_name]["name"]
				inv_box.icon_state = inv_box_data[slot_name]["icon_state"]
				inv_box.screen_loc = inv_box_data[slot_name]["screen_loc"]
				inv_box.slot_id = slot_name
				inv_box.other = inv_box_data[slot_name]["other"]
				inv_box.visible_when_hud_reduced = inv_box_data[slot_name]["reduced"]
				inv_box.layer = inv_box_data[slot_name]["hud_layer"] ? inv_box_data[slot_name]["hud_layer"] : HUD_LAYER
				inv_box.plane = HUD_PLANE
				inv_slots_data[slot_name] = inv_box
				initialize_hand()
			else
				inv_slots_data[slot_name] = null
			item_in_slot["[slot_name]"] = null
			if(owner)
				owner.bodyparts_slot_by_name[slot_name] = body_zone

/*
	Makes inventory hud to actually appear on players screen (used when player logins into the mob).
*/
/mob/living/carbon/var/list/bodyparts_slot_by_name = list()
/mob/living/carbon/proc/initialize_bodyparts_hud(ui_style, ui_color, ui_alpha, list/adding, list/other, list/reduced)
	for(var/obj/item/bodypart/BP in bodyparts)
		if(BP.inv_slots_data)
			for(var/slot_name in BP.inv_slots_data)
				var/obj/screen/inventory/S = BP.inv_slots_data[slot_name]
				if(S)
					if(ui_style)
						S.icon = ui_style
					if(ui_color)
						S.color = ui_color
					if(ui_alpha)
						S.alpha = ui_alpha
					if(S.other)
						other += S
					else
						adding += S
					if(S.visible_when_hud_reduced)
						reduced += S
		BP.update_inv_hud()

/*
	This proc should be used, when we attach this limb to the mob.
*/
/mob/living/carbon/proc/add_hud_data(obj/item/bodypart/BP)
	if(!BP || !hud_used)
		return

	if(BP.inv_slots_data)
		for(var/slot_name in BP.inv_slots_data)
			var/obj/screen/inventory/S = BP.inv_slots_data[slot_name]
			if(S)
				if(client) // if no client - this will be done upon mob login with datum/hud initialization proc.
					S.icon = ui_style2icon(client.prefs.UI_style)
					S.color = client.prefs.UI_style_color
					S.alpha = client.prefs.UI_style_alpha
				if(S.other)
					hud_used.other += S
				else
					hud_used.adding += S
				if(S.visible_when_hud_reduced)
					hud_used.visible_elements_while_reduced += S
			bodyparts_slot_by_name[slot_name] = BP.body_zone
	BP.update_inv_hud()

/*
	When we detach this limb destroy var should be false. TRUE is for Destroy() proc.
*/
/obj/item/bodypart/proc/remove_hud_data(destroy = FALSE)
	if(!inv_slots_data || !inv_slots_data.len)
		return

	var/list/removing = list()
	for(var/slot_name in inv_slots_data)
		if(owner)
			removing += inv_slots_data[slot_name]
			removing += item_in_slot[slot_name]

			owner.bodyparts_slot_by_name -= slot_name // so the mob will know, that he no longer has this slot anymore.

		if(destroy)
			var/obj/screen/inventory/S = inv_slots_data[slot_name]
			qdel(S)
			inv_slots_data[slot_name] = null
			inv_slots_data -= slot_name

			var/obj/item/I = item_in_slot[slot_name] // TODO maybe drop items instead of qdel?
			qdel(I)
			item_in_slot[slot_name] = null
			item_in_slot -= slot_name

	if(owner && removing.len)
		if(owner.client)
			owner.client.screen -= removing

		if(can_grasp)
			if(owner.active_hand == src)
				owner.active_hand = null
				owner.swap_hand()
			else
				owner.inactive_hands -= src

		if(owner.hud_used)
			owner.hud_used.adding -= removing
			owner.hud_used.other -= removing

/*
	Code below used in hud creation process (mostly).
*/
/* Note: in most SS13 builds you will find something like this:
	inv_box = new /obj/screen/inventory()
	inv_box.name = "i_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = slot_w_uniform
	inv_box.icon_state = "center"
	inv_box.screen_loc = ui_iclothing
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	In our build, we use associative list called inv_box_data with code below.
*/

/datum/species/proc/get_hud_data(body_zone)
	switch(body_zone)
		if(BP_HEAD) // this bodypart totally compatible with monkeys.
			return list(
				slot_head = list(
					"name" = "head"
					,"icon_state" = "hair"
					,"screen_loc" = ui_head
					,"slot_layer" = -HEAD_LAYER
					,"mob_icon_path" = 'icons/mob/head.dmi'
					,"other" = TRUE
					,"mob_blood_overlay" = "helmetblood"
					)
				,slot_glasses = list(
					"name" = "eyes"
					,"icon_state" = "glasses"
					,"screen_loc" = ui_glasses
					,"slot_layer" = -GLASSES_LAYER
					,"mob_icon_path" = 'icons/mob/eyes.dmi'
					,"other" = TRUE
					)
				,slot_l_ear = list(
					"name" = "l_ear"
					,"icon_state" = "ears"
					,"screen_loc" = ui_l_ear
					,"slot_layer" = -EARS_LAYER
					,"mob_icon_path" = 'icons/mob/ears.dmi'
					,"other" = TRUE
					)
				,slot_r_ear = list(
					"name" = "r_ear"
					,"icon_state" = "ears"
					,"screen_loc" = ui_r_ear
					,"slot_layer" = -EARS_LAYER
					,"mob_icon_path" = 'icons/mob/ears.dmi'
					,"other" = TRUE
					)
				,slot_wear_mask = list(
					"name" = "mask"
					,"icon_state" = "mask"
					,"screen_loc" = ui_mask
					,"slot_layer" = -FACEMASK_LAYER
					,"mob_icon_path" = 'icons/mob/mask.dmi'
					,"other" = TRUE
					,"mob_blood_overlay" = "maskblood"
					)
				)
		if(BP_CHEST)
			return list(
				slot_back = list(
					"name" = "back"
					,"icon_state" = "back"
					,"screen_loc" = ui_back
					,"slot_layer" = -BACK_LAYER
					,"mob_icon_path" = 'icons/mob/back.dmi'
					,"persistent_hud" = TRUE
					)
				,slot_w_uniform = list(
					"name" = "i_clothing"
					,"icon_state" = "center"
					,"screen_loc" = ui_iclothing
					,"slot_layer" = -UNIFORM_LAYER
					,"mob_icon_path" = 'icons/mob/uniform.dmi'
					,"other" = TRUE
					,"icon_state_as_color" = TRUE  // uniform may use item_color var for icon_states, so for now, i need working code... TODO deal with this?
					,"support_fat_people" = TRUE
					,"mob_blood_overlay" = "uniformblood"
					,"has_tie" = TRUE // TODO add this into uniform itself?
					)
				,slot_undershirt = list(
					"name" = "undershirt"
					,"icon_state" = "center_u"
					,"screen_loc" = ui_iclothing
					,"no_item_on_screen" = TRUE // So item won't block uniform slot with uniform, since this slot is somekind sub slot for uniforms.
					,"hud_layer" = HUD_LAYER + 0.1
					,"slot_layer" = -BODY_LAYER
					,"mob_icon_path" = 'icons/mob/human_undershirt.dmi'
					,"other" = TRUE
					,"mob_blood_overlay" = "armorblood"
					)
				,slot_underwear = list(
					"name" = "underwear"
					,"icon_state" = "center_w"
					,"screen_loc" = ui_iclothing
					,"no_item_on_screen" = TRUE // So item won't block uniform slot with uniform, since this slot is somekind sub slot for uniforms.
					,"hud_layer" = HUD_LAYER + 0.1
					,"slot_layer" = -BODY_LAYER
					,"mob_icon_path" = 'icons/mob/human_underwear.dmi'
					,"other" = TRUE
					,"mob_blood_overlay" = "wearblood"
					)
				,slot_wear_suit = list(
					"name" = "o_clothing"
					,"icon_state" = "suit"
					,"screen_loc" = ui_oclothing
					,"slot_layer" = -SUIT_LAYER
					,"mob_icon_path" = 'icons/mob/suit.dmi'
					,"other" = TRUE
					,"mob_blood_overlay" = "by_type"
					)
				,slot_wear_id = list(
					"name" = "id"
					,"icon_state" = "id"
					,"screen_loc" = ui_id
					,"slot_layer" = -ID_LAYER
					,"mob_icon_path" = 'icons/mob/mob.dmi'
					,"simple_overlays" = TRUE
					,"mob_icon_state" = "id"
					,"persistent_hud" = TRUE // used in persistent_inventory_update() proc (_onclick\hud\hud.dm)
					)
				,slot_l_store = list(
					"name" = "storage1"
					,"icon_state" = "pocket"
					,"screen_loc" = ui_storage1
					,"persistent_hud" = TRUE
					)
				,slot_r_store = list(
					"name" = "storage2"
					,"icon_state" = "pocket"
					,"screen_loc" = ui_storage2
					,"persistent_hud" = TRUE
					)
				,slot_s_store = list(
					"name" = "suit storage"
					,"icon_state" = "suitstorage"
					,"screen_loc" = ui_sstore1
					,"slot_layer" = -SUIT_STORE_LAYER
					,"mob_icon_path" = 'icons/mob/belt_mirror.dmi'
					,"icon_state_as_item_state" = TRUE
					,"simple_overlays" = TRUE
					,"persistent_hud" = TRUE
					)
				,slot_belt = list(
					"name" = "belt"
					,"icon_state" = "belt"
					,"screen_loc" = ui_belt
					,"slot_layer" = -BELT_LAYER
					,"mob_icon_path" = 'icons/mob/belt.dmi'
					,"icon_state_as_item_state" = TRUE
					,"persistent_hud" = TRUE
					)
				,slot_gloves = list(
					"name" = "gloves"
					,"icon_state" = "gloves"
					,"screen_loc" = ui_gloves
					,"slot_layer" = -GLOVES_LAYER
					,"mob_icon_path" = 'icons/mob/hands.dmi'
					,"other" = TRUE
					,"icon_state_as_item_state" = TRUE
					,"mob_blood_overlay" = "bloodyhands"
					)
				,slot_shoes = list( // should be moved into legs later (if separated)
					"name" = "shoes"
					,"icon_state" = "shoes"
					,"screen_loc" = ui_shoes
					,"slot_layer" = -SHOES_LAYER
					,"mob_icon_path" = 'icons/mob/feet.dmi'
					,"other" = TRUE
					,"mob_blood_overlay" = "shoeblood"
					)
				,slot_socks = list( // should be moved into legs later
					"name" = "socks"
					,"icon_state" = "center_s"
					,"screen_loc" = ui_shoes
					,"no_item_on_screen" = TRUE // So item won't block uniform slot with uniform, since this slot is somekind sub slot for uniforms.
					,"hud_layer" = HUD_LAYER + 0.1
					,"slot_layer" = -BODY_LAYER
					,"mob_icon_path" = 'icons/mob/human_socks.dmi'
					,"other" = TRUE
					,"mob_blood_overlay" = "shoeblood"
					)
				,slot_handcuffed = list(
					"no_hud" = TRUE
					,"slot_layer" = -HANDCUFF_LAYER
					,"mob_icon_path" = 'icons/mob/mob.dmi'
					,"mob_icon_state" = "handcuff1"
					)
				,slot_legcuffed = list(
					"no_hud" = TRUE
					,"slot_layer" = -LEGCUFF_LAYER
					,"mob_icon_path" = 'icons/mob/mob.dmi'
					,"mob_icon_state" = "legcuff1"
					)
				,slot_in_backpack = list(
					"no_hud" = TRUE
					)
				)
		if(BP_L_ARM)
			return list(
				slot_l_hand = list( // !IMPORTANT! put hands slots ALWAYS first.
					"name" = "l_hand"
					,"icon_state" = "l_arm"
					,"screen_loc" = ui_lhand
					,"slot_layer" = -L_HAND_LAYER
					,"mob_icon_path" = null
					,"reduced" = TRUE
					,"icon_state_as_item_state" = TRUE
					)
				)
		if(BP_R_ARM)
			return list(
				slot_r_hand = list(
					"name" = "r_hand"
					,"icon_state" = "r_arm"
					,"screen_loc" = ui_rhand
					,"slot_layer" = -R_HAND_LAYER
					,"mob_icon_path" = null
					,"reduced" = TRUE
					,"icon_state_as_item_state" = TRUE
					)
				)

/datum/species/monkey/get_hud_data(body_zone)
	switch(body_zone)
		if(BP_CHEST)
			return list(
				slot_back = list(
					"name" = "back"
					,"icon_state" = "back"
					,"screen_loc" = ui_back
					,"slot_layer" = -BACK_LAYER
					,"mob_icon_path" = 'icons/mob/back.dmi'
					,"persistent_hud" = TRUE
					)
				,slot_undershirt = list(
					"name" = "undershirt"
					,"icon_state" = "center_u"
					,"screen_loc" = ui_iclothing
					,"no_item_on_screen" = TRUE
					,"hud_layer" = HUD_LAYER + 0.1
					,"slot_layer" = -BODY_LAYER
					,"mob_icon_path" = 'icons/mob/monkey_undershirt.dmi'
					,"other" = TRUE
					,"mob_blood_overlay" = "armorblood"
					)
				,slot_handcuffed = list(
					"no_hud" = TRUE
					,"slot_layer" = -HANDCUFF_LAYER
					,"mob_icon_path" = 'icons/mob/mob.dmi'
					,"mob_icon_state" = "handcuff1"
					)
				,slot_legcuffed = list(
					"no_hud" = TRUE
					,"slot_layer" = -LEGCUFF_LAYER
					,"mob_icon_path" = 'icons/mob/mob.dmi'
					,"mob_icon_state" = "legcuff2"
					)
				,slot_in_backpack = list(
					"no_hud" = TRUE
					)
				)
		else
			return ..()

/datum/species/monkey/nymph/get_hud_data(body_zone)
	switch(body_zone)
		if(BP_CHEST)
			return list(
				slot_r_hand = list(
					"name" = "r_hand"
					,"icon_state" = "r_arm"
					,"screen_loc" = ui_rhand
					,"slot_layer" = -R_HAND_LAYER
					,"mob_icon_path" = null
					,"reduced" = TRUE
					,"icon_state_as_item_state" = TRUE
					)
				,slot_back = list(
					"name" = "back"
					,"icon_state" = "back"
					,"screen_loc" = ui_back
					,"slot_layer" = -BACK_LAYER
					,"mob_icon_path" = 'icons/mob/back.dmi'
					,"persistent_hud" = TRUE
					)
				,slot_in_backpack = list(
					"no_hud" = TRUE
					)
				)

/datum/hud/proc/human_hud(ui_style='icons/mob/screen1_White.dmi', ui_color = "#ffffff", ui_alpha = 255)

	src.adding = list()
	src.other = list()
	src.hotkeybuttons = list() //These can be disabled for hotkey usersx
	src.visible_elements_while_reduced = list()

	mymob.client.screen = list()

	var/mob/living/carbon/C = mymob
	C.initialize_bodyparts_hud(ui_style, ui_color, ui_alpha, adding, other, visible_elements_while_reduced)

	var/obj/screen/using // TODO transfer code below into bodypart too?

	using = new /obj/screen()
	using.name = "act_intent"
	using.icon = ui_style
	using.icon_state = "intent_"+mymob.a_intent
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	action_intent = using

//intent small hud objects
	var/icon/ico
	for(var/intent in list("help", "disarm", "grab", "harm"))
		using = new /obj/screen( src )
		ico = new(ui_style, "black")
		ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
		switch(intent)
			if("help")
				ico.DrawBox(rgb(255,255,255,1),1,ico.Height()/2,ico.Width()/2,ico.Height())
				help_intent = using
			if("disarm")
				ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,ico.Height()/2,ico.Width(),ico.Height())
				disarm_intent = using
			if("grab")
				ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,1,ico.Width(),ico.Height()/2)
				grab_intent = using
			if("harm")
				ico.DrawBox(rgb(255,255,255,1),1,1,ico.Width()/2,ico.Height()/2)
				hurt_intent = using
		using.name = intent
		using.icon = ico
		using.screen_loc = ui_acti
		using.layer = ABOVE_HUD_LAYER
		using.plane = ABOVE_HUD_PLANE
		src.adding += using
//end intent small hud objects

	using = new /obj/screen()
	using.name = "mov_intent"
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using
	move_intent = using

	using = new /obj/screen()
	using.name = "drop"
	using.icon = ui_style
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	using.color = ui_color
	using.alpha = ui_alpha
	src.hotkeybuttons += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /obj/screen()
	using.name = "resist"
	using.icon = ui_style
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	using.color = ui_color
	using.alpha = ui_alpha
	src.hotkeybuttons += using

	using = new /obj/screen()
	using.name = "toggle"
	using.icon = ui_style
	using.icon_state = "other"
	using.screen_loc = ui_inventory
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	using = new /obj/screen()
	using.name = "equip"
	using.icon = ui_style
	using.icon_state = "act_equip"
	using.screen_loc = ui_equip
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	using.color = ui_color
	using.alpha = ui_alpha
	src.adding += using

	mymob.throw_icon = new /obj/screen()
	mymob.throw_icon.icon = ui_style
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw
	mymob.throw_icon.color = ui_color
	mymob.throw_icon.alpha = ui_alpha
	src.hotkeybuttons += mymob.throw_icon

	mymob.internals = new /obj/screen()
	mymob.internals.icon = ui_style
	mymob.internals.icon_state = "internal0"
	mymob.internals.name = "internal"
	mymob.internals.screen_loc = ui_internal

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen_gen.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.healthdoll = new /obj/screen()
	mymob.healthdoll.icon = 'icons/mob/screen_gen.dmi'
	mymob.healthdoll.name = "health doll"
	mymob.healthdoll.screen_loc = ui_healthdoll

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist
	src.hotkeybuttons += mymob.pullin

	lingchemdisplay = new /obj/screen()
	lingchemdisplay.icon = 'icons/mob/screen_gen.dmi'
	lingchemdisplay.name = "chemical storage"
	lingchemdisplay.icon_state = "power_display"
	lingchemdisplay.screen_loc = ui_lingchemdisplay
	lingchemdisplay.layer = ABOVE_HUD_LAYER
	lingchemdisplay.plane = ABOVE_HUD_PLANE
	lingchemdisplay.invisibility = 101

	lingstingdisplay = new /obj/screen()
	lingstingdisplay.icon = 'icons/mob/screen_gen.dmi'
	lingstingdisplay.name = "current sting"
	lingstingdisplay.screen_loc = ui_lingstingdisplay
	lingstingdisplay.layer = ABOVE_HUD_LAYER
	lingstingdisplay.plane = ABOVE_HUD_PLANE
	lingstingdisplay.invisibility = 101

	mymob.pain = new /obj/screen( null )

	mymob.zone_sel = new /obj/screen/zone_sel( null )
	mymob.zone_sel.icon = ui_style
	mymob.zone_sel.color = ui_color
	mymob.zone_sel.alpha = ui_alpha
	mymob.zone_sel.overlays.Cut()
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	//Handle the gun settings buttons
	mymob.gun_setting_icon = new /obj/screen/gun/mode(null)
	if (mymob.client)
		if (mymob.client.gun_mode) // If in aim mode, correct the sprite
			mymob.gun_setting_icon.icon_state = "gun1"
	for(var/obj/item/weapon/gun/G in mymob) // If targeting someone, display other buttons
		if (G.target)
			mymob.item_use_icon = new /obj/screen/gun/item(null)
			if (mymob.client.target_can_click)
				mymob.item_use_icon.icon_state = "gun0"
			src.adding += mymob.item_use_icon
			mymob.gun_move_icon = new /obj/screen/gun/move(null)
			if (mymob.client.target_can_move)
				mymob.gun_move_icon.icon_state = "gun0"
				mymob.gun_run_icon = new /obj/screen/gun/run(null)
				if (mymob.client.target_can_run)
					mymob.gun_run_icon.icon_state = "gun0"
				src.adding += mymob.gun_run_icon
			src.adding += mymob.gun_move_icon


	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.internals, mymob.healths, mymob.healthdoll, mymob.pullin, mymob.gun_setting_icon, lingchemdisplay, lingstingdisplay) //, mymob.hands, mymob.rest, mymob.sleep) //, mymob.mach )
	mymob.client.screen += src.adding + src.hotkeybuttons
	mymob.client.screen += mymob.client.void
	inventory_shown = 0


/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 0
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 1

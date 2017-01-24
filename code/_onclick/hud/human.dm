/datum/hud/proc/human_hud(ui_style='icons/mob/screen1_White.dmi', ui_color = "#ffffff", ui_alpha = 255)

	src.adding = list()
	src.other = list()
	src.hotkeybuttons = list() //These can be disabled for hotkey usersx

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

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

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,ico.Height()/2,ico.Width()/2,ico.Height())
	using = new /obj/screen( src )
	using.name = "help"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	help_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,ico.Height()/2,ico.Width(),ico.Height())
	using = new /obj/screen( src )
	using.name = "disarm"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	disarm_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,1,ico.Width(),ico.Height()/2)
	using = new /obj/screen( src )
	using.name = "grab"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	grab_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,1,ico.Width()/2,ico.Height()/2)
	using = new /obj/screen( src )
	using.name = "harm"
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	hurt_intent = using

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

	inv_box = new /obj/screen/inventory()
	inv_box.name = "o_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = slot_wear_suit
	inv_box.icon_state = "suit"
	inv_box.screen_loc = ui_oclothing
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r_inactive"
	if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
		inv_box.icon_state = "hand_r_active"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = slot_r_hand
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha

	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l_inactive"
	if(mymob && mymob.hand)	//This being 1 means the left hand is in use
		inv_box.icon_state = "hand_l_active"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = slot_l_hand
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.l_hand_hud_object = inv_box
	src.adding += inv_box

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

	inv_box = new /obj/screen/inventory()
	inv_box.name = "id"
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = ui_id
	inv_box.slot_id = slot_wear_id
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = ui_mask
	inv_box.slot_id = slot_wear_mask
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = slot_back
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage1"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = slot_l_store
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage2"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = slot_r_store
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "suit storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suitstorage"
	inv_box.screen_loc = ui_sstore1
	inv_box.slot_id = slot_s_store
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

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

	inv_box = new /obj/screen/inventory()
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
	inv_box.screen_loc = ui_gloves
	inv_box.slot_id = slot_gloves
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "eyes"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
	inv_box.screen_loc = ui_glasses
	inv_box.slot_id = slot_glasses
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_l_ear
	inv_box.slot_id = slot_l_ear
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_ear"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_r_ear
	inv_box.slot_id = slot_r_ear
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "hair"
	inv_box.screen_loc = ui_head
	inv_box.slot_id = slot_head
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
	inv_box.screen_loc = ui_shoes
	inv_box.slot_id = slot_shoes
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.other += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_belt
	inv_box.slot_id = slot_belt
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	src.adding += inv_box

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


	mymob.client.screen = list()

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

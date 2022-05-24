/mob/living/carbon/human/add_to_hud(datum/hud/hud)
	hud.ui_color = client.prefs.UI_style_color
	hud.ui_alpha = client.prefs.UI_style_alpha
	
	..()
	hud.add_hands()

	hud.init_screens(list(
		/atom/movable/screen/inventory/craft, // craft
		/atom/movable/screen/drop, // simple hotkeys
		/atom/movable/screen/inventory/swap/first,
		/atom/movable/screen/inventory/swap/second,
		/atom/movable/screen/resist,
		/atom/movable/screen/equip,
		/atom/movable/screen/complex/human, // hidden inventory
		/atom/movable/screen/inventory/id,	// visible inventory
		/atom/movable/screen/inventory/back,
		/atom/movable/screen/inventory/pocket1,
		/atom/movable/screen/inventory/pocket2,
		/atom/movable/screen/inventory/suit_storage,
		/atom/movable/screen/inventory/belt,
	))

	hud.add_throw_icon()
	hud.add_internals()
	hud.add_healths()
	hud.add_health_doll()
	hud.add_nutrition_icon()

	leap_icon?.add_to_hud(hud)

	hud.add_gun_setting()

/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = FALSE
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = TRUE

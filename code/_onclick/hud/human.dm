/mob/living/carbon/human/add_to_hud(datum/hud/hud)
	hud.ui_color = client.prefs.UI_style_color
	hud.ui_alpha = client.prefs.UI_style_alpha

	..(hud, FALSE)

	hud.init_screens(list(
		/atom/movable/screen/inventory/hand/r,
		/atom/movable/screen/inventory/hand/l,
		/atom/movable/screen/inventory/craft,
		/atom/movable/screen/drop,
		/atom/movable/screen/swap/first,
		/atom/movable/screen/swap/second,
		/atom/movable/screen/resist,
		/atom/movable/screen/equip,
		/atom/movable/screen/throw,
		/atom/movable/screen/complex/human,
		/atom/movable/screen/inventory/id,
		/atom/movable/screen/inventory/back,
		/atom/movable/screen/inventory/pocket1,
		/atom/movable/screen/inventory/pocket2,
		/atom/movable/screen/inventory/suit_storage,
		/atom/movable/screen/inventory/belt,
		/atom/movable/screen/complex/gun,
		/atom/movable/screen/health,
		/atom/movable/screen/health_doll,
		/atom/movable/screen/nutrition,
	))


	leap_icon?.add_to_hud(hud)

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

/datum/hud/proc/human_hud(ui_color = "#ffffff", ui_alpha = 255)
	var/mob/living/carbon/human/H = mymob

	add_intents(ui_style)
	add_move_intent(ui_style, ui_color, ui_alpha)
	adding += new /atom/movable/screen/inventory/craft

	// hiddable inventory
	var/list/types = list(
		/atom/movable/screen/inventory/uniform,
		/atom/movable/screen/inventory/suit,
		/atom/movable/screen/inventory/mask,
		/atom/movable/screen/inventory/gloves,
		/atom/movable/screen/inventory/eyes,
		/atom/movable/screen/inventory/l_ear,
		/atom/movable/screen/inventory/r_ear,
		/atom/movable/screen/inventory/head,
		/atom/movable/screen/inventory/shoes,
	)
	init_screens(types, ui_style, ui_color, ui_alpha, other)

	add_hands(ui_style, ui_color, ui_alpha)

	// simple hotkeys
	types = list(
		/atom/movable/screen/drop,
		/atom/movable/screen/inventory/swap/first,
		/atom/movable/screen/inventory/swap/second,
		/atom/movable/screen/resist,
		/atom/movable/screen/equip,
	)
	init_screens(types, ui_style, ui_color, ui_alpha, hotkeybuttons)

	// visible inventory, inventory toggle and craft
	types = list(
		/atom/movable/screen/toggle,
		/atom/movable/screen/inventory/id,
		/atom/movable/screen/inventory/back,
		/atom/movable/screen/inventory/pocket1,
		/atom/movable/screen/inventory/pocket2,
		/atom/movable/screen/inventory/suit_storage,
		/atom/movable/screen/inventory/belt,
	)
	init_screens(types, ui_style, ui_color, ui_alpha, adding)

	add_throw_icon(ui_style, ui_color, ui_alpha)
	add_internals(ui_style)
	add_healths(ui_style)
	add_health_doll()
	add_nutrition_icon()
	add_pullin(ui_style)

	add_changeling()

	mymob.pain = new /atom/movable/screen( null )

	add_zone_sel(ui_style, ui_color, ui_alpha)

	if(isanycop(H) || isanygangster(H))
		add_wanted_level()

	if(mymob.leap_icon)
		src.adding += mymob.leap_icon

	add_gun_setting()

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

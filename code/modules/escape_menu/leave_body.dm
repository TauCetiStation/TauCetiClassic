/datum/escape_menu/proc/show_leave_body_page()
	PRIVATE_PROC(TRUE)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/leave_body_button(
		src,
		"Суицид",
		"Драматично окончить свою жизнь самоубийством",
		/* pixel_offset = */ -105,
		CALLBACK(src, PROC_REF(leave_suicide)),
		/* button_overlay = */ "clown",
	))

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/leave_body_button(
			src,
			"Призрак",
			"Тихонько выйти, оставив своё тело",
			/* pixel_offset = */ 0,
			CALLBACK(src, PROC_REF(leave_ghost)),
			/* button_overlay = */ "ghost",
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/leave_body_button(
			src,
			"Вернуться",
			/* tooltip_text = */ "Вернуться в меню",
			/* pixel_offset = */ 105,
			CALLBACK(src, PROC_REF(open_home_page)),
			/* button_overlay = */ "back",
		)
	)

/datum/escape_menu/proc/leave_ghost()
	PRIVATE_PROC(TRUE)

	// Not guaranteed to be living. Everything defines verb/ghost separately. Fuck you.
	var/mob/living/living_user = client?.mob
	living_user?.ghost()

/datum/escape_menu/proc/leave_suicide()
	PRIVATE_PROC(TRUE)

	// Not guaranteed to be human. Everything defines verb/suicide separately. Fuck you, still.
	var/mob/living/carbon/human/human_user = client?.mob
	human_user?.suicide()

/atom/movable/screen/escape_menu/leave_body_button
	icon = 'icons/hud/escape_menu_leave_body.dmi'
	icon_state = "template"
	maptext_width = 114
	maptext_y = -32

	VAR_PRIVATE
		datum/callback/on_click_callback
		hovered = FALSE
		tooltip_text

/atom/movable/screen/escape_menu/leave_body_button/atom_init(
	mapload,
	button_text,
	tooltip_text,
	pixel_offset,
	on_click_callback,
	button_overlay,
)
	. = ..()

	src.on_click_callback = on_click_callback
	src.tooltip_text = tooltip_text

	add_overlay(button_overlay)

	maptext = MAPTEXT_VCR_OSD_MONO("<span b style='font-size: 16px; text-align: center'>[button_text]</span>")
	screen_loc = "CENTER:[pixel_offset],CENTER-1"

/atom/movable/screen/escape_menu/leave_body_button/Destroy()
	on_click_callback = null
	return ..()

/atom/movable/screen/escape_menu/leave_body_button/Click(location, control, params)
	on_click_callback?.InvokeAsync()

/atom/movable/screen/escape_menu/leave_body_button/MouseEntered(location, control, params)
	if (hovered)
		return

	hovered = TRUE

	// The UX on this is pretty shit, but it's okay enough for now.
	// Regularly goes way too far from your cursor. Not designed for large icons.
	openToolTip(usr, src, params, content = tooltip_text)

/atom/movable/screen/escape_menu/leave_body_button/MouseExited(location, control, params)
	if (!hovered)
		return

	hovered = FALSE
	closeToolTip(usr)

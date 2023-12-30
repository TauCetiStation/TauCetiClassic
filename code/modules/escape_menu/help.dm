/datum/escape_menu/proc/show_help_page()
	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button/text(
			null,
			/* hud_owner = */ src,
			src,
			/* button_text = */ "Мой вопрос касаемо...",
			/* offset = */ 0,
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button/help(
			null,
			/* hud_owner = */ src,
			src,
			/* button_text = */ "Правил",
			/* offset = */ 2,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(adminhelp)),
			/* tooltip_text = */ "Следует обращаться, если правила были нарушены или имеется вопрос по ним. К примеру, Вас кто-то неправомерно убил, нарушает РП, атмосферу и т.п.",
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button/help(
			null,
			/* hud_owner = */ src,
			src,
			/* button_text = */ "Игровых механик",
			/* offset = */ 3,
			/* on_click_callback = */ CALLBACK(src, PROC_REF(mentorhelp)),
			/* tooltip_text = */ "Следует обращаться, если у Вас имеются вопросы по игре. К примеру, как поменять руки, снять рюкзак, настроить двигатель или кто такой ГСБ.",
		)
	)

	page_holder.give_screen_object(
		new /atom/movable/screen/escape_menu/home_button/help(
			null,
			/* hud_owner = */ src,
			src,
			/* button_text = */"Вернуться",
			/* offset = */ 5,
			/* on_click_callback = */CALLBACK(src, PROC_REF(open_home_page)),
			/* tooltip_text = */"Вернуться в меню.",
		)
	)

/atom/movable/screen/escape_menu/home_button/text/atom_init(mapload, datum/hud/hud_owner, datum/escape_menu/escape_menu, button_text, offset, on_click_callback)
	. = ..()
	home_button_text.maptext = MAPTEXT_VCR_OSD_MONO("<span style='font-size: 32px; color: white'>[button_text]</span>")
	home_button_text.update_text()
	vis_contents += home_button_text

/atom/movable/screen/escape_menu/home_button/text/MouseEntered(location, control, params)
	return

/atom/movable/screen/escape_menu/home_button/text/MouseExited(location, control, params)
	return

/atom/movable/screen/escape_menu/home_button/text/enabled()
	return FALSE

/atom/movable/screen/escape_menu/home_button/text/text_color()
	return "white"

/atom/movable/screen/escape_menu/home_button/help //Partly from leave_body
	VAR_PRIVATE
		hovered = FALSE
		tooltip_text

/atom/movable/screen/escape_menu/home_button/help/atom_init(
	mapload,
	datum/hud/hud_owner,
	datum/escape_menu/escape_menu,
	button_text,
	offset,
	on_click_callback,
	tooltip_text,
	)
	. = ..()

	src.tooltip_text = tooltip_text


/atom/movable/screen/escape_menu/home_button/help/Destroy()
	on_click_callback = null
	return ..()

/atom/movable/screen/escape_menu/home_button/help/Click(location, control, params)
	on_click_callback?.InvokeAsync()

/atom/movable/screen/escape_menu/home_button/help/MouseEntered(location, control, params)
	. = ..()
	if (hovered)
		return

	hovered = TRUE

	// The UX on this is pretty shit, but it's okay enough for now.
	// Regularly goes way too far from your cursor. Not designed for large icons.
	openToolTip(usr, src, params, content = tooltip_text)

/atom/movable/screen/escape_menu/home_button/help/MouseExited(location, control, params)
	. = ..()
	if (!hovered)
		return

	hovered = FALSE
	closeToolTip(usr)

/datum/escape_menu/proc/adminhelp() //Silly
	PRIVATE_PROC(TRUE)
	client.adminhelp()

/datum/escape_menu/proc/mentorhelp()
	PRIVATE_PROC(TRUE)
	client.get_mentorhelp()

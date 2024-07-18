/obj/item/pen_holder
	name = "pen holder"
	desc = "Держатель для ручки."
	icon = 'icons/obj/items.dmi'
	icon_state = "penholder"

	var/obj/item/weapon/pen/holded

/obj/item/pen_holder/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen) && !holded)
		user.drop_from_inventory(I, src)
		holded = I
		holded.pixel_x = -2
		holded.pixel_y = 5
		underlays += holded
		icon_state = "penholder_full"

/obj/item/pen_holder/attack_hand(mob/user)
	if(holded)
		underlays = null
		holded.pixel_x = 0
		holded.pixel_y = 0
		user.put_in_active_hand(holded)
		holded = null
		icon_state = "penholder"
	else
		..()

/obj/item/pens_bin
	name = "pens bin"
	desc = "Органайзер для ручек."
	icon = 'icons/obj/items.dmi'
	icon_state = "pens_bin"

	var/list/pens_locations = list(list(-2, 4), list(-2, 5), list(-3, 6), list(-3, 7), list(-4, 7))

/obj/item/pens_bin/atom_init(mapload)
	. = ..()

	if(mapload)
		var/turf/T = get_turf(src)
		for(var/obj/item/weapon/pen/Pen in T.contents)
			var/list/offsets = pick(pens_locations)
			Pen.pixel_x = offsets[1]
			Pen.pixel_y = offsets[2]
			Pen.forceMove(src)
		update_icon()

/obj/item/pens_bin/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen))
		var/list/offsets = pick(pens_locations)
		I.pixel_x = offsets[1]
		I.pixel_y = offsets[2]
		user.drop_from_inventory(I, src)
		update_icon()
		return
	return ..()

/obj/item/pens_bin/attack_hand(mob/user)
	if(contents.len)
		var/list/pens = list()
		for(var/obj/item/weapon/pen in contents)
			pens[pen] = image(icon = pen.icon, icon_state = pen.icon_state)

		var/obj/item/weapon/pen/selection = show_radial_menu(user, src, pens, require_near = TRUE, tooltips = TRUE)

		if(selection)
			if(ishuman(user))
				user.put_in_hands(selection)
			else
				selection.forceMove(get_turf(src))
			update_icon()
	else
		..()

/obj/item/pens_bin/update_icon()
	cut_overlays()
	for(var/obj/item/weapon/pen/Pen in contents)
		add_overlay(Pen)

	var/image/front_side = image('icons/obj/items.dmi', "pens_bin_front")
	front_side.layer = layer + 0.01
	add_overlay(front_side)

/obj/item/mars_globe
	name = "mars globe"
	desc = "Глобус Марса."
	icon = 'icons/obj/items.dmi'
	icon_state = "globe"

/obj/item/newtons_pendulum
	name = "newton's pendulum"
	desc = "Вечный двигатель в миниатюре."
	icon = 'icons/obj/items.dmi'
	icon_state = "newtons_pendulum"

/obj/item/tableclock
	name = "table clock"
	desc = "Точное время в любое время."
	icon = 'icons/obj/items.dmi'
	icon_state = "clock"

	maptext_x = 1
	maptext_y = 1

/obj/item/tableclock/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/tableclock/process()
	var/time = world.time
	var/new_text = {"<div style="font-size:3;color:#61a53f;font-family:'TINIESTONE';text-align:center;" valign="middle">[round(time / 36000)+12] [(time / 600 % 60) < 10 ? add_zero(time / 600 % 60, 1) : time / 600 % 60]</div>"}

	if(maptext != new_text)
		maptext = new_text

		desc = "'Точное время в любое время'. Показывают: [worldtime2text()]"

/obj/item/wallclock
	name = "wall clock"
	desc = "Показывают время."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "clock"

	anchored = TRUE

/obj/item/wallclock/atom_init(mapload)
	. = ..()
	if(!mapload)
		anchored = FALSE

/obj/item/wallclock/attack_hand(mob/user)
	if(!Adjacent(usr) || usr.incapacitated())
		return
	src.anchored = FALSE
	user.put_in_hands(src)

/obj/item/wallclock/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Показывают: [worldtime2text()]</span>")

/obj/item/portrait
	name = "portrait"
	desc = "Портрет должностного лица НаноТрейзен."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nt_portrait_1"

	anchored = TRUE

/obj/item/portrait/atom_init(mapload)
	. = ..()
	if(!mapload)
		anchored = FALSE
	// gusev....
	if(istype(src, /obj/item/portrait/neuro))
		return
	var/portrait_number = rand(1, 3)
	icon_state = "nt_portrait_[portrait_number]"
	switch(portrait_number)
		if(1)
			desc = "Альфред Д.Кроуфорд - директор отдела развития и интеграциий НаноТрейзен."
		if(2)
			desc = "Измаил Моше - генеральный инспектор НаноТрейзен."
		if(3)
			desc = "Константин Карпатенко - ранее адмирал ракетного флота, ныне духовный лидер флота НаноТрейзен."

/obj/item/portrait/attack_hand(mob/user)
	if(!Adjacent(user) || user.incapacitated())
		return
	anchored = FALSE
	user.put_in_hands(src)

var/global/list/station_head_portraits = list()
ADD_TO_GLOBAL_LIST(/obj/item/portrait/captain, station_head_portraits)
/obj/item/portrait/captain
	desc = "Портрет главы станции."
	icon_state = "portrait_empty"

/obj/item/portrait/captain/atom_init()
	. = ..()
	desc = "Портрет главы [station_name_ru()]."

/proc/update_station_head_portraits()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(update_station_head_portraits)), 10 MINUTES)
	var/image/Heads_photo

	var/newdesc
	var/datum/data/record/CAP = find_general_record("rank", "Captain")
	var/datum/data/record/HOS = find_general_record("rank", "Head of Security")
	var/datum/data/record/HOP = find_general_record("rank", "Head of Personnel")

	if(CAP)
		Heads_photo = image(CAP.fields["photo_f"])
		newdesc = "Портрет [CAP.fields["name"]], главы [station_name_ru()]."
	else if(HOP)
		Heads_photo = image(HOP.fields["photo_f"])
		newdesc = "Портрет [HOP.fields["name"]], главы кадровой службы [station_name_ru()]."
	else if(HOS)
		Heads_photo = image(HOS.fields["photo_f"])
		newdesc = "Портрет [HOS.fields["name"]], главы службы безопасности [station_name_ru()]."

	if(Heads_photo)
		Heads_photo.add_filter("portrait_mask", 1, alpha_mask_filter(icon = icon('icons/obj/stationobjs.dmi', "portrait_mask")))
		Heads_photo.pixel_y = -2

		for(var/obj/item/portrait/captain/Portrait in global.station_head_portraits)
			Portrait.cut_overlays()
			Portrait.icon_state = "portrait_empty"
			Portrait.desc = newdesc
			Portrait.add_overlay(Heads_photo)

/obj/item/portrait/neuro
	name = "neuro frame"
	desc = "Это всего лишь рамка. Только кристалл и дерево. Рамка нарисует картину? Рамка превратит кусок холста в шедевр искусства? А Вы?"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portrait_empty"

	anchored = TRUE

	// neural image generation
	var/autogenerating = TRUE
	var/autogenerating_timer

	var/generating = FALSE

	var/frame_width = 13
	var/frame_height = 17
	var/image_offset_x = 9
	var/image_offset_y = 11
	var/generating_scale = 50
	var/examinate_scale = 15

	var/prompt
	var/style = "Детальное фото"
	var/output_image_base64

	var/list/prompt_rotation = list(
		"portrait of cool cat in googles",
		"portrait of cool cat in space",
		"portrait of the President of the big corporation",
		"portrait of cool dog in googles",
		"portrait of cool dog in space",
	)

/obj/item/portrait/neuro/atom_init(mapload)
	. = ..()
	if(autogenerating)
		generate_new_image()

/obj/item/portrait/neuro/Destroy()
	deltimer(autogenerating_timer)
	return ..()

/obj/item/portrait/neuro/examine(mob/user)
	. = ..()
	if(output_image_base64)
		to_chat(user, "\[[prompt]\] в стиле [style]:<br><img height='[frame_height*examinate_scale]' width='[frame_width*examinate_scale]' src='data:image/png;base64, [output_image_base64]' />")

/obj/item/portrait/neuro/attack_hand(mob/user)
	var/choice = tgui_input_list(user, "Что сделать?", "Портрет", list("Изменить", "Снять", "Ничего"))
	switch(choice)
		if("Снять")
			return ..()
		if("Изменить")
			change_neuro_settings(user)

/obj/item/portrait/neuro/proc/change_neuro_settings(mob/user)
	if(!Adjacent(user) || user.incapacitated())
		return

	var/autogenerating_variant = "Включить авторотацию"
	if(autogenerating)
		autogenerating_variant = "Выключить авторотацию"

	var/choice = tgui_input_list(
		user,
		"Что сделать?",
		"Портрет",
		list("Добавить вариант", "Удалить вариант", "Сменить стиль", "Обновить картину", autogenerating_variant, "Выйти")
		)
	switch(choice)
		if("Добавить вариант")
			var/new_prompt = sanitize(input(user, "Введите запрос", "Портрет") as text|null)
			if(new_prompt)
				prompt_rotation += new_prompt
			change_neuro_settings(user)
		if("Удалить вариант")
			var/remove_prompt = tgui_input_list(user, "Выберите запрос", "Портрет", prompt_rotation)
			if(remove_prompt)
				prompt_rotation -= remove_prompt
			change_neuro_settings(user)
		if("Сменить стиль")
			var/new_style = tgui_input_list(user, "Выберите стиль", "Портрет", SSneural.get_available_styles())
			if(new_style)
				style = new_style
			change_neuro_settings(user)
		if("Обновить картину")
			generate_new_image(user)
			change_neuro_settings(user)
		if("Включить авторотацию")
			set_autorogenerating(TRUE)
			change_neuro_settings(user)
		if("Выключить авторотацию")
			set_autorogenerating(FALSE)
			change_neuro_settings(user)
		else
			return

/obj/item/portrait/neuro/proc/generate_new_image(mob/user)
	if(autogenerating && !autogenerating_timer)
		autogenerating_timer = addtimer(CALLBACK(src, PROC_REF(generate_new_image)), 3 MINUTE, TIMER_STOPPABLE)
		if(prob(10))
			style = pick(SSneural.get_available_styles())

	if(generating)
		if(user)
			to_chat(user, "<span class='warning'>Пожалуйста, подождите! Генерация в процессе!</span>")
		return

	if(prompt_rotation.len == 0)
		if(user)
			to_chat(user, "<span class='warning'>Список запросов пуст!</span>")
		return

	set_neural_image()

/obj/item/portrait/neuro/proc/set_neural_image()
	set waitfor = FALSE

	autogenerating_timer = null

	if(prompt_rotation.len == 0)
		return

	generating = TRUE
	prompt = pick(prompt_rotation)
	var/datum/neural_query/query = new
	query.prompt = prompt
	query.style = style
	query.target_width = frame_width
	query.target_height = frame_height
	query.generate_width = frame_width*generating_scale
	query.generate_height = frame_height*generating_scale
	query.file_path = SSneural.get_full_path("portrait", prompt)

	output_image_base64 = SSneural.generate_neural_image(query)
	if(!output_image_base64)
		generating = FALSE
		return
	// Just in case the frame is deleted during generation
	if(src == null)
		SSneural.release_cache(query.file_path)
		return

	cut_overlays()

	var/icon/I = new(query.file_path)
	var/mutable_appearance/image = mutable_appearance(I)
	image.pixel_x = image_offset_x
	image.pixel_y = image_offset_y
	add_overlay(image)

	SSneural.release_cache(query.file_path)
	generating = FALSE

/obj/item/portrait/neuro/proc/set_autorogenerating(value)
	if(value)
		autogenerating = TRUE
		generate_new_image()
	else
		autogenerating = FALSE
		autogenerating_timer = null
		deltimer(autogenerating_timer)

/obj/item/portrait/neuro/big
	icon_state = "portrait_big_empty"

	frame_width = 28
	frame_height = 28
	image_offset_x = 2
	image_offset_y = 2
	generating_scale = 32

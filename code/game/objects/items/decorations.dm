/obj/item/pen_holder
	name = "pen holder"
	desc = "Держатель для ручки."
	icon = 'icons/obj/items.dmi'
	icon_state = "penholder"

	var/obj/item/weapon/pen/holded

/obj/item/pen_holder/atom_init(mapload)
	. = ..()

	if(mapload)
		var/turf/T = get_turf(src)
		var/obj/item/weapon/pen/Pen = locate() in T.contents
		if(Pen)
			Pen.forceMove(src)
			holded = Pen

			update_icon()

/obj/item/pen_holder/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen) && !holded)
		user.drop_from_inventory(I, src)
		holded = I

		update_icon()

/obj/item/pen_holder/attack_hand(mob/user)
	if(holded)
		holded.pixel_x = 0
		holded.pixel_y = 0
		user.put_in_active_hand(holded)
		holded = null

		update_icon()
	else
		..()

/obj/item/pen_holder/update_icon()
	underlays = null
	icon_state = "penholder"

	if(holded)
		icon_state = "penholder_full"
		holded.pixel_x = -2
		holded.pixel_y = 5
		underlays += holded

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
			selection.pixel_x = 0
			selection.pixel_y = 0
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

/obj/item/globe
	name = "mars globe"
	cases = list("глобус Марса", "глобуса Марса", "глобусу Марса", "глобус Марса", "глобусом Марса", "глобусе Марса")
	desc = "Точное отображение поверхности Марса."
	icon = 'icons/obj/items.dmi'
	icon_state = "globe_mars"

/obj/item/globe/venus
	name = "venus globe"
	cases = list("глобус Венеры", "глобуса Венеры", "глобусу Венеры", "глобус Венеры", "глобусом Венеры", "глобусе Венеры")
	desc = "Точное отображение поверхности Венеры."
	icon_state = "globe_venus"

/obj/item/globe/earth
	name = "earth globe"
	cases = list("глобус Земли", "глобуса Земли", "глобусу Земли", "глобус Земли", "глобусом Земли", "глобусе Земли")
	desc = "Точное отображение поверхности Земли."
	icon_state = "globe_earth"

/obj/item/globe/yargon
	name = "yargon IV globe"
	cases = list("глобус Яргона-4", "глобуса Яргона-4", "глобусу Яргона-4", "глобус Яргона-4", "глобусом Яргона-4", "глобусе Яргона-4")
	desc = "Точное отображение поверхности Яргона-4."
	icon_state = "globe_yargon4"

/obj/item/globe/moghes
	name = "moghes globe"
	cases = list("глобус Могеса", "глобуса Могеса", "глобусу Могеса", "глобус Могеса", "глобусом Могеса", "глобусе Могеса")
	desc = "Точное отображение поверхности Могеса."
	icon_state = "globe_moghes"

/obj/item/globe/adhomai
	name = "adhomai globe"
	cases = list("глобус Адомая", "глобуса Адомая", "глобусу Адомая", "глобус Адомая", "глобусом Адомая", "глобусе Адомая")
	desc = "Точное отображение поверхности Адомая."
	icon_state = "globe_adhomai"

/obj/item/globe/gestalt
	name = "dionaea gestalt model"
	cases = list("модель гештальта", "модели гештальта", "модели гештальта", "модель гештальта", "моделью гештальта", "модели гештальта")
	desc = "Модель единственного найденного гештальта Дион."
	icon_state = "globe_gestalt"

/obj/item/globe/pluvia
	name = "pluvia globe"
	cases = list("глобус Плувии", "глобуса Плувии", "глобусу Плувии", "глобус Плувии", "глобусом Плувии", "глобусе Плувии")
	desc = "Точное отображение поверхности Плувии."
	icon_state = "globe_pluvia"

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

/obj/item/woodenclock
	name = "wooden clock"
	cases = list("настольные часы", "настольных часов", "настольным часам", "настольные часы", "настольными часами", "настольных часах")
	desc = "Показывают время."
	icon = 'icons/obj/items.dmi'
	icon_state = "wooden_clock"

	var/image/hours_hand
	var/image/minute_hand

/obj/item/woodenclock/atom_init()
	. = ..()

	hours_hand = image('icons/obj/stationobjs.dmi', "clock_h_0")
	hours_hand.pixel_y = -7
	add_overlay(hours_hand)
	minute_hand = image('icons/obj/stationobjs.dmi', "clock_m_0")
	minute_hand.pixel_y = -7
	add_overlay(minute_hand)
	START_PROCESSING(SSobj, src)

/obj/item/woodenclock/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Показывают: [worldtime2text()]</span>")

/obj/item/woodenclock/process()
	var/timeChanged = FALSE
	var/new_hours_state = "clock_h_[worldtime_hours() % 12]"
	if(hours_hand.icon_state != new_hours_state)
		cut_overlay(hours_hand)
		hours_hand.icon_state = new_hours_state
		add_overlay(hours_hand)
		timeChanged = TRUE

	var/new_minute_state = "clock_m_[(round(worldtime_minutes() / 5) % 12)]"

	if(minute_hand.icon_state != new_minute_state)
		cut_overlay(minute_hand)
		minute_hand.icon_state = new_minute_state
		add_overlay(minute_hand)
		timeChanged = TRUE

	if(timeChanged && istype(loc, /obj/structure/bookcase/shelf))
		var/obj/structure/bookcase/shelf/Shelf = loc
		Shelf.update_icon()

/obj/item/wallclock
	name = "wall clock"
	desc = "Показывают время."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "clock"

	anchored = TRUE

	var/image/hours_hand
	var/image/minute_hand

/obj/item/wallclock/atom_init(mapload)
	. = ..()
	if(!mapload)
		anchored = FALSE

	hours_hand = image('icons/obj/stationobjs.dmi', "clock_h_0")
	add_overlay(hours_hand)
	minute_hand = image('icons/obj/stationobjs.dmi', "clock_m_0")
	add_overlay(minute_hand)
	START_PROCESSING(SSobj, src)

/obj/item/wallclock/attack_hand(mob/user)
	if(!Adjacent(usr) || usr.incapacitated())
		return
	src.anchored = FALSE
	user.put_in_hands(src)

/obj/item/wallclock/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Показывают: [worldtime2text()]</span>")

/obj/item/wallclock/process()
	var/new_hours_state = "clock_h_[worldtime_hours() % 12]"
	if(hours_hand.icon_state != new_hours_state)
		cut_overlay(hours_hand)
		hours_hand.icon_state = new_hours_state
		add_overlay(hours_hand)

	var/new_minute_state = "clock_m_[(round(worldtime_minutes() / 5) % 12)]"
	if(minute_hand.icon_state != new_minute_state)
		cut_overlay(minute_hand)
		minute_hand.icon_state = new_minute_state
		add_overlay(minute_hand)

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
	if(!Adjacent(usr) || usr.incapacitated())
		return
	src.anchored = FALSE
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

/obj/item/bust
	name = "gypsum bust"
	cases = list("гипсовый бюст", "гипсового бюста", "гипсовому бюсту", "гипсовый бюст", "гипсовым бюстом", "гипсомвом бюсте")
	desc = "Гипсовый бюст должностного лица НаноТрейзен."
	icon = 'icons/obj/items.dmi'
	icon_state = "bust_1"

/obj/item/bust/atom_init(mapload)
	. = ..()
	var/bust_number = rand(1, 3)
	icon_state = "bust_[bust_number]"
	switch(bust_number)
		if(1)
			desc = "Франклин Моррис - Главный представитель НаноТрейзен на территории СолГов."
		if(2)
			desc = "Эдвард Мунос - Начальник ОБОП НаноТрейзен."
		if(3)
			desc = "Маргарет Чейн - Директор отдела кооперации и связей с общественностью НаноТрейзен."

/obj/item/jar
	name = "jar"
	desc = "Банка для печенья или конфет."
	icon = 'icons/obj/items.dmi'
	icon_state = "candy_jar"

	var/itemsMax = 10

	var/list/spawn_paths = list()

	var/image/front_side

/obj/item/jar/atom_init(mapload)
	. = ..()

	if(spawn_paths)
		for(var/i in 1 to rand(7, itemsMax))
			var/item_path = pick(spawn_paths)
			if(!item_path)
				break

			new item_path(src)

	front_side = image(icon = 'icons/obj/items.dmi', icon_state = "candy_jar_front")

	update_icon()

/obj/item/jar/attackby(obj/item/I, mob/user, params)
	if(I.w_class <= SIZE_TINY && contents.len < itemsMax)
		user.drop_from_inventory(I, src)
		update_icon()
		return
	return ..()

/obj/item/jar/attack_hand(mob/user)
	if(!contents.len)
		return ..()

	var/list/candies = list()
	candies["Pickup"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_pickup")

	for(var/obj/item/Candy in contents)
		candies[Candy] = image(icon = Candy.icon, icon_state = Candy.icon_state)

	var/obj/item/selection = show_radial_menu(user, src, candies, require_near = TRUE, tooltips = TRUE)

	if(!selection)
		return

	if(selection == "Pickup")
		return ..()

	if(ishuman(user))
		user.put_in_hands(selection)
	else
		selection.forceMove(get_turf(src))

	update_icon()

/obj/item/jar/update_icon()
	cut_overlay(front_side)
	front_side.clear_filters()

	var/i = 1
	for(var/obj/item/Candy in contents)
		front_side.add_filter("add_item_[i])", 1, layering_filter(x = rand(-4, 4), y = rand(-8, 2), icon = icon(Candy.icon, Candy.icon_state), flags = FILTER_UNDERLAY))
		i++

	front_side.add_filter("jar_front", 1, alpha_mask_filter(icon = icon('icons/obj/items.dmi', "candy_jar_mask")))

	add_overlay(front_side)

/obj/item/jar/candy
	name = "candy jar"
	spawn_paths = list(/obj/random/foods/candies)

/obj/item/jar/cookie
	name = "cookie jar"
	spawn_paths = list(/obj/item/weapon/reagent_containers/food/snacks/cookie)

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

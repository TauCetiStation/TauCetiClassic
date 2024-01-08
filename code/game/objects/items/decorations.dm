/obj/item/pen_holder
	name = "pen holder"
	cases = list("держатель для ручки", "держателя для ручки", "держателю для ручки", "держатель для ручки", "держателем для ручки", "держателе для ручки")
	desc = "Удержит любую ручку."
	icon = 'icons/obj/items.dmi'
	icon_state = "penholder"

	var/obj/item/weapon/pen/holded

/obj/item/pen_holder/atom_init(mapload)
	. = ..()

	if(mapload)
		var/turf/T = get_turf(src)
		var/obj/item/weapon/pen/Pen = locate(/obj/item/weapon/pen) in T.contents
		if(!Pen)
			return
		Pen.pixel_x = -2
		Pen.pixel_y = 5
		Pen.forceMove(src)
		holded = Pen
		underlays += Pen
		icon_state = "penholder_full"

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
	cases = list("стакан для ручек", "стакана для ручек", "стакану для ручек", "стакан для ручек", "стаканом для ручек", "стакане для ручек")
	desc = "Удобный органайзер для ручек."
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
	cases = list("глобус Марса", "глобуса Марса", "глобусу Марса", "глобус Марса", "глобусом Марса", "глобусе Марса")
	desc = "Точное отображение поверхности Марса."
	icon = 'icons/obj/items.dmi'
	icon_state = "globe_mars"

/obj/item/venus_globe
	name = "venus globe"
	cases = list("глобус Венеры", "глобуса Венеры", "глобусу Венеры", "глобус Венеры", "глобусом Венеры", "глобусе Венеры")
	desc = "Точное отображение поверхности Венеры."
	icon = 'icons/obj/items.dmi'
	icon_state = "globe_venus"

/obj/item/earth_globe
	name = "earth globe"
	cases = list("глобус Земли", "глобуса Земли", "глобусу Земли", "глобус Земли", "глобусом Земли", "глобусе Земли")
	desc = "Точное отображение поверхности Земли."
	icon = 'icons/obj/items.dmi'
	icon_state = "globe_earth"

/obj/item/yargon_globe
	name = "yargon IV globe"
	cases = list("глобус Яргона-4", "глобуса Яргона-4", "глобусу Яргона-4", "глобус Яргона-4", "глобусом Яргона-4", "глобусе Яргона-4")
	desc = "Точное отображение поверхности Яргона-4."
	icon = 'icons/obj/items.dmi'
	icon_state = "globe_yargon4"

/obj/item/newtons_pendulum
	name = "newton's pendulum"
	cases = list("маятник Ньютона", "маятника Ньютона", "маятнику Ньютона", "маятник Ньютона", "маятником Ньютона", "маятнике Ньютона")
	desc = "Вечный двигатель в миниатюре."
	icon = 'icons/obj/items.dmi'
	icon_state = "newtons_pendulum"

/obj/item/statuette
	name = "statuette"
	cases = list("статуэтка", "статуэтки", "статуэтке", "статуэтку", "статуэткой", "статуэтке")
	desc = "Абстрактная статуэтка."
	icon = 'icons/obj/items.dmi'
	icon_state = "statuette_1"

/obj/item/statuette/atom_init(mapload)
	. = ..()
	var/statuette_number = rand(1, 12)
	icon_state = "statuette_[statuette_number]"

/obj/item/vase
	name = "vase"
	cases = list("ваза", "вазы", "вазе", "вазу", "вазой", "вазе")
	desc = "Ваза для цветка."
	icon = 'icons/obj/items.dmi'
	icon_state = "vase_1"

	var/list/canplace = list(/obj/item/weapon/reagent_containers/food/snacks/grown/harebell, /obj/item/weapon/grown/sunflower, /obj/item/weapon/reagent_containers/food/snacks/grown/mtear, /obj/item/weapon/reagent_containers/food/snacks/grown/poppy)
	var/obj/item/flower

	var/image/flower_image
	var/image/front_image

/obj/item/vase/atom_init(mapload)
	. = ..()
	var/vase_number = rand(1, 15)
	icon_state = "vase_[vase_number]"
	front_image = image(icon, "[icon_state]_front")

	if(mapload)
		var/turf/T = get_turf(src)
		for(var/obj/item/weapon/G in T.contents)
			if(G.type in canplace)
				G.forceMove(src)
				flower = G
				update_icon()
				break

/obj/item/vase/attackby(obj/item/I, mob/user, params)
	if(I.type in canplace)
		user.drop_from_inventory(I, src)
		flower = I
		update_icon()
		return
	return ..()

/obj/item/vase/attack_hand(mob/user)
	if(user && user.a_intent == INTENT_GRAB)
		return ..()

	if(flower)
		if(ishuman(user))
			user.put_in_hands(flower)
		else
			flower.forceMove(get_turf(src))

		flower = null
		update_icon()
		return
	..()

/obj/item/vase/MouseDrop(mob/user)
	. = ..()
	if(user == usr && !usr.incapacitated() && Adjacent(usr))
		var/prev_intent = user.a_intent
		user.set_a_intent(INTENT_GRAB)
		attack_hand(user)
		user.set_a_intent(prev_intent)

/obj/item/vase/update_icon()
	cut_overlay(flower_image)
	cut_overlay(front_image)

	if(!flower)
		return

	flower_image = image(flower.icon, flower.item_state_world)
	add_overlay(flower_image)
	add_overlay(front_image)

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

/obj/item/tableclock
	name = "electronic clock"
	cases = list("электронные часы", "электронных часов", "электронным часам", "электронные часы", "электронными часами", "электронных часах")
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

/obj/item/woodenclock/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Показывают: [worldtime2text()]</span>")

/obj/item/wallclock
	name = "wall clock"
	cases = list("настенные часы", "настенных часов", "настенным часам", "настенные часы", "настенными часами", "настенных часах")
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
	cases = list("портрет", "портрета", "портрету", "портрет", "портретом", "портрете")
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
	desc = "Портрет главы станции Исход."
	icon_state = "portrait_empty"

/proc/update_station_head_portraits()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(update_station_head_portraits)), 10 MINUTES)
	var/image/Heads_photo

	var/newdesc
	var/datum/data/record/CAP = find_general_record("rank", "Captain")
	var/datum/data/record/HOS = find_general_record("rank", "Head of Security")
	var/datum/data/record/HOP = find_general_record("rank", "Head of Personnel")

	if(CAP)
		Heads_photo = image(CAP.fields["photo_f"])
		newdesc = "Портрет [CAP.fields["name"]], главы станции Исход."
	else if(HOP)
		Heads_photo = image(HOP.fields["photo_f"])
		newdesc = "Портрет [HOP.fields["name"]], главы кадровой службы станции Исход."
	else if(HOS)
		Heads_photo = image(HOS.fields["photo_f"])
		newdesc = "Портрет [HOS.fields["name"]], главы службы безопасности станции Исход."

	if(Heads_photo)
		Heads_photo.add_filter("portrait_mask", 1, alpha_mask_filter(icon = icon('icons/obj/stationobjs.dmi', "portrait_mask")))
		Heads_photo.pixel_y = -2

		for(var/obj/item/portrait/captain/Portrait in global.station_head_portraits)
			Portrait.cut_overlays()
			Portrait.icon_state = "portrait_empty"
			Portrait.desc = newdesc
			Portrait.add_overlay(Heads_photo)

/obj/structure/water_cooler
	name = "Water-Cooler"
	cases = list("кулер", "кулера", "кулеру", "кулер", "кулером", "кулере")
	desc = "Кулер фирмы Einstein Electronics."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "water_cooler_grey"

	anchored = TRUE
	density = TRUE

	var/obj/item/weapon/reagent_containers/food/drinks/water_cooler_bottle/bottle
	var/cups = 7
	var/maxcups = 10

	var/image/bottle_image
	var/image/cups_image

/obj/structure/water_cooler/atom_init()
	. = ..()

	icon_state = "water_cooler_[pick(list("red", "grey", "black", "white"))]"

	cups = rand(cups, maxcups)

	bottle = new(src)
	update_icon()

/obj/structure/water_cooler/update_icon()
	cut_overlay(bottle_image)
	cut_overlay(cups_image)

	if(bottle)
		bottle_image = image('icons/obj/stationobjs.dmi', "water_cooler_bottle_[ceil(bottle.reagents.total_volume/25)]")
		bottle_image.pixel_y = 4
		add_overlay(bottle_image)

	if(cups)
		cups_image = image(icon, "water_cooler_cups_[cups]")
		add_overlay(cups_image)

/obj/structure/water_cooler/attack_hand(mob/user)
	if(!Adjacent(usr) || usr.incapacitated())
		return

	if(!cups)
		return

	var/obj/item/weapon/reagent_containers/food/drinks/sillycup/cup = new

	if(ishuman(user))
		user.put_in_hands(cup)
	else
		cup.forceMove(get_turf(user))

	cups--

	to_chat(user, "<span class='notice'>Вы взяли стакан.</span>")
	update_icon()

/obj/structure/water_cooler/MouseDrop(mob/user)
	. = ..()
	if(!Adjacent(usr) || usr.incapacitated())
		return
	if(!user)
		return
	if(!bottle)
		return

	if(ishuman(user))
		user.put_in_hands(bottle)
	else
		bottle.forceMove(get_turf(user))

	bottle = null

	to_chat(user, "<span class='notice'>Вы забрали бутыль.</span>")
	update_icon()

/obj/structure/water_cooler/attackby(obj/item/I, mob/user, params)
	if(iswrenching(I))
		add_fingerprint(user)
		user.SetNextMove(CLICK_CD_INTERACT)
		if(user.is_busy())
			return

		anchored = !anchored
		return

	else if(istype(I, /obj/item/weapon/reagent_containers/food/drinks/water_cooler_bottle) && !bottle)
		user.drop_from_inventory(I, src)

		bottle = I
		update_icon()
		return

	return ..()

/obj/item/weapon/reagent_containers/food/drinks/water_cooler_bottle
	name = "cooler bottle"
	cases = list("бутыль", "бутыли", "бутыли", "бутыль", "бутылью", "бутыли")
	desc = "Бутыль живительной влаги."
	gender = FEMALE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "cooler_bottle"
	item_state = "cooler_bottle"
	volume = 200
	possible_transfer_amounts = list(10,25,50,100,200)

	density = TRUE

/obj/item/weapon/reagent_containers/food/drinks/water_cooler_bottle/atom_init()
	. = ..()

	reagents.add_reagent("water", rand(150,200))
	update_icon()

/obj/item/weapon/reagent_containers/food/drinks/water_cooler_bottle/update_icon()
	cut_overlays()

	if(reagents?.total_volume)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[icon_state][get_filling_state()]")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling)

/obj/item/weapon/reagent_containers/food/drinks/water_cooler_bottle/proc/get_filling_state()
	var/percent = round((reagents.total_volume / volume) * 100)
	var/list/increments = list()
	for(var/x in list(20, 40, 60, 80, 100))
		increments += text2num(x)
	if(!length(increments))
		return

	var/last_increment = increments[1]
	for(var/increment in increments)
		if(percent < increment)
			break

		last_increment = increment

	return last_increment

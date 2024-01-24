/obj/structure/bigDelivery
	desc = "A big wrapped package."
	name = "large parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycloset"
	density = TRUE
	var/sortTag = ""
	var/lot_number = null
	var/image/lot_lock_image
	flags = NOBLUDGEON
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	max_integrity = 5
	damage_deflection = 0
	resistance_flags = CAN_BE_HIT

/obj/structure/bigDelivery/proc/dump()
	for(var/atom/movable/AM in contents)
		if(istype(AM, /obj/structure/closet))
			var/obj/structure/closet/O = AM
			O.welded = 0
		AM.forceMove(get_turf(src))

/obj/structure/bigDelivery/Destroy()
	dump()
	if(lot_number)
		var/datum/shop_lot/Lot = global.online_shop_lots["[lot_number]"]
		qdel(Lot)
	return ..()

/obj/structure/bigDelivery/attack_hand(mob/user)
	if(lot_number && !(user in contents))
		var/datum/shop_lot/Lot = global.online_shop_lots["[lot_number]"]
		if(Lot && !Lot.delivered)
			to_chat(user, "<span class='notice'>Отметьте посылку доставленной в корзине чтобы открыть замок</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER)
			return
	if(contents.len > 0)
		dump()
	else
		to_chat(user, "<span class='notice'>The parcel was empty!</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', VOL_EFFECTS_MASTER)
	qdel(src)

/obj/structure/bigDelivery/attackby(obj/item/W, mob/user)
	if(istagger(W))
		var/obj/item/device/tagger/O = W
		if(src.sortTag != O.currTag)
			to_chat(user, "<span class='notice'>*[O.currTag]*</span>")
			src.sortTag = O.currTag
			playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)

	else if(istype(W, /obj/item/weapon/pen))
		var/str = sanitize_safe(input(usr,"Label text?","Set label",""), MAX_NAME_LEN)
		if(!str || !length(str))
			to_chat(usr, "<span class='warning'>Invalid text.</span>")
			return
		for(var/mob/M in viewers())
			to_chat(M, "<span class='notice'>[user] labels [src] as [str].</span>")
		src.name = "[src.name] ([str])"

	else if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/Crayon = W
		color = Crayon.colour

/obj/item/smallDelivery
	desc = "A small wrapped package."
	name = "small parcel"
	icon = 'icons/obj/storage.dmi'
	icon_state = "deliverycrateSmall"
	var/sortTag = ""
	var/lot_number = null
	var/image/lot_lock_image

	max_integrity = 5
	damage_deflection = 0
	resistance_flags = CAN_BE_HIT

/obj/item/smallDelivery/proc/dump(mob/user)
	for(var/atom/movable/AM in contents)
		if(user && user.put_in_active_hand(AM))
			AM.add_fingerprint(user)
		else
			AM.forceMove(src.loc)

/obj/item/smallDelivery/Destroy()
	dump()
	if(lot_number)
		var/datum/shop_lot/Lot = global.online_shop_lots["[lot_number]"]
		qdel(Lot)
	return ..()

/obj/item/smallDelivery/attack_self(mob/user)
	if(lot_number)
		var/datum/shop_lot/Lot = global.online_shop_lots["[lot_number]"]
		if(Lot && !Lot.delivered)
			to_chat(user, "<span class='notice'>Отметьте посылку доставленной в корзине чтобы открыть замок</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER)
			return
	if(contents.len > 0)
		user.drop_from_inventory(src)
		dump(user)
	else
		to_chat(user, "<span class='notice'>The parcel was empty!</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', VOL_EFFECTS_MASTER)
	qdel(src)

/obj/item/smallDelivery/attackby(obj/item/I, mob/user, params)
	if(istagger(I))
		var/obj/item/device/tagger/O = I
		if(src.sortTag != O.currTag)
			to_chat(user, "<span class='notice'>*[O.currTag]*</span>")
			sortTag = O.currTag
			playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)

	else if(istype(I, /obj/item/weapon/pen))
		var/str = sanitize_safe(input(usr,"Label text?","Set label",""), MAX_NAME_LEN)
		if(!str || !length(str))
			to_chat(usr, "<span class='warning'>Invalid text.</span>")
			return
		for(var/mob/M in viewers())
			to_chat(M, "<span class='notice'>[user] labels [src] as [str].</span>")
		name = "[name] ([str])"

	else if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/Crayon = I
		color = Crayon.colour

	else
		return ..()

/obj/item/weapon/packageWrap
	name = "package wrapper"
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	w_class = SIZE_SMALL
	var/amount = 25.0


/obj/item/weapon/packageWrap/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(!istype(target))	//this really shouldn't be necessary (but it is).	-Pete
		return
	if(istype(target, /obj/item/smallDelivery) || istype(target,/obj/structure/bigDelivery) \
	|| istype(target, /obj/item/weapon/gift) || istype(target, /obj/item/weapon/evidencebag))
		return
	if(!isobj(target))
		return
	var/obj/O = target
	if(O.flags_2 & CANT_BE_INSERTED)
		return
	if(O.anchored)
		return
	if(O in user)
		return
	if(user in O) //no wrapping closets that you are inside - it's not physically possible
		return

	user.attack_log += text("\[[time_stamp()]\] <font color='blue'>Has used [src.name] on \ref[O]</font>")


	if (isitem(O))
		var/obj/item/I = target
		if (src.amount > 1)
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_turf(I.loc))	//Aaannd wrap it up!
			if(!istype(I.loc, /turf))
				if(user.client)
					user.client.screen -= I
			P.w_class = I.w_class
			var/i = round(I.w_class)
			if(i >= SIZE_MINUSCULE && i <= SIZE_BIG)
				if(istype(I, /obj/item/pizzabox))
					var/obj/item/pizzabox/B = I
					P.icon_state = "deliverypizza[length(B.boxes)]"
				else
					P.icon_state = "deliverycrate[i]"
			I.loc = P
			P.add_fingerprint(usr)
			I.add_fingerprint(usr)
			add_fingerprint(usr)
			src.amount -= 1
	else if (istype(O, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/C = target
		if (src.amount > 3 && !C.opened)
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(C.loc))
			P.icon_state = "deliverycrate"
			C.loc = P
			src.amount -= 3
		else if(src.amount < 3)
			to_chat(user, "<span class='notice'>You need more paper.</span>")
	else if (istype (O, /obj/structure/closet))
		var/obj/structure/closet/C = target
		if(src.amount < 3)
			to_chat(user, "<span class='notice'>You need more paper.</span>")
			return
		else if(C.welded)
			to_chat(user, "<span class='notice'>You cannot wrap a welded closet.</span>")
			return
		else if (!C.opened)
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(C.loc))
			C.welded = 1
			C.loc = P
			src.amount -= 3
	else
		to_chat(user, "<span class='notice'>The object you are trying to wrap is unsuitable for the sorting machinery!</span>")
	if (src.amount <= 0)
		new /obj/item/weapon/c_tube( src.loc )
		qdel(src)
		return
	return

/obj/item/weapon/packageWrap/examine(mob/user)
	..()
	if(src in user)
		to_chat(user, "<span class='notice'>There are [amount] units of package wrap left!</span>")

/obj/item/device/tagger
	name = "tagger"
	desc = "Используется для наклейки меток, ценников и бирок."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler_shop"
	var/currTag = 0

	w_class = SIZE_TINY
	item_state = "electronic"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	m_amt = 3000
	g_amt = 1300
	origin_tech = "materials=1;engineering=1"

	var/mode = 1
	var/list/modes = list(1 = "Метка", 2 = "Ценник", 3 = "Бирка")

	var/lot_description = "Это что-то"
	var/lot_account_number = null
	var/lot_category = "Разное"
	var/lot_price = 0

	var/autodescription = TRUE
	var/autocategory = TRUE

	var/label = ""

	var/next_instruction = 0

/obj/item/device/tagger/atom_init()
	. = ..()

	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_round_start))

/obj/item/device/tagger/Destroy()
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)
	return ..()

/obj/item/device/tagger/proc/on_round_start(datum/source)
	SIGNAL_HANDLER
	lot_account_number = global.cargo_account.account_number
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/obj/item/device/tagger/shop/on_round_start(datum/source)
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

/obj/item/device/tagger/shop
	name = "shop tagger"
	desc = "Используется для наклейки ценников и бирок."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	modes = list(1 = "Ценник", 2 = "Бирка")

/obj/item/device/tagger/proc/openwindow(mob/user)
	var/dat = "<tt>"

	dat += "<table style='width:100%; padding:4px;'><tr>"

	dat += "<center><HR>Режим: <A href='?src=\ref[src];change_mode=1'>[modes[mode]]</A></center><BR>\n"

	switch(modes[mode])
		if("Метка")
			for(var/i = 1, i <= tagger_locations.len, i++)
				dat += "<td><a href='?src=\ref[src];nextTag=[tagger_locations[i]]'>[tagger_locations[i]]</a></td>"

				if (i%4==0)
					dat += "</tr><tr>"

			dat += "</tr></table><br>Выбрано: [currTag ? currTag : "None"]</tt>"
		if("Ценник")
			if(autodescription)
				dat += "Описание: [lot_description]"
			else
				dat += "Описание: <A href='?src=\ref[src];description=1'>[lot_description]</A>"
			dat += " <A href='?src=\ref[src];autodesc=1'>авто</A><BR>\n"
			dat += "Номер аккаунта: <A href='?src=\ref[src];number=1'>[lot_account_number ? lot_account_number : 111111]</A> <A href='?src=\ref[src];takeid=1'>id</A><BR>\n"
			dat += "Цена: <A href='?src=\ref[src];price=1'>[lot_price]$</A> Наценка: +[global.online_shop_delivery_cost * 100]% ([lot_price * global.online_shop_delivery_cost]$)<BR>\n"
			if(autocategory)
				dat += "Категория: [lot_category]"
			else
				dat += "Категория: <A href='?src=\ref[src];category=1'>[lot_category]</A>"
			dat += " <A href='?src=\ref[src];autocateg=1'>авто</A><BR><BR>\n"
		if("Бирка")
			dat += "Текст бирки: <A href='?src=\ref[src];label_text=1'>[label ? label : "Написать"]</A><BR>\n"

	var/datum/browser/popup = new(user, "destTagScreen", "Маркировщик 2.3", 450, 400)
	popup.set_content(dat)
	popup.open()

/obj/item/device/tagger/Topic(href, href_list)
	add_fingerprint(usr)
	if(href_list["nextTag"] && (href_list["nextTag"] in tagger_locations))
		src.currTag = href_list["nextTag"]
	else if(href_list["description"])
		var/T = sanitize(input("Введите описание:", "Маркировщик", input_default(lot_description), null)  as text)
		if(T)
			lot_description = T
	else if(href_list["autodesc"])
		autodescription = !autodescription
	else if(href_list["number"])
		var/T = input("Введите номер аккаунта:", "Маркировщик", input_default(lot_account_number), null)  as num
		if(T && isnum(T) && T >= 111111 && T <= 999999)
			lot_account_number = T
	else if(href_list["takeid"])
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			var/obj/item/weapon/card/id/ID = H.get_idcard()
			if(ID)
				lot_account_number = ID.associated_account_number
	else if(href_list["price"])
		var/T = input("Введите цену:", "Маркировщик", input_default(lot_price), null)  as num
		if(T && isnum(T) && T >= 0)
			lot_price = min(T, 5000)
	else if(href_list["category"])
		var/T = input("Выберите каталог", "Маркировщик", lot_category) in global.shop_categories
		if(T && (T in global.shop_categories))
			lot_category = T
	else if(href_list["autocateg"])
		autocategory = !autocategory
	else if(href_list["label_text"])
		var/T = sanitize(input("Введите текст бирки:", "Маркировщик", label, null)  as text)
		if(T)
			label = T
	else if(href_list["change_mode"])
		mode++
		if(mode > modes.len)
			mode = 1
		currTag = 0
	updateUsrDialog()
	openwindow(usr)


/obj/item/device/tagger/attack_self(mob/user)
	openwindow(user)
	return

/obj/item/device/tagger/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && isturf(src.loc))
		var/obj/item/weapon/wrench/Tool = W
		if(Tool.use_tool(src, user, SKILL_TASK_VERY_EASY, volume = 50))
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			user.SetNextMove(CLICK_CD_INTERACT)
			var/obj/structure/table/Table = locate(/obj/structure/table, get_turf(src))
			if(!anchored)
				if(!Table)
					to_chat(user, "<span class='warning'>Маркировщик можно прикрутить только к столу.</span>")
					return
				to_chat(user, "<span class='warning'>Маркировщик прикручен.</span>")
				anchored = TRUE
				RegisterSignal(Table, list(COMSIG_PARENT_QDELETING), PROC_REF(unwrench))
				return
			to_chat(user, "<span class='notice'>Маркировщик откручен.</span>")
			anchored = FALSE
			UnregisterSignal(Table, list(COMSIG_PARENT_QDELETING))
	else if(istagger(W))
		return ..()
	else if(can_apply_action(W, user))
		get_action(W, user)

/obj/item/device/tagger/proc/unwrench()
	anchored = FALSE

/obj/item/device/tagger/afterattack(obj/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(can_apply_action(target, user))
		get_action(target, user)

/obj/item/device/tagger/proc/can_apply_action(obj/target, mob/user)
	if(!istype(target))	//this really shouldn't be necessary (but it is).	-Pete
		return FALSE
	if(target.anchored)
		return FALSE
	if(user in target)
		return FALSE
	if(target == loc)
		return FALSE
	if(target.flags & ABSTRACT)
		return FALSE

	return TRUE

/obj/item/device/tagger/proc/get_action(obj/target, mob/user)
	switch(modes[mode])
		if("Метка")
			return
		if("Ценник")
			price(target, user)
			playsound(src, 'sound/items/label_printing.ogg', VOL_EFFECTS_MASTER, 100, FALSE)
		if("Бирка")
			label(target, user)
			playsound(src, 'sound/items/label_printing.ogg', VOL_EFFECTS_MASTER, 100, FALSE)

/obj/item/device/tagger/proc/price(obj/target, mob/user)
	if(target.price_tag)
		to_chat(user, "<span class='notice'>[target] already has a price tag.</span>")
		return
	if(!((isitem(target) && !istype(target, /obj/item/smallDelivery)) || (istype(target, /obj/structure) && !istype(target, /obj/structure/bigDelivery))))
		to_chat(user, "<span class='notice'>Нельзя повесить ценник на [target].</span>")
		return

	if((src in user) && (user.get_inactive_hand() == target || user.get_active_hand() == target))
		var/new_price = input("Введите цену:", "Маркировщик", input_default(lot_price), null)  as num
		if(user.get_active_hand() != src && user.get_active_hand() != target && user.get_inactive_hand() != src && user.get_inactive_hand() != target)
			return
		if(user.incapacitated())
			return

		if(new_price && isnum(new_price) && new_price >= 0)
			lot_price = min(new_price, 5000)

	user.visible_message("<span class='notice'>[user] adds a price tag to [target].</span>", \
						 "<span class='notice'>You added a price tag to [target].</span>")

	if(autodescription)
		lot_description = target.desc

	if(autocategory)
		lot_category = get_category(target)

	if(!lot_account_number)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/obj/item/weapon/card/id/ID = H.get_idcard()
			if(ID)
				lot_account_number = ID.associated_account_number

	target.price_tag = list("description" = lot_description, "price" = lot_price, "category" = lot_category, "account" = lot_account_number)
	target.verbs += /obj/proc/remove_price_tag

	target.underlays += icon(icon = 'icons/obj/device.dmi', icon_state = "tag")

	if(next_instruction < world.time)
		next_instruction = world.time + 30 SECONDS
		to_chat(user, "<span class='notice'>Осталось отправить этот предмет по пневмопочте(смыть в мусорку) или выставить на прилавок - и денюжки будут у тебя в кармане!</span>")

	if(user.client && LAZYACCESS(user.client.browsers, "destTagScreen"))
		openwindow(user)

/obj/item/device/tagger/proc/label(obj/target, mob/user)
	if(!label || !length(label))
		to_chat(user, "<span class='notice'>Нет текста на бирке.</span>")
		return
	if(length(target.name) + length(label) > 64)
		to_chat(user, "<span class='notice'>Текст бирки слишком большой.</span>")
		return
	if(ishuman(target))
		to_chat(user, "<span class='notice'>Вы не можете повесить бирку на человека.</span>")
		return
	if(issilicon(target))
		to_chat(user, "<span class='notice'>Вы не можете повесить бирку на киборга.</span>")
		return
	if(istype(target, /obj/item/weapon/reagent_containers/glass))
		to_chat(user, "<span class='notice'>The label can't stick to the [target.name].  (Try using a pen)</span>")
		return

	user.visible_message("<span class='notice'>[user] labels [target] as [label].</span>", \
						 "<span class='notice'>You label [target] as [label].</span>")
	target.name = "[target.name] ([label])"

/obj/item/device/tagger/proc/get_category(obj/target)
	if(istype(target, /obj/item/weapon/reagent_containers/food))
		return "Еда"
	else if(istype(target, /obj/item/weapon/storage/food))
		return "Еда"
	else if(istype(target, /obj/item/weapon/storage))
		return "Наборы"
	else if(istype(target, /obj/item/weapon))
		return "Инструменты"
	else if(istype(target, /obj/item/clothing))
		return "Одежда"
	else if(istype(target, /obj/item/device))
		return "Устройства"
	else if(istype(target, /obj/item/stack))
		return "Ресурсы"
	else
		return "Разное"


/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = TRUE
	icon_state = "intake"

	var/c_mode = 0

/obj/machinery/disposal/deliveryChute/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/disposal/deliveryChute/atom_init_late()
	trunk = locate() in loc
	if(trunk)
		trunk.linked = src	// link the pipe trunk to self

/obj/machinery/disposal/deliveryChute/Destroy()
	if(trunk)
		trunk.linked = null
	return ..()

/obj/machinery/disposal/deliveryChute/interact()
	return

/obj/machinery/disposal/deliveryChute/update()
	return

/obj/machinery/disposal/deliveryChute/Bumped(atom/movable/AM) //Go straight into the chute
	if(istype(AM, /obj/item/projectile) || istype(AM, /obj/effect))
		return
	switch(dir)
		if(NORTH)
			if(AM.loc.y != src.loc.y+1)
				return
		if(EAST)
			if(AM.loc.x != src.loc.x+1)
				return
		if(SOUTH)
			if(AM.loc.y != src.loc.y-1)
				return
		if(WEST)
			if(AM.loc.x != src.loc.x-1)
				return

	if(istype(AM, /obj) || istype(AM, /mob)) // istype(AM) ?
		AM.forceMove(src)
		flush()

/obj/machinery/disposal/deliveryChute/flush()
	flushing = 1
	flick("intake-closing", src)

	sleep(10)
	playsound(src, 'sound/machines/disposalflush.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	sleep(5) // wait for animation to finish

	var/obj/structure/disposalholder/H = new(null, contents, new /datum/gas_mixture)

	if(!trunk)
		expel(H)
		return

	H.start(trunk) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
	update()
	return

/obj/machinery/disposal/deliveryChute/attackby(obj/item/I, mob/user)
	if(!I || !user)
		return

	if(isscrewing(I))
		if(c_mode==0)
			c_mode=1
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "You remove the screws around the power connection.")
			return
		else if(c_mode==1)
			c_mode=0
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "You attach the screws around the power connection.")
			return
	else if(iswelding(I) && c_mode==1 && !user.is_busy())
		var/obj/item/weapon/weldingtool/W = I
		if(W.use(0,user))
			to_chat(user, "You start slicing the floorweld off the delivery chute.")
			if(W.use_tool(src, user, 20, volume = 100, required_skills_override = list(/datum/skill/atmospherics = SKILL_LEVEL_TRAINED)))
				to_chat(user, "You sliced the floorweld off the delivery chute.")
				var/obj/structure/disposalconstruct/C = new (src.loc)
				C.ptype = 8 // 8 =  Delivery chute
				C.update()
				C.anchored = TRUE
				C.density = TRUE
				qdel(src)
			return
		else
			to_chat(user, "You need more welding fuel to complete this task.")
			return

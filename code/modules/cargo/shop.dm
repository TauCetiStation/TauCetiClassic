var/global/list/online_shop_lots = list()
var/global/list/shop_categories = list("Еда", "Одежда", "Устройства", "Инструменты", "Ресурсы", "Наборы", "Разное")
var/global/list/packers = list()

/datum/shop_lot
	var/name = "Лот"
	var/description = "Описание лота"
	var/price = 0
	var/number = 1
	var/category = "Разное"
	var/sold = FALSE
	var/delivered = FALSE
	var/account = 111111


/datum/shop_lot/New(name, description, price, category, number, account)
	global.online_shop_lots[number] = src
	src.name = name
	src.description = description
	src.price = price
	src.category = category
	src.number = number
	src.account = account

/datum/shop_lot/Destroy()
	global.online_shop_lots -= src
	return ..()

/obj/lot_lock
	icon = 'icons/obj/storage.dmi'
	icon_state = "package_lock"
	var/datum/shop_lot/lot
	w_class = SIZE_MINUSCULE

/obj/lot_lock/New(datum/shop_lot/Lot)
	src.lot = Lot
	return ..()

/obj/verb/remove_lot_lock()
	for(var/obj/lot_lock/P in contents)
		if(!P.lot.delivered)
			return
		contents -= P
		cut_overlay(P)
		P.lot = null
		qdel(P)
		verbs -= /obj/verb/remove_lot_lock

/obj/machinery/packer
	name = "Shop Packer"
	desc = "Для упаковки предметов для онлайн-магазина."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "packer_base"
	req_access = list(access_cargo)
	density = TRUE
	anchored = TRUE
	emagged = FALSE

	active_power_usage = 50
	use_power = ACTIVE_POWER_USE

	var/obj/Item = null
	var/image/Item_Overlay
	var/image/Screen_Overlay
	var/image/Hand_Overlay

	var/lot_name
	var/lot_desc
	var/lot_price
	var/lot_category = "Разное"
	var/lot_account

	var/scanning = FALSE

	var/locked = FALSE

/obj/machinery/packer/atom_init()
	. = ..()
	Item_Overlay = image('icons/effects/32x32.dmi', "blank", src)
	Item_Overlay.appearance_flags = PIXEL_SCALE
	Item_Overlay.transform = matrix().Scale(0.75)
	Item_Overlay.pixel_y = 4
	Screen_Overlay = image('icons/obj/stationobjs.dmi', "packer_display", src)
	Hand_Overlay = image('icons/obj/stationobjs.dmi', "packer_hand", src)

	global.packers += src

	update_icon()

/obj/machinery/packer/Destroy()
	global.packers -= src
	eject_item()
	return ..()

/obj/machinery/packer/power_change()
	..()
	if(stat & (NOPOWER|BROKEN) && Item)
		eject_item()

/obj/machinery/packer/emag_act(mob/user)
	if(anchored)
		return
	emagged = !emagged
	user.visible_message("<span class='warning'>[user.name] slides something into the [src.name]'s card-reader.</span>","<span class='warning'>You short out the [src.name].</span>")
	return TRUE

/obj/machinery/packer/update_icon()
	cut_overlays()
	if(Item)
		Screen_Overlay.icon_state = "packer_display_ready"
		Item_Overlay.icon = Item.icon
		Item_Overlay.icon_state = Item.icon_state
	else
		Screen_Overlay.icon_state = "packer_display"
		Item_Overlay.icon = 'icons/effects/32x32.dmi'
		Item_Overlay.icon_state = "blank"

	if(scanning)
		icon_state = "packer_base_processing"
		Screen_Overlay.icon_state = "packer_display_processing"
		Hand_Overlay.icon_state = "packer_hand_processing"
	else
		icon_state = "packer_base"
		Screen_Overlay.icon_state = "packer_display"
		Hand_Overlay.icon_state = "packer_hand"

	add_overlay(Item_Overlay)
	add_overlay(Screen_Overlay)
	add_overlay(Hand_Overlay)

/obj/machinery/packer/attackby(obj/item/O, mob/user)
	if(Item)
		return
	if(iswrench(O))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return
	if(!anchored)
		return ..()
	user.drop_from_inventory(O, src)
	Item = O

	if(locate(/obj/price_tag) in O.contents)
		locked = TRUE
		for(var/obj/price_tag/Tag in O.contents)
			lot_desc = Tag.desc
			lot_price = Tag.price
			lot_account = Tag.account_number
	else
		lot_desc = Item.desc ? Item.desc : "Это что-то"
		lot_price = 0
		lot_account = global.cargo_account.account_number
	lot_name = Item.name ? Item.name : "Штука"


	lot_category = default_categories(O)

	update_icon()
	updateUsrDialog()

/obj/machinery/packer/proc/default_categories(obj/item/I)
	if(istype(I, /obj/item/weapon/reagent_containers/food))
		return "Еда"
	if(istype(I, /obj/item/weapon/storage/food))
		return "Еда"
	else if(istype(I, /obj/item/weapon/storage))
		return "Наборы"
	else if(istype(I, /obj/item/weapon))
		return "Инструменты"
	else if(istype(I, /obj/item/clothing))
		return "Одежда"
	else if(istype(I, /obj/item/device))
		return "Устройства"
	else if(istype(I, /obj/item/stack))
		return "Ресурсы"
	else
		return "Разное"

/obj/machinery/packer/MouseDrop_T(obj/structure/closet/C, mob/living/user)
	if(Item)
		return
	if(!Adjacent(usr))
		return
	if(isAI(user))
		return
	if(!anchored)
		return

	C.forceMove(src)
	Item = C

	lot_name = Item.name ? Item.name : "Штука"
	lot_desc = Item.desc ? Item.desc : "Это что-то"
	lot_price = 0
	lot_category = "Наборы"
	lot_account = global.cargo_account.account_number

	update_icon()
	updateUsrDialog()

/obj/machinery/packer/proc/scan_item()
	scanning = TRUE
	update_icon()
	addtimer(CALLBACK(src, .proc/stop_scanning), 30)

/obj/machinery/packer/proc/stop_scanning()
	scanning = FALSE
	global.online_shop_lots.len++

	if (isitem(Item))
		var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(src)
		P.w_class = Item.w_class
		var/i = round(Item.w_class)
		if(i >= SIZE_MINUSCULE && i <= SIZE_NORMAL)
			P.icon_state = "deliverycrate[i]"
		Item.loc = P
		Item = P
	else if (istype(Item, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/C = Item
		if (!C.opened)
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(C.loc))
			P.icon_state = "deliverycrate"
			C.loc = P
			Item = P
	else if (istype (Item, /obj/structure/closet))
		var/obj/structure/closet/C = Item
		if (!C.opened)
			var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_turf(C.loc))
			C.welded = 1
			C.loc = P
			Item = P
	else if(istype (Item, /mob))
		var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(src)
		P.w_class = SIZE_NORMAL
		P.icon_state = "deliverycrate[SIZE_NORMAL]"
		Item.loc = P
		Item = P
		lot_desc = Item.desc
		lot_name = Item.name
		lot_price = 200
		lot_category = "Разное"

	Item.pixel_y = 6
	Item.name = "Посылка номер: [global.online_shop_lots.len]"
	Item.desc = "Наименование: [lot_name], Описание: [lot_desc], Цена: [lot_price]"

	var/datum/shop_lot/Lot = new /datum/shop_lot(lot_name, lot_desc, lot_price, lot_category, global.online_shop_lots.len, lot_account)

	var/obj/lot_lock/Lock = new /obj/lot_lock(Lot)
	Lock.loc = Item
	Item.add_overlay(Lock)
	Item.verbs += /obj/verb/remove_lot_lock

	eject_item()
	update_icon()
	updateUsrDialog()

/obj/machinery/packer/proc/eject_item()
	if(!Item)
		return
	Item.loc = get_turf(src.loc)
	Item = null

	lot_name = null
	lot_desc = null
	lot_price = null
	lot_category = null
	lot_account = null

	locked = FALSE

	update_icon()

/obj/machinery/packer/ui_interact(mob/user)
	if(!anchored)
		return
	var/dat = "<div class='Section__title'>Упаковщик</div>"

	if(Item)
		dat += "Наименование: <A href='?src=\ref[src];field=name'>[lot_name]</A><BR>\n"
		if(locked)
			dat += "Описание: [lot_desc]<BR>"
			dat += "Цена: [lot_price]<BR>"
		else
			dat += "Описание: <A href='?src=\ref[src];field=description'>[lot_desc]</A><BR>\n"
			dat += "Цена: <A href='?src=\ref[src];field=price'>[lot_price]$</A><BR>\n"
		dat += "Каталог: <A href='?src=\ref[src];field=category'>[lot_category]</A><BR>\n"

		dat += "<A href='?src=\ref[src];scan=1'>Сканировать</A>"
		dat += "<A href='?src=\ref[src];eject=1'>Вытащить</A>"
	else
		dat += "Вставьте предмет"

	var/datum/browser/popup = new(user, "packer", "Packer Console", 600, 400)	//Set up the popup browser window
	popup.set_content(dat)
	popup.open()

/obj/machinery/packer/Topic(href, href_list)
	. = ..()
	if(!. || usr == occupant)
		return FALSE
	if(!anchored)
		return FALSE

	if (href_list["field"])
		switch(href_list["field"])
			if("name")
				var/T = sanitize(input("Введите наименование:", "Shop", input_default(lot_name), null)  as text)
				if(T && istext(T))
					lot_name = T
			if("description")
				var/T = sanitize(input("Введите описание:", "Shop", input_default(lot_desc), null)  as text)
				if(T && istext(T))
					lot_desc = T
			if("price")
				var/T = input("Введите цену:", "Shop", input_default(lot_price), null)  as num
				if(T && isnum(T) && T >= 0)
					lot_price = T
			if("category")
				var/T = input("Выберите каталог", "Shop", lot_category) in global.shop_categories
				if(T && (T in global.shop_categories))
					lot_category = T
	else if(href_list["scan"])
		if(emagged)
			pack_human_being(usr)
		else
			scan_item()
	else if(href_list["eject"])
		eject_item()

	updateUsrDialog()

/obj/machinery/packer/proc/pack_human_being(mob/user)
	if(Item)
		eject_item()
	user.forceMove(src)
	Item = user
	scan_item()

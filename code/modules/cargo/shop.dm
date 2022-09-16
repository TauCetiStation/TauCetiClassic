var/global/list/online_shop_lots = list()
var/global/list/shop_categories = list("Food", "Clothes", "Devices", "Tools", "Resources", "Packs", "Misc")

/datum/shop_lot
	var/name = "Shop_Lot"
	var/description = "Lot_Description"
	var/price = 0
	var/number = 1
	var/category = "Misc"
	var/sold = FALSE


/datum/shop_lot/New(name, description, price, category, number)
	global.online_shop_lots[number] = src
	src.name = name
	src.description = description
	src.price = price
	src.category = category
	src.number = number

/datum/shop_lot/Destroy()
	global.online_shop_lots -= src
	return ..()

/obj/machinery/packer
	name = "Shop Packer"
	desc = "Used to scan and pack shop items."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "packer_base"
	req_access = list(access_cargo)
	density = TRUE
	anchored = TRUE
	var/obj/Item = null
	var/image/Item_Overlay
	var/image/Screen_Overlay
	var/image/Hand_Overlay

	var/lot_name
	var/lot_desc
	var/lot_price
	var/lot_category = "Misc"

	var/scanning = FALSE

/obj/machinery/packer/atom_init()
	. = ..()
	Item_Overlay = image('icons/effects/32x32.dmi', "blank", src)
	Item_Overlay.appearance_flags = PIXEL_SCALE
	Item_Overlay.transform = matrix().Scale(0.75)
	Item_Overlay.pixel_y = 4
	Screen_Overlay = image('icons/obj/stationobjs.dmi', "packer_display", src)
	Hand_Overlay = image('icons/obj/stationobjs.dmi', "packer_hand", src)

	tag = "Packer"

	update_icon()

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
	user.drop_from_inventory(O, src)
	Item = O

	lot_name = Item.name
	lot_desc = Item.desc
	lot_price = 0
	lot_category = "Misc"

	update_icon()
	updateUsrDialog()

/obj/machinery/packer/MouseDrop_T(obj/structure/closet/C, mob/living/user)
	if(Item)
		return
	if(!Adjacent(usr))
		return
	if(isAI(user))
		return

	C.forceMove(src)
	Item = C

	lot_name = Item.name
	lot_desc = Item.desc
	lot_price = 0
	lot_category = "Packs"

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

	Item.pixel_y = 6
	Item.name = "Package number: [global.online_shop_lots.len]"
	Item.desc = "Name: [lot_name], Description: [lot_desc], Price: [lot_price]"

	new /datum/shop_lot(lot_name, lot_desc, lot_price, lot_category, global.online_shop_lots.len)

	eject_item()
	update_icon()
	updateUsrDialog()

/obj/machinery/packer/proc/eject_item()
	Item.loc = get_turf(src.loc)
	Item = null

	lot_name = null
	lot_desc = null
	lot_price = null
	lot_category = null

	update_icon()

/obj/machinery/packer/ui_interact(mob/user)
	var/dat = "<div class='Section__title'>Shop Packer</div>"

	if(Item)
		dat += "Name: <A href='?src=\ref[src];field=name'>[lot_name]</A><BR>\n"
		dat += "Description: <A href='?src=\ref[src];field=description'>[lot_desc]</A><BR>\n"
		dat += "Price: <A href='?src=\ref[src];field=price'>[lot_price]$</A><BR>\n"
		dat += "Category: <A href='?src=\ref[src];field=category'>[lot_category]</A><BR>\n"

		dat += "<A href='?src=\ref[src];scan=1'>Scan</A>"
		dat += "<A href='?src=\ref[src];eject=1'>Eject</A>"
	else
		dat += "No Item inserted"

	var/datum/browser/popup = new(user, "packer", "Packer Console", 600, 400)	//Set up the popup browser window
	popup.set_content(dat)
	popup.open()

/obj/machinery/packer/Topic(href, href_list)
	. = ..()
	if(!. || usr == occupant)
		return FALSE

	if (href_list["field"])
		switch(href_list["field"])
			if("name")
				var/T = sanitize(input("Please input name:", "Shop", input_default(lot_name), null)  as text)
				if(T)
					lot_name = T
			if("description")
				var/T = sanitize(input("Please input description:", "Shop", input_default(lot_desc), null)  as text)
				if(T)
					lot_desc = T
			if("price")
				var/T = input("Please input price:", "Shop", input_default(lot_price), null)  as num
				if(T)
					lot_price = T
			if("category")
				var/T = input("Please select a lot category", "Shop", lot_category) in global.shop_categories
				if(T)
					lot_category = T
	else if(href_list["scan"])
		scan_item()
	else if(href_list["eject"])
		eject_item()

	updateUsrDialog()

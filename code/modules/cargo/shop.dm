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

	var/scanning = FALSE

/obj/machinery/packer/atom_init()
	. = ..()
	Item_Overlay = image('icons/effects/32x32.dmi', "blank", src)
	Item_Overlay.transform = matrix().Scale(0.625)
	Item_Overlay.pixel_y = 4
	Screen_Overlay = image('icons/obj/stationobjs.dmi', "packer_display", src)
	Hand_Overlay = image('icons/obj/stationobjs.dmi', "packer_hand", src)

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
	update_icon()
	updateUsrDialog()

/obj/machinery/packer/proc/scan_item()
	scanning = TRUE
	update_icon()
	addtimer(CALLBACK(src, .proc/stop_scanning), 25)

/obj/machinery/packer/proc/stop_scanning()
	scanning = FALSE
	var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(src)

	P.w_class = Item.w_class
	if(P.w_class <= SIZE_MINUSCULE)
		P.icon_state = "deliverycrate1"
	else if (P.w_class <= SIZE_TINY)
		P.icon_state = "deliverycrate2"
	else if (P.w_class <= SIZE_SMALL)
		P.icon_state = "deliverycrate3"
	else
		P.icon_state = "deliverycrate4"
	Item.loc = P
	Item = P
	var/i = round(Item.w_class)
	if(i in list(1,2,3,4,5))
		P.icon_state = "deliverycrate[i]"

	eject_item()
	update_icon()
	updateUsrDialog()

/obj/machinery/packer/proc/eject_item()
	Item.loc = get_turf(src.loc)
	Item = null
	update_icon()

/obj/machinery/packer/ui_interact(mob/user)
	var/dat = "<div class='Section__title'>Shop Packer</div>"

	if(Item)
		dat += "Name = [Item.name]<BR>"
		dat += "Description = [Item.desc]<BR>"
		dat += "Price = 0<BR>"

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

	if(href_list["scan"])
		scan_item()
	else if(href_list["eject"])
		eject_item()

	updateUsrDialog()

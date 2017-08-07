/obj/machinery/computer/intruder_station
	name = "Management Console of Intruding"
	desc = "A device used to manage and buy the way of invasion to station."
	icon_state = "tcboss"
	var/list/tools = list()
	var/show_tool_desc
	var/obj/item/stored_uplink

/obj/machinery/computer/intruder_station/New()
	..()
	for(var/Dat in subtypesof(/datum/intruder_tools))
		tools += new Dat

/obj/machinery/computer/intruder_station/attackby(obj/item/O, mob/user)
	if(stored_uplink)
		to_chat(user, "<span class='notice'>Eject stored Uplink first!</span>")
		return
	if(!O.hidden_uplink)
		to_chat(user, "<span class='notice'>[O] does not have uplink!</span>")
		return
	user.drop_from_inventory(O)
	O.loc = src
	stored_uplink = O
	to_chat(user, "<span class='notice'>You insert [O] in [src]!</span>")
	updateUsrDialog()

/obj/machinery/computer/intruder_station/attack_hand(mob/user)
	if(..())
		return
	src.add_fingerprint(user)
	user.set_machine(src)

	var/dat = ""
	var/available_telecrystalls = 0
	if(stored_uplink && stored_uplink.hidden_uplink)
		available_telecrystalls = stored_uplink.hidden_uplink.uses
		dat += "Station has [available_telecrystalls] points remaining.<BR>"
		dat += "<a href='byond://?src=\ref[src];eject=1'>Eject Uplink</a><BR>"
	else
		dat += "Uplink device not finded!<BR>"
	dat += "<BR><BR>"

	for(var/datum/intruder_tools/T in tools)
		dat += "[T.name] ([T.cost]):"
		var/buyable = (available_telecrystalls >= T.cost)
		dat += "<a href ='?src=\ref[src];buy=\ref[T]'>[buyable ? "Buy"  : "<font color='grey'>Buy</font>"]</a> | "
		dat += "<a href ='?src=\ref[src];desc=\ref[T]'>Show Desc</a><BR>"
		if(show_tool_desc == T)
			dat += "[T.desc]<BR>"
		dat += "<BR>"

	var/datum/browser/popup = new(user, "intruder_computer", "Management Console of Intruding", 700, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/intruder_station/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["eject"])
		stored_uplink.loc = get_turf(src)
		stored_uplink = null

	else if(href_list["buy"])
		var/datum/intruder_tools/T = locate(href_list["buy"])
		if(!stored_uplink || !stored_uplink.hidden_uplink || stored_uplink.hidden_uplink.uses < T.cost)
			return
		if(istype(T, /datum/intruder_tools/shuttle_unlocker)) // if we get more suchlike actions, just add to datums Inherited proc which will be called from here
			var/area/cur_area = get_area(src)
			if(!istype(cur_area, /area/syndicate_mothership))
				to_chat(usr, "<span class='userdanger'>If you see this, Please, Notify nearest coder or mapper about wrong place of this station!</span>")
				return

			var/passed = FALSE
			for(var/obj/machinery/door/poddoor/shutters/syndi/shutter in cur_area)
				if(shutter.tag == "Syndicate_shuttle")
					to_chat(usr, "<span class='notice'>The Shuttle has been unlocked!</span>")
					qdel(shutter)
					passed = TRUE
					break
			if(passed)
				playsound(src, 'sound/machines/twobeep.ogg', 50, 2)
			else
				to_chat(usr, "<span class='userdanger'>If you see this, Please, Notify nearest coder or mapper about this failure with shutter!</span>")
				updateUsrDialog()
				return
		stored_uplink.hidden_uplink.uses -= T.cost
		if(T.item)
			new T.item(get_turf(src))
		if(T.delete_dat_after_buying)
			tools -= T
			qdel(T)

	else if(href_list["desc"])
		var/datum/intruder_tools/T = locate(href_list["desc"])
		if(show_tool_desc == T)
			show_tool_desc = null
		else
			show_tool_desc = T

	updateUsrDialog()

/datum/intruder_tools
	var/name = "item name"
	var/desc = "item description"
	var/delete_dat_after_buying = FALSE
	var/item = null
	var/cost = 0

/datum/intruder_tools/shuttle_unlocker
	name = "Shuttle Unlocker"
	desc = "An unlocker of the Shuttle, which Parked near your base. In Bonus aboard, will be some aids and instruments. Caution. You'll have to buy spacesuit's in addition."
	delete_dat_after_buying = TRUE
	cost = 30

/datum/intruder_tools/gateway_locker
	name = "Gateway Locker"
	desc = "Device, capable to hack station Gateway.\
	After Hack, you can switch entering through gateway."
	item = /obj/item/device/gateway_locker
	delete_dat_after_buying = TRUE
	cost = 10

/datum/intruder_tools/Drop_system
	name = "Exosuit Drop System"
	desc = "A module for exosuit, that allow you launching at Long distances"
	item = /obj/item/mecha_parts/mecha_equipment/Drop_system
	cost = 15

/datum/intruder_tools/droppod
	name = "Drop Pod"
	desc = "A two-seater pod, that can fall into station, aim system can be upgraded with camera bug and simple Drop System."
	item = /obj/item/device/drop_caller/Syndi
	cost = 15

/datum/intruder_tools/drop_aim
	name = "Simple Drop System"
	desc = "A simple drop system, which can be installed in pods to increase accuracy of droping"
	item =  /obj/item/weapon/simple_drop_system
	cost = 10

/datum/intruder_tools/camera_bug
	name = "Camera Bug"
	desc = "Can be attached to Drop Pod to reach exemplary accuracy and allow to return to the base."
	item = /obj/item/device/camera_bug
	cost = 2
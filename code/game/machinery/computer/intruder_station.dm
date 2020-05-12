/obj/machinery/computer/intruder_station
	name = "Management Console of Intruding"
	desc = "A device used to manage and buy the way of invasion to station."
	icon_state = "tcboss"
	var/list/tools = list()
	var/show_tool_desc
	var/obj/item/stored_uplink

/obj/machinery/computer/intruder_station/atom_init()
	. = ..()
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

/obj/machinery/computer/intruder_station/ui_interact(mob/user)
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
		var/buyable = (stored_uplink && stored_uplink.hidden_uplink && available_telecrystalls >= T.cost)
		dat += "<a href ='?src=\ref[src];buy=\ref[T]'>[buyable ? "Buy"  : "<font color='grey'>Buy</font>"]</a> | "
		dat += "<a href ='?src=\ref[src];desc=\ref[T]'>Show Desc</a><BR>"
		if(show_tool_desc == T)
			dat += "[T.desc]<BR>"
		dat += "<BR>"

	var/datum/browser/popup = new(user, "intruder_computer", "Management Console of Intruding", 700, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

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
		T.buy(src, usr)

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

/datum/intruder_tools/proc/buy(obj/machinery/computer/intruder_station/console, mob/living/user)
	console.stored_uplink.hidden_uplink.uses -= cost
	if(item)
		new item(get_turf(console))
	if(delete_dat_after_buying)
		console.tools -= src
		qdel(src)


/datum/intruder_tools/war_device
	name = "War Device"
	desc = "Device to send a declaration of hostilities to the target, delaying your shuttle departure for 20 minutes while they prepare for your assault.  \
			Such a brazen move will attract the attention of powerful benefactors within the Syndicate, who will supply your team with a massive amount of bonus telecrystals.  \
			Must be used within five minutes, or your benefactors will lose interest."
	delete_dat_after_buying = TRUE
	item = /obj/item/device/nuclear_challenge

/datum/intruder_tools/shuttle_unlocker
	name = "Shuttle Unlocker"
	desc = "An unlocker of the Shuttle, which Parked near your base. In Bonus aboard, will be tactical aid and instruments. Caution. You'll have to buy spacesuit's in addition."
	delete_dat_after_buying = TRUE
	cost = 30

/datum/intruder_tools/shuttle_unlocker/buy(obj/machinery/computer/intruder_station/console, mob/living/user)
	var/area/cur_area = get_area(console)
	if(!istype(cur_area, /area/custom/syndicate_mothership))
		to_chat(user, "<span class='userdanger'>If you see this, Please, Notify nearest coder or mapper about wrong place of this station!</span>")
		return

	for(var/obj/machinery/door/poddoor/shutters/syndi/shutter in cur_area)
		if(shutter.dock_tag == "Syndicate_shuttle")
			to_chat(user, "<span class='notice'>The Shuttle has been unlocked!</span>")
			qdel(shutter)
			playsound(console, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
			for(var/datum/intruder_tools/gateway_locker/D in console.tools)
				console.tools -= D
				qdel(D)
			return ..()

	to_chat(user, "<span class='userdanger'>If you see this, Please, Notify nearest coder or mapper about this failure with shutter!</span>")

/datum/intruder_tools/gateway_locker
	name = "Gateway Locker"
	desc = "Device, capable to hack station Gateway.\
	After Hack, you can switch entering through gateway."
	item = /obj/item/device/gateway_locker
	delete_dat_after_buying = TRUE
	cost = 15

/datum/intruder_tools/gateway_locker/buy(obj/machinery/computer/intruder_station/console, mob/living/user)
	..()
	for(var/datum/intruder_tools/shuttle_unlocker/D in console.tools)
		console.tools -= D
		qdel(D)

/datum/intruder_tools/Drop_system
	name = "Exosuit Drop System"
	desc = "A module for exosuit, that allow you launching at Long distances"
	item = /obj/item/mecha_parts/mecha_equipment/Drop_system
	cost = 15

/datum/intruder_tools/droppod
	name = "Drop Pod"
	desc = "A two-seater pod, that can fall into station, aim system can be upgraded with camera bug and simple Drop System."
	item = /obj/item/device/drop_caller/Syndi
	cost = 14

/datum/intruder_tools/drop_aim
	name = "Simple Drop System"
	desc = "A simple drop system, which can be installed in pods to increase accuracy of droping"
	item =  /obj/item/weapon/simple_drop_system
	cost = 8

/datum/intruder_tools/camera_bug
	name = "Camera Bug"
	desc = "Can be attached to Drop Pod to reach exemplary accuracy and allow to return to the base."
	item = /obj/item/device/camera_bug
	cost = 2

/datum/intruder_tools/rig
	name = "Syndi Rig"
	desc = "The red syndicate space rig with additional armor plating.\
	 Nanotrasen crewmembers are trained to report red space suit sightings."
	item = /obj/item/weapon/storage/box/syndie_kit/rig
	cost = 8

/datum/intruder_tools/heavy_rig
	name = "Heavy Syndi Rig"
	desc = "Combat rig fitted with heavy armor plates made to endure even the greatest damage, developed off existing 'Striker' space suit."
	item = /obj/item/weapon/storage/box/syndie_kit/heavy_rig
	cost = 12

/datum/intruder_tools/armor
	name = "Syndi Assault Armor"
	desc = "The red syndicate heavy armor with additional armor plating and helmet to it."
	item = /obj/item/weapon/storage/box/syndie_kit/armor
	cost = 4

//Common
/obj/machinery/abductor
	var/team = 0

// Machinery
/obj/machinery/abductor/atom_init()
	. = ..()
	abductor_machinery_list += src

/obj/machinery/abductor/Destroy()
	abductor_machinery_list -= src
	return ..()

//*************-Console-*************//

/obj/machinery/abductor/console
	name = "abductor console"
	desc = "Ship command center."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	var/obj/item/device/abductor/gizmo/gizmo
	var/obj/item/clothing/suit/armor/abductor/vest/vest
	var/obj/machinery/abductor/experiment/experiment
	var/obj/machinery/abductor/pad/pad
	var/obj/machinery/computer/camera_advanced/abductor/camera
	var/list/datum/icon_snapshot/disguises = list()
	var/show_price_list = FALSE
	var/list/price_list = list(
							"heal injector" 					=2,
							"decloner"							=2,
							"advanced baton"					=2,
							"additional permissions"			=2,
							"advanced console"					="Free",
							"radio silencer"					=1,
							"science tool" 						=1,
							"agent helmet" 						=1,
							"additional agent equipment" 		=1,
							"additional scientist equipment" 	=1,
							"transforming gland" 				=1,
							"silence gloves"					=3,
							"recall implant" 					=4)

	var/baton_modules_bought = FALSE

/obj/machinery/abductor/console/Destroy()
	if(gizmo)
		gizmo.console = null
		gizmo = null
	if(experiment)
		experiment.console = null
		experiment = null
	if(pad)
		pad.console = null
		pad = null
	if(camera)
		camera.console = null
		camera = null
	return ..()

/obj/machinery/abductor/console/interact(mob/user)
	if(issilicon(user)) //Borgs probably shouldn't be able to interact with it
		return
	if(!isabductor(user) && !isobserver(user))
		if(user.is_busy())
			return
		to_chat(user, "<span class='warning'>You start mashing alien buttons at random!</span>")
		if(do_after(user, 100, target = src))
			TeleporterSend()
	else
		..()

/obj/machinery/abductor/console/ui_interact(mob/user)
	var/dat = ""
	dat += "<H2> Abductsoft 3000 </H2>"

	if(experiment != null)
		var/points = experiment.points
		dat += "<font color = #7E8D9F><b>Collected Samples : </b></font>[points]<br>"
		dat += "<H4> Transfer data in exchange for supplies</H4>"
		dat += "<a href='?src=\ref[src];dispense=injector'>Heal Injector</A><br>"
		dat += "<a href='?src=\ref[src];dispense=pistol'>Decloner</A><br>"
		dat += "<a href='?src=\ref[src];dispense=baton'>Advanced Baton</A><br>"

		if(!baton_modules_bought)
			dat += "<a href='?src=\ref[src];dispense=permissions'>Additional Permissions for Advanced Baton</A><br>"
		else
			dat += "<span class='disabled'>Additional Permissions for Advanced Baton</span><br>"

		dat += "<a href='?src=\ref[src];dispense=helmet'>Agent Helmet</A><br>"

		if(!camera)
			dat += "<a href='?src=\ref[src];dispense=adv_console'>Advanced Console</A><br>"
		else
			dat += "<span class='disabled'>Advanced Console</span><br>"

		dat += "<a href='?src=\ref[src];dispense=silencer'>Radio Silencer</A><br>"
		dat += "<a href='?src=\ref[src];dispense=tool'>Science Tool</A><br>"
		dat += "<a href='?src=\ref[src];dispense=agent_gear'>Additional agent equipment</A><br>"
		dat += "<a href='?src=\ref[src];dispense=scientist_gear'>Additional scientist equipment</A><br>"
		dat += "<a href='?src=\ref[src];dispense=trans_gland'>Transforming gland</A><br>"
		dat += "<a href='?src=\ref[src];dispense=silence_gloves'>Silence gloves</A><br>"
		dat += "<a href='?src=\ref[src];dispense=recall_implant'>Recall implant</A><br>"
		dat += "<a href='?src=\ref[src];show_prices=1'>[show_price_list ? "Close Price List" : "Open Price List"]</a><br>"
		if(show_price_list)
			dat += "<div class='Section'>[get_price_list()]</div>"
	else
		dat += "<span class='bad'>NO EXPERIMENT MACHINE DETECTED</span> <br>"

	if(pad)
		dat += "<H4> Teleport control</H4>"
		dat += "<a href='?src=\ref[src];teleporter_send=1'>Activate Teleporter</A><br>"
		dat += "<a href='?src=\ref[src];teleporter_set=1'>Set Teleporter</A><br>"
		dat += "<font color = #7E8D9F><b>Set to: </b></font>[pad.teleport_target ? "[copytext("[pad.target_name]",3)]" : "Nothing"]<br>"
		if(gizmo && gizmo.marked)
			dat += "<a href='?src=\ref[src];teleporter_retrieve=1'>Retrieve Mark</A><br>"
		else
			dat += "<span class='disabled'>Retrieve Mark</span><br>"
	else
		dat += "<span class='bad'>NO TELEPAD DETECTED</span></br>"

	var/datum/browser/popup = new(user, "computer", "Abductor Console", 400, 500, ntheme = CSS_THEME_ABDUCTOR)
	popup.set_content(dat)
	popup.open()

/obj/machinery/abductor/console/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list["teleporter_set"])
		TeleporterSet()
	else if(href_list["teleporter_send"])
		TeleporterSend()
	else if(href_list["teleporter_retrieve"])
		if(do_after(usr, 7 SECONDS, FALSE, src))
			TeleporterRetrieve()
	else if(href_list["select_disguise"])
		SelectDisguise()
	else if(href_list["dispense"])
		switch(href_list["dispense"])
			if("injector")
				Dispense(/obj/item/weapon/lazarus_injector/alien, 2)
			if("pistol")
				Dispense(/obj/item/weapon/gun/energy/decloner/alien, 2)
			if("permissions")
				visible_message("Addtitional permisions has been aquired! You can use all advanced baton's modes now!")
				baton_modules_bought = TRUE
			if("adv_console")
				visible_message("Agent Observation Console has been replaced with advanced one.")
				for(var/obj/machinery/computer/security/abductor_ag/C in range(2, src))
					camera = new(get_turf(C))
					camera.console = src
					qdel(C)
			if("baton")
				Dispense(/obj/item/weapon/abductor_baton, 2)
			if("helmet")
				Dispense(/obj/item/clothing/head/helmet/abductor)
			if("silencer")
				Dispense(/obj/item/device/abductor/silencer)
			if("tool")
				Dispense(/obj/item/device/abductor/gizmo)
			if("agent_gear")
				if(Dispense(/obj/item/clothing/gloves/combat))
					var/obj/item/weapon/card/id/syndicate/C = new(pad.loc)
					C.name = "Card"
					C.access = list()
					new /obj/item/clothing/shoes/boots/combat(pad.loc)
			if("scientist_gear")
				if(Dispense(/obj/item/clothing/glasses/hud/health/night))
					new /obj/item/weapon/storage/visuals/surgery(pad.loc)
			if("trans_gland")
				Dispense(/obj/item/gland/abductor)
			if("recall_implant")
				var/obj/item/weapon/implanter/abductor/G = Dispense(/obj/item/weapon/implanter/abductor, 3)
				if(G)
					var/obj/item/weapon/implant/abductor/I = G.imp
					I.home = pad
			if("silence_gloves")
				Dispense(/obj/item/clothing/gloves/black/silence, 3)
	else if(href_list["show_prices"])
		show_price_list = !show_price_list
	updateUsrDialog()

/obj/machinery/abductor/console/proc/get_price_list()
	var/dat = "<table border='0' width='300'>"
	for(var/item in price_list)
		var/price = price_list[item]
		dat += "<tr><td>[capitalize(item)]</td><td>[price]</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/abductor/console/proc/TeleporterSet()
	var/A = null
	A = input("Select area to teleport to", "Teleport", A) in teleportlocs
	if(pad)
		pad.teleport_target = teleportlocs[A]
		pad.target_name = pad.teleport_target.name

/obj/machinery/abductor/console/proc/SetDroppoint(turf/location,user)
	if(!istype(location))
		to_chat(user, "<span class='warning'>That place is not safe for the specimen.</span>")
		return

	if(pad)
		pad.precise_teleport_target = location
		to_chat(user, "<span class='notice'>Location marked as test subject release point.</span>")

/obj/machinery/abductor/console/proc/TeleporterRetrieve()
	if(gizmo && pad && gizmo.marked)
		pad.Retrieve(gizmo.marked)

/obj/machinery/abductor/console/proc/TeleporterSend()
	if(pad)
		pad.Send()

/obj/machinery/abductor/console/proc/SelectDisguise()
	var/list/entries = list()
	var/tempname
	var/datum/icon_snapshot/temp
	for(var/i = 1; i <= disguises.len; i++)
		temp = disguises[i]
		tempname = temp.name
		entries["[tempname]"] = disguises[i]
	var/entry_name = input( "Choose Disguise", "Disguise") in entries
	var/datum/icon_snapshot/chosen = entries[entry_name]
	if(chosen)
		vest.SetDisguise(chosen)

/obj/machinery/abductor/console/proc/Initialize()
	for(var/obj/machinery/abductor/pad/p in range(2, src))
		pad = p
		break

	for(var/obj/machinery/abductor/experiment/e in range(2, src))
		experiment = e
		e.console = src

	for(var/obj/machinery/computer/camera_advanced/abductor/c in range(2, src))
		camera = c
		c.console = src

/obj/machinery/abductor/console/proc/AddSnapshot(mob/living/carbon/human/target)
	var/datum/icon_snapshot/entry = new
	entry.name = target.name
	entry.icon = target.icon
	entry.icon_state = target.icon_state
	entry.overlays = target.overlays.Copy()
	entry.overlays_standing = target.get_overlays_copy()
	for(var/i=1,i<=disguises.len,i++)
		var/datum/icon_snapshot/temp = disguises[i]
		if(temp.name == entry.name)
			disguises[i] = entry
			return
	disguises.Add(entry)
	return

/obj/machinery/abductor/console/attackby(O, user, params)
	if(istype(O, /obj/item/device/abductor/gizmo))
		var/obj/item/device/abductor/gizmo/G = O
		to_chat(user, "<span class='notice'>You link the tool to the console.</span>")
		gizmo = G
		G.console = src
		return FALSE
	else if(istype(O, /obj/item/clothing/suit/armor/abductor/vest))
		var/obj/item/clothing/suit/armor/abductor/vest/V = O
		to_chat(user, "<span class='notice'>You link the vest to the console.</span>")
		vest = V
		return FALSE
	else if(istype(O, /obj/item/weapon/abductor_baton))
		var/obj/item/weapon/abductor_baton/B = O
		to_chat(user, "<span class='notice'>You link the advanced baton to the console.</span>")
		B.console = src
		return FALSE
	else if(istype(O, /obj/item/gland/abductor))
		experiment.points++
		visible_message("Refunded!")
		qdel(O)
		return FALSE
	return ..()

/obj/machinery/abductor/console/proc/Dispense(item,cost=1)
	if(experiment && experiment.points >= cost)
		experiment.points -= cost
		visible_message("Incoming supply!")
		if(pad)
			flick("alien-pad", pad)
			. = new item(pad.loc)
		else
			. = new item(loc)
	else
		visible_message("Insufficent data!")
		return FALSE

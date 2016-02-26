//Common
/obj/machinery/abductor
	var/team = 0

/obj/machinery/abductor/proc/IsAbductor(var/mob/living/carbon/human/H)
	if(!H.species)
		return 0
	return H.species.name == "Abductor"

/obj/machinery/abductor/proc/IsAgent(var/mob/living/carbon/human/H)
	if(H.species.name == "Abductor")
		return H.agent
	return 0

/obj/machinery/abductor/proc/IsScientist(var/mob/living/carbon/human/H)
	if(H.species.name == "Abductor")
		return H.scientist
	return 0

//*************-Console-*************//

/obj/machinery/abductor/console
	name = "abductor console"
	desc = "Ship command center."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "console"
	density = 1
	anchored = 1.0
	var/obj/item/device/abductor/gizmo/gizmo
	var/obj/item/clothing/suit/armor/abductor/vest/vest
	var/obj/machinery/abductor/experiment/experiment
	var/obj/machinery/abductor/pad/pad
	var/list/datum/icon_snapshot/disguises = list()
	var/show_price_list = 0
	var/list/price_list = list(
							"heal injector" =4,
							"decloner"		=3,
							"advanced baton"=2,
							"science tool" 	=1,
							"agent helmet" 	=1,
							"radio silencer"=1)

/obj/machinery/abductor/console/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(!IsAbductor(user))
		user << "<span class='warning'>You start mashing alien buttons at random!</span>"
		if(do_after(user,100,target = src))
			TeleporterSend()
		return
	user.set_machine(src)
	var/dat = ""
	dat += "<H2> Abductsoft 3000 </H2>"

	if(experiment != null)
		var/points = experiment.points
		dat += "<font color = #7E8D9F><b>Collected Samples : </b></font>[points]<br>"
		dat += "<H4> Transfer data in exchange for supplies</H4>"
		dat += "<a href='?src=\ref[src];dispense=injector'>Heal Injector</A><br>"
		dat += "<a href='?src=\ref[src];dispense=pistol'>Decloner</A><br>"
		dat += "<a href='?src=\ref[src];dispense=baton'>Advanced Baton</A><br>"
		dat += "<a href='?src=\ref[src];dispense=helmet'>Agent Helmet</A><br>"
		dat += "<a href='?src=\ref[src];dispense=silencer'>Radio Silencer</A><br>"
		dat += "<a href='?src=\ref[src];dispense=tool'>Science Tool</A><br>"
		dat += "<a href='?src=\ref[src];show_prices=1'>[show_price_list ? "Close Price List" : "Open Price List"]</a><br>"
		if(show_price_list)
			dat += "<div class='statusDisplay'>[get_price_list()]</div>"
	else
		dat += "<span class='bad'>NO EXPERIMENT MACHINE DETECTED</span> <br>"

	if(pad!=null)
		dat += "<H4> Teleport control</H4>"
		dat += "<a href='?src=\ref[src];teleporter_send=1'>Activate Teleporter</A><br>"
		dat += "<a href='?src=\ref[src];teleporter_set=1'>Set Teleporter</A><br>"
		dat += "<font color = #7E8D9F><b>Set to: </b></font>[pad.teleport_target ? "[copytext("[pad.target_name]",3)]" : "Nothing"]<br>"
		if(gizmo!=null && gizmo.marked!=null)
			dat += "<a href='?src=\ref[src];teleporter_retrieve=1'>Retrieve Mark</A><br>"
		else
			dat += "<span class='linkOff'>Retrieve Mark</span><br>"
	else
		dat += "<span class='bad'>NO TELEPAD DETECTED</span></br>"

	if(vest!=null)
		dat += "<h4> Agent Vest Mode</h4>"
		var/mode = vest.mode
		if(mode == VEST_STEALTH)
			dat += "<a href='?src=\ref[src];flip_vest=1'>Combat</A>"
			dat += "<span class='linkOff'>Stealth</span>"
		else
			dat += "<span class='linkOff'>Combat</span>"
			dat += "<a href='?src=\ref[src];flip_vest=1'>Stealth</A>"

		dat += "<br>"
		dat += "<a href='?src=\ref[src];select_disguise=1'>Select Agent Vest Disguise</a><br>"
		dat += "<font color = #7E8D9F><b>Selected: </b></font>[vest.disguise ? "[vest.disguise.name]" : "Nobody"]"
	else
		dat += "<span class='bad'>NO AGENT VEST DETECTED</span>"
	var/datum/browser/popup = new(user, "computer", "Abductor Console", 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/abductor/console/Topic(href, href_list)
	if(..())
		return
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
		if(href_list["teleporter_set"])
			TeleporterSet()
		else if(href_list["teleporter_send"])
			TeleporterSend()
		else if(href_list["teleporter_retrieve"])
			TeleporterRetrieve()
		else if(href_list["flip_vest"])
			FlipVest()
		else if(href_list["select_disguise"])
			SelectDisguise()
		else if(href_list["dispense"])
			switch(href_list["dispense"])
				if("injector")
					Dispense(/obj/item/weapon/lazarus_injector/alien,cost=4)
				if("pistol")
					Dispense(/obj/item/weapon/gun/energy/decloner/alien,cost=3)
				if("baton")
					Dispense(/obj/item/weapon/abductor_baton,cost=2)
				if("helmet")
					Dispense(/obj/item/clothing/head/helmet/abductor)
				if("silencer")
					Dispense(/obj/item/device/abductor/silencer)
				if("tool")
					Dispense(/obj/item/device/abductor/gizmo)
		else if(href_list["show_prices"])
			show_price_list = !show_price_list
		src.updateUsrDialog()

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
	if(pad!=null)
		pad.teleport_target = teleportlocs[A]
		pad.target_name = pad.teleport_target.name
	return

/obj/machinery/abductor/console/proc/TeleporterRetrieve()
	if(gizmo!=null && pad!=null && gizmo.marked)
		pad.Retrieve(gizmo.marked)
	return

/obj/machinery/abductor/console/proc/TeleporterSend()
	if(pad!=null)
		pad.Send()
	return

/obj/machinery/abductor/console/proc/FlipVest()
	if(vest!=null)
		vest.flip_mode()
	return

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
	return

/obj/machinery/abductor/console/proc/Initialize()

	for(var/obj/machinery/abductor/pad/p in machines)
		if(p.team == team)
			pad = p
			break

	for(var/obj/machinery/abductor/experiment/e in machines)
		if(e.team == team)
			experiment = e
			e.console = src

/obj/machinery/abductor/console/proc/AddSnapshot(var/mob/living/carbon/human/target)
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

/obj/machinery/abductor/console/attackby(O as obj, user as mob, params)
	if(istype(O, /obj/item/device/abductor/gizmo))
		var/obj/item/device/abductor/gizmo/G = O
		user << "<span class='notice'>You link the tool to the console.</span>"
		gizmo = G
		G.console = src
	else if(istype(O, /obj/item/clothing/suit/armor/abductor/vest))
		var/obj/item/clothing/suit/armor/abductor/vest/V = O
		user << "<span class='notice'>You link the vest to the console.</span>"
		vest = V
	else
		..()

/obj/machinery/abductor/console/proc/Dispense(var/item,var/cost=1)
	if(experiment && experiment.points >= cost)
		experiment.points-=cost
		src.visible_message("Incoming supply!")
		if(pad)
			flick("alien-pad", pad)
			new item(pad.loc)
		else
			new item(src.loc)
	else
		src.visible_message("Insufficent data!")
	return
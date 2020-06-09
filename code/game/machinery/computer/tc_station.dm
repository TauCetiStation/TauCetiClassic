var/list/possible_uplinker_IDs = list("Alfa","Bravo","Charlie","Delta","Echo","Foxtrot","Zero", "Niner")
#define INITIAL_NUCLEAR_TELECRYSTALS 60
#define TELECRYSTALS_PER_ONE_OPERATIVE 9

/obj/machinery/computer/telecrystals
	name = "Telecrystal assignment station"
	desc = "A device used to manage telecrystals during group operations. You shouldn't be looking at this particular one..."
	icon_state = "tcstation"

/////////////////////////////////////////////
/obj/machinery/computer/telecrystals/uplinker
	name = "Telecrystal upload/recieve station"
	desc = "A device used to manage telecrystals during group operations. To use, simply insert your uplink. With your uplink installed \
	you can upload your telecrystals to the group's pool using the console, or be assigned additional telecrystals by your lieutenant."
	icon_state = "tcstation"
	var/obj/item/uplinkholder = null
	var/obj/machinery/computer/telecrystals/boss/linkedboss = null

/obj/machinery/computer/telecrystals/uplinker/atom_init()
	. = ..()

	var/ID
	if(possible_uplinker_IDs.len)
		ID = pick(possible_uplinker_IDs)
		possible_uplinker_IDs -= ID
		name = "[name] [ID]"
	else
		name = "[name] [rand(1,999)]"


/obj/machinery/computer/telecrystals/uplinker/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item))

		if(uplinkholder)
			to_chat(user, "<span class='notice'>The [src] already has an uplink in it.</span>")
			return

		if(O.hidden_uplink)
			var/obj/item/P = user.get_active_hand()
			user.drop_item()
			uplinkholder = P
			P.loc = src
			P.add_fingerprint(user)
			update_icon()
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>The [O] doesn't appear to be an uplink...</span>")



/obj/machinery/computer/telecrystals/uplinker/update_icon()
	cut_overlays()
	if(uplinkholder)
		add_overlay("[initial(icon_state)]-closed")


/obj/machinery/computer/telecrystals/uplinker/proc/ejectuplink()
	if(uplinkholder)
		uplinkholder.loc = get_turf(src.loc)
		uplinkholder = null
		update_icon()

/obj/machinery/computer/telecrystals/uplinker/proc/donateTC(amt, addLog = 1)
	if(uplinkholder && linkedboss)
		if(amt <= uplinkholder.hidden_uplink.uses)
			uplinkholder.hidden_uplink.uses -= amt
			linkedboss.storedcrystals += amt
			if(addLog)
				linkedboss.logTransfer("[src] donated [amt] telecrystals to [linkedboss].")

/obj/machinery/computer/telecrystals/uplinker/proc/giveTC(amt, addLog = 1)
	if(uplinkholder && linkedboss)
		if(amt <= linkedboss.storedcrystals)
			uplinkholder.hidden_uplink.uses += amt
			linkedboss.storedcrystals -= amt
			if(addLog)
				linkedboss.logTransfer("[src] recieved [amt] telecrystals from [linkedboss].")

///////

/obj/machinery/computer/telecrystals/uplinker/ui_interact(mob/user)
	var/dat = ""
	if(linkedboss)
		dat += "[linkedboss] has [linkedboss.storedcrystals] telecrystals available for distribution. <BR><BR>"
	else
		dat += "No linked management consoles detected. Scan for uplink stations using the management console.<BR><BR>"

	if(uplinkholder)
		dat += "[uplinkholder.hidden_uplink.uses] telecrystals remain in this uplink.<BR>"
		if(linkedboss)
			dat += "Donate TC: <a href='byond://?src=\ref[src];donate1=1'>1</a> | <a href='byond://?src=\ref[src];donate5=1'>5</a>"
		dat += "<br><a href='byond://?src=\ref[src];eject=1'>Eject Uplink</a>"

	var/datum/browser/popup = new(user, "computer", "Telecrystal Upload/Recieve Station", 700, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/telecrystals/uplinker/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["donate1"])
		donateTC(1)

	else if(href_list["donate5"])
		donateTC(5)

	else if(href_list["eject"])
		ejectuplink()

	src.updateUsrDialog()


/////////////////////////////////////////
/obj/machinery/computer/telecrystals/boss
	name = "team Telecrystal management console"
	desc = "A device used to manage telecrystals during group operations. To use, simply initialize the machine by scanning for nearby uplink stations. \
	Once the consoles are linked up, you can assign any telecrystals amongst your operatives; be they donated by your agents or rationed to the squad \
	based on the danger rating of the mission."
	icon_state = "tcboss"
	var/virgin = 1
	var/scanrange = 10
	var/storedcrystals = 0
	var/list/TCstations = list()
	var/list/transferlog = list()

/obj/machinery/computer/telecrystals/boss/proc/logTransfer(logmessage)
	transferlog += ("<b>[worldtime2text()]</b> [logmessage]")

/obj/machinery/computer/telecrystals/boss/proc/scanUplinkers()
	for(var/obj/machinery/computer/telecrystals/uplinker/A in range(scanrange, src.loc))
		if(!A.linkedboss)
			TCstations += A
			A.linkedboss = src
	if(virgin)
		getDangerous()
		virgin = 0

/obj/machinery/computer/telecrystals/boss/proc/getDangerous()//This scales the TC assigned with the round population.
	var/danger
	var/active_players = length(player_list)
	var/agent_numbers = CLAMP((active_players / 5), 2, 6)
	storedcrystals = agent_numbers * TELECRYSTALS_PER_ONE_OPERATIVE + INITIAL_NUCLEAR_TELECRYSTALS
	danger = active_players

	while(!IS_MULTIPLE(++danger,10))//Just round up to the nearest multiple of ten.
	storedcrystals += danger

/////////

/obj/machinery/computer/telecrystals/boss/ui_interact(mob/user)
	var/dat = ""
	dat += "<a href='byond://?src=\ref[src];scan=1'>Scan for TC stations.</a><BR>"
	dat += "This [src] has [storedcrystals] telecrystals available for distribution. <BR>"
	dat += "<BR><BR>"

	for(var/obj/machinery/computer/telecrystals/uplinker/A in TCstations)
		dat += "[A.name] | "
		if(A.uplinkholder)
			dat += "[A.uplinkholder.hidden_uplink.uses] telecrystals."
		if(storedcrystals)
			dat+= "<BR>Add TC: <a href ='?src=\ref[src];give1=\ref[A]'>1</a> | <a href ='?src=\ref[src];give5=\ref[A]'>5</a>"
		dat += "<BR>"

	if(TCstations.len)
		dat += "<BR><BR><a href='byond://?src=\ref[src];distrib=1'>Evenly distribute remaining TC.</a><BR><BR>"

	for(var/entry in transferlog)
		dat += "<small>[entry]</small><BR>"

	var/datum/browser/popup = new(user, "computer", "Team Telecrystal Management Console", 700, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/computer/telecrystals/boss/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["scan"])
		scanUplinkers()

	else if(href_list["give1"])
		var/obj/machinery/computer/telecrystals/uplinker/A = locate(href_list["give1"])
		A.giveTC(1)

	else if(href_list["give5"])
		var/obj/machinery/computer/telecrystals/uplinker/A = locate(href_list["give5"])
		A.giveTC(5)

	else if(href_list["distrib"])
		var/sanity = 0
		while(storedcrystals && sanity < 100)
			for(var/obj/machinery/computer/telecrystals/uplinker/A in TCstations)
				A.giveTC(1,0)
			sanity++
		logTransfer("[src] evenly distributed telecrystals.")

	updateUsrDialog()

#undef INITIAL_NUCLEAR_TELECRYSTALS
#undef TELECRYSTALS_PER_ONE_OPERATIVE

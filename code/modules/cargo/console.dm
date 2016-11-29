/obj/machinery/computer/cargo
	name = "Supply console"
	desc = "Used to order supplies, approve requests, and control the shuttle."
	icon = 'icons/obj/computer.dmi'
	icon_state = "supply"
	light_color = "#b88b2e"
	req_access = list(access_cargo)
	circuit = /obj/item/weapon/circuitboard/computer/cargo
	var/requestonly = FALSE
	var/contraband = FALSE
	var/hacked = FALSE
	var/temp = ""
	var/last_viewed_group = "categories"
	var/reqtime = 0 //Cooldown for requisitions - Quarxink
	var/safety_warning = "For safety reasons the automated supply shuttle \
		cannot transport live organisms, classified nuclear weaponry or \
		homing beacons."

/obj/machinery/computer/cargo/request
	name = "Supply request console"
	desc = "Used to request supplies from cargo."
	icon = 'icons/obj/computer.dmi'
	icon_state = "request"
	light_color = "#b88b2e"
	circuit = /obj/item/weapon/circuitboard/computer/cargo/request
	requestonly = TRUE

/obj/machinery/computer/cargo/New()
	..()
	var/obj/item/weapon/circuitboard/computer/cargo/board = circuit
	contraband = board.contraband_enabled
	hacked = board.hacked

/obj/machinery/computer/cargo/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/cargo/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/computer/cargo/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat
	if(!requestonly)
		post_signal("supply")
	if(temp)
		dat = temp
	else
		dat += {"<BR><B>Supply shuttle</B><HR>
		Location: [SSshuttle.moving ? "Moving to station ([SSshuttle.eta] Mins.)":SSshuttle.at_station ? "Station":"Dock"]<BR>
		<HR>Supply points: [SSshuttle.points]<BR>\n<BR>"}
		if(requestonly)
			dat += "\n<A href='?src=\ref[src];order=categories'>Request items</A><BR><BR>"
		else
			dat += {"[SSshuttle.moving ? "\n*Must be away to order items*<BR>\n<BR>":SSshuttle.at_station ? "\n*Must be away to order items*<BR>\n<BR>":"\n<A href='?src=\ref[src];order=categories'>Order items</A><BR>\n<BR>"]
			[SSshuttle.moving ? "\n*Shuttle already called*<BR>\n<BR>":SSshuttle.at_station ? "\n<A href='?src=\ref[src];send=1'>Send away</A><BR>\n<BR>":"\n<A href='?src=\ref[src];send=1'>Send to station</A><BR>\n<BR>"]"}
		dat += {"<A href='?src=\ref[src];viewrequests=1'>View requests</A><BR><BR>
		<A href='?src=\ref[src];vieworders=1'>View approved orders</A><BR><BR>"}
		if(!requestonly)
			dat += "<A href='?src=\ref[src];viewcentcom=1'>View Centcom message</A><BR><BR>"
		dat += "<A href='?src=\ref[user];mach_close=computer'>Close</A>"


	var/datum/browser/popup = new(user, "computer", name, 575, 450)
	popup.set_content(dat)
	popup.open()
	onclose(user, "computer")

/obj/machinery/computer/cargo/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["send"])
		if(!SSshuttle.can_move())
			temp = "[safety_warning]<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		else if(SSshuttle.at_station)
			SSshuttle.moving = -1
			SSshuttle.sell()
			SSshuttle.send()
			temp = "The supply shuttle has departed.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
		else
			SSshuttle.moving = 1
			SSshuttle.buy()
			SSshuttle.eta_timeofday = (world.timeofday + SSshuttle.movetime) % 864000
			temp = "The supply shuttle has been called and will arrive in [round(SSshuttle.movetime/600,1)] minutes.<BR><BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"
			post_signal("supply")

	if(href_list["order"])
		if(!requestonly && SSshuttle.moving)
			return
		if(href_list["order"] == "categories")
			//all_supply_groups
			//Request what?
			last_viewed_group = "categories"
			temp = "<b>Supply points: [SSshuttle.points]</b><BR>"
			temp += "<A href='?src=\ref[src];mainmenu=1'>Main Menu</A><HR><BR><BR>"
			temp += "<b>Select a category</b><BR><BR>"
			for(var/supply_group_name in all_supply_groups )
				temp += "<A href='?src=\ref[src];order=[supply_group_name]'>[supply_group_name]</A><BR>"
		else
			last_viewed_group = href_list["order"]
			temp = "<b>Supply points: [SSshuttle.points]</b><BR>"
			temp += "<A href='?src=\ref[src];order=categories'>Back to all categories</A><HR><BR><BR>"
			temp += "<b>Request from: [last_viewed_group]</b><BR><BR>"
			for(var/supply_name in SSshuttle.supply_packs)
				var/datum/supply_pack/N = SSshuttle.supply_packs[supply_name]
				if(requestonly)
					if(N.hidden || N.contraband || N.group != last_viewed_group)
						continue	//Have to send the type instead of a reference to
				else if((N.hidden && !hacked) || (N.contraband && !contraband) || N.group != last_viewed_group)
					continue
				temp += "<A href='?src=\ref[src];doorder=[supply_name]'>[supply_name]</A> Cost: [N.cost]<BR>"		//the obj because it would get caught by the garbage

	if(href_list["doorder"])
		if(world.time < reqtime)
			for(var/mob/V in hearers(src))
				V.show_message("<b>[src]</b>'s monitor flashes, \"[world.time - reqtime] seconds remaining until another requisition form may be printed.\"")
			return FALSE
		//Find the correct supply_pack datum
		var/datum/supply_pack/P = SSshuttle.supply_packs[href_list["doorder"]]
		if(!istype(P))
			return FALSE
		var/timeout = world.time + 600
		var/reason = sanitize_alt(copytext(input(usr,"Reason:","Why do you require this item?","") as null|text,1,MAX_MESSAGE_LEN))
		if(world.time > timeout)
			return FALSE
		if(!reason)
			return FALSE
		var/idname = "*None Provided*"
		var/idrank = "*None Provided*"
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			idname = H.get_authentification_name()
			idrank = H.get_assignment()
		else if(issilicon(usr))
			idname = usr.real_name
			idrank = "Silicon"

		reqtime = (world.time + 5) % 1e5

		//make our supply_order datum
		var/datum/supply_order/O = new /datum/supply_order(P, idname, idrank, usr.ckey, reason)
		SSshuttle.requestlist += O
		O.generateRequisition(loc) //print supply request

		if(requestonly)
			temp = "Thanks for your request. The cargo team will process it as soon as possible.<BR>"
			temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
		else
			temp = "Order request placed.<BR>"
			temp += "<BR><A href='?src=\ref[src];order=[last_viewed_group]'>Back</A> | <A href='?src=\ref[src];mainmenu=1'>Main Menu</A> | <A href='?src=\ref[src];confirmorder=[O.id]'>Authorize Order</A>"

	if(href_list["confirmorder"])
		//Find the correct supply_order datum
		var/ordernum = text2num(href_list["confirmorder"])
		var/datum/supply_order/O
		var/datum/supply_pack/P
		temp = "Invalid Request"
		for(var/i = 1 to SSshuttle.requestlist.len)
			var/datum/supply_order/SO = SSshuttle.requestlist[i]
			if(SO.id == ordernum)
				O = SO
				P = O.object
				if(SSshuttle.points >= P.cost)
					SSshuttle.requestlist.Cut(i,i+1)
					SSshuttle.points -= P.cost
					SSshuttle.shoppinglist += O
					temp = "Thanks for your order.<BR>"
					temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
				else
					temp = "Not enough supply points.<BR>"
					temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"
				break

	if(href_list["vieworders"])
		temp = "Current approved orders: <BR><BR>"
		for(var/S in SSshuttle.shoppinglist)
			var/datum/supply_order/SO = S
			if(requestonly)
				temp += "[SO.object.name] approved by [SO.orderer] [SO.reason ? "([SO.reason])":""]<BR>"
			else
				temp += "#[SO.id] - [SO.object.name] approved by [SO.orderer][SO.reason ? " ([SO.reason])":""]<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	if(href_list["viewrequests"])
		temp = "Current requests: <BR><BR>"
		for(var/S in SSshuttle.requestlist)
			var/datum/supply_order/SO = S
			if(requestonly)
				temp += "#[SO.id] - [SO.object.name] requested by [SO.orderer]<BR>"
			else
				temp += "#[SO.id] - [SO.object.name] requested by [SO.orderer]  [SSshuttle.moving ? "":SSshuttle.at_station ? "":"<A href='?src=\ref[src];confirmorder=[SO.id]'>Approve</A> <A href='?src=\ref[src];rreq=[SO.id]'>Remove</A>"]<BR>"
		if(!requestonly)
			temp += "<BR><A href='?src=\ref[src];clearreq=1'>Clear list</A>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	else if (href_list["rreq"])
		var/ordernum = text2num(href_list["rreq"])
		temp = "Invalid Request.<BR>"
		for(var/i = 1 to SSshuttle.requestlist.len)
			var/datum/supply_order/SO = SSshuttle.requestlist[i]
			if(SO.id == ordernum)
				SSshuttle.requestlist.Cut(i,i+1)
				temp = "Request removed.<BR>"
				break
		temp += "<BR><A href='?src=\ref[src];viewrequests=1'>Back</A> <A href='?src=\ref[src];mainmenu=1'>Main Menu</A>"

	else if (href_list["clearreq"])
		SSshuttle.requestlist.Cut()
		temp = "List cleared.<BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	if(href_list["viewcentcom"])
		if(SSshuttle && SSshuttle.centcom_message)
			temp += "Latest Centcom message: <BR><BR>"
			temp += SSshuttle.centcom_message
			temp += "<BR><BR>"
		else
			temp += "Can not find any messages from Centcom. <BR><BR>"
		temp += "<BR><A href='?src=\ref[src];mainmenu=1'>OK</A>"

	if(href_list["mainmenu"])
		temp = null

	updateUsrDialog()

/obj/machinery/computer/cargo/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/emag) && !hacked)
		to_chat(user, "\blue Special supplies unlocked.")
		hacked = TRUE
		contraband = TRUE
		user.visible_message("<span class='warning'>[user] swipes a suspicious card through [src]!",
		"<span class='notice'>You adjust [src]'s routing and receiver spectrum, unlocking special supplies and contraband.</span>")

		// This also permamently sets this on the circuit board
		var/obj/item/weapon/circuitboard/computer/cargo/board = circuit
		board.contraband_enabled = TRUE
		board.hacked = TRUE
	else
		..()

/obj/machinery/computer/cargo/proc/post_signal(command)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	frequency.post_signal(src, status_signal)

/*
/obj/machinery/computer/cargo/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
											datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cargo", name, 1000, 800, master_ui, state)
		ui.open()

/obj/machinery/computer/cargo/ui_data()
	var/list/data = list()
	data["requestonly"] = requestonly
	data["location"] = SSshuttle.supply.getStatusText()
	data["points"] = SSshuttle.points
	data["away"] = SSshuttle.supply.getDockedId() == "supply_away"
	data["docked"] = SSshuttle.supply.mode == SHUTTLE_IDLE
	data["loan"] = !!SSshuttle.shuttle_loan
	data["loan_dispatched"] = SSshuttle.shuttle_loan && SSshuttle.shuttle_loan.dispatched
	data["message"] = SSshuttle.centcom_message || "Remember to stamp and send back the supply manifests."

	data["supplies"] = list()
	for(var/pack in SSshuttle.supply_packs)
		var/datum/supply_pack/P = SSshuttle.supply_packs[pack]
		if(!data["supplies"][P.group])
			data["supplies"][P.group] = list(
				"name" = P.group,
				"packs" = list()
			)
		if((P.hidden && !emagged) || (P.contraband && !contraband) || (P.special && !P.special_enabled))
			continue
		data["supplies"][P.group]["packs"] += list(list(
			"name" = P.name,
			"cost" = P.cost,
			"id" = pack
		))

	data["cart"] = list()
	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		data["cart"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"id" = SO.id
		))

	data["requests"] = list()
	for(var/datum/supply_order/SO in SSshuttle.requestlist)
		data["requests"] += list(list(
			"object" = SO.pack.name,
			"cost" = SO.pack.cost,
			"orderer" = SO.orderer,
			"reason" = SO.reason,
			"id" = SO.id
		))

	return data

/obj/machinery/computer/cargo/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(action != "add" && requestonly)
		return
	switch(action)
		if("send")
			if(!SSshuttle.supply.canMove())
				say(safety_warning)
				return
			if(SSshuttle.supply.getDockedId() == "supply_home")
				SSshuttle.supply.emagged = emagged
				SSshuttle.supply.contraband = contraband
				SSshuttle.moveShuttle("supply", "supply_away", TRUE)
				say("The supply shuttle has departed.")
				investigate_log("[key_name(usr)] sent the supply shuttle away.", "cargo")
			else
				investigate_log("[key_name(usr)] called the supply shuttle.", "cargo")
				say("The supply shuttle has been called and will arrive in [SSshuttle.supply.timeLeft(600)] minutes.")
				SSshuttle.moveShuttle("supply", "supply_home", TRUE)
			. = TRUE
		if("loan")
			if(!SSshuttle.shuttle_loan)
				return
			else if(SSshuttle.supply.mode != SHUTTLE_IDLE)
				return
			else if(SSshuttle.supply.getDockedId() != "supply_away")
				return
			else
				SSshuttle.shuttle_loan.loan_shuttle()
				say("The supply shuttle has been loaned to Centcom.")
				. = TRUE
		if("add")
			var/id = text2path(params["id"])
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				return
			if((pack.hidden && !emagged) || (pack.contraband && !contraband))
				return

			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = usr.ckey
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment()
			else if(issilicon(usr))
				name = usr.real_name
				rank = "Silicon"

			var/reason = ""
			if(requestonly)
				reason = input("Reason:", name, "") as text|null
				if(isnull(reason) || ..())
					return

			var/turf/T = get_turf(src)
			var/datum/supply_order/SO = new(pack, name, rank, ckey, reason)
			SO.generateRequisition(T)
			if(requestonly)
				SSshuttle.requestlist += SO
			else
				SSshuttle.shoppinglist += SO
			. = TRUE
		if("remove")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
				if(SO.id == id)
					SSshuttle.shoppinglist -= SO
					. = TRUE
					break
		if("clear")
			SSshuttle.shoppinglist.Cut()
			. = TRUE
		if("approve")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.id == id)
					SSshuttle.requestlist -= SO
					SSshuttle.shoppinglist += SO
					. = TRUE
					break
		if("deny")
			var/id = text2num(params["id"])
			for(var/datum/supply_order/SO in SSshuttle.requestlist)
				if(SO.id == id)
					SSshuttle.requestlist -= SO
					. = TRUE
					break
		if("denyall")
			SSshuttle.requestlist.Cut()
			. = TRUE
	if(.)
		post_signal("supply")
*/

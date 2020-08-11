//gangtool device
/obj/item/device/gangtool
	name = "suspicious device"
	desc = "A strange device of sorts. Hard to really make out what it actually does just by looking."
	icon_state = "gangtool"
	item_state = "walkietalkie"
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	var/gang //Which gang uses this?
	var/boss = 1 //Is this the original boss?
	var/recalling = 0
	var/outfits = 3
	var/free_pen = 0

/obj/item/device/gangtool/atom_init() //Initialize supply point income if it hasn't already been started
	. = ..()
	if(!SSticker.mode.gang_points)
		SSticker.mode.gang_points = new /datum/gang_points(SSticker.mode)
		SSticker.mode.gang_points.start()
	if(boss)
		desc += " Looks important."

/obj/item/device/gangtool/attack_self(mob/user)
	if (!can_use(user))
		return

	var/gang_bosses = ((gang == "A")? SSticker.mode.A_bosses.len : SSticker.mode.B_bosses.len)

	var/dat
	if(!gang)
		dat += "This device is not registered.<br><br>"
		if(user.mind in (SSticker.mode.A_bosses | SSticker.mode.B_bosses))
			dat += "Give this device to another member of your organization to use to promote them.<hr>"
			dat += "If this is meant as a spare device for yourself:<br>"
			dat += "<a href='?src=\ref[src];register=1'>Register Device</a><br>"
		else if (gang_bosses < 3)
			dat += "You have been selected for a promotion!<br>"
			dat += "<a href='?src=\ref[src];register=1'>Register Device</a><br>"
		else
			dat += "No promotions available: All positions filled."
	else
		var/datum/game_mode/gang/gangmode
		if(istype(SSticker.mode, /datum/game_mode/gang))
			gangmode = SSticker.mode

		var/gang_size = gang_bosses + ((gang == "A")? SSticker.mode.A_gang.len : SSticker.mode.B_gang.len)
		var/gang_territory = ((gang == "A")? SSticker.mode.A_territory.len : SSticker.mode.B_territory.len)
		var/points = ((gang == "A") ? SSticker.mode.gang_points.A : SSticker.mode.gang_points.B)
		var/timer
		if(gangmode)
			timer = ((gang == "A") ? gangmode.A_timer : gangmode.B_timer)
			if(isnum(timer))
				dat += "<center><font color='red'>Takeover In Progress:<br><B>[timer] seconds remain</B></font></center><br>"

		dat += "Registration: <B>[(gang == "A")? gang_name("A") : gang_name("B")] Gang [boss ? "Administrator" : "Lieutenant"]</B><br>"
		dat += "Organization Size: <B>[gang_size]</B> | Station Control: <B>[round((gang_territory/start_state.num_territories)*100, 1)]%</B><br>"
		dat += "Influence: <B>[points]</B><br>"
		dat += "Time until Influence grows: <B>[(points >= 999) ? ("--:--") : (time2text(SSticker.mode.gang_points.next_point_time - world.time, "mm:ss"))]</B><br>"
		dat += "<hr>"
		dat += "<B>Gangtool Functions:</B><br>"

		dat += "<a href='?src=\ref[src];choice=ping'>Send Message to Gang</a><br>"
		if(outfits > 0)
			dat += "<a href='?src=\ref[src];choice=outfit'>Create Armored Gang Outfit</a><br>"
		else
			dat += "<b>Create Gang Outfit</b> (Restocking)<br>"
		if(gangmode)
			dat += "<a href='?src=\ref[src];choice=recall'>Recall Emergency Shuttle</a><br>"

		dat += "<br>"
		dat += "<B>Purchase Weapons:</B><br>"

		dat += "(10 Influence) "
		if(points >= 10)
			dat += "<a href='?src=\ref[src];purchase=switchblade'>Switchblade</a><br>"
		else
			dat += "Switchblade<br>"

		dat += "(25 Influence) "
		if(points >= 25)
			dat += "<a href='?src=\ref[src];purchase=pistol'>9mm Pistol</a><br>"
		else
			dat += "9mm Pistol<br>"

		dat += "(10 Influence) "
		if(points >= 10)
			dat += "<a href='?src=\ref[src];purchase=9mmammo'>9mm Ammo</a><br>"
		else
			dat += "9mm Ammo<br>"

		dat += "(50 Influence) "
		if(points >= 50)
			dat += "<a href='?src=\ref[src];purchase=uzi'>Mini Uzi</a><br>"
		else
			dat += "Mini Uzi<br>"

		dat += "(20 Influence) "
		if(points >= 20)
			dat += "<a href='?src=\ref[src];purchase=9mmammoU'>Uzi Ammo</a><br>"
		else
			dat += "Uzi Magazine<br>"

		dat += "<br>"
		dat += "<B>Purchase Equipment:</B><br>"

		dat += "(5 Influence) "
		if(points >= 5)
			dat += "<a href='?src=\ref[src];purchase=spraycan'>Territory Spraycan</a><br>"
		else
			dat += "Territory Spraycan<br>"

		dat += "(10 Influence) "
		if(points >= 10)
			dat += "<a href='?src=\ref[src];purchase=C4'>C4 Explosive</a><br>"
		else
			dat += "C4 Explosive<br>"

		if(free_pen)
			dat += "(ONE FREE) "
		else
			dat += "(50 Influence) "
		if(free_pen || (points >= 50))
			dat += "<a href='?src=\ref[src];purchase=pen'>Recruitment Pen</a><br>"
		else
			dat += "Recruitment Pen<br>"

		var/tool_cost = (boss ? 10 : 30)
		var/gangtooldesc = "Promote a Gangster ([3-gang_bosses] left)."
		if(gang_bosses >= 3)
			gangtooldesc = "Additional Gangtools."
		dat += "([tool_cost] Influence) "
		if(points >= tool_cost)
			dat += "<a href='?src=\ref[src];purchase=gangtool'>[gangtooldesc]</a><br>"
		else
			dat += "[gangtooldesc]<br>"

		if(gangmode)
			if(gang == "A" ? !gangmode.A_dominations : !gangmode.B_dominations)
				dat += "(Out of stock) Station Dominator"
			else
				dat += "(30 Influence) "
				if(points >= 30)
					dat += "<a href='?src=\ref[src];purchase=dominator'><b>Station Dominator</b></a><br>"
				else
					dat += "<b>Station Dominator</b><br>"
				dat += "<i>(Estimated Takeover Time: [round(max(300,900 - ((round((gang_territory/start_state.num_territories)*200, 10) - 60) * 15))/60,1)] minutes)</i><br>"

	dat += "<br>"
	dat += "<a href='?src=\ref[src];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome to GangTool v2.1", 340, 600)
	popup.set_content(dat)
	popup.open()



/obj/item/device/gangtool/Topic(href, href_list)
	if(!can_use(usr))
		return

	add_fingerprint(usr)

	if(recalling)
		to_chat(usr, "<span class='warning'>Device is busy. Shuttle recall in progress.</span>")
		return

	if(href_list["register"])
		register_device(usr)

	else if(!gang) //Gangtool must be registered before you can use the functions below
		return

	if(href_list["purchase"])
		var/points = ((gang == "A") ? SSticker.mode.gang_points.A : SSticker.mode.gang_points.B)
		var/item_type
		switch(href_list["purchase"])
			if("spraycan")
				if(points >= 5)
					item_type = /obj/item/toy/crayon/spraycan/gang
					points = 5
			if("switchblade")
				if(points >= 10)
					item_type = /obj/item/weapon/switchblade
					points = 10
			if("pistol")
				if(points >= 25)
					item_type = /obj/item/weapon/gun/projectile/automatic/pistol
					points = 25
			if("9mmammo")
				if(points >= 10)
					item_type = /obj/item/ammo_box/magazine/m9mm
					points = 10
			if("uzi")
				if(points >= 50)
					item_type = /obj/item/weapon/gun/projectile/automatic/mini_uzi
					points = 50
			if("9mmammoU")
				if(points >= 20)
					item_type = /obj/item/ammo_box/magazine/uzim9mm
					points = 20
			if("C4")
				if(points >= 10)
					item_type = /obj/item/weapon/plastique
					points = 10
			if("pen")
				if(free_pen)
					item_type = /obj/item/weapon/pen/gang
					free_pen = 0
					points = 0
				else if(points >= 50)
					item_type = /obj/item/weapon/pen/gang
					points = 50
			if("gangtool")
				var/tool_cost = (boss ? 10 : 30)
				if(points >= tool_cost)
					item_type = /obj/item/device/gangtool/lt
					points = tool_cost
			if("dominator")
				if(istype(SSticker.mode, /datum/game_mode/gang))
					var/datum/game_mode/gang/mode = SSticker.mode
					if(isnum((gang == "A") ? mode.A_timer : mode.B_timer))
						return

					if(gang == "A" ? !mode.A_dominations : !mode.B_dominations)
						return

					var/area/usrarea = get_area(usr.loc)
					var/usrturf = get_turf(usr.loc)
					if(initial(usrarea.name) == "Space" || istype(usrturf,/turf/space) || !is_station_level(usr.z))
						to_chat(usr, "<span class='warning'>You can only use this on the station!</span>")
						return

					for(var/obj/obj in usrturf)
						if(obj.density)
							to_chat(usr, "<span class='warning'>There's not enough room here!</span>")
							return

					if(points >= 30)
						item_type = /obj/machinery/dominator
						points = 30

		if(item_type)
			if(gang == "A")
				SSticker.mode.gang_points.A -= points
			else if(gang == "B")
				SSticker.mode.gang_points.B -= points
			if(ispath(item_type))
				var/obj/purchased = new item_type(get_turf(usr))
				var/mob/living/carbon/human/H = usr
				H.put_in_any_hand_if_possible(purchased)
			if(points)
				SSticker.mode.message_gangtools(((gang=="A")? SSticker.mode.A_tools : SSticker.mode.B_tools), "A [href_list["purchase"]] was purchased by [usr] for [points] Influence.")
			log_game("A [href_list["purchase"]] was purchased by [key_name(usr)] for [points] Influence.")

		else
			to_chat(usr, "<span class='warning'>Not enough influence.</span>")

	else if(href_list["choice"])
		switch(href_list["choice"])
			if("recall")
				recall(usr)
			if("outfit")
				if(outfits > 0)
					SSticker.mode.gang_outfit(usr,src,gang)
					outfits -= 1
			if("ping")
				ping_gang(usr)
	attack_self(usr)


/obj/item/device/gangtool/proc/ping_gang(mob/user)
	if(!user)
		return
	var/message = sanitize(input(user,"Discreetly send a gang-wide message.","Send Message") as null|text)
	if(!message || (message == "") || !can_use(user))
		return
	if(!is_centcom_level(user.z) && !is_station_level(user.z))
		to_chat(user, "<span class='info'>[bicon(src)]Error: Station out of range.</span>")
		return
	var/list/members = list()
	if(gang == "A")
		members += SSticker.mode.A_bosses | SSticker.mode.A_gang
	else if(gang == "B")
		members += SSticker.mode.B_bosses | SSticker.mode.B_gang
	if(members.len)
		var/ping = "<span class='danger'><B><i>[gang_name(gang)] [boss ? "Gang Boss" : "Gang Lieutenant"]</i>: [sanitize(message)]</B></span>"
		for(var/datum/mind/ganger in members)
			if((ganger.current.z <= 2) && (ganger.current.stat == CONSCIOUS))
				to_chat(ganger.current, ping)
		for(var/mob/M in dead_mob_list)
			to_chat(M, ping)
		log_game("[key_name(user)] Messaged [gang_name(gang)] Gang ([gang]): [sanitize(message)].")


/obj/item/device/gangtool/proc/register_device(mob/user)
	if(!(user.mind in (SSticker.mode.A_bosses|SSticker.mode.B_bosses)))
		var/gang_bosses = ((gang == "A")? SSticker.mode.A_bosses.len : SSticker.mode.B_bosses.len)
		if(gang_bosses >= 3)
			to_chat(user, "<span class='warning'>[bicon(src)] Error: All positions filled.</span>")
			return

	if(jobban_isbanned(user, ROLE_REV) || jobban_isbanned(user, "Syndicate") || role_available_in_minutes(user, ROLE_REV))
		to_chat(user, "<span class='warning'>[bicon(src)] ACCESS DENIED: Blacklisted user.</span>")
		return 0

	var/promoted
	if(user.mind in (SSticker.mode.A_gang | SSticker.mode.A_bosses))
		SSticker.mode.A_tools += src
		gang = "A"
		icon_state = "gangtool-a"
		if(!(user.mind in SSticker.mode.A_bosses))
			SSticker.mode.remove_gangster(user.mind, 0, 2)
			SSticker.mode.A_bosses += user.mind
			user.mind.special_role = "[gang_name("A")] Gang (A) Lieutenant"
			SSticker.mode.update_gang_icons_added(user.mind, "A")
			log_game("[key_name(user)] has been promoted to Lieutenant in the [gang_name("A")] Gang (A)")
			promoted = 1
	else if(user.mind in (SSticker.mode.B_gang | SSticker.mode.B_bosses))
		SSticker.mode.B_tools += src
		gang = "B"
		icon_state = "gangtool-b"
		if(!(user.mind in SSticker.mode.B_bosses))
			SSticker.mode.remove_gangster(user.mind, 0, 2)
			SSticker.mode.B_bosses += user.mind
			user.mind.special_role = "[gang_name("B")] Gang (B) Lieutenant"
			SSticker.mode.update_gang_icons_added(user.mind, "B")
			log_game("[key_name(user)] has been promoted to Lieutenant in the [gang_name("B")] Gang (B)")
			promoted = 1
	if(promoted)
		SSticker.mode.message_gangtools(((gang=="A")? SSticker.mode.A_tools : SSticker.mode.B_tools), "[user] has been promoted to Lieutenant.")
		to_chat(user, "<FONT size=3 color=red><B>You have been promoted to Lieutenant!</B></FONT>")
		SSticker.mode.forge_gang_objectives(user.mind)
		SSticker.mode.greet_gang(user.mind,0)
		to_chat(user, "The <b>Gangtool</b> you registered will allow you to purchase items, send messages to your gangsters and to recall the emergency shuttle from anywhere on the station.")
		to_chat(user, "Unlike regular gangsters, you may use <b>recruitment pens</b> to add recruits to your gang. Use them on unsuspecting crew members to recruit them. Don't forget to get your one free pen from the gangtool.")
	if(!gang)
		to_chat(usr, "<span class='warning'>ACCESS DENIED: Unauthorized user.</span>")

/obj/item/device/gangtool/proc/recall(mob/user)
	if(!can_use(user))
		return 0

	if(!istype(SSticker.mode, /datum/game_mode/gang))
		return 0

	var/datum/game_mode/gang/mode = SSticker.mode
	recalling = 1
	to_chat(loc, "<span class='info'>[bicon(src)]Generating shuttle recall order with codes retrieved from last call signal...</span>")

	sleep(rand(100,300))

	if(SSshuttle.location!=0) //Shuttle can only be recalled when it's moving to the station
		to_chat(user, "<span class='info'>[bicon(src)]Emergency shuttle cannot be recalled at this time.</span>")
		recalling = 0
		return 0
	to_chat(loc, "<span class='info'>[bicon(src)]Shuttle recall order generated. Accessing station long-range communication arrays...</span>")

	sleep(rand(100,300))

	if(gang == "A" ? !mode.A_dominations : !mode.B_dominations)
		to_chat(user, "<span class='info'>[bicon(src)]Error: Unable to access communication arrays. Firewall has logged our signature and is blocking all further attempts.</span>")
		recalling = 0
		return 0

	var/turf/userturf = get_turf(user)
	if(!is_station_level(userturf.z)) //Shuttle can only be recalled while on station
		to_chat(user, "<span class='info'>[bicon(src)]Error: Device out of range of station communication arrays.</span>")
		recalling = 0
		return 0
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	if((100 *  start_state.score(end_state)) < 70) //Shuttle cannot be recalled if the station is too damaged
		to_chat(user, "<span class='info'>[bicon(src)]Error: Station communication systems compromised. Unable to establish connection.</span>")
		recalling = 0
		return 0
	to_chat(loc, "<span class='info'>[bicon(src)]Comm arrays accessed. Broadcasting recall signal...</span>")

	sleep(rand(100,300))

	recalling = 0
	log_game("[key_name(user)] has tried to recall the shuttle with a gangtool.")
	message_admins("[key_name_admin(user)] has tried to recall the shuttle with a gangtool. [ADMIN_JMP(user)]", 1)
	userturf = get_turf(user)
	if(is_station_level(userturf.z)) //Check one more time that they are on station.
		if(cancel_call_proc(user))
			return 1

	to_chat(loc, "<span class='info'>[bicon(src)]No response recieved. Emergency shuttle cannot be recalled at this time.</span>")
	return 0

/obj/item/device/gangtool/proc/can_use(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.incapacitated())
		return
	if(!(src in user.contents))
		return

	var/success
	if(user.mind)
		if(gang)
			if((gang == "A") && (user.mind in SSticker.mode.A_bosses))
				success = 1
			else if((gang == "B") && (user.mind in SSticker.mode.B_bosses))
				success = 1
		else
			success = 1
	if(success)
		return 1
	to_chat(user, "<span class='warning'>[bicon(src)] ACCESS DENIED: Unauthorized user.</span>")
	return 0

/obj/item/device/gangtool/lt
	boss = 0
	outfits = 1
	free_pen = 1

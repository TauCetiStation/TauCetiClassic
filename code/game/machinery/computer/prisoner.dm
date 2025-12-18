/obj/machinery/computer/prisoner
	name = "Implant Management"
	icon = 'icons/obj/computer.dmi'
	icon_state = "explosive"
	state_broken_preset = "securityb"
	state_nopower_preset = "security0"
	light_color = "#a91515"
	req_access = list(access_armory)
	circuit = /obj/item/weapon/circuitboard/prisoner
	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - No Access Denied, 1 - Access allowed

	required_skills = list(/datum/skill/police = SKILL_LEVEL_PRO)

/obj/machinery/computer/prisoner/ui_interact(mob/user)
	var/dat = ""
	if(screen == 0)
		dat += "<HR><A href='byond://?src=\ref[src];lock=1'>Unlock Console</A>"
	else if(screen == 1)
		dat += "<HR>Chemical Implants<BR>"
		var/turf/Tr = null
		for(var/obj/item/weapon/implant/chem/C in global.implant_list)
			if(!C.implanted_mob)
				continue
			Tr = get_turf(C)
			if(!Tr || Tr.z != src.z) // Out of range
				continue
			dat += "[C.implanted_mob.name] | Remaining Units: [C.reagents.total_volume] | Inject: "
			dat += "<A class='red' href='byond://?src=\ref[src];inject=\ref[C];amount=1'>1</A>"
			dat += "<A class='red' href='byond://?src=\ref[src];inject=\ref[C];amount=5'>5</A>"
			dat += "<A class='red' href='byond://?src=\ref[src];inject=\ref[C];amount=10'>10</A><BR>"
			dat += "********************************<BR>"
		dat += "<HR>Tracking Implants<BR>"
		for(var/obj/item/weapon/implant/tracking/T in global.implant_list)
			if(!T.implanted_mob)
				continue
			Tr = get_turf(T)
			if(!Tr || Tr.z != src.z) // Out of range
				continue
			var/loc_display = "Unknown"
			var/turf/mob_loc = get_turf_loc(T.implanted_mob)
			if(!isenvironmentturf(mob_loc))
				loc_display = mob_loc.loc
			if(T.malfunction)
				loc_display = pick(teleportlocs)
			dat += "ID: [T.id] | Location: [loc_display]<BR>"
			dat += "<A class='red' href='byond://?src=\ref[src];warn=\ref[T]'><i>Message Holder</i></A> |<BR>"
			dat += "********************************<BR>"
		dat += "<HR><A href='byond://?src=\ref[src];lock=1'>Lock Console</A>"

	var/datum/browser/popup = new(user, "computer", "Prisoner Implant Manager System", 400, 500)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/prisoner/process()
	if(!..())
		updateDialog()
	return


/obj/machinery/computer/prisoner/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["inject"])
		var/obj/item/weapon/implant/chem/I = locate(href_list["inject"])
		if(!istype(I) || !I.implanted_mob)
			return

		var/turf/T = get_turf(I.implanted_mob)

		if(!T || T.z != src.z)
			return

		var/amount = clamp(text2num(href_list["amount"]), 1, 10)

		I.use_implant(amount)

	else if(href_list["warn"])
		var/warning = sanitize(input(usr,"Message:","Enter your message here!",""))
		if(!warning)
			return

		var/obj/item/weapon/implant/tracking/I = locate(href_list["warn"])
		if(!istype(I) || !I.implanted_mob)
			return

		var/turf/T = get_turf(I.implanted_mob)

		if(!T || T.z != src.z)
			return

		to_chat(I.implanted_mob, "<span class='notice'>You hear a voice in your head saying: '[warning]'</span>")

	else if(href_list["lock"])
		if(allowed(usr))
			screen = !screen
		else
			to_chat(usr, "Unauthorized Access.")


	updateUsrDialog()

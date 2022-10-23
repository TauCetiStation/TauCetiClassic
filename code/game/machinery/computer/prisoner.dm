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
		dat += "<HR><A href='?src=\ref[src];lock=1'>Unlock Console</A>"
	else if(screen == 1)
		dat += "<HR>Chemical Implants<BR>"
		var/turf/Tr = null
		for(var/obj/item/weapon/implant/chem/C in implant_list)
			Tr = get_turf(C)
			if((Tr) && (Tr.z != src.z))	continue//Out of range
			if(!C.implanted) continue
			dat += "[C.imp_in.name] | Remaining Units: [C.reagents.total_volume] | Inject: "
			dat += "<A class='red' href='?src=\ref[src];inject1=\ref[C]'>1</A>"
			dat += "<A class='red' href='?src=\ref[src];inject5=\ref[C]'>5</A>"
			dat += "<A class='red' href='?src=\ref[src];inject10=\ref[C]'>10</A><BR>"
			dat += "********************************<BR>"
		dat += "<HR>Tracking Implants<BR>"
		for(var/obj/item/weapon/implant/tracking/T in implant_list)
			Tr = get_turf(T)
			if((Tr) && (Tr.z != src.z))	continue//Out of range
			if(!T.implanted) continue
			var/loc_display = "Unknown"
			var/mob/living/carbon/M = T.imp_in
			var/turf/mob_loc = get_turf_loc(M)
			if(!isenvironmentturf(mob_loc))
				loc_display = mob_loc.loc
			if(T.malfunction)
				loc_display = pick(teleportlocs)
			dat += "ID: [T.id] | Location: [loc_display]<BR>"
			dat += "<A class='red' href='?src=\ref[src];warn=\ref[T]'><i>Message Holder</i></A> |<BR>"
			dat += "********************************<BR>"
		dat += "<HR><A href='?src=\ref[src];lock=1'>Lock Console</A>"

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
	if(href_list["inject1"])
		var/obj/item/weapon/implant/I = locate(href_list["inject1"])
		if(I)	I.activate(1)

	else if(href_list["inject5"])
		var/obj/item/weapon/implant/I = locate(href_list["inject5"])
		if(I)	I.activate(5)

	else if(href_list["inject10"])
		var/obj/item/weapon/implant/I = locate(href_list["inject10"])
		if(I)	I.activate(10)

	else if(href_list["lock"])
		if(allowed(usr))
			screen = !screen
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["warn"])
		var/warning = sanitize(input(usr,"Message:","Enter your message here!",""))
		if(!warning) return
		var/obj/item/weapon/implant/I = locate(href_list["warn"])
		if((I)&&(I.imp_in))
			var/mob/living/carbon/R = I.imp_in
			to_chat(R, "<span class='notice'>You hear a voice in your head saying: '[warning]'</span>")

	updateUsrDialog()

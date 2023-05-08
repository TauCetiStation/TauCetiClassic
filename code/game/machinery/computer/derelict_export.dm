/obj/machinery/computer/export
	name = "export console"
	desc = "No questions asked and zero fee."
	icon_state = "export"
	light_color = "#ff7f01"
	allowed_checks = ALLOWED_CHECK_NONE
	var/obj/machinery/export_pad/pad = null
	var/holding_credits = 0

/obj/machinery/computer/export/atom_init()
	. = ..()
	pad = locate(/obj/machinery/export_pad) in range(2, src)

/obj/machinery/computer/export/ui_interact(mob/user)
	var/dat = ""

	dat += "<center><h1>FTU Export Outpost TO-11312</h4></center>"
	dat += "<center><h3>Welcome, dear customer!</h3></center>"
	if(!pad)
		dat+="<center><h3><span class='red'>Bluespace export pad is missing! Contact your local maintenance technician.</span></h3></center>"
	else
		dat += "<br><center><h3><a href='byond://?src=\ref[src];sell=1'>SELL</a> <a href='byond://?src=\ref[src];withdraw=1'>WITHDRAW</a></h3></center>"
		dat += "<center><h3>Credits on hold: [holding_credits ? " <span class='green'><b>[holding_credits]</b></span>" : "<span class='red'><b>0 :(</b></span>"]</h3></center>"
	var/datum/browser/popup = new(user, "export", "Free Trade Union", ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/export/Topic(href, href_list)
	. = ..()
	if(!. || !pad)
		return

	if(href_list["sell"])
		var/turf/simulated/floor/F = get_turf(pad)
		for(var/obj/item/I in F)
			holding_credits += I.price
			qdel(I)

	if(href_list["withdraw"])
		if(!holding_credits)
			return
		var/turf/simulated/floor/F = get_turf(pad)
		spawn_money(holding_credits, F)
		holding_credits = 0

	updateUsrDialog()

/obj/machinery/export_pad
	name = "export bluespace pad"
	desc = "Put your goods here!"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle_old"
	anchored = TRUE

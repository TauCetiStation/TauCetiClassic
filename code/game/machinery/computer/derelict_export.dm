/obj/machinery/computer/export
	name = "export console"
	icon_state = "dna"
	light_color = "#315ab4"
	circuit = /obj/item/weapon/circuitboard/cloning
	allowed_checks = ALLOWED_CHECK_NONE
	var/obj/machinery/export_pad/pad = null


/obj/machinery/computer/export/atom_init()
	. = ..()
	var/obj/machinery/export_pad/pad = locate(/obj/machinery/export_pad) in range(2, src)

	if(!isnull(pad))
		return

/obj/machinery/computer/export/ui_interact(mob/user)
	var/dat

	dat += "<center><h4>Export Outpost TO-11312</h4></center>"

	dat += "<br><center><h3>Welcome, dear customer!</h3></center>"

	dat += "<br><center><h5><a href='byond://?src=\ref[src];sell=1'>!!!SELL!!!</a></h5></center>"

	var/datum/browser/popup = new(user, "export", "[name]", ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/export/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if (href_list["sell"])
		var/turf/simulated/floor/F = pad.get_turf()
		for(var/obj/item/I in F)
			qdel(I)


/obj/machinery/export_pad
	name = "export bluespace pad"
	desc = "Put your goods here!"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-beam_old"
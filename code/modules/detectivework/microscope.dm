/obj/machinery/microscope
	name = "microscope"
	desc = "A high-tech microscope that can magnify images up to 3,000 times. Used for analyzing forensic samples like swabs, bags with fiber and fingerprint tape."
	icon = 'icons/obj/detective_work.dmi'
	icon_state = "microscope"
	anchored = TRUE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 40

	var/obj/item/sample = null
	var/report_num = 0
	var/scanning = FALSE

/obj/machinery/microscope/atom_init(mapload)
	. = ..()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/microscope(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)

	RefreshParts()
	update_icon()

/obj/machinery/microscope/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/swab) || istype(O, /obj/item/weapon/forensic_sample/fibers) || istype(O, /obj/item/weapon/forensic_sample/print))
		if(panel_open)
			to_chat(user, "<span class='warning'>The panel is open!</span>")
			return
		if(sample)
			to_chat(user, "<span class='warning'>There is already a sample in the microscope!</span>")
			return
		add_fingerprint(user)
		to_chat(user, "<span class='notice'>You put [O] inside the microscope.</span>")
		user.unEquip(O)
		O.forceMove(src)
		sample = O
		update_icon()
		return

	if(exchange_parts(user, O))
		return

	default_deconstruction_crowbar(O)

	if(default_deconstruction_screwdriver(user, "microscope_off", "microscope", O))
		if(sample)
			sample.forceMove(get_turf(src))
			sample = null
		return

	update_icon()

	return ..()

/obj/machinery/microscope/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/weapon/I)
	if(scanning)
		to_chat(user, "<span class='warning'>The microscope is currently busy scanning!</span>")
	else
		..()

/obj/machinery/microscope/attack_hand(mob/living/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>The panel is open!</span>")
		return
	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>There is no power!</span>")
		return
	if(!sample)
		to_chat(user, "<span class='warning'>There is no sample in the microscope!</span>")
		return
	if(scanning)
		to_chat(user, "<span class='warning'>The microscope is currently scanning!</span>")
		return
	add_fingerprint(user)
	to_chat(user, "<span class='notice'>Microscope buzzes while you start analyzing the [sample].</span>")

	scanning = TRUE
	if(!do_after(user, 2 SECONDS, target = user))
		scanning = FALSE
		return
	scanning = FALSE
	if(!sample)
		to_chat(user, "<span class='warning'>There is no sample!</span>")
		return
	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>There is no power!</span>")
		return
	visible_message("<span class='notice'>Microscope starts printing a report.</span>")
	var/obj/item/weapon/paper/report = new(get_turf(src))
	report_num++

	if(istype(sample, /obj/item/weapon/swab))
		var/obj/item/weapon/swab/swab = sample

		report.name = ("Forensic Report №[report_num]: [swab.name]")
		report.info = "<b>Object analyzed:</b><br>[swab.name]<br><br>"
		//dna data itself
		var/data = "No data to analyze."
		if(swab.dna != null)
			data = "Spectrometric analysis of the provided sample revealed the presence of DNA strands in the amount of [swab.dna.len].<br><br>"
			for(var/blood in swab.dna)
				data += "<span class='notice'>Blood type: [swab.dna[blood]]<br>\nDNA: [blood]</span><br><br>"
		else
			data += "\nNo DNA found.<br>"
		report.info += data
	else if(istype(sample, /obj/item/weapon/forensic_sample/fibers))
		var/obj/item/weapon/forensic_sample/fibers/fibers = sample
		report.name = ("Forensic Report №[report_num]: [fibers.name]")
		report.info = "<b>Object analyzed:</b><br>[fibers.name]<br><br>"
		if(fibers.evidence)
			report.info += "<br>A molecular analysis of the provided sample revealed the presence of unique fiber strings.<br><br>"
			for(var/fiber in fibers.evidence)
				report.info += "<span class='notice'>The most likely match: [fiber]</span><br><br>"
		else
			report.info += "No fibers found."
	else if(istype(sample, /obj/item/weapon/forensic_sample/print))
		var/obj/item/weapon/forensic_sample/print/print = sample
		report.name = ("Forensic Report №[report_num]: [print.name]")
		report.info = "<b>Object analyzed:</b><br>[print.name]<br><br>"
		if(print.evidence && print.evidence.len)
			report.info += "<br>A surface analysis identified the following unique fingerprint strings:<br><br>"
			for(var/prints in print.evidence)
				report.info += "<span class='notice'>Fingerprint: </span>"
				report.info += "[prints]"
				report.info += "<br>"
		else
			report.info += "There is no information about the analysis."

	if(report)
		report.update_icon()
	if(sample)
		sample.forceMove(get_turf(src))
		sample = null
		update_icon()

/obj/machinery/microscope/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || remover.incapacitated() || !Adjacent(remover))
		return
	if(!sample)
		to_chat(remover, "<span class='warning'>There is no sample in the microscope!</span>")
		return
	if(scanning)
		to_chat(remover, "<span class='warning'>The microscope is currently scanning!</span>")
		return
	to_chat(remover, "<span class='notice'>You remove [sample] from the microscope.</span>")
	sample.forceMove(get_turf(src))
	remover.put_in_hands(sample)
	sample = null
	update_icon()

/obj/machinery/microscope/MouseDrop(atom/other)
	if(usr == other)
		remove_sample(usr)
	else
		return ..()

/obj/machinery/microscope/update_icon()
	icon_state = "microscope"
	if(panel_open || stat & NOPOWER)
		icon_state += "_off"
	if(sample)
		icon_state += "_slide"

/obj/machinery/microscope/power_change()
	..()
	update_icon()

/obj/machinery/microscope/Destroy()
	. = ..()
	if(sample)
		sample.forceMove(get_turf(src))
		sample = null

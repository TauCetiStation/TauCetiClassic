
/obj/machinery/artifact_analyser
	name = "Anomaly Analyser"
	desc = "Studies the emissions of anomalous materials to discover their uses."
	icon = 'icons/obj/xenoarchaeology/machinery.dmi'
	icon_state = "xenoarch_console"
	anchored = TRUE
	density = FALSE
	var/scan_in_progress = FALSE
	var/scan_num = 0
	var/obj/scanned_obj
	var/obj/machinery/artifact_scanpad/owned_scanner = null
	var/scan_completion_time = 0
	var/scan_duration = 100
	var/obj/scanned_object
	var/report_num = 0

/obj/machinery/artifact_analyser/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/artifact_analyser/atom_init_late()
	reconnect_scanner()

/obj/machinery/artifact_analyser/proc/reconnect_scanner()
	//connect to a nearby scanner pad
	owned_scanner = locate(/obj/machinery/artifact_scanpad) in get_step(src, dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/artifact_scanpad) in orange(1, src)

/obj/machinery/artifact_analyser/ui_interact(mob/user)
	if(stat & (NOPOWER|BROKEN) || !in_range(src, user) && !issilicon(user) && !isobserver(user))
		user.unset_machine(src)
		return

	var/dat = "<B>Anomalous material analyser</B><BR>"
	dat += "<HR>"
	if(!owned_scanner)
		owned_scanner = locate() in orange(1, src)

	if(!owned_scanner)
		dat += "<b><font color=red>Unable to locate analysis pad.</font></b><br>"
	else if(scan_in_progress)
		dat += "Please wait. Analysis in progress.<br>"
		dat += "<a href='?src=\ref[src];halt_scan=1'>Halt scanning.</a><br>"
	else
		dat += "Scanner is ready.<br>"
		dat += "<a href='?src=\ref[src];begin_scan=1'>Begin scanning.</a><br>"

	dat += "<br>"
	dat += "<hr>"
	dat += "<a href='?src=\ref[src]'>Refresh</a> <a href='?src=\ref[src];close=1'>Close</a>"

	var/datum/browser/popup = new(user, "artanalyser", name, 450, 500)
	popup.set_content(dat)
	popup.open()


/obj/machinery/artifact_analyser/process()
	if(scan_in_progress && world.time > scan_completion_time)
		// finish scanning
		scan_in_progress = FALSE
		updateDialog()

		// print results
		var/results = ""
		if(!owned_scanner)
			reconnect_scanner()
		if(!owned_scanner)
			results = "Error communicating with scanner."
			playsound(src, 'sound/machines/buzz-two.ogg', 20, 1)
		else if(!scanned_object || scanned_object.loc != owned_scanner.loc)
			results = "Unable to locate scanned object. Ensure it was not moved in the process."
			playsound(src, 'sound/machines/buzz-two.ogg', 20, 1)
		else
			results = get_scan_info(scanned_object)
		owned_scanner.icon_state = "xenoarch_scanner"
		src.visible_message("<b>[name]</b> states, \"Scanning complete.\"")
		var/obj/item/weapon/paper/P = new(src.loc)
		P.name = "[src] report #[++report_num]"
		P.info = "<b>[src] analysis report #[report_num]</b><br>"
		P.info += "<br>"
		P.info += "[bicon(scanned_object)] [results]"
		P.update_icon()

		var/obj/item/weapon/stamp/S = new
		S.stamp_paper(P)
		playsound(src, 'sound/items/polaroid1.ogg', 50, 1)

		if(scanned_object && istype(scanned_object, /obj/machinery/artifact))
			var/obj/machinery/artifact/A = scanned_object
			A.being_used = 0

/obj/machinery/artifact_analyser/Topic(href, href_list)
	if(href_list["close"])
		playsound(src, "keyboard", 50, 0)
		usr.unset_machine(src)
		usr << browse(null, "window=artanalyser")
		return FALSE

	. = ..()
	if(!.)
		return

	if(href_list["begin_scan"])
		playsound(src, "keyboard", 50, 0)
		if(!owned_scanner)
			reconnect_scanner()
		if(owned_scanner)
			var/artifact_in_use = 0
			for(var/obj/O in owned_scanner.loc)
				if(O == owned_scanner)
					continue
				if(O.invisibility)
					continue
				if(istype(scanned_object, /obj/machinery/artifact))
					var/obj/machinery/artifact/A = scanned_object
					if(A.being_used)
						artifact_in_use = 1
					else
						A.being_used = 1

				if(artifact_in_use)
					src.visible_message("<b>[name]</b> states, \"Cannot harvest. Too much interference.\"")
					playsound(src, 'sound/machines/buzz-two.ogg', 20, 1)
				else
					scanned_object = O
					scan_in_progress = 1
					scan_completion_time = world.time + scan_duration
					src.visible_message("<b>[name]</b> states, \"Scanning begun.\"")
					owned_scanner.icon_state = "xenoarch_scanner_scanning"
					flick("xenoarch_console_working", src)
				break
			if(!scanned_object)
				src.visible_message("<b>[name]</b> states, \"Unable to isolate scan target.\"")
	if(href_list["halt_scan"])
		playsound(src, "keyboard", 50, 0)
		owned_scanner.icon_state = "xenoarch_scanner"
		scan_in_progress = 0
		src.visible_message("<b>[name]</b> states, \"Scanning halted.\"")

	updateDialog()

// hardcoded responses, oh well
/obj/machinery/artifact_analyser/proc/get_scan_info(obj/scanned_obj)
	switch(scanned_obj.type)
		if(/obj/item/clothing/glasses/hud/mining/ancient)
			return "A heads-up display that scans the rocks in view and provides some data about their composition."
		if(/obj/machinery/auto_cloner)
			return "Automated cloning pod - appears to rely on organic nanomachines with a self perpetuating \
			ecosystem involving self cannibalism and a symbiotic relationship with the contained liquid.<br><br>\
			Structure is composed of a carbo-titanium alloy with interlaced reinforcing energy fields, and the contained liquid \
			resembles proto-plasmic residue supportive of single cellular developmental conditions."
		if(/obj/machinery/power/supermatter)
			return "Super dense phoron clump - Appears to have been shaped or hewn, structure is composed of matter 2000% denser than ordinary carbon matter residue.\
			Potential application as unrefined phoron source."
		if(/obj/machinery/power/supermatter)
			return "Super dense phoron clump - Appears to have been shaped or hewn, structure is composed of matter 2000% denser than ordinary carbon matter residue.\
			Potential application as unrefined phoron source."
		if(/obj/structure/constructshell)
			return "Tribal idol - Item resembles statues/emblems built by superstitious pre-warp civilisations to honour their gods. Material appears to be a \
			rock/plastcrete composite."
		if(/obj/machinery/giga_drill)
			return "Automated mining drill - structure composed of titanium-carbide alloy, with tip and drill lines edged in an alloy of diamond and phoron."
		if(/obj/structure/cult/pylon)
			return "Tribal pylon - Item resembles statues/emblems built by cargo cult civilisations to honour energy systems from post-warp civilisations."
		if(/obj/mecha/working/hoverpod)
			return "Vacuum capable repair pod - Item is a remarkably intact single man repair craft capable of flight in a vacuum. Outer shell composed of primarily \
			post-warp hull alloys, with internal wiring and circuitry consistent with modern electronics and engineering."
		if(/obj/machinery/replicator)
			return "Automated construction unit - Item appears to be able to synthesize synthetic items, some with simple internal circuitry. Method unknown, \
			phasing suggested?"
		if(/obj/machinery/power/crystal)
			return "Crystal formation - Pseudo organic crystalline matrix, unlikely to have formed naturally. No known technology exists to synthesize this exact composition. \
			Attention: energetic excitement is noticed. The appearance of current is possible. Connect the crystal to the network, using wrench and wires on it. Make sure there is a cable underneath."
		if(/obj/machinery/artifact)
			// the fun one
			var/obj/machinery/artifact/A = scanned_obj
			var/out = "Anomalous alien device - Composed of an unknown alloy, "

			// primary effect
			if(A.my_effect)
				// what kind of effect the artifact has
				switch(A.my_effect.effect_type)
					if(1)
						out += "concentrated energy emissions"
					if(2)
						out += "intermittent psionic wavefront"
					if(3)
						out += "electromagnetic energy"
					if(4)
						out += "high frequency particles"
					if(5)
						out += "organically reactive exotic particles"
					if(6)
						out += "interdimensional/bluespace? phasing"
					if(7)
						out += "atomic synthesis"
					else
						out += "low level energy emissions"
				out += " have been detected "

				// how the artifact does it's effect
				switch(A.my_effect.effect)
					if(1)
						out += " emitting in an ambient energy field."
					if(2)
						out += " emitting in periodic bursts."
					else
						out += " interspersed throughout substructure and shell."

				if(A.my_effect.trigger >= 0 && A.my_effect.trigger <= 4)
					out += " Activation index involves physical interaction with artifact surface."
				else if(A.my_effect.trigger >= 5 && A.my_effect.trigger <= 8)
					out += " Activation index involves energetic interaction with artifact surface."
				else if(A.my_effect.trigger >= 9 && A.my_effect.trigger <= 12)
					out += " Activation index involves precise local atmospheric conditions."
				else
					out += " Unable to determine any data about activation trigger."

			// secondary:
			if(A.secondary_effect && A.secondary_effect.activated)
				// sciencey words go!
				out += "<br><br>Warning, internal scans indicate ongoing [pick("subluminous","subcutaneous","superstructural")] activity operating \
				independantly from primary systems. Auxiliary activity involves "

				// what kind of effect the artifact has
				switch(A.secondary_effect.effect_type)
					if(1)
						out += "concentrated energy emissions"
					if(2)
						out += "intermittent psionic wavefront"
					if(3)
						out += "electromagnetic energy"
					if(4)
						out += "high frequency particles"
					if(5)
						out += "organically reactive exotic particles"
					if(6)
						out += "interdimensional/bluespace? phasing"
					if(7)
						out += "atomic synthesis"
					else
						out += "low level radiation"

				// how the artifact does it's effect
				switch(A.secondary_effect.effect)
					if(1)
						out += " emitting in an ambient energy field."
					if(2)
						out += " emitting in periodic bursts."
					else
						out += " interspersed throughout substructure and shell."

				if(A.secondary_effect.trigger >= 0 && A.secondary_effect.trigger <= 4)
					out += " Activation index involves physical interaction with artifact surface, but subsystems indicate \
					anomalous interference with standard attempts at triggering."
				else if(A.secondary_effect.trigger >= 5 && A.secondary_effect.trigger <= 8)
					out += " Activation index involves energetic interaction with artifact surface, but subsystems indicate \
					anomalous interference with standard attempts at triggering."
				else if(A.secondary_effect.trigger >= 9 && A.secondary_effect.trigger <= 12)
					out += " Activation index involves precise local atmospheric conditions, but subsystems indicate \
					anomalous interference with standard attempts at triggering."
				else
					out += " Unable to determine any data about activation trigger."
			return out
		else
			// it was an ordinary item
			return "[scanned_obj.name] - Mundane application, composed of carbo-ferritic alloy composite."

// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/locked
	name = "Body Scanner"
	desc = "Used for a more detailed analysis of the patient."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1
	light_color = "#00FF00"

/obj/machinery/bodyscanner/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/bodyscanner/relaymove(mob/user)
	if(!user.stat)
		open_machine()

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if (usr.stat != CONSCIOUS)
		return
	open_machine()
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if (usr.stat != CONSCIOUS || usr.lying)
		return
	if(!move_inside_checks(usr, usr))
		return
	close_machine(usr, usr)

/obj/machinery/bodyscanner/proc/move_inside_checks(mob/target, mob/user)
	if(occupant)
		to_chat(user, "<span class='userdanger'>The scanner is already occupied!</span>")
		return FALSE
	if(!iscarbon(target))
		return FALSE
	if(target.abiotic())
		to_chat(user, "<span class='userdanger'>Subject cannot have abiotic items on.</span>")
		return FALSE
	return TRUE

/obj/machinery/bodyscanner/attackby(obj/item/weapon/grab/G, mob/user)
	if(!istype(G))
		return
	if(!move_inside_checks(G.affecting, user))
		return
	add_fingerprint(user)
	close_machine(G.affecting)
	playsound(src, 'sound/machines/analysis.ogg', 40, 0)
	qdel(G)

/obj/machinery/bodyscanner/update_icon()
	icon_state = "body_scanner_[occupant ? "1" : "0"]"

/obj/machinery/bodyscanner/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user))
		return
	if(!iscarbon(user) && !isrobot(user))
		return
	if(!move_inside_checks(target, user))
		return
	add_fingerprint(user)
	close_machine(target)
	playsound(src, 'sound/machines/analysis.ogg', 40, 0)

/obj/machinery/bodyscanner/ex_act(severity)
	var/should_destroy = FALSE
	switch(severity)
		if(1.0)
			should_destroy = TRUE
		if(2.0)
			if(prob(50))
				should_destroy = TRUE
		if(3.0)
			if(prob(25))
				should_destroy = TRUE
	if(should_destroy)
		for(var/atom/movable/A in src)
			A.forceMove(loc)
			ex_act(severity)
		qdel(src)

/obj/machinery/bodyscanner/blob_act()
	if(prob(50))
		for(var/atom/movable/A in src)
			A.forceMove(loc)
		qdel(src)

/obj/machinery/body_scanconsole/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				qdel(src)

/obj/machinery/body_scanconsole/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/body_scanconsole/power_change()
	if(stat & BROKEN)
		icon_state = "body_scannerconsole-p"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "body_scannerconsole-p"
			stat |= NOPOWER

/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/mindshield, /obj/item/weapon/implant/tracking, /obj/item/weapon/implant/mindshield/loyalty)
	var/delete
	var/temphtml
	name = "Body Scanner Console"
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scannerconsole"
	anchored = 1
	var/next_print = 0
	var/storedinfo = null


/obj/machinery/body_scanconsole/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/body_scanconsole/atom_init_late()
	connected = locate(/obj/machinery/bodyscanner, get_step(src, WEST))

/*

/obj/machinery/body_scanconsole/process() //not really used right now
	if(stat & (NOPOWER|BROKEN))
		return
	//use_power(250) // power stuff

//	var/mob/M //occupant
//	if (!( src.status )) //remove this
//		return
//	if ((src.connected && src.connected.occupant)) //connected & occupant ok
//		M = src.connected.occupant
//	else
//		if (istype(M, /mob))
//		//do stuff
//		else
///			src.temphtml = "Process terminated due to lack of occupant in scanning chamber."
//			src.status = null
//	src.updateDialog()
//	return

*/


/obj/machinery/body_scanconsole/ui_interact(mob/user)
	if(!ishuman(connected.occupant))
		to_chat(user, "\red This device can only scan compatible lifeforms.")
		return

	var/dat

	if (src.delete && src.temphtml) //Window in buffer but its just simple message, so nothing
		src.delete = src.delete
	else if (!src.delete && src.temphtml) //Window in buffer - its a menu, dont add clear message
		dat = text("[]<BR><BR><A href='?src=\ref[];clear=1'>Main Menu</A>", src.temphtml, src)
	else
		if (src.connected) //Is something connected?
			var/mob/living/carbon/human/occupant = src.connected.occupant
			dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>" //Blah obvious
			if (istype(occupant)) //is there REALLY someone in there?
				var/t1
				switch(occupant.stat) // obvious, see what their status is
					if(0)
						t1 = "Conscious"
					if(1)
						t1 = "Unconscious"
					else
						t1 = "*dead*"
				if (!istype(occupant,/mob/living/carbon/human))
					dat += "<font color='red'>This device can only scan human occupants.</FONT>"
				else
					dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)

					//if(occupant.mind && occupant.mind.changeling && occupant.status_flags & FAKEDEATH)
					if(occupant.mind && occupant.mind.changeling && occupant.fake_death)
						dat += text("<font color='red'>Abnormal bio-chemical activity detected!</font><BR>")

					if(occupant.virus2.len)
						dat += text("<font color='red'>Viral pathogen detected in blood stream.</font><BR>")

					dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
					dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
					dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
					dat += text("[]\t-Burn Severity %: []</FONT><BR><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())

					dat += text("[]\tRadiation Level %: []</FONT><BR>", (occupant.radiation < 10 ?"<font color='blue'>" : "<font color='red'>"), occupant.radiation)
					dat += text("[]\tGenetic Tissue Damage %: []</FONT><BR>", (occupant.getCloneLoss() < 1 ?"<font color='blue'>" : "<font color='red'>"), occupant.getCloneLoss())
					dat += text("[]\tApprox. Brain Damage %: []</FONT><BR>", (occupant.getBrainLoss() < 1 ?"<font color='blue'>" : "<font color='red'>"), occupant.getBrainLoss())
					dat += text("Paralysis Summary %: [] ([] seconds left!)<BR>", occupant.paralysis, round(occupant.paralysis / 4))
					dat += text("Body Temperature: [occupant.bodytemperature-T0C]&deg;C ([occupant.bodytemperature*1.8-459.67]&deg;F)<BR><HR>")

					if(occupant.has_brain_worms())
						dat += "Large growth detected in frontal lobe, possibly cancerous. Surgical removal is recommended.<BR/>"

					if(occupant.vessel)
						var/blood_volume = round(occupant.vessel.get_reagent_amount("blood"))
						var/blood_percent =  blood_volume / 560
						blood_percent *= 100
						dat += text("[]\tBlood Level %: [] ([] units)</FONT><BR>", (blood_volume > 448 ?"<font color='blue'>" : "<font color='red'>"), blood_percent, blood_volume)
					if(occupant.reagents)
						dat += text("Inaprovaline units: [] units<BR>", occupant.reagents.get_reagent_amount("inaprovaline"))
						dat += text("Soporific (Sleep Toxin): [] units<BR>", occupant.reagents.get_reagent_amount("stoxin"))
						dat += text("[]\tDermaline: [] units</FONT><BR>", (occupant.reagents.get_reagent_amount("dermaline") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("dermaline"))
						dat += text("[]\tBicaridine: [] units<BR>", (occupant.reagents.get_reagent_amount("bicaridine") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("bicaridine"))
						dat += text("[]\tDexalin: [] units<BR>", (occupant.reagents.get_reagent_amount("dexalin") < 30 ? "<font color='black'>" : "<font color='red'>"), occupant.reagents.get_reagent_amount("dexalin"))

					for(var/datum/disease/D in occupant.viruses)
						if(!D.hidden[SCANNER])
							dat += text("<font color='red'><B>Warning: [D.form] Detected</B>\nName: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</FONT><BR>")

					dat += "<HR><A href='?src=\ref[src];print=1'>Print body parts report</A><BR>"
					storedinfo = null
					dat += "<HR><table border='1'>"
					dat += "<tr>"
					dat += "<th>Body Part</th>"
					dat += "<th>Burn Damage</th>"
					dat += "<th>Brute Damage</th>"
					dat += "<th>Other Wounds</th>"
					dat += "</tr>"
					storedinfo += "<HR><table border='1'>"
					storedinfo += "<tr>"
					storedinfo += "<th>Body Part</th>"
					storedinfo += "<th>Burn Damage</th>"
					storedinfo += "<th>Brute Damage</th>"
					storedinfo += "<th>Other Wounds</th>"
					storedinfo += "</tr>"

					for(var/obj/item/organ/external/BP in occupant.bodyparts)

						dat += "<tr>"
						storedinfo += "<tr>"
						var/AN = ""
						var/open = ""
						var/infected = ""
						var/imp = ""
						var/bled = ""
						var/robot = ""
						var/splint = ""
						var/arterial_bleeding = ""
						var/lung_ruptured = ""
						if(BP.status & ORGAN_ARTERY_CUT)
							arterial_bleeding = "<br>Arterial bleeding"
						if(istype(BP, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
							lung_ruptured = "Lung ruptured:"
						if(BP.status & ORGAN_SPLINTED)
							splint = "Splinted:"
						if(BP.status & ORGAN_BLEEDING)
							bled = "Bleeding:"
						if(BP.status & ORGAN_BROKEN)
							AN = "[BP.broken_description]:"
						if(BP.status & ORGAN_ROBOT)
							robot = "Prosthetic:"
						if(BP.open)
							open = "Open:"
						switch (BP.germ_level)
							if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE_PLUS)
								infected = "Mild Infection:"
							if (INFECTION_LEVEL_ONE_PLUS to INFECTION_LEVEL_ONE_PLUS_PLUS)
								infected = "Mild Infection+:"
							if (INFECTION_LEVEL_ONE_PLUS_PLUS to INFECTION_LEVEL_TWO)
								infected = "Mild Infection++:"
							if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO_PLUS)
								infected = "Acute Infection:"
							if (INFECTION_LEVEL_TWO_PLUS to INFECTION_LEVEL_TWO_PLUS_PLUS)
								infected = "Acute Infection+:"
							if (INFECTION_LEVEL_TWO_PLUS_PLUS to INFECTION_LEVEL_THREE)
								infected = "Acute Infection++:"
							if (INFECTION_LEVEL_THREE to INFINITY)
								infected = "Septic:"

						var/unknown_body = 0
						for(var/I in BP.implants)
							if(is_type_in_list(I,known_implants))
								imp += "[I] implanted:"
							else
								unknown_body++

						if(unknown_body || BP.hidden)
							imp += "Unknown body present:"
						if(!AN && !open && !infected & !imp)
							AN = "None:"
						if(!(BP.status & ORGAN_DESTROYED))
							dat += "<td>[BP.name]</td><td>[BP.burn_dam]</td><td>[BP.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][arterial_bleeding][lung_ruptured]</td>"
							storedinfo += "<td>[BP.name]</td><td>[BP.burn_dam]</td><td>[BP.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][arterial_bleeding][lung_ruptured]</td>"
						else
							dat += "<td>[BP.name]</td><td>-</td><td>-</td><td>Not Found</td>"
							storedinfo += "<td>[BP.name]</td><td>-</td><td>-</td><td>Not Found</td>"
						dat += "</tr>"
						storedinfo += "</tr>"
					for(var/obj/item/organ/internal/IO in occupant.organs)
						var/mech = ""
						if(IO.robotic == 1)
							mech = "Assisted:"
						if(IO.robotic == 2)
							mech = "Mechanical:"

						var/infection = "None"
						switch (IO.germ_level)
							if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE_PLUS)
								infection = "Mild Infection:"
							if (INFECTION_LEVEL_ONE_PLUS to INFECTION_LEVEL_ONE_PLUS_PLUS)
								infection = "Mild Infection+:"
							if (INFECTION_LEVEL_ONE_PLUS_PLUS to INFECTION_LEVEL_TWO)
								infection = "Mild Infection++:"
							if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO_PLUS)
								infection = "Acute Infection:"
							if (INFECTION_LEVEL_TWO_PLUS to INFECTION_LEVEL_TWO_PLUS_PLUS)
								infection = "Acute Infection+:"
							if (INFECTION_LEVEL_TWO_PLUS_PLUS to INFECTION_LEVEL_THREE)
								infection = "Acute Infection++:"
							if (INFECTION_LEVEL_THREE to INFINITY)
								infection = "Necrotic:"

						dat += "<tr>"
						dat += "<td>[IO.name]</td><td>N/A</td><td>[IO.damage]</td><td>[infection]:[mech]</td><td></td>"
						dat += "</tr>"
						storedinfo += "<tr>"
						storedinfo += "<td>[IO.name]</td><td>N/A</td><td>[IO.damage]</td><td>[infection]:[mech]</td><td></td>"
						storedinfo += "</tr>"
					dat += "</table>"
					storedinfo += "</table>"
					if(occupant.sdisabilities & BLIND)
						dat += text("<font color='red'>Cataracts detected.</font><BR>")
						storedinfo += text("<font color='red'>Cataracts detected.</font><BR>")
					if(occupant.sdisabilities & NEARSIGHTED)
						dat += text("<font color='red'>Retinal misalignment detected.</font><BR>")
						storedinfo += text("<font color='red'>Retinal misalignment detected.</font><BR>")
			else
				dat += "\The [src] is empty."
		else
			dat = "<font color='red'> Error: No Body Scanner connected.</font>"
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=scanconsole'>Close</A>", user)
	user << browse(entity_ja(dat), "window=scanconsole;size=430x600")

/obj/machinery/body_scanconsole/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list["print"])
		if (next_print < world.time) //10 sec cooldown
			next_print = world.time + 10 SECONDS
			to_chat(usr, "<span class='notice'>Printing... Please wait.</span>")
			playsound(src, 'sound/items/polaroid1.ogg', 20, 0)
			addtimer(CALLBACK(src, .proc/print_scan, storedinfo), 1 SECOND)
		else
			to_chat(usr, "<span class='notice'>The console can't print that fast!</span>")

/obj/machinery/body_scanconsole/proc/print_scan(additional_info)
	var/obj/item/weapon/paper/P = new(loc)
	if(!connected || !connected.occupant) // If while we were printing the occupant got out or our thingy did a boom.
		return
	var/mob/living/carbon/human/occupant = connected.occupant
	var/t1 = "<B>[occupant ? occupant.name : "Unknown"]'s</B> advanced scanner report.<BR>"
	t1 += "Station Time: <B>[worldtime2text()]</B><BR>"
	switch(occupant.stat) // obvious, see what their status is
		if(CONSCIOUS)
			t1 += "Status: <B>Conscious</B>"
		if(UNCONSCIOUS)
			t1 += "Status: <B>Unconscious</B>"
		else
			t1 += "Status: <B>\red*dead*</B>"
	t1 += additional_info
	P.info = t1
	P.name = "[occupant.name]'s scanner report"
	P.update_icon()

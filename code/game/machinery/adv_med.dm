// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/locked
	name = "Body Scanner"
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1

	light_color = "#00FF00"

	power_change()
		..()
		if(!(stat & (BROKEN|NOPOWER)))
			set_light(2)
		else
			set_light(0)

/*/obj/machinery/bodyscanner/allow_drop()
	return 0*/

/obj/machinery/bodyscanner/relaymove(mob/user)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if (usr.stat != CONSCIOUS)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if (usr.stat != CONSCIOUS)
		return
	if (src.occupant)
		to_chat(usr, "\blue <B>The scanner is already occupied!</B>")
		return
	if (usr.abiotic())
		to_chat(usr, "\blue <B>Subject cannot have abiotic items on.</B>")
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "body_scanner_1"
	for(var/obj/O in src)
		//O = null
		qdel(O)
		//Foreach goto(124)
	src.add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(30)
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "body_scanner_0"
	return

/obj/machinery/bodyscanner/attackby(obj/item/weapon/grab/G, user)
	if ((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if (src.occupant)
		to_chat(user, "\blue <B>The scanner is already occupied!</B>")
		return
	if (G.affecting.abiotic())
		to_chat(user, "\blue <B>Subject cannot have abiotic items on.</B>")
		return
	var/mob/M = G.affecting
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	src.icon_state = "body_scanner_1"
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(154)
	src.add_fingerprint(user)
	//G = null
	qdel(G)
	return

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				qdel(src)
				return
		else
	return

/obj/machinery/bodyscanner/blob_act()
	if(prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		qdel(src)

/obj/machinery/body_scanconsole/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		else
	return

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
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/loyalty, /obj/item/weapon/implant/tracking)
	var/delete
	var/temphtml
	name = "Body Scanner Console"
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scannerconsole"
	anchored = 1
	var/latestprint = 0
	var/storedinfo = null


/obj/machinery/body_scanconsole/New()
	..()
	spawn( 5 )
		src.connected = locate(/obj/machinery/bodyscanner, get_step(src, WEST))
		return
	return

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


/obj/machinery/body_scanconsole/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/body_scanconsole/attack_hand(mob/user)
	if(..())
		return
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

					dat += "<HR><A href='?src=\ref[src];print=1'>Print organs report</A><BR>"
					storedinfo = null
					dat += "<HR><table border='1'>"
					dat += "<tr>"
					dat += "<th>Organ</th>"
					dat += "<th>Burn Damage</th>"
					dat += "<th>Brute Damage</th>"
					dat += "<th>Other Wounds</th>"
					dat += "</tr>"
					storedinfo += "<HR><table border='1'>"
					storedinfo += "<tr>"
					storedinfo += "<th>Organ</th>"
					storedinfo += "<th>Burn Damage</th>"
					storedinfo += "<th>Brute Damage</th>"
					storedinfo += "<th>Other Wounds</th>"
					storedinfo += "</tr>"

					for(var/datum/organ/external/e in occupant.organs)

						dat += "<tr>"
						storedinfo += "<tr>"
						var/AN = ""
						var/open = ""
						var/infected = ""
						var/imp = ""
						var/bled = ""
						var/robot = ""
						var/splint = ""
						var/internal_bleeding = ""
						var/lung_ruptured = ""
						for(var/datum/wound/W in e.wounds) if(W.internal)
							internal_bleeding = "<br>Internal bleeding"
							break
						if(istype(e, /datum/organ/external/chest) && occupant.is_lung_ruptured())
							lung_ruptured = "Lung ruptured:"
						if(e.status & ORGAN_SPLINTED)
							splint = "Splinted:"
						if(e.status & ORGAN_BLEEDING)
							bled = "Bleeding:"
						if(e.status & ORGAN_BROKEN)
							AN = "[e.broken_description]:"
						if(e.status & ORGAN_ROBOT)
							robot = "Prosthetic:"
						if(e.open)
							open = "Open:"
						switch (e.germ_level)
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
						for(var/I in e.implants)
							if(is_type_in_list(I,known_implants))
								imp += "[I] implanted:"
							else
								unknown_body++

						if(unknown_body || e.hidden)
							imp += "Unknown body present:"
						if(!AN && !open && !infected & !imp)
							AN = "None:"
						if(!(e.status & ORGAN_DESTROYED))
							dat += "<td>[e.display_name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured]</td>"
							storedinfo += "<td>[e.display_name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured]</td>"
						else
							dat += "<td>[e.display_name]</td><td>-</td><td>-</td><td>Not Found</td>"
							storedinfo += "<td>[e.display_name]</td><td>-</td><td>-</td><td>Not Found</td>"
						dat += "</tr>"
						storedinfo += "</tr>"
					for(var/datum/organ/internal/i in occupant.internal_organs)
						var/mech = ""
						if(i.robotic == 1)
							mech = "Assisted:"
						if(i.robotic == 2)
							mech = "Mechanical:"

						var/infection = "None"
						switch (i.germ_level)
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
						dat += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>[infection]:[mech]</td><td></td>"
						dat += "</tr>"
						storedinfo += "<tr>"
						storedinfo += "<td>[i.name]</td><td>N/A</td><td>[i.damage]</td><td>[infection]:[mech]</td><td></td>"
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
	user << browse(dat, "window=scanconsole;size=430x600")
	return

/obj/machinery/body_scanconsole/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if (href_list["print"])
		if (src.latestprint + 100 < world.time) //10sec cooldown
			src.latestprint = world.time
			to_chat(usr, "<span class='notice'>Printing... Please wait.</span>")
			spawn(10)
				var/obj/item/weapon/paper/P = new(loc)
				var/mob/living/carbon/human/occupant = src.connected.occupant
				var/t1 = "<B>[occupant ? occupant.name : "Unknown"]'s</B> advanced scanner report.<BR>"
				t1 += "Station Time: <B>[worldtime2text()]</B><BR>"
				switch(occupant.stat) // obvious, see what their status is
					if(0)
						t1 += "Status: <B>Conscious</B>"
					if(1)
						t1 += "Status: <B>Unconscious</B>"
					else
						t1 += "Status: <B>\red*dead*</B>"
				t1 += storedinfo
				P.info = t1
				P.name = "[occupant.name]'s scanner report"
		else
			to_chat(usr, "<span class='notice'>The console can't print that fast!</span>")

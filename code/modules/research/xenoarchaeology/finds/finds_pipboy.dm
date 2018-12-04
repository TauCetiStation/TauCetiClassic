
// Fallout Pip-Boy!
/obj/item/clothing/gloves/pipboy
	name = "\improper Pip-Boy 3000"
	desc = "It's a strange looking device with a screen. Seems like it's worn on the arm. This thing clearly has seen better days."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "pipboy3000"
	item_state = "pipboy3000"
	slot_flags = SLOT_BELT | SLOT_GLOVES
	action_button_name = "Toggle Pip-Boy"
	species_restricted = null
	protect_fingers = 0

	var/on = 1 // Is it on.
	var/profile_name = null // Master's name.
	var/screen = 1 // Which screen is currently showing.

	var/alarm_1 = "Expired: 200 years"
	var/alarm_2 = null
	var/alarm_3 = null
	var/alarm_4 = null
	var/alarm_playing = 0 // So they can't abuse alarm's sound

/obj/item/clothing/gloves/pipboy/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	icon_state = "[initial(icon_state)]_off"
	on = 0
	verbs -= /obj/item/clothing/gloves/pipboy/verb/switch_off


/obj/item/clothing/gloves/pipboy/process()
	if(alarm_playing == 1)
		return
	if(("[worldtime2text()]" == alarm_1) || ("[worldtime2text()]" == alarm_2) || ("[worldtime2text()]" == alarm_3) || ("[worldtime2text()]" == alarm_4))
		var/turf/T = get_turf(src)
		for(var/mob/M in T)
			for(var/obj/item/clothing/gloves/pipboy/P in M.contents)
				if(P == src)
					M.visible_message("<span class='warning'>[bicon(src)][src] rings loudly!</span>")
					alarm_playing = 1
		playsound(src, 'sound/weapons/ring.ogg',50, 1)
		if(alarm_playing != 1)
			src.visible_message("<span class='warning'>[bicon(src)][src] rings loudly!</span>")
			alarm_playing = 1
		sleep(60)
		alarm_playing = 0

/obj/item/clothing/gloves/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/stack/cable_coil) || istype(W, /obj/item/weapon/stock_parts/cell) || istype(W, /obj/item/weapon/wirecutters) || istype(W, /obj/item/weapon/scalpel))
		return
	..()

/obj/item/clothing/gloves/pipboy/ui_action_click()
	open_interface()

/obj/item/clothing/gloves/pipboy/verb/open_interface()
	set name = "Open Interface"
	set category = "Object"

	if(usr.incapacitated())
		return
	var/mob/H = usr
	src.interact(H)

/obj/item/clothing/gloves/pipboy/verb/switch_off()
	set name = "Switch Off"
	set category = "Object"
	icon_state = "[initial(icon_state)]_off"
	playsound(src, 'sound/items/buttonclick.ogg', 50, 1)
	on = 0
	set_light(0)
	verbs -= /obj/item/clothing/gloves/pipboy/verb/switch_off

/obj/item/clothing/gloves/pipboy/attack_self(mob/user)
	return src.interact(user)

/obj/item/clothing/gloves/pipboy/interact(mob/user)
	if(on)
		if(profile_name)
			playsound(src, 'sound/items/buttonclick.ogg', 50, 1)
			var/dat = "<body link='#30CC30' alink='white' bgcolor='#1A351A'><font color='#30CC30'>[name]<br>"
			switch(screen)
				if(1)
					dat += "Hello, [profile_name]!<br>"
					dat += "<h3>MENU</h3>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=2'>STATS</A><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=3'>ITEMS</A><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=4'>DATA</A><br>"
					dat += "<br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];close=1'>Close</A><br>"
				if(2)
					dat += "<h3>STATS</h3>"
					dat += "<br>"
					var/mob/living/M = usr
					dat += health_analyze(M, user)
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=1'>Back to menu</A><br>"
				if(3)
					dat += "<h3>ITEMS</h3>"
					dat += "<br>"
					dat += list_of_items(user)
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=1'>Back to menu</A><br>"
				if(4)
					dat += "<h3>DATA</h3>"
					dat += "<br>"
					dat += "ALARMS LIST<br>"
					dat += "<br>"
					for(var/i in 1 to 4)
						dat += "Alarm [i]. Ringing Time:      "
						var/current_alarm = null
						switch(i)
							if(1)
								current_alarm = alarm_1
							if(2)
								current_alarm = alarm_2
							if(3)
								current_alarm = alarm_3
							if(4)
								current_alarm = alarm_4
						if(current_alarm)
							dat += "[current_alarm]<br>"
						else
							dat += "NOT SET<br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];setalarm=1'>Set Alarm 1</A><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];setalarm=2'>Set Alarm 2</A><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];setalarm=3'>Set Alarm 3</A><br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];setalarm=4'>Set Alarm 4</A><br>"
					dat += "<br>"
					dat += "<br>"
					dat += "<A href='?src=\ref[src];menu=1'>Back to menu</A><br>"
			dat += "</font></body>"
			user << browse(entity_ja(dat), "window=pipboy")
			onclose(user, "pipboy")
			return
		else
			var/mob/living/U = usr
			create_personality(U)
			to_chat(user, "<span class='notice'>[bicon(src)]You have successfully created a profile! Hello, [profile_name]!</span>")
			return
	else
		icon_state = "[initial(icon_state)]"
		to_chat(user, "<span class='notice'>[bicon(src)]You blow the dust off the [name]'s screen and twist the power button. A small screen happily lights up. This device is now on.</span>")
		set_light(2, 1, "#59f65f")
		on = 1
		verbs += /obj/item/clothing/gloves/pipboy/verb/switch_off
		playsound(src, 'sound/mecha/powerup.ogg', 30, 1)
		return

/obj/item/clothing/gloves/pipboy/Topic(href, href_list, mob/user)
	..()
	usr.set_machine(src)

	if(href_list["menu"]) // Switches menu screens. Converts a sent text string into a number. Saves a LOT of code.
		screen = text2num(href_list["menu"])

	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=pipboy")
	if(href_list["setalarm"])
		var/newnumberalarm = text2num(href_list["setalarm"])
		create_alarm_clock(usr, newnumberalarm)

	updateSelfDialog()

/obj/item/clothing/gloves/pipboy/proc/create_personality(mob/living/U = usr)
	playsound(src, 'sound/items/buttonclick.ogg', 50, 1)
	U.visible_message("<span class='notice'>[U] taps on \his [name]'s screen.</span>")
	U.last_target_click = world.time
	var/t = sanitize(input(U, "Please enter your name", name, null) as text)
	t = replacetext(t, "&#34;", "\"")

	if (!t)
		return

	if (!in_range(src, U))
		return

	if (!(on))
		return

	if(U.stat || U.restrained() || U.paralysis || U.stunned || U.weakened)
		return

	playsound(src, 'sound/machines/twobeep.ogg', 50, 1)
	profile_name = "[t]"

/obj/item/clothing/gloves/pipboy/proc/create_alarm_clock(mob/living/U = usr, numb_of_alarm)
	playsound(src, 'sound/items/buttonclick.ogg', 50, 1)
	U.visible_message("<span class='notice'>[U] taps on \his [name]'s screen.</span>")
	U.last_target_click = world.time
	var/alarm = sanitize(input(U, "Please time for the alarm to ring(e.g. 12:00)", name, null) as text)
	switch(numb_of_alarm)
		if(1)
			alarm_1 = "[alarm]"
		if(2)
			alarm_2 = "[alarm]"
		if(3)
			alarm_3 = "[alarm]"
		if(4)
			alarm_4 = "[alarm]"

/obj/item/clothing/gloves/pipboy/proc/health_analyze(mob/living/M, mob/living/user)
	var/message
	var/fake_oxy = max(rand(1,40), M.getOxyLoss(), (300 - (M.getToxLoss() + M.getFireLoss() + M.getBruteLoss())))
	var/OX = M.getOxyLoss() > 50 	? 	"<b>[M.getOxyLoss()]</b>" 		: M.getOxyLoss()
	var/TX = M.getToxLoss() > 50 	? 	"<b>[M.getToxLoss()]</b>" 		: M.getToxLoss()
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 			? 	"<b>[fake_oxy]</b>" 			: fake_oxy
		message += "Analyzing Results for [M]:\n&emsp; Overall Status: dead<br>"
	else
		message += "<span class='notice'>STATS for [M]:\n&emsp;<br> Overall Status: [M.stat > 1 ? "dead" : "[M.health - M.halloss]% healthy"]</span><br>"
	message += "&emsp; Key: <font color='blue'>Suffocation</font>/<font color='green'>Toxin</font>/<font color='#FFA500'>Burns</font>/<font color='red'>Brute</font><br>"
	message += "&emsp; Damage Specifics: <font color='blue'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font><br>"
	message += "<span class='notice'>Body Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span><br>"
	if(M.tod && (M.stat == DEAD || (M.status_flags & FAKEDEATH)))
		message += "<span class='notice'>Time of Death: [M.tod]</span><br>"
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_bodyparts(1, 1)
		message += "<span class='notice'>Localized Damage, Brute/Burn:</span><br>"
		if(length(damaged))
			for(var/obj/item/organ/external/BP in damaged)
				message += "<span class='notice'>&emsp; [capitalize(BP.name)]: [(BP.brute_dam > 0) ? "<span class='warning'>[BP.brute_dam]</span>" : 0][(BP.status & ORGAN_BLEEDING) ? "<span class='warning bold'>\[Bleeding\]</span>" : "&emsp;"] - [(BP.burn_dam > 0) ? "<font color='#FFA500'>[BP.burn_dam]</font>" : 0]</span><br>"
		else
			message += "<span class='notice'>&emsp; Limbs are OK.</span><br>"

	OX = M.getOxyLoss() > 50 ? "<font color='blue'><b>Severe oxygen deprivation detected</b></font>" : "Subject bloodstream oxygen level normal"
	TX = M.getToxLoss() > 50 ? "<font color='green'><b>Dangerous amount of toxins detected</b></font>" : "Subject bloodstream toxin level minimal"
	BU = M.getFireLoss() > 50 ? "<font color='#FFA500'><b>Severe burn damage detected</b></font>" : "Subject burn injury status O.K"
	BR = M.getBruteLoss() > 50 ? "<font color='red'><b>Severe anatomical damage detected</b></font>" : "Subject brute-force injury status O.K"
	if(M.status_flags & FAKEDEATH)
		OX = fake_oxy > 50 ? 		"<span class='warning'>Severe oxygen deprivation detected<span class='notice'>" : "Subject bloodstream oxygen level normal"
	message += "[OX] | [TX] | [BU] | [BR]<br>"
	if(istype(M, /mob/living/carbon))
		var/mob/living/carbon/C = M
		if(C.reagents.total_volume || C.is_infected_with_zombie_virus())
			message += "<span class='warning'>Warning: Unknown substance detected in subject's blood.</span><br>"
		if(C.virus2.len)
			for (var/ID in C.virus2)
				if (ID in virusDB)
					var/datum/data/record/V = virusDB[ID]
					message += "<span class='warning'>Warning: Pathogen [V.fields["name"]] detected in subject's blood. Known antigen : [V.fields["antigen"]]</span><br>"
	if(M.getCloneLoss())
		user.show_message("<span class='warning'>Subject appears to have been imperfectly cloned.</span>")
	for(var/datum/disease/D in M.viruses)
		if(!D.hidden[SCANNER])
			message += "<span class = 'warning bold'>Warning: [D.form] Detected</span>\n<span class = 'warning'>Name: [D.name].\nType: [D.spread].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure]</span><br>"
	if(M.reagents && M.reagents.get_reagent_amount("inaprovaline"))
		message += "<span class='notice'>Bloodstream Analysis located [M.reagents:get_reagent_amount("inaprovaline")] units of rejuvenation chemicals.</span><br>"
	if(M.has_brain_worms())
		message += "<span class='warning'>Subject suffering from aberrant brain activity. Recommend further scanning.</span><br>"
	else if(M.getBrainLoss() >= 100 || istype(M, /mob/living/carbon/human) && M:brain_op_stage == 4.0)
		message += "<span class='warning'>Subject is brain dead.</span>"
	else if(M.getBrainLoss() >= 60)
		message += "<span class='warning'>Severe brain damage detected. Subject likely to have mental retardation.</span><br>"
	else if(M.getBrainLoss() >= 10)
		message += "<span class='warning'>Significant brain damage detected. Subject may have had a concussion.</span><br>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		var/found_bleed
		var/found_broken
		for(var/obj/item/organ/external/BP in H.bodyparts)
			if(BP.status & ORGAN_BROKEN)
				if(((BP.body_zone == BP_L_ARM) || (BP.body_zone == BP_R_ARM) || (BP.body_zone == BP_L_LEG) || (BP.body_zone == BP_R_LEG)) && !(BP.status & ORGAN_SPLINTED))
					message += "<span class='warning'>Unsecured fracture in subject [BP.name]. Splinting recommended for transport.</span><br>"
				if(!found_broken)
					found_broken = TRUE

			if(!found_bleed && (BP.status & ORGAN_ARTERY_CUT))
				found_bleed = TRUE

			if(BP.has_infected_wound())
				message += "<span class='warning'>Infected wound detected in subject [BP.name]. Disinfection recommended.</span><br>"

		if(found_bleed)
			message += "<span class='warning'>Arterial bleeding detected. Advanced scanner required for location.</span><br>"
		if(found_broken)
			message += "<span class='warning'>Bone fractures detected. Advanced scanner required for location.</span><br>"

		if(H.vessel)
			var/blood_volume = round(H.vessel.get_reagent_amount("blood"))
			var/blood_percent =  blood_volume / 560
			var/blood_type = H.dna.b_type
			blood_percent *= 100
			if(blood_volume <= 500 && blood_volume > 336)
				message += "<span class='warning bold'>Warning: Blood Level LOW: [blood_percent]% [blood_volume]cl.</span><span class='notice'>Type: [blood_type]</span><br>"
			else if(blood_volume <= 336)
				message += "<span class='warning bold'>Warning: Blood Level CRITICAL: [blood_percent]% [blood_volume]cl.</span><span class='notice bold'>Type: [blood_type]</span><br>"
			else
				message += "<span class='notice'>Blood Level Normal: [blood_percent]% [blood_volume]cl. Type: [blood_type]</span><br>"
		message += "<span class='notice'>Subject's pulse: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "blue"]'>[H.get_pulse(GETPULSE_TOOL)] bpm.</font></span><br>"
	return message


/obj/item/clothing/gloves/pipboy/proc/list_of_items(mob/user)
	var/message
	var/message_items
	var/message_clothing
	var/mob/living/H = user
	for(var/obj/item/T in H.contents)
		if(T == src)
			continue
		if(istype(T, /obj/item/clothing))
			message_clothing += "[bicon(T)][T.name]<br>"
		else
			if(istype(T, /obj/item/weapon/storage))
				message_clothing += "[bicon(T)][T.name]<br>"
				for(var/obj/item/B in T.contents)
					if(istype(B, /obj/item/clothing))
						message_clothing += "[bicon(B)][B.name]<br>"
					else
						if(istype(B, /obj/item/weapon/storage))
							for(var/obj/item/G in B.contents)
								if(istype(G, /obj/item/clothing))
									message_clothing += "[bicon(G)][G.name]<br>"
								else
									message_items += "[bicon(G)][G.name]<br>"
						message_items += "[bicon(B)][B.name]<br>"
				continue
			else
				message_items += "[bicon(T)][T.name]<br>"

	message = "CLOTHING<br>"
	message += message_clothing
	message += "<br>"
	message += "ITEMS<br>"
	message += message_items

	return message

/obj/item/clothing/gloves/pipboy/pimpboy3billion
	name = "\improper Pimp-Boy 3 Billion"
	desc = "It's a strange looking device with what appears to be gold and silver plating as well as encrusted diamonds. Seems like it's worn on the arm."
	icon_state = "pimpboy3billion"
	item_state = "pimpboy3billion"

/obj/item/clothing/gloves/pipboy/pipboy3000mark4
	name = "\improper Pip-Boy 3000 Mark IV"
	icon_state = "pipboy3000mark4"
	item_state = "pipboy3000mark4"

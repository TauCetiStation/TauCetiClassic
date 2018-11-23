


//endless reagents!
/obj/item/weapon/reagent_containers/glass/replenishing
	var/spawning_id

/obj/item/weapon/reagent_containers/glass/replenishing/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	spawning_id = pick("blood","holywater","unholywater","lube","stoxin","ethanol","ice","glycerol","fuel","cleaner")

/obj/item/weapon/reagent_containers/glass/replenishing/process()
	reagents.add_reagent(spawning_id, 0.3)



//a talking gas mask!
/obj/item/clothing/mask/gas/poltergeist
	var/list/heard_talk = list()
	var/last_twitch = 0
	var/max_stored_messages = 100

/obj/item/clothing/mask/gas/poltergeist/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

var/list/bad_messages = list("Never take me off, please!",\
		"They all want to wear me... But I'm yours!",\
		"They're all want to take me from you! Bastards!",\
		"We are one",\
		"I want to be only yours!",\
		"Help me!")

/obj/item/clothing/mask/gas/poltergeist/process(/mob/living/H)
	if(heard_talk.len && istype(src.loc, /mob/living) && prob(20))
		var/mob/living/M = src.loc
		M.say(pick(heard_talk))
	if(istype(src.loc, /mob/living) && prob(20))
		var/mob/living/M = src.loc
		to_chat(M, "A strange voice goes through your head: <b><font color='red' size='[num2text(rand(1,3))]'><b>[pick(bad_messages)]</b></font>")

/obj/item/clothing/mask/gas/poltergeist/hear_talk(mob/M, text)
	..()
	if(heard_talk.len > max_stored_messages)
		heard_talk.Remove(pick(heard_talk))
	heard_talk.Add(text)
	if(istype(src.loc, /mob/living) && world.time - last_twitch > 50)
		last_twitch = world.time



//a vampiric statuette
//todo: cult integration
/obj/item/weapon/vampiric
	name = "statuette"
	icon_state = "statuette"
	icon = 'icons/obj/xenoarchaeology.dmi'
	var/charges = 0
	var/list/nearby_mobs = list()
	var/last_bloodcall = 0
	var/bloodcall_interval = 50
	var/last_eat = 0
	var/eat_interval = 100
	var/wight_check_index = 1
	var/list/shadow_wights = list()

/obj/item/weapon/vampiric/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/vampiric/process()
	//see if we've identified anyone nearby
	if(world.time - last_bloodcall > bloodcall_interval && nearby_mobs.len)
		var/mob/living/carbon/human/M = pop(nearby_mobs)
		if(M in view(7,src) && M.health > 20)
			if(prob(50))
				bloodcall(M)
				nearby_mobs.Add(M)

	//suck up some blood to gain power
	if(world.time - last_eat > eat_interval)
		var/obj/effect/decal/cleanable/blood/B = locate() in range(2,src)
		if(B)
			last_eat = world.time
			B.loc = null
			if(istype(B, /obj/effect/decal/cleanable/blood/drip))
				charges += 0.25
			else
				charges += 1
				playsound(src.loc, 'sound/effects/splat.ogg', 50, 1, -3)

	//use up stored charges
	if(charges >= 10)
		charges -= 10
		new /obj/effect/spider/eggcluster(pick(view(1,src)))

	if(charges >= 3)
		if(prob(5))
			charges -= 1
			var/spawn_type = pick(/mob/living/simple_animal/hostile/creature)
			new spawn_type(pick(view(1,src)))
			playsound(src.loc, pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg'), 50, 1, -3)

	if(charges >= 1)
		if(shadow_wights.len < 5 && prob(5))
			shadow_wights.Add(new /obj/effect/shadow_wight(src.loc))
			playsound(src.loc, 'sound/effects/ghost.ogg', 50, 1, -3)
			charges -= 0.1

	if(charges >= 0.1)
		if(prob(5))
			src.visible_message("\red [bicon(src)] [src]'s eyes glow ruby red for a moment!")
			charges -= 0.1

	//check on our shadow wights
	if(shadow_wights.len)
		wight_check_index++
		if(wight_check_index > shadow_wights.len)
			wight_check_index = 1

		var/obj/effect/shadow_wight/W = shadow_wights[wight_check_index]
		if(isnull(W))
			shadow_wights.Remove(wight_check_index)
		else if(isnull(W.loc))
			shadow_wights.Remove(wight_check_index)
		else if(get_dist(W, src) > 10)
			shadow_wights.Remove(wight_check_index)

/obj/item/weapon/vampiric/hear_talk(mob/M, text)
	..()
	if(world.time - last_bloodcall >= bloodcall_interval && M in view(7, src))
		bloodcall(M)

/obj/item/weapon/vampiric/proc/bloodcall(mob/living/carbon/human/M)
	last_bloodcall = world.time
	if(istype(M))
		playsound(src.loc, pick('sound/hallucinations/wail.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/far_noise.ogg'), 50, 1, -3)
		nearby_mobs.Add(M)

		var/target = pick(BP_CHEST , BP_GROIN , BP_HEAD , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG)
		M.apply_damage(rand(5, 10), BRUTE, target)
		to_chat(M, "\red The skin on your [parse_zone(target)] feels like it's ripping apart, and a stream of blood flies out.")
		var/obj/effect/decal/cleanable/blood/splatter/animated/B = new(M.loc)
		B.target_turf = pick(range(1, src))
		B.blood_DNA = list()
		B.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
		M.vessel.remove_reagent("blood",rand(25,50))

//animated blood 2 SPOOKY
/obj/effect/decal/cleanable/blood/splatter/animated
	var/turf/target_turf
	var/loc_last_process

/obj/effect/decal/cleanable/blood/splatter/animated/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	loc_last_process = loc

/obj/effect/decal/cleanable/blood/splatter/animated/process()
	if(target_turf && src.loc != target_turf)
		step_towards(src,target_turf)
		if(src.loc == loc_last_process)
			target_turf = null
		loc_last_process = src.loc

		//leave some drips behind
		if(prob(50))
			var/obj/effect/decal/cleanable/blood/drip/D = new(src.loc)
			D.blood_DNA = src.blood_DNA.Copy()
			if(prob(50))
				D = new(src.loc)
				D.blood_DNA = src.blood_DNA.Copy()
				if(prob(50))
					D = new(src.loc)
					D.blood_DNA = src.blood_DNA.Copy()
	else
		..()

/obj/effect/shadow_wight
	name = "shadow wight"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	density = 1

/obj/effect/shadow_wight/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/shadow_wight/process()
	if(src.loc)
		src.loc = get_turf(pick(orange(1,src)))
		var/mob/living/carbon/M = locate() in src.loc
		if(M)
			playsound(src.loc, pick('sound/hallucinations/behind_you1.ogg',\
			'sound/hallucinations/behind_you2.ogg',\
			'sound/hallucinations/i_see_you1.ogg',\
			'sound/hallucinations/i_see_you2.ogg',\
			'sound/hallucinations/im_here1.ogg',\
			'sound/hallucinations/im_here2.ogg',\
			'sound/hallucinations/look_up1.ogg',\
			'sound/hallucinations/look_up2.ogg',\
			'sound/hallucinations/over_here1.ogg',\
			'sound/hallucinations/over_here2.ogg',\
			'sound/hallucinations/over_here3.ogg',\
			'sound/hallucinations/turn_around1.ogg',\
			'sound/hallucinations/turn_around2.ogg',\
			), 50, 1, -3)
			M.sleeping = max(M.sleeping,rand(5,10))
			src.loc = null
	else
		STOP_PROCESSING(SSobj, src)

/obj/effect/shadow_wight/Bump(var/atom/obstacle)
	to_chat(obstacle, "\red You feel a chill run down your spine!")


//healing tool
/obj/item/weapon/strangetool
	name = "strange device"
	desc = "This device is made of metal, emits a strange purple formation of unknown origin."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "strange_tool"
	var/last_time_used = 0

/obj/item/weapon/strangetool/attack_self(mob/user)
	if(last_time_used + 50 < world.time)
		to_chat(user, "<span class='notice'><font color='purple'>[bicon(src)]Divice blinks brightly.</font></span>")
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			to_chat(C, "\blue You feel a soothing energy invigorate you.")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				for(var/obj/item/organ/external/BP in H.bodyparts)
					BP.heal_damage(rand(20,30),rand(20,30))
				H.vessel.add_reagent("blood",5)
				H.nutrition += rand(30,55)
				H.adjustBrainLoss(rand(-10,-25))
				H.radiation -= min(H.radiation, rand(20,30))
				H.bodytemperature = initial(H.bodytemperature)
				spawn(1)
					H.fixblood()
			//
			C.adjustOxyLoss(rand(-40,-20))
			C.adjustToxLoss(rand(-40,-20))
			C.adjustBruteLoss(rand(-40,-20))
			C.adjustFireLoss(rand(-40,-20))
			//
			C.regenerate_icons()
		last_time_used = world.time
	else
		to_chat(user, "<span class='notice'><font color='red'>[bicon(src)]Divice blinks faintly.</font></span>")


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
			to_chat(user, "<span class='notice'>[bicon(src)]You you have successfully created a profile! Hello, [profile_name]!</span>")
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
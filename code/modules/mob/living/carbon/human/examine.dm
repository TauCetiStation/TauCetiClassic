/mob/living/carbon/human/examine(mob/user)
	var/skipgloves = 0
	var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipears = 0
	var/skipeyes = 0
	var/skipface = 0

	//exosuits and helmets obscure our view and stuff.
	if(wear_suit)
		skipgloves = wear_suit.flags_inv & HIDEGLOVES
		skipsuitstorage = wear_suit.flags_inv & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.flags_inv & HIDEJUMPSUIT
		skipshoes = wear_suit.flags_inv & HIDESHOES

	if(head)
		skipmask = head.flags_inv & HIDEMASK
		skipeyes = head.flags_inv & HIDEEYES
		skipears = head.flags_inv & HIDEEARS
		skipface = head.flags_inv & HIDEFACE

	if(wear_mask)
		skipface |= wear_mask.flags_inv & HIDEFACE

	// crappy hacks because you can't do \his[src] etc. I'm sorry this proc is so unreadable, blame the text macros :<
	var/t_He = "It" //capitalised for use at the start of each line.
	var/t_His = "Its"
	var/t_his = "its"
	var/t_him = "it"
	var/t_has = "has"
	var/t_is = "is"

	var/msg = "<span class='info'>*---------*\nThis is "

	if( skipjumpsuit && skipface ) //big suits/masks/helmets make it hard to tell their gender
		t_He = "They"
		t_His = "Their"
		t_his = "their"
		t_him = "them"
		t_has = "have"
		t_is = "are"
	else
		switch(gender)
			if(MALE)
				t_He = "He"
				t_His = "His"
				t_his = "his"
				t_him = "him"
			if(FEMALE)
				t_He = "She"
				t_His = "Her"
				t_his = "her"
				t_him = "her"

	msg += "<EM>[src.name]"
	if(!(skipface && skipjumpsuit))
		var/species_name = "[get_species()]"
		msg += ", <span color='[species.flesh_color]'>\a [species_name]</span>"
	msg += "</EM>!\n"

	//uniform
	if(w_uniform && !skipjumpsuit)
		//Ties
		var/list/ties = list()
		if(istype(w_uniform,/obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			for(var/accessory in U.accessories)
				ties += "[bicon(accessory)] \a [accessory]"
		var/tie_msg = ties.len ? ". Attached to it is [english_list(ties)]" : ""

		if(w_uniform.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(w_uniform)] [w_uniform.gender==PLURAL?"some":"a"] [w_uniform.dirt_description()][tie_msg]!</span>\n"
		else if(w_uniform.wet)
			msg += "<span class='wet'>[t_He] [t_is] wearing [bicon(w_uniform)] [w_uniform.gender==PLURAL?"some":"a"] wet [w_uniform.name][tie_msg]!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(w_uniform)] \a [w_uniform][tie_msg].\n"

	//head
	if(head)
		if(head.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(head)] [head.gender==PLURAL?"some":"a"] [head.dirt_description()] on [t_his] head!</span>\n"
		else if(head.wet)
			msg += "<span class='wet'>[t_He] [t_is] wearing [bicon(head)] [head.gender==PLURAL?"some":"a"] wet [head.name] on [t_his] head!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(head)] \a [head] on [t_his] head.\n"

	//suit/armour
	if(wear_suit)
		if(wear_suit.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(wear_suit)] [wear_suit.gender==PLURAL?"some":"a"] [wear_suit.dirt_description()]!</span>\n"
		else if(wear_suit.wet)
			msg += "<span class='wet'>[t_He] [t_is] wearing [bicon(wear_suit)] [wear_suit.gender==PLURAL?"some":"a"] wet [wear_suit.name]!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(wear_suit)] \a [wear_suit].\n"

		//suit/armour storage
		if(s_store && !skipsuitstorage)
			if(s_store.dirt_overlay)
				msg += "<span class='warning'>[t_He] [t_is] carrying [bicon(s_store)] [s_store.gender==PLURAL?"some":"a"] [s_store.dirt_description()] on [t_his] [wear_suit.name]!</span>\n"
			else
				msg += "[t_He] [t_is] carrying [bicon(s_store)] \a [s_store] on [t_his] [wear_suit.name].\n"

	//back
	if(back)
		if(back.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(back)] [back.gender==PLURAL?"some":"a"] [back.dirt_description()] on [t_his] back.</span>\n"
		else if(back.wet)
			msg += "<span class='wet'>[t_He] [t_has] [bicon(back)] [back.gender==PLURAL?"some":"a"] wet [back] on [t_his] back.</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(back)] \a [back] on [t_his] back.\n"

	var/static/list/changeling_weapons = list(/obj/item/weapon/changeling_whip, /obj/item/weapon/shield/changeling, /obj/item/weapon/melee/arm_blade, /obj/item/weapon/changeling_hammer)
	//left hand
	if(l_hand && !(l_hand.flags&ABSTRACT))
		if(l_hand.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_is] holding [bicon(l_hand)] [l_hand.gender==PLURAL?"some":"a"] [l_hand.dirt_description()] in [t_his] left hand!</span>\n"
		else if(l_hand.wet)
			msg += "<span class='wet'>[t_He] [t_is] holding [bicon(l_hand)] [l_hand.gender==PLURAL?"some":"a"] wet [l_hand.name] in [t_his] left hand!</span>\n"
		else
			msg += "[t_He] [t_is] holding [bicon(l_hand)] \a [l_hand] in [t_his] left hand.\n"
	else if(l_hand && (l_hand.type in changeling_weapons))
		msg += "<span class='warning'>[t_He] [t_has] [bicon(l_hand)] \a [l_hand] instead of his left arm!</span>\n"

	//right hand
	if(r_hand && !(r_hand.flags&ABSTRACT))
		if(r_hand.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_is] holding [bicon(r_hand)] [r_hand.gender==PLURAL?"some":"a"] [r_hand.dirt_description()] in [t_his] right hand!</span>\n"
		else if(r_hand.wet)
			msg += "<span class='wet'>[t_He] [t_is] holding [bicon(r_hand)] [r_hand.gender==PLURAL?"some":"a"] wet [r_hand.name] in [t_his] right hand!</span>\n"
		else
			msg += "[t_He] [t_is] holding [bicon(r_hand)] \a [r_hand] in [t_his] right hand.\n"
	else if(r_hand && (r_hand.type in changeling_weapons))
		msg += "<span class='warning'>[t_He] [t_has] [bicon(r_hand)] \a [r_hand] instead of his right arm!</span>\n"

	//gloves
	if(gloves && !skipgloves)
		if(gloves.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(gloves)] [gloves.gender==PLURAL?"some":"a"] [gloves.dirt_description()] on [t_his] hands!</span>\n"
		else if(gloves.wet)
			msg += "<span class='wet'>[t_He] [t_has] [bicon(gloves)] [gloves.gender==PLURAL?"some":"a"] wet [gloves.name] on [t_his] hands!</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(gloves)] \a [gloves] on [t_his] hands.\n"
	else if(hand_dirt_datum)
		msg += "<span class='warning'>[t_He] [t_has] [hand_dirt_datum.name]-stained hands!</span>\n"

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/weapon/handcuffs/cable))
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] restrained with cable!</span>\n"
		else
			msg += "<span class='warning'>[t_He] [t_is] [bicon(handcuffed)] handcuffed!</span>\n"

	//buckled
	if(buckled)
		msg += "<span class='warning'>[t_He] [t_is] [bicon(buckled)] buckled to [buckled]!</span>\n"

	//belt
	if(belt)
		if(belt.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(belt)] [belt.gender==PLURAL?"some":"a"] [belt.dirt_description()] about [t_his] waist!</span>\n"
		else if(belt.wet)
			msg += "<span class='wet'>[t_He] [t_has] [bicon(belt)] [belt.gender==PLURAL?"some":"a"] wet [belt.name] about [t_his] waist!</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(belt)] \a [belt] about [t_his] waist.\n"

	//shoes
	if(shoes && !skipshoes)
		if(shoes.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_is] wearing [bicon(shoes)] [shoes.gender==PLURAL?"some":"a"] [shoes.dirt_description()] on [t_his] feet!</span>\n"
		else if(shoes.wet)
			msg += "<span class='wet'>[t_He] [t_is] wearing [bicon(shoes)] [shoes.gender==PLURAL?"some":"a"] wet [shoes.name] on [t_his] feet!</span>\n"
		else
			msg += "[t_He] [t_is] wearing [bicon(shoes)] \a [shoes] on [t_his] feet.\n"
	else if(feet_dirt_color)
		msg += "<span class='warning'>[t_He] [t_has] [feet_dirt_color.name]-stained feet!</span>\n"

	//mask
	if(wear_mask && !skipmask)
		if(wear_mask.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(wear_mask)] [wear_mask.gender==PLURAL?"some":"a"] [wear_mask.dirt_description()] on [t_his] face!</span>\n"
		else if(wear_mask.wet)
			msg += "<span class='wet'>[t_He] [t_has] [bicon(wear_mask)] [wear_mask.gender==PLURAL?"some":"a"] wet [wear_mask.name] on [t_his] face!</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(wear_mask)] \a [wear_mask] on [t_his] face.\n"

	//eyes
	if(glasses && !skipeyes)
		if(glasses.dirt_overlay)
			msg += "<span class='warning'>[t_He] [t_has] [bicon(glasses)] [glasses.gender==PLURAL?"some":"a"] [glasses.dirt_description()] covering [t_his] eyes!</span>\n"
		else if(glasses.wet)
			msg += "<span class='wet'>[t_He] [t_has] [bicon(glasses)] [glasses.gender==PLURAL?"some":"a"] wet [glasses] covering [t_his] eyes!</span>\n"
		else
			msg += "[t_He] [t_has] [bicon(glasses)] \a [glasses] covering [t_his] eyes.\n"

	//left ear
	if(l_ear && !skipears)
		msg += "[t_He] [t_has] [bicon(l_ear)] \a [l_ear] on [t_his] left ear.\n"

	//right ear
	if(r_ear && !skipears)
		msg += "[t_He] [t_has] [bicon(r_ear)] \a [r_ear] on [t_his] right ear.\n"

	//ID
	if(wear_id)
		msg += "[t_He] [t_is] wearing [bicon(wear_id)] \a [wear_id].\n"

	//Status effects
	var/list/status_examines = status_effect_examines()
	if (length(status_examines))
		msg += status_examines

	//Jitters
	if(is_jittery)
		if(jitteriness >= 300)
			msg += "<span class='warning'><B>[t_He] [t_is] convulsing violently!</B></span>\n"
		else if(jitteriness >= 200)
			msg += "<span class='warning'>[t_He] [t_is] extremely jittery.</span>\n"
		else if(jitteriness >= 100)
			msg += "<span class='warning'>[t_He] [t_is] twitching ever so slightly.</span>\n"

	//splints
	for(var/bodypart in list(BP_L_LEG , BP_R_LEG , BP_L_ARM , BP_R_ARM))
		var/obj/item/organ/external/BP = bodyparts_by_name[bodypart]
		if(BP && BP.status & ORGAN_SPLINTED)
			msg += "<span class='warning'>[t_He] [t_has] a splint on [t_his] [BP.name]!</span>\n"

	if(suiciding)
		msg += "<span class='warning'>[t_He] appears to have commited suicide... there is no hope of recovery.</span>\n"

	if(SMALLSIZE in mutations)
		if(gnomed)
			msg += "[t_He] [t_is] a gnome!\n"
		else
			msg += "[t_He] [t_is] a small halfling!\n"

	var/distance = get_dist(user,src)
	if(istype(user, /mob/dead/observer) || user.stat == DEAD) // ghosts can see anything
		distance = 1
	if (src.stat || (iszombie(src) && (crawling || lying || resting)))
		msg += "<span class='warning'>[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep.</span>\n"
		if((stat == DEAD || src.losebreath || iszombie(src)) && distance <= 3)
			msg += "<span class='warning'>[t_He] does not appear to be breathing.</span>\n"
		if(istype(user, /mob/living/carbon/human) && !user.stat && distance <= 1)
			user.visible_message("[user] checks [src]'s pulse.")
		spawn(15)
			if(distance <= 1 && user && user.stat != UNCONSCIOUS)
				if(pulse == PULSE_NONE)
					to_chat(user, "<span class='deadsay'>[t_He] has no pulse[src.client ? "" : " and [t_his] soul has departed"]...</span>")
				else
					to_chat(user, "<span class='deadsay'>[t_He] has a pulse!</span>")

	msg += "<span class='warning'>"

	if(!species.flags[IS_SYNTHETIC])
		if(nutrition < 100)
			msg += "[t_He] [t_is] severely malnourished.\n"
		else if(nutrition >= 500)
			msg += "[t_He] [t_is] quite chubby.\n"
	else
		var/obj/item/organ/internal/liver/IO = organs_by_name[O_LIVER]
		var/obj/item/weapon/stock_parts/cell/C = locate(/obj/item/weapon/stock_parts/cell) in IO
		if(C)
			if(nutrition < (C.maxcharge*0.1))
				msg += "His indicator of charge blinks red.\n"
		else
			msg += "[t_He] has no battery!\n"

	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] look[t_is] a little soaked.\n"

	msg += "</span>"

	if(bodyparts_by_name[BP_HEAD] && getBrainLoss() >= 60)
		msg += "[t_He] [t_has] a stupid expression on [t_his] face.\n"

	if(!key && has_brain() && stat != DEAD)
		msg += "<span class='deadsay'>[t_He] [t_is] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely</span>\n"
	else if(!client && has_brain() && stat != DEAD)
		msg += "[t_He] [t_has] suddenly fallen asleep.\n"

	var/list/wound_flavor_text = list()
	var/list/is_destroyed = list()
	var/list/is_bleeding = list()
	var/applying_pressure = ""

	for(var/BP_ZONE in species.has_bodypart)
		var/BP_Name = parse_zone(BP_ZONE)
		var/obj/item/organ/external/BP = bodyparts_by_name[BP_ZONE]
		if(!BP)
			is_destroyed[BP_Name] = 1
			wound_flavor_text[BP_Name] = "<span class='warning'><b>[t_He] is missing [t_his] [BP_Name].</b></span>\n"
		if(BP)
			if(istype(BP, /obj/item/organ/external/stump))
				is_destroyed[BP_Name] = 1
				wound_flavor_text[BP_Name] = "<span class='warning'><b>[t_He] [t_has] a stump where [t_his] [BP_Name] should be.</b></span>\n"
				continue
			if(BP.applied_pressure)
				if(BP.applied_pressure == src)
					applying_pressure = "<span class='info'>[t_He] is applying pressure to [t_his] [BP.name].</span><br>"
				else
					applying_pressure = "<span class='info'>[BP.applied_pressure] is applying pressure to [t_his] [BP.name].</span><br>"
			if(BP.is_robotic())
				if(!(BP.brute_dam + BP.burn_dam))
					if(!species.flags[IS_SYNTHETIC])
						wound_flavor_text[BP_Name] = "<span class='warning'>[t_He] has a robot [BP.name]!</span>\n"
						continue
				else
					wound_flavor_text[BP_Name] = "<span class='warning'>[t_He] has a robot [BP.name], it has"
				if(BP.brute_dam)
					switch(BP.brute_dam)
						if(0 to 20)
							wound_flavor_text[BP_Name] += " some dents"
						if(21 to INFINITY)
							wound_flavor_text[BP_Name] += pick(" a lot of dents"," severe denting")
				if(BP.brute_dam && BP.burn_dam)
					wound_flavor_text[BP_Name] += " and"
				if(BP.burn_dam)
					switch(BP.burn_dam)
						if(0 to 20)
							wound_flavor_text[BP_Name] += " some burns"
						if(21 to INFINITY)
							wound_flavor_text[BP_Name] += pick(" a lot of burns"," severe melting")
				if(wound_flavor_text[BP_Name])
					wound_flavor_text[BP_Name] += "!</span>\n"
			else if(BP.wounds.len > 0)
				var/list/wound_descriptors = list()
				for(var/datum/wound/W in BP.wounds)
					var/this_wound_desc = W.desc
					if(W.damage_type == BURN && W.salved) this_wound_desc = "salved [this_wound_desc]"
					if(W.bleeding()) this_wound_desc = "bleeding [this_wound_desc]"
					else if(W.bandaged) this_wound_desc = "bandaged [this_wound_desc]"
					if(W.germ_level > 600) this_wound_desc = "badly infected [this_wound_desc]"
					else if(W.germ_level > 330) this_wound_desc = "lightly infected [this_wound_desc]"
					if(this_wound_desc in wound_descriptors)
						wound_descriptors[this_wound_desc] += W.amount
						continue
					wound_descriptors[this_wound_desc] = W.amount
				if(wound_descriptors.len)
					var/list/flavor_text = list()
					var/list/no_exclude = list("gaping wound", "big gaping wound", "massive wound", "large bruise",\
					"huge bruise", "massive bruise", "severe burn", "large burn", "deep burn", "carbonised area")
					var/span_flavor = "<span class='warning'>"
					for(var/wound in wound_descriptors)
						switch(wound_descriptors[wound])
							if(1)
								if(!flavor_text.len)
									flavor_text += "[span_flavor][t_He] has[prob(10) && !(wound in no_exclude)  ? " what might be" : ""] a [wound]"
								else
									flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a [wound]"
							if(2)
								if(!flavor_text.len)
									flavor_text += "[span_flavor][t_He] has[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
								else
									flavor_text += "[prob(10) && !(wound in no_exclude) ? " what might be" : ""] a pair of [wound]s"
							if(3 to 5)
								if(!flavor_text.len)
									flavor_text += "[span_flavor][t_He] has several [wound]s"
								else
									flavor_text += " several [wound]s"
							if(6 to INFINITY)
								if(!flavor_text.len)
									flavor_text += "[span_flavor][t_He] has a bunch of [wound]s"
								else
									flavor_text += " a ton of [wound]\s"
					var/flavor_text_string = ""
					for(var/text = 1, text <= flavor_text.len, text++)
						if(text == flavor_text.len && flavor_text.len > 1)
							flavor_text_string += ", and"
						else if(flavor_text.len > 1 && text > 1)
							flavor_text_string += ","
						flavor_text_string += flavor_text[text]
					flavor_text_string += " on [t_his] [BP.name].</span><br>"
					wound_flavor_text[BP_Name] = flavor_text_string
				else
					wound_flavor_text[BP_Name] = ""
				if(BP.status & ORGAN_BLEEDING)
					is_bleeding[BP_Name] = 1
			else
				wound_flavor_text[BP_Name] = ""

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.
	var/display_chest = 0
	var/display_shoes = 0
	var/display_gloves = 0
	if(wound_flavor_text["head"] && (is_destroyed["head"] || (!skipmask && !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas)))))
		msg += wound_flavor_text["head"]
	else if(is_bleeding["head"])
		msg += "<span class='warning'>[src] has blood running down [t_his] face!</span>\n"
	if(wound_flavor_text["chest"] && !w_uniform && !skipjumpsuit) //No need.  A missing chest gibs you.
		msg += wound_flavor_text["chest"]
	else if(is_bleeding["chest"])
		display_chest = 1
	if(wound_flavor_text["left arm"] && (is_destroyed["left arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["left arm"]
	else if(is_bleeding["left arm"])
		display_chest = 1
	if(wound_flavor_text["left hand"] && (is_destroyed["left hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["left hand"]
	else if(is_bleeding["left hand"])
		display_gloves = 1
	if(wound_flavor_text["right arm"] && (is_destroyed["right arm"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right arm"]
	else if(is_bleeding["right arm"])
		display_chest = 1
	if(wound_flavor_text["right hand"] && (is_destroyed["right hand"] || (!gloves && !skipgloves)))
		msg += wound_flavor_text["right hand"]
	else if(is_bleeding["right hand"])
		display_gloves = 1
	if(wound_flavor_text["groin"] && (is_destroyed["groin"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["groin"]
	else if(is_bleeding["groin"])
		display_chest = 1
	if(wound_flavor_text["left leg"] && (is_destroyed["left leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["left leg"]
	else if(is_bleeding["left leg"])
		display_chest = 1
	if(wound_flavor_text["left foot"]&& (is_destroyed["left foot"] || (!shoes && !skipshoes)))
		msg += wound_flavor_text["left foot"]
	else if(is_bleeding["left foot"])
		display_shoes = 1
	if(wound_flavor_text["right leg"] && (is_destroyed["right leg"] || (!w_uniform && !skipjumpsuit)))
		msg += wound_flavor_text["right leg"]
	else if(is_bleeding["right leg"])
		display_chest = 1
	if(wound_flavor_text["right foot"]&& (is_destroyed["right foot"] || (!shoes  && !skipshoes)))
		msg += wound_flavor_text["right foot"]
	else if(is_bleeding["right foot"])
		display_shoes = 1
	if(display_chest)
		msg += "<span class='warning'><b>[src] has blood soaking through from under [t_his] clothing!</b></span>\n"
	if(display_shoes)
		msg += "<span class='warning'><b>[src] has blood running from [t_his] shoes!</b></span>\n"
	if(display_gloves)
		msg += "<span class='warning'><b>[src] has blood running from under [t_his] gloves!</b></span>\n"

	var/list/implants = get_visible_implants(1)
	for(var/implant in implants)
		var/obj/item/organ/external/BP = implants[implant]
		msg += "<span class='warning'><b>[src] has \a [implant] sticking out of their [BP.name]!</b></span>\n"
	if(digitalcamo)
		msg += "<span class='warning'>[t_He] [t_is] moving [t_his] body in an unnatural and blatantly inhuman manner.</span>\n"
	if(mind && mind.changeling && mind.changeling.isabsorbing)
		msg += "<span class='warning'><b>[t_He] sucking fluids from someone through a giant proboscis!</b></span>\n"

	if(!skipface)
		var/obj/item/organ/external/head/BP = bodyparts_by_name[BP_HEAD]
		if(istype(BP) && BP.disfigured)
			msg += "<span class='warning'><b>[t_His] face is violently disfigured!</b></span>\n"

	if((!skipface || !skipjumpsuit || !skipgloves) && (HUSK in mutations))
		msg += "<span class='warning'><b>[t_His] skin is looking cadaveric!</b></span>\n"

	if(hasHUD(user,"security"))
		var/perpname = "wot"
		var/criminal = "None"

		if(wear_id)
			var/obj/item/weapon/card/id/I = wear_id.GetID()
			if(I)
				perpname = I.registered_name
			else
				perpname = name
		else
			perpname = name

		if(perpname)
			for (var/datum/data/record/E in data_core.general)
				if(E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if(R.fields["id"] == E.fields["id"])
							criminal = R.fields["criminal"]

			msg += "<span class = 'deptradio'>Criminal status:</span> <a href='?src=\ref[src];criminal=1'>\[[criminal]\]</a>\n"
			msg += "<span class = 'deptradio'>Security records:</span> <a href='?src=\ref[src];secrecord=`'>\[View\]</a>  <a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>\n"

	if(hasHUD(user,"medical"))
		if(hasHUD(user,"security"))
			msg += "---------\n"
		var/perpname = "wot"
		var/medical = "None"

		if(wear_id)
			if(istype(wear_id,/obj/item/weapon/card/id))
				perpname = wear_id:registered_name
			else if(istype(wear_id,/obj/item/device/pda))
				var/obj/item/device/pda/tempPda = wear_id
				perpname = tempPda.owner
		else
			perpname = src.name

		for (var/datum/data/record/E in data_core.general)
			if (E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.general)
					if (R.fields["id"] == E.fields["id"])
						medical = R.fields["p_stat"]

		msg += "<span class = 'deptradio'>Physical status:</span> <a href='?src=\ref[src];medical=1'>\[[medical]\]</a>\n"
		msg += "<span class = 'deptradio'>Medical records:</span> <a href='?src=\ref[src];medrecord=`'>\[View\]</a> <a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>\n"


	if(!skipface && print_flavor_text())
		msg += "[print_flavor_text()]\n"

	msg += "*---------*</span><br>"
	if(applying_pressure)
		msg += applying_pressure
	else if(busy_with_action)
		msg += "<span class='info'>[t_He] is busy with something!</span><br>"
	if (pose)
		if( findtext(pose,".",-1) == 0 && findtext(pose,"!",-1) == 0 && findtext(pose,"?",-1) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\n[t_He] is [pose]"

	//someone here, but who?
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species && H.species.name != ABDUCTOR)
			for(var/obj/item/clothing/suit/armor/abductor/vest/V in list(wear_suit))
				if(V.stealth_active)
					to_chat(H, "<span class='notice'>You can't focus your eyes on [src].</span>")
					return

	if(roundstart_quirks.len && isobserver(user))
		var/mob/dead/observer/O = user
		if(O.started_as_observer)
			msg += "<span class='notice'>[t_He] has these traits: [get_trait_string()].</span>"

	to_chat(user, msg)

//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M, hudtype)
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		switch(hudtype)
			if("security")
				return istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/hud/secmed)
			if("medical")
				return istype(H.glasses, /obj/item/clothing/glasses/hud/health) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/hud/secmed)
			else
				return 0
	else if(istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		switch(hudtype)
			if("security")
				return istype(R.module_state_1, /obj/item/borg/sight/hud/sec) || istype(R.module_state_2, /obj/item/borg/sight/hud/sec) || istype(R.module_state_3, /obj/item/borg/sight/hud/sec)
			if("medical")
				return istype(R.module_state_1, /obj/item/borg/sight/hud/med) || istype(R.module_state_2, /obj/item/borg/sight/hud/med) || istype(R.module_state_3, /obj/item/borg/sight/hud/med)
			else
				return 0
	else
		return 0

/mob/living/proc/status_effect_examines() //You can include this in any mob's examine() to show the examine texts of status effects!
	var/list/dat = list()
	for(var/V in status_effects)
		var/datum/status_effect/E = V
		if(E.examine_text)
			dat += "[E.examine_text]\n" //dat.Join("\n") doesn't work here, for some reason
	if(dat.len)
		return dat.Join()

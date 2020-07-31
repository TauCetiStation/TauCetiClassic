#define CHANGELING_STATPANEL_STATS(BYOND) \
	if(mind && mind.changeling) \
	{ \
		stat("Chemical Storage", "[mind.changeling.chem_charges]/[mind.changeling.chem_storage]"); \
		stat("Genetic Damage Time", mind.changeling.geneticdamage); \
		stat("Absorbed DNA", mind.changeling.absorbedcount); \
	}


#define CHANGELING_STATPANEL_POWERS(BYOND) \
	if(mind && mind.changeling && mind.changeling.purchasedpowers.len) \
	{ \
		for(var/P in mind.changeling.purchasedpowers) \
		{ \
			var/obj/effect/proc_holder/changeling/S = P; \
			if(S.chemical_cost >=0 && S.can_be_used_by(src)) \
			{ \
				statpanel("[S.panel]", ((S.chemical_cost > 0) ? "[S.chemical_cost]" : ""), S); \
			} \
		} \
	}

// see _DEFINES/is_helpers.dm for mob type checks
#define SAFE_PERP -50

/mob/living/proc/isSynthetic()
	return FALSE

/mob/living/carbon/human/isSynthetic(target_zone)
	if(isnull(full_prosthetic))
		robolimb_count = 0
		for(var/obj/item/organ/external/BP in bodyparts)
			if(BP.is_robotic())
				robolimb_count++
		full_prosthetic = (robolimb_count == bodyparts.len)

	if(!full_prosthetic && target_zone)
		var/obj/item/organ/external/BP = get_bodypart(target_zone)
		if(BP)
			return BP.is_robotic()

	return full_prosthetic

/mob/living/silicon/isSynthetic()
	return TRUE

/proc/hsl2rgb(h, s, l)
	return

/proc/ismindshielded(A, only_mindshield = FALSE) //Checks to see if the person contains a mindshield implant, then checks that the implant is actually inside of them

	for(var/obj/item/weapon/implant/mindshield/L in A)
		if(only_mindshield && L.type != /obj/item/weapon/implant/mindshield)
			continue
		if(L.implanted)
			return TRUE
	return FALSE

/proc/isloyal(A)
	for(var/obj/item/weapon/implant/mindshield/loyalty/L in A)
		if(L.implanted)
			return TRUE
	return FALSE

/proc/check_zone(zone)
	if(!zone)
		return BP_CHEST

	switch(zone)
		if(O_EYES)
			zone = BP_HEAD
		if(O_MOUTH)
			zone = BP_HEAD

	return zone

// Returns zone with a certain probability.
// If the probability misses, returns "chest" instead.
// If "chest" was passed in as zone, then on a "miss" will return "head", "l_arm", or "r_arm"
// Do not use this if someone is intentionally trying to hit a specific body part.
// Use get_zone_with_miss_chance() for that.
/proc/ran_zone(zone, probability = 90)
	zone = check_zone(zone)
	if(probability == 100)
		return zone

	if(zone == BP_CHEST)
		if(prob(probability))
			return BP_CHEST

		var/t = rand(1, 9)
		switch(t)
			if(1 to 3) return BP_HEAD
			if(4 to 6) return BP_L_ARM
			if(7 to 9) return BP_R_ARM

	if(prob(probability * 0.75))
		return zone

	return BP_CHEST

// Emulates targetting a specific body part, and miss chances
// May return null if missed
// miss_chance_mod may be negative.
/proc/get_zone_with_miss_chance(zone, mob/target, miss_chance_mod = 0)
	zone = check_zone(zone)

	// you can only miss if your target is standing and not restrained
	if(!target.buckled && !target.lying)
		var/miss_chance = 10
		switch(zone)
			if(BP_HEAD)
				miss_chance = 50
			if(BP_GROIN)
				miss_chance = 50
			if(BP_L_ARM)
				miss_chance = 60
			if(BP_R_ARM)
				miss_chance = 60
			if(BP_L_LEG)
				miss_chance = 60
			if(BP_R_LEG)
				miss_chance = 60
		if(prob(max(miss_chance + miss_chance_mod, 0)))
			if(prob(max(20, (miss_chance/2))))
				return null
			else
				var/t = rand(1, 100)
				switch(t)
					if(1 to 65)
						return BP_CHEST
					if(66 to 75)
						return BP_HEAD
					if(76 to 80)
						return BP_L_ARM
					if(81 to 85)
						return BP_R_ARM
					if(86 to 90)
						return BP_R_LEG
					if(91 to 95)
						return BP_L_LEG
					if(96 to 100)
						return BP_GROIN

	return zone

/proc/get_zone_with_probabilty(zone, probability = 80)

	zone = check_zone(zone)

	if(prob(probability))
		return zone

	var/t = rand(1, 18) // randomly pick a different zone, or maybe the same one
	switch(t)
		if(1)        return BP_HEAD
		if(2)        return BP_CHEST
		if(3 to 6)   return BP_L_ARM
		if(7 to 10)  return BP_R_ARM
		if(11 to 14) return BP_L_LEG
		if(15 to 18) return BP_R_LEG

	return zone

/proc/stars(text, probability = 25)
	if (probability >= 100)
		return text

	text = html_decode(text)

	var/new_text = ""
	var/bytes_length = length(text)
	var/letter = ""
	for(var/i = 1, i <= bytes_length, i += length(letter))
		letter = text[i]
		if(letter != " " && prob(probability))
			new_text += "*"
		else
			new_text += letter

	return new_text

/proc/slur(text)

	text = html_decode(text)

	var/bytes_length = length(text)
	var/new_text = ""
	var/letter = ""
	var/new_letter = ""

	for(var/i = 1, i <= bytes_length, i += length(letter))
		letter = text[i]
		new_letter = letter

		if(prob(35))
			switch(lowertext(new_letter))
				// latin
				if("o")
					new_letter = "u"
				if("s")
					new_letter = "ch"
				if("a")
					new_letter = "ah"
				if("c")
					new_letter = "k"
				// cyrillic
				if("ч")
					new_letter = "щ"
				if("е")
					new_letter = "и"
				if("з")
					new_letter = "с"
				if("к")
					new_letter = "х"

		switch(rand(1,15))
			if(1,3,5,8)
				new_letter = lowertext(new_letter)
			if(2,4,6,15)
				new_letter = uppertext(new_letter)
			if(7)
				new_letter += "'"

		new_text += new_letter

	return html_encode(capitalize(new_text))

/proc/stutter(text)

	text = html_decode(text)

	var/bytes_length = length(text)
	var/new_text = ""
	var/letter = ""
	var/new_letter = ""

	var/static/list/stutter_alphabet = list("b","c","d","f","g","h","j","k","l","m","n","p","q","r","s","t","v","w","x","y","z","б","в","г","д","ж","з","й","к","л","м","н","п","р","с","т","ф","х","ц","ч","ш","щ")


	for(var/i = 1, i <= bytes_length, i += length(letter))
		letter = text[i]
		new_letter = letter

		if(prob(80) && (lowertext(new_letter) in stutter_alphabet))
			if (prob(10))
				new_letter = "[new_letter]-[new_letter]-[new_letter]-[new_letter]"
			else
				if (prob(20))
					new_letter = "[new_letter]-[new_letter]-[new_letter]"
				else
					if (prob(5))
						new_letter = ""
					else
						new_letter = "[new_letter]-[new_letter]"

		new_text += new_letter

	return html_encode(new_text)

/proc/Gibberish(text, p) // Any value higher than 70 for p will cause letters to be replaced instead of added
	text = html_decode(text)

	var/bytes_length = length(text)
	var/new_text = ""
	var/letter = ""
	var/new_letter = ""

	for(var/i = 1, i <= bytes_length, i += length(letter))
		letter = text[i]
		new_letter = letter

		if(prob(50))

			if(p >= 70)
				new_letter = ""

			for(var/j = 1, j <= rand(0, 2), j++)
				new_letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		new_text += new_letter

	return html_encode(new_text)

/proc/GibberishAll(text) // Same as above, except there is no probability and chance always 100.
	text = html_decode(text)

	var/bytes_length = length(text)
	var/new_text = ""
	var/letter = ""
	var/new_letter = ""

	for(var/i = 1, i <= bytes_length, i += length(letter))
		letter = text[i]
		new_letter = letter

		for(var/j = 1, j <= rand(0, 2), j++)
			new_letter += pick("#","@","*","&","%","$","/", "<", ">", ";","*","*","*","*","*","*","*")

		new_text += new_letter

	return html_encode(new_text)

/proc/zombie_talk(var/message)
	var/list/message_list = splittext(message, " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len)
		message_list.Insert(insertpos, "[pick("МОЗГИ", "Мозги", "Моозгиии", "МОООЗГИИИИ", "БОЛЬНО", "БОЛЬ", "ПОМОГИ", "РАААА", "АААА", "АРРХ", "ОТКРОЙТЕ", "ОТКРОЙ")]...")

	for(var/i = 1, i <= message_list.len, i++)
		if(prob(50) && !(copytext(message_list[i], -3) == "..."))
			message_list[i] = message_list[i] + "..."

		if(prob(60))
			message_list[i] = stutter(message_list[i])

		message_list[i] = stars(message_list[i], 80)

		if(prob(60))
			message_list[i] = slur(message_list[i])

	return jointext(message_list, " ")

/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || !strength) return
	spawn()
		strength *= 32
		for(var/i=0; i<duration, i++)
			animate(M.client, pixel_x = rand(-strength,strength), pixel_y = rand(-strength,strength), time = 2)
			sleep(2)
		animate(M.client, pixel_x = 0, pixel_y = 0, time = 2)


/proc/findname(msg)
	for(var/mob/M in mob_list)
		if (M.real_name == text("[msg]"))
			return 1
	return 0


/mob/proc/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask)))
		return 1

	if((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )))
		return 1

	if(l_hand && !l_hand.flags&ABSTRACT || r_hand && !r_hand.flags&ABSTRACT)
		return 1

	return 0

//converts intent-strings into numbers and back
var/list/intents = list(INTENT_HELP, INTENT_PUSH, INTENT_GRAB, INTENT_HARM)
/proc/intent_numeric(argument)
	if(istext(argument))
		switch(argument)
			if(INTENT_HELP)
				return 0
			if(INTENT_PUSH)
				return 1
			if(INTENT_GRAB)
				return 2
			else
				return 3
	else
		switch(argument)
			if(0)
				return INTENT_HELP
			if(1)
				return INTENT_PUSH
			if(2)
				return INTENT_GRAB
			else
				return INTENT_HARM

//change a mob's act-intent. Use the defines of style INTENT_%thingy%
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(isliving(src))
		switch(input)
			if(INTENT_HELP, INTENT_PUSH, INTENT_GRAB, INTENT_HARM)
				a_intent = input
			if(INTENT_HOTKEY_RIGHT)
				a_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
			if(INTENT_HOTKEY_LEFT)
				a_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)
		if(hud_used && hud_used.action_intent)
			hud_used.action_intent.icon_state = "intent_[a_intent]"

/proc/broadcast_security_hud_message(message, broadcast_source)
	broadcast_hud_message(message, broadcast_source, sec_hud_users)

/proc/broadcast_medical_hud_message(message, broadcast_source)
	broadcast_hud_message(message, broadcast_source, med_hud_users)

/proc/broadcast_hud_message(message, broadcast_source, list/targets)
	var/turf/sourceturf = get_turf(broadcast_source)
	for(var/mob/M in targets)
		var/turf/targetturf = get_turf(M)
		if((targetturf.z == sourceturf.z))
			to_chat(M, "<span class='info'>[bicon(broadcast_source)] [message]</span>")
	for(var/mob/dead/observer/G in player_list) //Ghosts? Why not.
		to_chat(G, "<span class='info'>[bicon(broadcast_source)] [message]</span>")

/mob/living/proc/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	if(stat == DEAD)
		return SAFE_PERP
	return 0

/mob/living/carbon/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	if(handcuffed)
		return SAFE_PERP
	return ..()

/mob/living/carbon/human/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	var/threatcount = ..()
	if(threatcount == SAFE_PERP)
		return SAFE_PERP

	//Agent cards lower threatlevel.
	var/obj/item/weapon/card/id/id = null
	if(wear_id)
		id = wear_id.GetID()
	else if(l_hand)
		id = l_hand.GetID()
	else if(r_hand)
		id = r_hand.GetID()

	if(id && istype(id, /obj/item/weapon/card/id/syndicate))
		threatcount -= 2
	// A proper CentCom id is hard currency.
	else if(id && is_type_in_list(id, list(/obj/item/weapon/card/id/centcom, /obj/item/weapon/card/id/ert)))
		return SAFE_PERP

	if(check_access && !access_obj.allowed(src))
		threatcount += 4

	if(auth_weapons && !access_obj.allowed(src))
		var/list/weapon_list = list(/obj/item/weapon/gun, /obj/item/weapon/melee)
		if(l_hand && is_type_in_list(l_hand, weapon_list))
			threatcount += 4

		if(r_hand && is_type_in_list(r_hand, weapon_list))
			threatcount += 4

		if(belt && is_type_in_list(belt, weapon_list))
			threatcount += 2

		if(species.name != HUMAN)
			threatcount += 2

	if(check_records || check_arrest)
		var/perpname = name
		if(id)
			perpname = id.registered_name

		var/datum/data/record/R = find_security_record("name", perpname)
		if(check_records && !R)
			threatcount += 4

		if(check_arrest && R && (R.fields["criminal"] == "*Arrest*"))
			threatcount += 4

	return threatcount

/mob/living/simple_animal/hostile/assess_perp(obj/access_obj, check_access, auth_weapons, check_records, check_arrest)
	var/threatcount = ..()
	if(threatcount == SAFE_PERP)
		return SAFE_PERP

	if(!istype(src, /mob/living/simple_animal/hostile/retaliate/goat) && !istype(src, /mob/living/simple_animal/hostile/mining_drone))
		threatcount += 4
	return threatcount

#undef SAFE_PERP

/proc/IsAdminGhost(mob/user)
	if(!istype(user)) // Are they a mob? Auto interface updates call this with a null src
		return
	if(!user.client) // Do they have a client?
		return
	if(!isobserver(user)) // Are they a ghost?
		return
	if(!check_rights_for(user.client, R_ADMIN)) // Are they allowed?
		return
	if(!user.client.AI_Interact) // Do they have it enabled?
		return
	return TRUE

/mob/proc/is_busy(atom/target, show_warning = TRUE)
	if(busy_with_action)
		if(show_warning)
			to_chat(src, "<span class='warning'>You are busy. Please finish or cancel your current action.</span>")
		return TRUE
	if(target && target.in_use_action)
		if(show_warning)
			to_chat(src, "<span class='warning'>Please wait while someone else will finish interacting with [target].</span>")
		return TRUE
	return FALSE

/mob/proc/become_busy(_hand = 0)
	busy_with_action = TRUE

/mob/proc/become_not_busy(_hand = 0)
	busy_with_action = FALSE

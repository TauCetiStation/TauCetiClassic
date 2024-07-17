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

/mob/proc/ismindshielded() //Checks to see if the person contains a mindshield implant, then checks that the implant is actually inside of them
	for(var/obj/item/weapon/implant/mind_protect/mindshield/L in src)
		if(L.implanted)
			return TRUE
	return FALSE

/mob/proc/isloyal()
	for(var/obj/item/weapon/implant/mind_protect/loyalty/L in src)
		if(L.implanted)
			return TRUE
	return FALSE

/mob/proc/ismindprotect()
	for(var/obj/item/weapon/implant/mind_protect/L in src)
		if(L.implanted)
			return TRUE
	return FALSE

/mob/proc/isimplantedobedience()
	for(var/obj/item/weapon/implant/obedience/L in src)
		if(L.implanted)
			return TRUE
	return FALSE

/mob/proc/isimplantedblueshield()
	for(var/obj/item/weapon/implant/blueshield/L in src)
		if(L.implanted)
			return TRUE
	return FALSE

/mob/proc/isimplantedchem()
	for(var/obj/item/weapon/implant/chem/L in src)
		if(L.implanted)
			return TRUE
	return FALSE

/mob/proc/isimplantedtrack()
	for(var/obj/item/weapon/implant/tracking/L in src)
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
	if(target.buckled || target.lying)
		return zone

	var/miss_chance = 10
	switch(zone)
		if(BP_HEAD, BP_GROIN)
			miss_chance = 50
		if(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)
			miss_chance = 60

	if(!prob(miss_chance + miss_chance_mod)) // chance to hit
		return zone

	if(prob(max(20, miss_chance / 2))) // chance to fully miss
		return null

	// redirecting
	return pickweight(list(
		BP_CHEST = 65,
		BP_HEAD  = 10,
		BP_L_ARM = 5,
		BP_R_ARM = 5,
		BP_L_LEG = 5,
		BP_R_LEG = 5,
		BP_GROIN = 5,
	))

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

	return html_encode(capitalize(new_text))

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
			if(1 to 4)
				new_letter = lowertext(new_letter)
			if(5 to 9)
				new_letter = uppertext(new_letter)
			if(10)
				new_letter += "'"
			if(11 to 15)
				SWITCH_PASS

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

	return html_encode(capitalize(new_text))

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

/proc/zombie_talk(message)
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

/proc/turret_talk(message, species)
	if(!(species in tourette_bad_words))
		return message
	var/list/message_list = splittext(message, " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)
	for(var/i in 1 to rand(maxchanges / 2, maxchanges))
		var/insertpos = rand(1, message_list.len)
		message_list[insertpos] = pick(tourette_bad_words[species])
	return jointext(message_list, " ")

var/global/list/cursed_words = list("МРАЧНЫЕ ВРЕМЕНА", "ТЬМА", "БУРЯ", "ВОЙНА", "ПУТЬ НА КОТОРОМ НЕ СНОСИТЬ ГОЛОВЫ", "КОПЬЕ", "УБИТЬ", "КРОВЬ",  "ЧИСТИЛИЩЕ", "МУЧИТЕЛЬНАЯ БОЛЬ", "МЯСО", "БОЙНЯ", "ПЫТКИ", "КРОВАВЫЙ ДОЖДЬ", "РАЗРЫВАЮЩИЕСЯ ГЛАЗНЫЕ ЯБЛОКИ", "ХАОС", "ВЗРЫВНОЕ УСТРОЙСТВО", "ДЕМОНИЧЕСКИЕ ВРАТА", "ЛАВА", "СМЕРТЬ", "РАЗОРВАННОЕ СЕРДЦЕ", "МУЧЕНИЯ", "СЖЕЧЬ", "РВОТА", "ВЫРВАННЫЙ ЯЗЫК", "ЗАБВЕНИЕ", "БЕЗЫСХОДНОСТЬ", "СУИЦИД", "БЕЗДНА", "ОБЕЗГЛАВЛИВАНИЕ", "РАЗРЫВ", "ДЫХАНИЕ СМЕРТИ", "УЖАСНАЯ УЧАСТЬ", "РАЗРУШЕНИЯ", "ГЛАЗНИЦА")
/proc/cursed_talk(message)
	var/text = ""
	var/words = round(length_char(message)/6)
	for(var/i in 1 to max(1, words))
		text += pick(cursed_words)
		if(i != words)
			text += " "

	return text


#define TILES_PER_SECOND 0.7
///Shake the camera of the person viewing the mob SO REAL!
///Takes the mob to shake, the time span to shake for, and the amount of tiles we're allowed to shake by in tiles
///Duration isn't taken as a strict limit, since we don't trust our coders to not make things feel shitty. So it's more like a soft cap.
/proc/shake_camera(mob/M, duration, strength=1)
	if(!M || !M.client || duration < 1)
		return
	var/client/C = M.client
	var/oldx = C.pixel_x
	var/oldy = C.pixel_y
	var/max = strength*world.icon_size
	var/min = -(strength*world.icon_size)

	//How much time to allot for each pixel moved
	var/time_scalar = (1 / world.icon_size) * TILES_PER_SECOND
	var/last_x = oldx
	var/last_y = oldy

	var/time_spent = 0
	while(time_spent < duration)
		//Get a random pos in our box
		var/x_pos = rand(min, max) + oldx
		var/y_pos = rand(min, max) + oldy

		//We take the smaller of our two distances so things still have the propencity to feel somewhat jerky
		var/time = round(max(min(abs(last_x - x_pos), abs(last_y - y_pos)) * time_scalar, 1))

		if (time_spent == 0)
			animate(C, pixel_x=x_pos, pixel_y=y_pos, time=time)
		else
			animate(pixel_x=x_pos, pixel_y=y_pos, time=time)

		last_x = x_pos
		last_y = y_pos
		//We go based on time spent, so there is a chance we'll overshoot our duration. Don't care
		time_spent += time

	animate(pixel_x=oldx, pixel_y=oldy, time=3)

#undef TILES_PER_SECOND


/proc/findname(msg)
	for(var/mob/M as anything in mob_list)
		if (M.real_name == text("[msg]"))
			return 1
	return 0


/mob/proc/abiotic(full_body = 0)
	if(full_body && ((l_hand.flags & ABSTRACT) || (r_hand && !(r_hand.flags & ABSTRACT)) || back || wear_mask))
		return TRUE

	if((l_hand && !(l_hand.flags & ABSTRACT)) || (r_hand && !(r_hand.flags & ABSTRACT)))
		return TRUE

	return FALSE

//converts intent-strings into numbers and back
var/global/list/intents = list(INTENT_HELP, INTENT_PUSH, INTENT_GRAB, INTENT_HARM)
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

/mob/proc/set_a_intent(new_intent)
	SEND_SIGNAL(src, COMSIG_MOB_SET_A_INTENT, new_intent)
	a_intent = new_intent
	if(hud_used)
		action_intent?.update_icon(src)

//change a mob's act-intent. Use the defines of style INTENT_%thingy%
/mob/verb/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1

	if(isliving(src))
		var/setting_intent = input
		switch(input)
			if(INTENT_HELP, INTENT_PUSH, INTENT_GRAB, INTENT_HARM)
				setting_intent = input
			if(INTENT_HOTKEY_RIGHT)
				setting_intent = intent_numeric((intent_numeric(a_intent)+1) % 4)
			if(INTENT_HOTKEY_LEFT)
				setting_intent = intent_numeric((intent_numeric(a_intent)+3) % 4)
		set_a_intent(setting_intent)
		SEND_SIGNAL(src, COMSIG_LIVING_INTENT_CHANGE, setting_intent)

/proc/broadcast_security_hud_message(message, broadcast_source)
	var/datum/atom_hud/hud = huds[DATA_HUD_SECURITY]
	var/list/sec_hud_users = hud.hudusers
	broadcast_hud_message(message, broadcast_source, sec_hud_users)

/proc/broadcast_medical_hud_message(message, broadcast_source)
	var/datum/atom_hud/hud = huds[DATA_HUD_MEDICAL]
	var/list/med_hud_users = hud.hudusers
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
	else if(id && istype(id, /obj/item/weapon/card/id/centcom))
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

/**
 * Fancy notifications for ghosts
 *
 * The kitchen sink of notification procs
 *
 * Arguments:
 * * message
 * * ghost_sound sound to play
 * * enter_link Href link to enter the ghost role being notified for
 * * source The source of the notification
 * * alert_overlay The alert overlay to show in the alert message
 * * action What action to take upon the ghost interacting with the notification, defaults to NOTIFY_JUMP
 * * header The header of the notifiaction
 * * notify_volume How loud the sound should be to spook the user
 */
/proc/notify_ghosts(message, ghost_sound, enter_link, atom/source, mutable_appearance/alert_overlay, action = NOTIFY_JUMP, header, notify_volume = 100) //Easy notification of ghosts.
	for(var/mob/dead/observer/ghost as anything in observer_list)
		var/orbit_link
		if(source && action == NOTIFY_ORBIT)
			orbit_link = " <span class='ghostalert'>[FOLLOW_LINK(ghost, source)]</span>"
		to_chat(ghost, "<span class='ghostalert'>[message][(enter_link) ? " [enter_link]" : ""][orbit_link]</span>")
		if(ghost_sound)
			playsound(ghost, ghost_sound, VOL_EFFECTS_MASTER, notify_volume)
		if(!source)
			continue
		var/atom/movable/screen/alert/notify_action/alert = ghost.throw_alert("[REF(source)]_notify_action", /atom/movable/screen/alert/notify_action, new_master=source)
		if(!alert)
			continue
		if (header)
			alert.name = header
		alert.desc = message
		alert.action = action
		alert.target = source
		if(!alert_overlay)
			alert_overlay = new(source)
			var/icon/size_check = icon(source.icon, source.icon_state)
			var/scale = 1
			var/width = size_check.Width()
			var/height = size_check.Height()
			if(width > world.icon_size || height > world.icon_size)
				if(width >= height)
					scale = world.icon_size / width
				else
					scale = world.icon_size / height
			alert_overlay.transform = alert_overlay.transform.Scale(scale)
			alert_overlay.appearance_flags |= TILE_BOUND
		alert_overlay.plane = ABOVE_HUD_PLANE
		alert.add_overlay(alert_overlay)

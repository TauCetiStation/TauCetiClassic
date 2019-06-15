#define DIONA_SUBJECT_NONE 0 // Nobody selected.
#define DIONA_SUBJECT_ALL 1 // Any nymph who can hear.
#define DIONA_SUBJECT_BODY 2 // Any nymph that makes up our body.
#define DIONA_SUBJECT_GESTALT 4 // Any nymph that is in our gestalt-mind-network-thing.
#define DIONA_SUBJECT_MIND 8 // Any nymph that is sitting in us, as in, merged.

/proc/message2order(message) // Returns selectors extracted.
	var/list/potential_tokens = splittext(replace_characters(message, list("," = " ", ":" = " ", ";" = " ", "." = " ", "\t" = " ", "\n" = " ")), " ")
	var/list/tokens = list()

	for(var/tok in potential_tokens)
		if(findtext(tok, " "))
			continue
		if(!tok)
			continue
		tokens += tok

	var/subject = ""
	var/command = ""
	var/selector = ""
	switch(tokens.len)
		if(0)
			;
		if(1)
			subject = tokens[1]
		if(2)
			subject = tokens[1]
			command = tokens[2]
		else
			subject = tokens[1]
			command = tokens[2]
			selector = tokens[3]
	return list("sub" = subject, "ord" = command, "sel" = selector)

/mob/living/carbon/monkey/diona/proc/handle_order_queue() // Extracts "missions" from "orders".
	if(speech_buffer.len)
		var/mob/living/speaker = speech_buffer[1]
		var/message = speech_buffer[2]

		var/list/selectors = message2order(message)

		var/permission_level = DIONA_SUBJECT_NONE
		if(speaker == gestalt)
			if(findtext(selectors["sub"], num2text(my_number)))
				permission_level |= DIONA_SUBJECT_ALL|DIONA_SUBJECT_BODY|DIONA_SUBJECT_GESTALT|DIONA_SUBJECT_MIND
			else if(findtext(selectors["sub"], "gestalt"))
				permission_level |= DIONA_SUBJECT_GESTALT
			else if(findtext(selectors["sub"], "body") && istype(loc.loc, /obj/item/organ/external))
				permission_level |= DIONA_SUBJECT_BODY
			else if(findtext(selectors["sub"], "mind") && loc == gestalt)
				permission_level |= DIONA_SUBJECT_MIND
			else if(findtext(selectors["sub"], "selected"))
				permission_level |= DIONA_SUBJECT_ALL|DIONA_SUBJECT_BODY|DIONA_SUBJECT_GESTALT|DIONA_SUBJECT_MIND
			else if(findtext(selectors["sub"], "all"))
				permission_level |= DIONA_SUBJECT_ALL|DIONA_SUBJECT_GESTALT
		else
			if(findtext(selectors["sub"], "all"))
				permission_level |= DIONA_SUBJECT_ALL
			else if(findtext(selectors["sub"], num2text(my_number)))
				permission_level |= DIONA_SUBJECT_ALL

		if(loc != gestalt)
			permission_level &= ~DIONA_SUBJECT_MIND
		else if(!istype(loc.loc, /obj/item/organ/external))
			permission_level &= ~DIONA_SUBJECT_BODY

		if(loc == gestalt && !(permission_level & DIONA_SUBJECT_MIND))
			permission_level = DIONA_SUBJECT_NONE
		else if(istype(loc.loc, /obj/item/organ/external) && !(permission_level & DIONA_SUBJECT_BODY))
			permission_level = DIONA_SUBJECT_NONE

		if(selectors["ord"])
			var/datum/nymph_order/NO = nymph_orders[lowertext(selectors["ord"])]
			if(NO)
				NO.attempt(speaker, src, permission_level, message, selectors)
			else
				speech_buffer.Cut(1, 3)

/mob/living/carbon/monkey/diona/proc/display_cloud(indicator, mob/living/carbon/human/ent)
	if(indicator && ent && ent.client)
		var/image/indicator_cloud = image('icons/mob/diona_indicator.dmi', loc = src, icon_state = indicator, layer = MOB_LAYER + 1)
		/*var/list/display_to = list()
		for(var/mob/M in viewers(src))
			if(M.client)
				display_to += M.client*/
		flick_overlay(indicator_cloud, list(ent.client), 3 SECONDS)

var/global/list/nymph_orders = list()

/proc/initiate_nymph_orders()
	for(var/type in (subtypesof(/datum/nymph_order) - /datum/nymph_order/target_action))
		var/datum/nymph_order/NO = new type
		nymph_orders[NO.command] = NO

/datum/nymph_order
	var/command = ""
	var/desc = "" // Format: "command - description of command".
	var/permissions_required = DIONA_SUBJECT_NONE // bitflag. at least one of these should be given to diona for order to executed.

	var/success_indicator = "order_done" // Icon state to grab from icons/mob/nymph_indicators.dmi
	var/list/fail_indicators = list("no_permission" = "no_permission", "no_selector" = "no_selector") // list(return_code = icon_state)

	/*
	    Selectors:
	       - "mind" - the ent giving orders.
	       - "pointer" - last pointed.
	       - "self" - applying action to the nymph itself.
	       - "stop" - stop this action.
	*/
	var/list/allowed_selectors = list()
	var/list/allowed_pointers = list() // Allowed types a pointer can be.

/datum/nymph_order/proc/attempt(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	if(is_accessible(ent, sub, permission_bitflag, message, selectors))
		var/fail_code = execute(ent, sub, permission_bitflag, message, selectors)
		if(!fail_code)
			sub.display_cloud(success_indicator, ent)
		else
			sub.display_cloud(fail_indicators[fail_code], ent)
	else
		if(findtext(selectors["sel"], "mind") || findtext(selectors["sel"], "body") || findtext(selectors["sel"], "gestalt") || findtext(selectors["sel"], "all"))
			sub.display_cloud(fail_indicators["no_permission"], ent) // Don't annoy with this when we never even intended to adress the nymph(Individual orders).
		on_no_permission(ent, sub, permission_bitflag, message, selectors)
	after_attempt(ent, sub, permission_bitflag, message, selectors)

/datum/nymph_order/proc/is_accessible(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	return permissions_required & permission_bitflag

/datum/nymph_order/proc/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	return

/datum/nymph_order/proc/on_no_permission(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	return

/datum/nymph_order/proc/after_attempt(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	sub.speech_buffer.Cut(1, 3) // We attempted this, next.

/datum/nymph_order/target_action
	success_indicator = "affirmative"
	var/action_on_target = ""
	var/max_dist_from_target = 1 // Basically an Adjacent check.

	allowed_selectors = list("mind" = "mind - The one giving commands.", "pointer" = "pointer - Last pointed thing", "self" = "self - Self.", "stop" = "stop - Stop.")
	allowed_pointers = list(/atom)

/datum/nymph_order/target_action/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	if(selectors["sel"] != "")
		for(var/selector in allowed_selectors)
			if(findtext(selector, selectors["sel"]))
				. = selector_process(ent, sub, permission_bitflag, message, selectors, selector)
				break
	else
		return "no_selector"

/datum/nymph_order/target_action/proc/selector_process(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors, process_sel)
	switch(process_sel)
		if("mind")
			sub.set_target_action(ent, action_on_target, max_dist_from_target)
		if("pointer")
			if(is_type_in_list(sub.last_pointed, allowed_pointers))
				sub.set_target_action(sub.last_pointed, action_on_target, max_dist_from_target)
		if("self")
			sub.set_target_action(sub, action_on_target, max_dist_from_target)
		if("stop")
			if(sub.action_on_target == action_on_target)
				sub.set_target_action(null)
		else
			return "no_selector"

/datum/nymph_order/target_action/after_attempt(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors, process_sel)
	return // We remove the command from buffer after when it's accomplished, see diona.dm.

/datum/nymph_order/target_action/on_no_permission(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	sub.speech_buffer.Cut(1, 3) // *look at the comment above*: Unless we don't!

/*
The orders begin here.
*/

/datum/nymph_order/join
	command = "join"
	desc = "join - Make nymph join your hive."
	permissions_required = DIONA_SUBJECT_ALL

/datum/nymph_order/join/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	if(sub.gestalt)
		return "no_permission"
	else
		sub.set_gestalt(ent)



/datum/nymph_order/leave
	command = "leave"
	desc = "leave - Make nymph leave the hive."
	permissions_required = DIONA_SUBJECT_GESTALT

/datum/nymph_order/leave/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	sub.set_gestalt(null)



/datum/nymph_order/split
	command = "split"
	desc = "split - Makes nymph split form gestalt."
	permissions_required = DIONA_SUBJECT_GESTALT|DIONA_SUBJECT_MIND|DIONA_SUBJECT_BODY
	fail_indicators = list("no_permission" = "no_permission", "no_selector" = "no_selector", "no_location" = "no_location")

/datum/nymph_order/split/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	if(permission_bitflag & DIONA_SUBJECT_BODY)
		var/obj/item/organ/external/O = sub.loc.loc
		O.droplimb(no_explode = TRUE, clean = TRUE, disintegrate = DROPLIMB_EDGE)
	else if(sub.loc == sub.gestalt)
		sub.split()
	else
		return "no_location"



/datum/nymph_order/hide
	command = "hide"
	desc = "hide - Order nymphs to hide."
	permissions_required = DIONA_SUBJECT_GESTALT
	fail_indicators = list("no_permission" = "no_permission", "no_selector" = "no_selector", "no_location" = "no_location")

/datum/nymph_order/hide/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	var/atom/movable/candidate
	var/candidate_distance = world.view + 1

	for(var/atom/movable/AM in view(7, sub))
		var/AM_dist = get_dist(src, AM)
		if(AM_dist > candidate_distance)
			continue
		if(AM == sub.gestalt)
			candidate = AM
			candidate_distance = AM_dist
		if(istype(AM, /obj/structure/closet))
			var/good_closet = FALSE
			var/obj/structure/closet/C = AM
			if(istype(C, /obj/structure/closet/secure_closet))
				var/obj/structure/closet/secure_closet/SC = C
				if(SC.allowed(src) && !SC.welded)
					good_closet = TRUE
			if(C.can_open())
				good_closet = TRUE
			if(good_closet)
				candidate = AM
				candidate_distance = AM_dist
		if(sub.can_ventcrawl() && is_type_in_list(AM, ventcrawl_machinery))
			candidate = AM
			candidate_distance = AM_dist
	if(candidate == sub.gestalt)
		sub.set_target_action(candidate, "merge")
	else if(is_type_in_list(candidate, ventcrawl_machinery))
		sub.set_target_action(candidate, "ventcrawl")
	else if(istype(candidate, /obj/structure/closet))
		sub.set_target_action(candidate, "closet_hide")
	else
		return "no_location"



/datum/nymph_order/status
	command = "status"
	desc = "status - Makes nymph report."
	permissions_required = DIONA_SUBJECT_ALL|DIONA_SUBJECT_BODY|DIONA_SUBJECT_GESTALT|DIONA_SUBJECT_MIND

	allowed_selectors = list("mind" = "mind - Report on who is mind.", "pointer" = "pointer - Last pointed thing", "self" = "self - Self.")

/datum/nymph_order/status/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	var/say_message = ""
	var/language_key = ":q"

	if(findtext(selectors["sel"], "pointer"))
		say_message = "[sub.last_pointed.desc]"
	else if(findtext(selectors["sel"], "mind"))
		if(ent == sub.gestalt)
			say_message = "Is mind."
		else
			say_message = "Not mind."
	else if(findtext(selectors["sel"], "self"))
		var/total_damage = sub.getBruteLoss() + sub.getFireLoss()
		var/damage_message = ""
		var/food_message = ""
		var/is_mind = "mind"
		if(ent != sub.gestalt)
			is_mind =  "not mind"
		switch(total_damage)
			if(0)
				damage_message = "Perfectly fine, [is_mind]."
			if(1 to 20)
				damage_message = "Need time, [is_mind]."
			if(21 to 50)
				damage_message = "Need rest bad, [is_mind]."
			if(51 to 100)
				damage_message = "Need time, rest and help, [is_mind]."
			else
				damage_message = "Bad, [is_mind]."
		switch(sub.get_nutrition())
			if(0)
				food_message = "Food - bad, [is_mind]."
			if(1 to 200)
				food_message = "Need food bad, [is_mind]."
			if(201 to 250)
				food_message = "Need more food, [is_mind]."
			if(251 to 300)
				food_message = "Food - good, [is_mind]."
			if(301 to 400)
				food_message = "Food - great, [is_mind]."
		say_message = "[damage_message] [food_message]"
	if(say_message)
		var/turf/T = get_turf(ent) || get_turf(sub)
		if(istype(sub.loc.loc, /obj/item/organ))
			var/obj/item/organ/O = sub.loc.loc
			T = get_turf(O.owner)
		if(istype(T, /turf/space))
			language_key = ":f"
		else
			var/datum/gas_mixture/environment = T.return_air()
			if(environment)
				var/pressure = environment.return_pressure()
				if(pressure < SOUND_MINIMUM_PRESSURE)
					language_key = ":f"
		sub.say("[language_key] [say_message]")



/datum/nymph_order/say
	command = "say"
	desc = "say - Force nymph to speak."
	permissions_required = DIONA_SUBJECT_GESTALT|DIONA_SUBJECT_BODY|DIONA_SUBJECT_MIND

	allowed_selectors = list("Rootspeak" = "Rootspeak - Speak in your own native language.", "Rootsong" = "Rootsong - Speak in a language that traverses through space.", "generic" = "generic - Speak in Galactic Common.", "none" = "none - Nymph will feel in whatever language.")

/datum/nymph_order/say/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	var/to_say = ""
	var/language_key = ":q"
	var/speech_pos = findtext(message, selectors["sel"])
	var/datum/language/L = all_languages[selectors["sel"]]
	if(L)
		language_key = ":[L.key[1]]"
		to_say = copytext(message, speech_pos + lentext(selectors["sel"]))
	else if(findtext(selectors["sel"], "generic"))
		language_key = "" // So we don't use any. Bootleg, but it works.
		to_say = copytext(message, speech_pos + lentext(selectors["sel"]))
	else
		var/found_lang = FALSE
		if(message[speech_pos - 2] == ":")
			for(var/lang in all_languages)
				var/datum/language/LL = all_languages[lang]
				for(var/k in LL.key)
					if(findtext(selectors["sel"], k))
						found_lang = TRUE
						language_key = ":[k]"
						to_say = copytext(message, speech_pos + lentext(selectors["sel"]))
						break

		if(!found_lang)
			to_say = copytext(message, speech_pos - 1)

	sub.say(language_key + to_say)



/datum/nymph_order/stay
	command = "stay"
	desc = "stay - Order nymph to stay in place."
	permissions_required = DIONA_SUBJECT_GESTALT

	allowed_selectors = list("stop" = "stop - Allow movement.")

/datum/nymph_order/stay/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	if(findtext(selectors["sel"], "stop"))
		sub.disable_random_movement = FALSE
		sub.following = null
		sub.set_target_action(null)
	else
		sub.disable_random_movement = TRUE
		sub.set_target_action(null)



/datum/nymph_order/select
	command = "select"
	desc = "select - Selects nymph."
	permissions_required = DIONA_SUBJECT_GESTALT|DIONA_SUBJECT_BODY|DIONA_SUBJECT_MIND

	allowed_selectors = list("stop" = "stop - Cancels the selection.")

/datum/nymph_order/select/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	if(findtext(selectors["sel"], "stop"))
		sub.selected = FALSE
	else
		sub.selected = TRUE



/datum/nymph_order/follow
	command = "follow"
	desc = "follow - Order nymph to follow something."
	permissions_required = DIONA_SUBJECT_GESTALT|DIONA_SUBJECT_MIND

	allowed_selectors = list("stop" = "stop - Stop following.", "pointer" = "pointer - Last pointed thing.", "mind" = "mind - The one giving commands.")
	allowed_pointers = list(/atom)

/datum/nymph_order/follow/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	if(findtext(selectors["sel"], "mind"))
		sub.following = ent
	else if(findtext(selectors["sel"], "pointer"))
		sub.following = sub.last_pointed
	else if(findtext(selectors["sel"], "stop"))
		sub.following = null



/*
/datum/nymph_order/morph
	command = "morph"
	desc = "morph - Morphs nymph into the pointed object."
	permissions_required = DIONA_SUBJECT_GESTALT

	allowed_selectors = list("pointer" = "pointer - Last pointed thing", "stop" = "stop - Demorphs the nymph.")
	allowed_pointers = list(/obj/item)

/datum/nymph_order/morph/execute(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	if(findtext(selectors["sel"], "pointer"))
		if(sub.last_pointed && is_type_in_list(sub.last_pointed, allowed_pointers))
			if(sub.loc == sub.gestalt)
				sub.split()
				sub.get_scooped(sub.gestalt)
			else if(istype(sub.loc.loc, /obj/item/organ/external))
				var/obj/item/organ/external/O = sub.loc.loc
				O.droplimb(no_explode = TRUE, clean = TRUE, disintegrate = DROPLIMB_EDGE)
				sub.loc.attack_hand(ent) // So we pick up the limb.
			sub.morph(sub.last_pointed)
			return
	else if(findtext(selectors["sel"], "stop"))
		if(istype(sub.loc, /obj/item/nymph_morph_ball))
			qdel(sub.loc)
			return
	return "no_selector"
*/



/datum/nymph_order/target_action/move_to
	command = "move"
	desc = "move - Order nymphs to move to target."
	permissions_required = DIONA_SUBJECT_GESTALT|DIONA_SUBJECT_MIND

	action_on_target = "" // No action, we just move.
	max_dist_from_target = 1 // So they wouldn't all bunch up together.



/datum/nymph_order/target_action/merge
	command = "merge"
	desc = "merge - Merge with target."
	permissions_required = DIONA_SUBJECT_GESTALT

	allowed_selectors = list("mind" = "mind - The one giving commands.", "stop" = "stop - Stop.")
	allowed_pointers = list(/mob/living/carbon/human)
	action_on_target = "merge"
	max_dist_from_target = 1

/datum/nymph_order/target_action/merge/is_accessible(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	return (permissions_required & permission_bitflag) && sub.can_merge()



/datum/nymph_order/target_action/grab
	command = "grab"
	desc = "grab - Grab the target."
	permissions_required = DIONA_SUBJECT_GESTALT

	allowed_selectors = list("pointer" = "pointer - Last pointed thing", "stop" = "stop - Stop.")
	allowed_pointers = list(/obj/item)
	action_on_target = "grab"
	max_dist_from_target = 1

/datum/nymph_order/target_action/grab/is_accessible(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	return (permissions_required & permission_bitflag) && !sub.get_active_hand() && !sub.get_inactive_hand()



/datum/nymph_order/target_action/drop
	command = "drop"
	desc = "drop - Drops the held item."
	permissions_required = DIONA_SUBJECT_GESTALT

	allowed_pointers = list(/atom)
	action_on_target = "drop"
	max_dist_from_target = 1

/datum/nymph_order/target_action/drop/is_accessible(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	return (permissions_required & permission_bitflag) && (sub.get_active_hand() || sub.get_inactive_hand())



/datum/nymph_order/target_action/bring
	command = "bring"
	desc = "bring - Bring the item."
	permissions_required = DIONA_SUBJECT_GESTALT

	allowed_selectors = list("pointer" = "pointer - Last pointed thing", "stop" = "stop - Stop.")
	allowed_pointers = list(/obj/item)
	action_on_target = "bring"
	max_dist_from_target = 1

/datum/nymph_order/target_action/bring/is_accessible(mob/living/carbon/human/ent, mob/living/carbon/monkey/diona/sub, permission_bitflag, message, selectors)
	return (permissions_required & permission_bitflag) && !sub.get_active_hand() && !sub.get_inactive_hand()



/datum/nymph_order/target_action/bite
	command = "bite"
	desc = "bite - Order to drink blood from the host."
	permissions_required = DIONA_SUBJECT_GESTALT

	allowed_selectors = list("pointer" = "pointer - Last pointed thing", "stop" = "stop - Stop.")
	allowed_pointers = list(/mob/living/carbon/human)
	action_on_target = "bite"
	max_dist_from_target = 1

#undef DIONA_SUBJECT_NONE
#undef DIONA_SUBJECT_BODY
#undef DIONA_SUBJECT_GESTALT
#undef DIONA_SUBJECT_ALL
#undef DIONA_SUBJECT_ME
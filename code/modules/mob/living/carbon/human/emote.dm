// sound's priorities
#define SOUND_PRIORITY_LOW    1
#define SOUND_PRIORITY_MEDIUM 2
#define SOUND_PRIORITY_HIGH   3

// these defines are made in order not to lose your mind(easier readability) and not to add a comment to each such check
#define ONE_HAND_IS_USABLE (!restrained() && ((bodyparts_by_name[BP_L_ARM] && bodyparts_by_name[BP_L_ARM].is_usable()) || (bodyparts_by_name[BP_R_ARM] && bodyparts_by_name[BP_R_ARM].is_usable())))
#define BOTH_HANDS_ARE_USABLE (!restrained() && bodyparts_by_name[BP_L_ARM] && bodyparts_by_name[BP_L_ARM].is_usable() && bodyparts_by_name[BP_R_ARM] && bodyparts_by_name[BP_R_ARM].is_usable())
#define HAS_HEAD (bodyparts_by_name[BP_HEAD] && bodyparts_by_name[BP_HEAD].is_usable()) // it may look weird but what if I told you that an IPC can live and make emotions without a head?

// auto = FALSE means that the sound is called by a human manually; auto = TRUE - automatically, in the code
/mob/living/carbon/human/emote(act = "", message_type = SHOWMSG_VISUAL, message = "", auto = TRUE)
	var/cloud_emote = ""
	var/sound_priority = SOUND_PRIORITY_LOW
	var/emote_sound
	var/conditions_for_emote = TRUE // special check in special emotions. For example, does a mob have the feeling of pain to scream from the pain?

	var/mute_message = "" // high priority. usuially VISIBLE
	var/muzzled_message = "" // medium priority. usually HEARABLE
	var/miming_message = "" // low priority. usually VISIBLE

	var/muted = HAS_TRAIT(src, TRAIT_MUTE)
	var/muzzled = istype(wear_mask, /obj/item/clothing/mask/muzzle)
	var/can_make_a_sound = !(muted || muzzled || silent)

	if(findtext(act, "s", -1) && !findtext(act, "_", -2)) // Removes ending s's unless they are prefixed with a '_'
		act = copytext(act, 1, -1)

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	if(stat == DEAD && (act != "deathgasp"))
		return

	var/his_macro = "its" // maybe put it in a separate file and expand the variables in such cases? I don't know how to make it through the BYOND macro
	switch(gender)
		if(FEMALE)
			his_macro = "her"
		if(MALE)
			his_macro = "his"
		if(PLURAL)
			his_macro = "their"
	var/he_macro = "it" // this too
	switch(gender)
		if(FEMALE)
			he_macro = "she"
		if(MALE)
			he_macro = "he"
		if(PLURAL)
			he_macro = "they"

	switch(act)

// ========== VOICED ==========

		if ("grunt")
			message_type = SHOWMSG_AUDIO
			message = pick("grunts slightly.", "groans.")
			mute_message = "writhes and sighs sligtly."
			muzzled_message = "groans silently!"
			miming_message = "appears to groan!"
			if(auto)
				conditions_for_emote = (!species.flags[NO_PAIN])
				sound_priority = SOUND_PRIORITY_MEDIUM
				message = pick("grunts in pain!", "grunts!", "wrinkles [his_macro] face and grunts!")
				emote_sound = (gender == FEMALE) ? pick(SOUNDIN_FEMALE_LIGHT_PAIN) : pick(SOUNDIN_MALE_LIGHT_PAIN)
			cloud_emote = "cloud-pain"
			add_combo_value_all(10)

		if("groan")
			message_type = SHOWMSG_AUDIO
			message = "groans."
			mute_message = pick("writhes and sighs sligtly.", "makes a very annoyed face.")
			muzzled_message = "makes a weak noise."
			miming_message = pick("slightly moans feigning pain.", "appears to be in pain!")
			if(auto)
				conditions_for_emote = (!species.flags[NO_PAIN])
				cloud_emote = "cloud-pain"
				sound_priority = SOUND_PRIORITY_MEDIUM
				message = pick("groans in pain.", "slightly winces in pain and groans.", "presses [his_macro] lips together in pain and groans.", "twists in pain.")
				if((get_species() != SKRELL) && HAS_TRAIT(src, TRAIT_LOW_PAIN_THRESHOLD) && prob(66)) // skrells don't have much emotions to cry in pain, but they can still groan
					emote_sound = pick((gender == FEMALE) ? SOUNDIN_FEMALE_WHINER_PAIN : SOUNDIN_MALE_WHINER_PAIN)
				else
					emote_sound = pick((gender == FEMALE) ? SOUNDIN_FEMALE_PASSIVE_PAIN : SOUNDIN_MALE_PASSIVE_PAIN)
			cloud_emote = "cloud-pain"
			add_combo_value_all(10)

		if ("scream")
			message_type = SHOWMSG_AUDIO
			message = pick("screams loudly!", "screams!")
			mute_message = pick("opens their mouth like a fish gasping for air!", "twists their face into an agonised expression!", "makes a very hurt expression!")
			muzzled_message = pick("makes a loud noise!", "groans soundly!", "screams silently!")
			miming_message = "acts out a scream!"
			conditions_for_emote = (get_species() != DIONA)
			if(auto)
				conditions_for_emote = (!species.flags[NO_PAIN])
				sound_priority = SOUND_PRIORITY_HIGH
				message = pick("screams in agony!", "writhes in heavy pain and screams!", "screams in pain as much as [he_macro] can!", "screams in pain loudly!")
				emote_sound = pick((gender == FEMALE) ? SOUNDIN_FEMALE_HEAVY_PAIN : SOUNDIN_MALE_HEAVY_PAIN)
			cloud_emote = "cloud-scream"
			add_combo_value_all(10)

		if ("cough")
			message_type = SHOWMSG_AUDIO
			message = (get_species() == DIONA) ? "creaks." : "coughs."
			mute_message = (get_species() == DIONA) ? "creaks." : "coughs."
			muzzled_message = "appears to [(get_species() == DIONA) ? "creak" : "cough"]."
			miming_message = (get_species() == DIONA) ? "creaks." : "coughs."
			if(auto)
				conditions_for_emote = (!species.flags[NO_BREATHE])
				sound_priority = SOUND_PRIORITY_MEDIUM
				emote_sound = pick((gender == FEMALE) ? SOUNDIN_FBCOUGH : SOUNDIN_MBCOUGH)

// ========== AUDIBLE ==========

		if ("choke")
			message_type = muted ? SHOWMSG_VISUAL : SHOWMSG_AUDIO
			message = "chokes."
			mute_message = "clutches their throat desperately!"
			muzzled_message = "makes a weak noise."

		if ("snore")
			message_type = SHOWMSG_AUDIO
			message = pick("snores.", "sleeps soundly.")
			muzzled_message = pick("snores.", "makes a noise.")
			miming_message = "snores."
			conditions_for_emote = (!species.flags[NO_BREATHE])

		if ("whimper")
			message_type = SHOWMSG_AUDIO
			message = "whimpers."
			mute_message = "whimpers"
			muzzled_message = pick("whimpers.", "makes a weak noise.", "whines.")
			miming_message = "whimpers."
			conditions_for_emote = (get_species() != ZOMBIE)

		if ("sniff")
			message_type = SHOWMSG_AUDIO
			message = "sniffs."
			mute_message = "sniffs."
			muzzled_message = "sniffs."
			miming_message = "sniffs."

		if ("sneeze")
			message_type = SHOWMSG_AUDIO
			message = "sneezes."
			mute_message = "sneezes."
			muzzled_message = "makes a strange noise."
			miming_message = "sneezes."
			conditions_for_emote = (get_species() != ZOMBIE)

		if ("gasp")
			message_type = SHOWMSG_AUDIO
			cloud_emote = "cloud-gasp"
			mute_message = "sucks in air violently!"
			miming_message = "appears to be gasping!"
			muzzled_message = "makes a weak noise."
			message = "gasps!"
			conditions_for_emote = (!species.flags[NO_BREATHE])

		if ("moan")
			message_type = SHOWMSG_AUDIO
			mute_message = "moans silently."
			miming_message = "appears to moan!"
			muzzled_message = "moans silently!"
			message = "moans!"
			conditions_for_emote = (get_species() != ZOMBIE)

		if ("sigh")
			message_type = SHOWMSG_AUDIO
			message = "sighs."
			muzzled_message = "makes a weak noise."
			miming_message = "sighs."
			conditions_for_emote = (get_species() != ZOMBIE)

		if ("mumble")
			message_type = SHOWMSG_VISUAL
			message = pick("grumbles.", "mumbles.")
			mute_message = "makes an annoyed face!"
			muzzled_message = "makes a weak noise"

// ========== HYBRID ==========

		if ("laugh")
			message_type = SHOWMSG_AUDIO | SHOWMSG_VISUAL
			message = "laughs."
			mute_message = "laughs silently."
			muzzled_message = pick("makes a weak noise.", "giggles sligthly.")
			miming_message = "acts out a laugh."
			conditions_for_emote = (get_species() != SKRELL) && HAS_HEAD && (get_species() != ZOMBIE)

		if ("cry")
			message_type = SHOWMSG_AUDIO | SHOWMSG_VISUAL
			message = "cries."
			muzzled_message = "makes a [pick("sad face", "weak noise")] and frowns."
			conditions_for_emote = (get_species() != SKRELL) && (get_species() != DIONA) && HAS_HEAD && (get_species() != ZOMBIE)

		if ("giggle")
			message_type = SHOWMSG_AUDIO | SHOWMSG_VISUAL
			message = pick("chuckles.", "giggles.")
			mute_message = "smiles slightly and [pick("chuckles", "giggles")] silently"
			muzzled_message = "[pick("chuckles", "giggles")] slightly."
			miming_message = "appears to [pick("chuckle", "giggle")]."
			conditions_for_emote = (get_species() != ZOMBIE)

		if ("clap")
			message_type = SHOWMSG_VISUAL | SHOWMSG_AUDIO
			message = "claps."
			conditions_for_emote = BOTH_HANDS_ARE_USABLE && (get_species() != ZOMBIE)

// ========== VISIBLE ==========

		if ("raisehand")
			message_type = SHOWMSG_VISUAL
			message = "raises a hand."
			conditions_for_emote = ONE_HAND_IS_USABLE && (get_species() != ZOMBIE)

		if ("blink")
			message_type = SHOWMSG_VISUAL
			message = pick("blinks.", "blinks rapidly.")
			conditions_for_emote = HAS_HEAD

		if ("drool")
			message_type = SHOWMSG_VISUAL
			message = "drools."
			conditions_for_emote = HAS_HEAD && (get_species() != DIONA)

		if ("eyebrow")
			message_type = SHOWMSG_VISUAL
			message = "raises an eyebrow."
			conditions_for_emote = HAS_HEAD

		if ("twitch")
			message_type = SHOWMSG_VISUAL
			message = pick("twitches violently.", "twitches.")

		if ("frown")
			message_type = SHOWMSG_VISUAL
			message = "frowns."
			conditions_for_emote = HAS_HEAD

		if ("nod")
			message_type = SHOWMSG_VISUAL
			message = "nods."
			conditions_for_emote = HAS_HEAD && (get_species() != ZOMBIE)

		if ("wave")
			message_type = SHOWMSG_VISUAL
			message = "waves."
			conditions_for_emote = ONE_HAND_IS_USABLE && (get_species() != ZOMBIE)

		if ("deathgasp")
			message_type = SHOWMSG_VISUAL
			message = "seizes up and falls limp, [his_macro] eyes dead and lifeless..."

		if ("grin")
			message_type = SHOWMSG_VISUAL
			message = "grins."
			conditions_for_emote = HAS_HEAD

		if ("shrug")
			message_type = SHOWMSG_VISUAL
			message = "shrugs."
			conditions_for_emote = (get_species() != ZOMBIE)

		if ("smile")
			message_type = SHOWMSG_VISUAL
			message = "smiles."
			conditions_for_emote = HAS_HEAD

		if ("shiver")
			message_type = SHOWMSG_VISUAL
			message = "shivers."

		if ("wink")
			message_type = SHOWMSG_VISUAL
			message = "winks."
			conditions_for_emote = HAS_HEAD && (get_species() != ZOMBIE)

		if ("yawn")
			message_type = SHOWMSG_VISUAL
			message = "yawns."
			conditions_for_emote = (!species.flags[NO_BREATHE])

		if ("collapse")
			message_type = SHOWMSG_VISUAL
			message = "collapses!"
			Paralyse(2)

		if ("bow")
			message_type = SHOWMSG_VISUAL
			message = pick("bows.", "bows in favor.")
			conditions_for_emote = (get_species() != ZOMBIE)

		if ("salute")
			message_type = SHOWMSG_VISUAL
			message = "salutes."
			conditions_for_emote = ONE_HAND_IS_USABLE && (get_species() != ZOMBIE)

		if ("pray")
			message_type = SHOWMSG_VISUAL
			message = "prays."
			INVOKE_ASYNC(src, /mob.proc/pray_animation)

// ========== SPECIAL ==========

		if ("custom")
			var/input = sanitize(input("Choose an emote to display.") as text|null)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			switch(input2)
				if ("Visible")
					message_type = SHOWMSG_VISUAL
				if ("Hearable")
					if (!can_make_a_sound)
						return
					message_type = SHOWMSG_AUDIO
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return
			return custom_emote(message_type, message)

		if ("me")
			if(client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'>You cannot send IC messages (MUTED).</span>")
					return
				if (client.handle_spam_prevention(message, MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(message_type, message)

		if ("help")
			to_chat(src, "<span class='notice'>Voiced in <B>BOLD</B>: grunt, groan, scream, choke, snore, whimper, sniff, sneeze, gasp, moan, sigh, mumble, groan, \
			                                                          laugh, cry, giggle, clap, blink, drool, eyebrow, twitch, frown, nod, blush, wave, deathgasp, \
			                                                          grin, raisehand, shrug, signal, smile, shiver, wink, yawn, collapse, bow, salute.</span>")

		else
			to_chat(src, "<span class='notice'>This action is not provided: \"[act]\". Write \"*help\" to find out all available emotes. Write \"*custom\" to do your own emote. \
			                                   Otherwise, you can perform your action via the \"F4\" button.</span>")

	if(!conditions_for_emote) // = if(cant_make_an_emotion)
		return auto ? FALSE : to_chat(src, "<span class='warning'>And how can I do that? I can't!</span>")

	if(muted && mute_message)
		message = mute_message
	else if((muzzled || silent) && muzzled_message)
		message = muzzled_message
	else if(miming && miming_message)
		message = miming_message

	if(!message || !message_type)
		return

	if(message_type & SHOWMSG_VISUAL)
		visible_message("<B>[src]</B> [message]", ignored_mobs = observer_list)
	else if(message_type & SHOWMSG_AUDIO)
		if(emote_sound && can_make_a_sound && (get_species() in list(HUMAN, SKRELL, TAJARAN, UNATHI))) // sounds of emotions for other species will look absurdly. We need individual sounds for special races(diona, ipc, etc))
			if(sound_priority == SOUND_PRIORITY_HIGH && next_high_priority_sound < world.time)
				playsound(src, emote_sound, VOL_EFFECTS_MASTER, null, FALSE)
				next_high_priority_sound = world.time + 4 SECONDS
				next_medium_priority_sound = next_high_priority_sound
				next_low_priority_sound = next_high_priority_sound
			else if(sound_priority == SOUND_PRIORITY_MEDIUM && next_medium_priority_sound < world.time)
				playsound(src, emote_sound, VOL_EFFECTS_MASTER, null, FALSE)
				next_medium_priority_sound = world.time + 4 SECONDS
				next_low_priority_sound = next_medium_priority_sound
			else if(sound_priority == SOUND_PRIORITY_LOW && next_low_priority_sound < world.time)
				playsound(src, emote_sound, VOL_EFFECTS_MASTER, null, FALSE)
				next_low_priority_sound = world.time + 4 SECONDS
			else
				return auto ? FALSE : to_chat(src, "<span class='warning'>You can't make sounds that often, you have to wait a bit.</span>")
		audible_message("<B>[src]</B> [message]", ignored_mobs = observer_list)

	log_emote("[key_name(src)] : [message]")

	for(var/mob/M in observer_list)
		if(!M.client)
			continue // skip leavers
		switch(M.client.prefs.chat_ghostsight)
			if(CHAT_GHOSTSIGHT_ALL)
				to_chat(M, "<a href='byond://?src=\ref[M];track=\ref[src]'>(F)</a> <B>[src]</B> [message]") // ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here
			if(CHAT_GHOSTSIGHT_ALLMANUAL)
				if(!auto)
					to_chat(M, "<a href='byond://?src=\ref[M];track=\ref[src]'>(F)</a> <B>[src]</B> [message]")

	if(cloud_emote)
		var/image/emote_bubble = image('icons/mob/emote.dmi', src, cloud_emote, EMOTE_LAYER)
		emote_bubble.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		flick_overlay(emote_bubble, clients, 30)
		QDEL_IN(emote_bubble, 3 SECONDS)

#undef SOUND_PRIORITY_LOW
#undef SOUND_PRIORITY_MEDIUM
#undef SOUND_PRIORITY_HIGH

#undef ONE_HAND_IS_USABLE
#undef BOTH_HANDS_ARE_USABLE
#undef HAS_HEAD

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  sanitize(input(usr, "This is [src]. \He is...", "Pose", null)  as text)

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	flavor_text =  sanitize(input(usr, "Please enter your new flavour text.", "Flavour text", null)  as text)

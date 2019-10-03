// sound's priorities
#define LOW    1
#define MEDIUM 2
#define HIGH   3

// auto = FALSE means that the sound is called by a human manually; auto = TRUE - automatically, in the code
/mob/living/carbon/human/emote(act = "", message_type = MESSAGE_VISIBLE, message = "", auto = FALSE)
	var/cloud_emote = ""
	var/sound_priority = LOW
	var/hidden_for_ghosts = auto // hide unimportant messages that can be spammed for ghosts? Default depends on auto but can be changed as needed
	var/emote_sound
	var/initial_message = message // useful in voiced emotions

	var/mute_message = "" // high priority. usuially VISIBLE
	var/muzzled_message = "" // medium priority. usually HEARABLE
	var/miming_message = "" // low priority. usually VISIBLE

// Constants. Even if they do not have a constant modifier, they are implied as constants
	var/MUTED = has_trait(TRAIT_MUTE)
	var/MUZZLED = istype(wear_mask, /obj/item/clothing/mask/muzzle)
	var/SILENT = silent
	var/CAN_MAKE_A_SOUND = !(MUTED || MUZZLED || SILENT)

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
			message_type = MESSAGE_AUDIBLE
			cloud_emote = "cloud-pain"
			message = pick("grunts slightly.", "groans.")
			mute_message = "writhes and sighs sligtly."
			muzzled_message = "groans silently!"
			miming_message = "appears to groan!"
			if(auto)
				sound_priority = MEDIUM
				message = pick("grunts in pain!", "grunts!", "wrinkles [his_macro] face and grunts!")
				emote_sound = (gender == FEMALE) ? pick(SOUNDIN_FEMALE_LIGHT_PAIN) : pick(SOUNDIN_MALE_LIGHT_PAIN)

		if("groan")
			message_type = MESSAGE_AUDIBLE
			message = "groans."
			mute_message = "writhes and sighs sligtly."
			muzzled_message = "makes a weak noise."
			miming_message = pick("slightly moans feigning pain.", "appears to be in pain!")
			if(auto)
				cloud_emote = "cloud-pain"
				sound_priority = MEDIUM
				message = pick("groans in pain.", "slightly winces in pain and groans.", "presses [his_macro] lips together in pain and groans.", "twists in pain.")
				if((species.name != SKRELL) && has_trait(TRAIT_LOW_PAIN_THRESHOLD) && prob(50)) // skrells don't have much emotions to cry in pain, but they can still groan
					emote_sound = pick((gender == FEMALE) ? SOUNDIN_FEMALE_WHINER_PAIN : SOUNDIN_MALE_WHINER_PAIN)
				else
					emote_sound = pick((gender == FEMALE) ? SOUNDIN_FEMALE_PASSIVE_PAIN : SOUNDIN_MALE_PASSIVE_PAIN)

		if ("scream")
			message_type = MESSAGE_AUDIBLE
			cloud_emote = "cloud-scream"
			message = pick("screams loudly!", "screams!")
			mute_message = pick("opens their mouth like a fish gasping for air!", "twists their face into an agonised expression!", "makes a very hurt expression!")
			muzzled_message = pick("makes a loud noise!", "groans soundly!", "screams silently!")
			miming_message = "acts out a scream!"
			if(auto)
				sound_priority = HIGH
				message = pick("screams in agony!", "writhes in heavy pain and screams!", "screams in pain as much as [he_macro] can!", "screams in pain loudly!")
				emote_sound = pick((gender == FEMALE) ? SOUNDIN_FEMALE_HEAVY_PAIN : SOUNDIN_MALE_HEAVY_PAIN)

		if ("cough")
			message_type = MESSAGE_AUDIBLE
			message = (get_species() == DIONA) ? "creaks." : "coughs."
			mute_message = (get_species() == DIONA) ? "creaks." : "coughs."
			muzzled_message = "appears to [(get_species() == DIONA) ? "creak" : "cough"]."
			miming_message = (get_species() == DIONA) ? "creaks." : "coughs."
			if(auto)
				sound_priority = MEDIUM
				emote_sound = pick((gender == FEMALE) ? SOUNDIN_FBCOUGH : SOUNDIN_MBCOUGH)

// ========== AUDIBLE ==========

		if ("choke")
			message_type = MUTED ? MESSAGE_VISIBLE : MESSAGE_AUDIBLE
			message = "chokes."
			mute_message = "clutches their throat desperately!"
			muzzled_message = "makes a weak noise."
			miming_message = message

		if ("snore")
			message_type = MESSAGE_AUDIBLE
			message = pick("snores.", "sleeps soundly.")
			mute_message = message
			muzzled_message = pick("snores.", "makes a noise.")
			miming_message = "snores."

		if ("whimper")
			message_type = MESSAGE_AUDIBLE
			message = "whimpers."
			mute_message = "whimpers"
			muzzled_message = pick("whimpers.", "makes a weak noise.", "whines.")
			miming_message = "whimpers."

		if ("sniff")
			message_type = MESSAGE_AUDIBLE
			message = "sniffs."
			mute_message = "sniffs."
			muzzled_message = "sniffs."
			miming_message = "sniffs."

		if ("sneeze")
			message_type = MESSAGE_AUDIBLE
			message = "sneezes."
			mute_message = "sneezes."
			muzzled_message = "makes a strange noise"
			miming_message = "sneezes"

		if ("gasp")
			message_type = MESSAGE_AUDIBLE
			cloud_emote = "cloud-gasp"
			mute_message = "sucks in air violently!"
			miming_message = "appears to be gasping!"
			muzzled_message = "makes a weak noise."
			message = "gasps!"

		if ("moan")
			message_type = MESSAGE_AUDIBLE
			mute_message = "moans silently."
			miming_message = "appears to moan!"
			muzzled_message = "moans silently!"
			message = "moans!"

		if ("sigh")
			message_type = MESSAGE_AUDIBLE
			message = "sighs."
			mute_message = message
			muzzled_message = "makes a weak noise."
			miming_message = "sighs."

		if ("mumble")
			message_type = MESSAGE_VISIBLE
			message = pick("grumbles.", "mumbles.")
			mute_message = "makes an annoyed face!"
			muzzled_message = "makes a weak noise"
			miming_message = message

		if ("groan")
			message_type = MESSAGE_AUDIBLE
			message = "groans"
			mute_message = "makes a very annoyed face."
			muzzled_message = "makes a noise."
			miming_message = message

// ========== HYBRID ==========

		if ("laugh")
			message_type = MESSAGE_AUDIBLE | MESSAGE_VISIBLE
			message = "laughs"
			mute_message = "laughs silently."
			muzzled_message = pick("makes a weak noise.", "giggles sligthly.")
			miming_message = "acts out a laugh"

		if ("cry")
			message_type = MESSAGE_AUDIBLE | MESSAGE_VISIBLE
			message = "cries"
			mute_message = message
			muzzled_message = "makes a [pick("sad face", "weak noise")] and frowns."
			miming_message = "cries."

		if ("giggle")
			message_type = MESSAGE_AUDIBLE | MESSAGE_VISIBLE
			message = pick("chuckles.", "giggles.")
			mute_message = "smiles slightly and [pick("chuckles", "giggles")] silently"
			muzzled_message = "[pick("chuckles", "giggles")] slightly."
			miming_message = "appears to [pick("chuckle", "giggle")]."

		if ("clap")
			message_type = MESSAGE_VISIBLE | MESSAGE_AUDIBLE
			message = "claps."
			if(restrained())
				return

// ========== VISIBLE ==========

		if ("raisehand")
			message_type = MESSAGE_VISIBLE
			message = "raises a hand."
			if(restrained())
				return

		if ("blink")
			message_type = MESSAGE_VISIBLE
			message = pick("blinks.", "blinks rapidly.")

		if ("drool")
			message_type = MESSAGE_VISIBLE
			message = "drools."

		if ("eyebrow")
			message_type = MESSAGE_VISIBLE
			message = "raises an eyebrow."

		if ("twitch")
			message_type = MESSAGE_VISIBLE
			message = pick("twitches violently.", "twitches.")

		if ("frown")
			message_type = MESSAGE_VISIBLE
			message = "frowns."

		if ("nod")
			message_type = MESSAGE_VISIBLE
			message = "nods."

		if ("blush")
			message_type = MESSAGE_VISIBLE
			message = "blushes."

		if ("wave")
			message_type = MESSAGE_VISIBLE
			message = "waves."

		if ("deathgasp")
			message_type = MESSAGE_VISIBLE
			message = "seizes up and falls limp, [his_macro] eyes dead and lifeless..."

		if ("grin")
			message_type = MESSAGE_VISIBLE
			message = "grins."

		if ("shrug")
			message_type = MESSAGE_VISIBLE
			message = "shrugs."

		if ("smile")
			message_type = MESSAGE_VISIBLE
			message = "smiles."

		if ("shiver")
			message_type = MESSAGE_VISIBLE
			message = "shivers."

		if ("wink")
			message_type = MESSAGE_VISIBLE
			message = "winks."

		if ("yawn")
			message_type = MESSAGE_VISIBLE
			message = "yawns."

		if ("collapse")
			message_type = MESSAGE_VISIBLE
			message = "collapses!"
			Paralyse(2)

		if ("bow")
			message_type = MESSAGE_VISIBLE
			message = pick("bows.", "bows in favor.")

		if ("salute")
			message_type = MESSAGE_VISIBLE
			message = "salutes."

// ========== SPECIAL ==========

		if ("custom")
			var/input = sanitize(input("Choose an emote to display.") as text|null)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				message_type = MESSAGE_VISIBLE
			else if (input2 == "Hearable")
				if(CAN_MAKE_A_SOUND)
					return
				message_type = MESSAGE_AUDIBLE
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			return custom_emote(message_type, message)

		if ("me")
			if(client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'>You cannot send IC messages (MUTEDd).</span>")
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


	if(initial_message)
		message = initial_message
	if((message_type & MESSAGE_AUDIBLE) && !(message_type & MESSAGE_VISIBLE)) // if(the human's mouth makes a sound, not something else). A bit crutchy but what to do
		if(MUTED)
			message = mute_message
		else if(MUZZLED || SILENT)
			message = muzzled_message
		else if(miming)
			message = miming_message

	if(!message)
		return

	log_emote("[name]/[key] : [message]")

	if(message_type & MESSAGE_VISIBLE)
		for(var/mob/M in viewers(src))
			M.show_message("<B>[src]</B> [message]", MESSAGE_VISIBLE, (message_type & MESSAGE_AUDIBLE) ? "You can hear that someone [message]" : null, MESSAGE_AUDIBLE)
	else if (message_type & MESSAGE_AUDIBLE)
		if(emote_sound && CAN_MAKE_A_SOUND)
			if(sound_priority == HIGH && next_high_priority_sound < world.time)
				playsound(src, emote_sound, VOL_EFFECTS_MASTER, null, FALSE)
				next_high_priority_sound = world.time + 4 SECONDS
				next_medium_priority_sound = next_high_priority_sound
				next_low_priority_sound = next_high_priority_sound
			else if(sound_priority == MEDIUM && next_medium_priority_sound < world.time)
				playsound(src, emote_sound, VOL_EFFECTS_MASTER, null, FALSE)
				next_medium_priority_sound = world.time + 4 SECONDS
				next_low_priority_sound = next_medium_priority_sound
			else if(sound_priority == LOW && next_low_priority_sound < world.time)
				playsound(src, emote_sound, VOL_EFFECTS_MASTER, null, FALSE)
				next_low_priority_sound = world.time + 4 SECONDS
			else if(!auto)
				to_chat(src, "<span class='warning'>You can't make sounds that often, you have to wait a bit.</span>")
				return
			else
				return
		for(var/mob/M in get_hearers_in_view(world.view, src))
			M.show_message(((sdisabilities & BLIND) || blinded) ? "You can hear that someone [message]" : "<B>[src]</B> [message]", MESSAGE_AUDIBLE, (message_type & MESSAGE_VISIBLE) ? "You can see that <B>[src]</B> [message]" : null, MESSAGE_VISIBLE)

	if(!hidden_for_ghosts)
		for(var/mob/M in observer_list)
			if(!M.client)
				continue // skip leavers
			if((M.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src, null)))
				M.show_message(message)

	if(cloud_emote)
		var/image/emote_bubble = image('icons/mob/emote.dmi', src, cloud_emote, MOB_LAYER + 1)
		flick_overlay(emote_bubble, clients, 30)
		QDEL_IN(emote_bubble, 3 SECONDS)

#undef LOW
#undef MEDIUM
#undef HIGH

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

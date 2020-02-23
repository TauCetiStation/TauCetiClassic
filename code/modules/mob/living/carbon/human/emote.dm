/mob/living/carbon/human/emote(act,m_type=SHOWMSG_VISUAL,message = null, auto)
	var/param = null
	var/virus_scream = FALSE

	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/muzzled = istype(wear_mask, /obj/item/clothing/mask/muzzle) || silent
	//var/m_type = SHOWMSG_VISUAL

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	if(stat == DEAD && (act != "deathgasp"))
		return

	var/cloud_emote = ""

	switch(act)
		if ("airguitar")
			if (!src.restrained())
				message = "<B>[src]</B> is strumming the air and headbanging like a safari chimp."
				m_type = SHOWMSG_VISUAL

		if ("blink")
			message = "<B>[src]</B> blinks."
			m_type = SHOWMSG_VISUAL

		if ("blink_r")
			message = "<B>[src]</B> blinks rapidly."
			m_type = SHOWMSG_VISUAL

		if ("bow")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> bows to [param]."
				else
					message = "<B>[src]</B> bows."
			m_type = SHOWMSG_VISUAL

		if ("custom")
			var/input = sanitize(input("Choose an emote to display.") as text|null)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = SHOWMSG_VISUAL
			else if (input2 == "Hearable")
				if (src.miming || HAS_TRAIT(src, TRAIT_MUTE))
					return
				m_type = SHOWMSG_AUDIO
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			return custom_emote(m_type, message)

		if ("me")

			//if(silent && silent > 0 && findtext(message,"\"",1, null) > 0)
			//	return //This check does not work and I have no idea why, I'm leaving it in for reference.

			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'>You cannot send IC messages (muted).</span>")
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if ("salute")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> salutes to [param]."
				else
					message = "<B>[src]</b> salutes."
			m_type = SHOWMSG_VISUAL

		if ("choke")
			if(miming || HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> clutches their throat desperately!"
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					message = "<B>[src]</B> chokes!"
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a strong noise."
					m_type = SHOWMSG_AUDIO

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = SHOWMSG_AUDIO
				if(miming)
					m_type = SHOWMSG_VISUAL
		if ("flap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings."
				m_type = SHOWMSG_AUDIO
				if(miming)
					m_type = SHOWMSG_VISUAL

		if ("aflap")
			if (!src.restrained())
				message = "<B>[src]</B> flaps his wings ANGRILY!"
				m_type = SHOWMSG_AUDIO
				if(miming)
					m_type = SHOWMSG_VISUAL

		if ("drool")
			message = "<B>[src]</B> drools."
			m_type = SHOWMSG_VISUAL

		if ("eyebrow")
			message = "<B>[src]</B> raises an eyebrow."
			m_type = SHOWMSG_VISUAL

		if ("chuckle")
			if(miming || HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> appears to chuckle."
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					message = "<B>[src]</B> chuckles."
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a noise."
					m_type = SHOWMSG_AUDIO

		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = SHOWMSG_VISUAL

		if ("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = SHOWMSG_VISUAL

		if ("faint")
			message = "<B>[src]</B> faints."
			if(IsSleeping())
				return //Can't faint while asleep
			SetSleeping(20 SECONDS) //Short-short nap
			m_type = SHOWMSG_VISUAL

		if ("cough")
			if(miming || HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> appears to cough!"
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					if (!(get_species() == DIONA))
						message = "<B>[src]</B> coughs!"
						m_type = SHOWMSG_AUDIO
					else
						message = "<B>[src]</B> creaks!"
						m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a strong noise."
					m_type = SHOWMSG_AUDIO

		if ("frown")
			message = "<B>[src]</B> frowns."
			m_type = SHOWMSG_VISUAL

		if ("nod")
			message = "<B>[src]</B> nods."
			m_type = SHOWMSG_VISUAL

		if ("blush")
			message = "<B>[src]</B> blushes."
			m_type = SHOWMSG_VISUAL

		if ("wave")
			message = "<B>[src]</B> waves."
			m_type = SHOWMSG_VISUAL

		if ("gasp")
			if(HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> sucks in air violently!"
				m_type = SHOWMSG_VISUAL
			else if(miming)
				message = "<B>[src]</B> appears to be gasping!"
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					if(auto)
						if(message == "coughs up blood!")
							if(world.time-lastSoundEmote >= 30)
								if(gender == FEMALE)
									playsound(src, pick(SOUNDIN_FBCOUGH), VOL_EFFECTS_MASTER, null, FALSE)
								else
									playsound(src, pick(SOUNDIN_MBCOUGH), VOL_EFFECTS_MASTER, null, FALSE)
								lastSoundEmote = world.time
					message = "<B>[src]</B> [message ? message : "gasps!"]"
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a noise."
					m_type = SHOWMSG_AUDIO

			cloud_emote = "cloud-gasp"

		if ("deathgasp")
			message = "<B>[src]</B> seizes up and falls limp, \his eyes dead and lifeless..."
			m_type = SHOWMSG_VISUAL

		if ("giggle")
			if(miming || HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> giggles silently!"
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					message = "<B>[src]</B> giggles."
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a noise."
					m_type = SHOWMSG_AUDIO

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> glares at [param]."
			else
				message = "<B>[src]</B> glares."

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> stares at [param]."
			else
				message = "<B>[src]</B> stares."

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break

			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> looks at [param]."
			else
				message = "<B>[src]</B> looks."
			m_type = SHOWMSG_VISUAL

		if ("grin")
			message = "<B>[src]</B> grins."
			m_type = SHOWMSG_VISUAL

		if ("cry")
			if(miming || HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> cries."
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					message = "<B>[src]</B> cries."
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a weak noise. \He frowns."
					m_type = SHOWMSG_AUDIO

		if ("sigh")
			if(miming || HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> sighs."
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					message = "<B>[src]</B> sighs."
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = SHOWMSG_AUDIO

		if ("laugh")
			if(HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> laughs silently."
				m_type = SHOWMSG_VISUAL
			else if(miming)
				message = "<B>[src]</B> acts out a laugh."
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					message = "<B>[src]</B> laughs."
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a noise."
					m_type = SHOWMSG_AUDIO

		if ("mumble")
			if(HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> makes an annoyed face!"
				m_type = SHOWMSG_VISUAL
			else
				message = "<B>[src]</B> mumbles!"
				m_type = SHOWMSG_AUDIO
				if(miming)
					m_type = SHOWMSG_VISUAL

		if ("grumble")
			if(miming)
				message = "<B>[src]</B> grumbles!"
				m_type = SHOWMSG_VISUAL
			else if(HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> makes an annoyed face!"
				m_type = SHOWMSG_VISUAL
			else if (!muzzled)
				message = "<B>[src]</B> grumbles!"
				m_type = SHOWMSG_AUDIO
			else
				message = "<B>[src]</B> makes a noise."
				m_type = SHOWMSG_AUDIO

		if ("groan")
			if(miming)
				message = "<B>[src]</B> appears to groan!"
				m_type = SHOWMSG_VISUAL
			else if(HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> makes a very annoyed face!"
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					message = "<B>[src]</B> groans!"
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a loud noise."
					m_type = SHOWMSG_AUDIO

		if ("moan")
			m_type = SHOWMSG_AUDIO
			if(miming)
				message = "<B>[src]</B> appears to moan!"
				m_type = SHOWMSG_VISUAL
			else
				if(!message)
					message = "<B>[src]</B> moans!"
				if(muzzled || HAS_TRAIT(src, TRAIT_MUTE))
					message = "<B>[src]</B> moans silently!"
				else if(auto)
					if(lastSoundEmote >= world.time)
						return
					message = pick("<B>[src]</B> grunts in pain!", "<B>[src]</B> grunts!", "<B>[src]</B> wrinkles \his face and grunts!")
					playsound(src, pick(gender == FEMALE ? SOUNDIN_FEMALE_LIGHT_PAIN : SOUNDIN_MALE_LIGHT_PAIN), VOL_EFFECTS_MASTER, null, FALSE)
					lastSoundEmote = world.time + 4 SECONDS

		if ("johnny")
			var/M
			if (param)
				M = param
			if (!M)
				param = null
			else
				if(miming || HAS_TRAIT(src, TRAIT_MUTE))
					message = "<B>[src]</B> takes a drag from a cigarette and blows \"[M]\" out in smoke."
					m_type = SHOWMSG_VISUAL
				else
					message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows his name out in smoke."
					m_type = SHOWMSG_AUDIO

		if ("point")
			if (!restrained())
				var/atom/target = null
				if (param)
					for (var/atom/A as mob|obj|turf in oview())
						if (param == A.name)
							target = A
							break
				if (!target)
					message = "<span class='notice'><b>[src]</b> points.</span>"
				else
					pointed(target)
			m_type = SHOWMSG_VISUAL

		if ("raise")
			if (!src.restrained())
				message = "<B>[src]</B> raises a hand."
			m_type = SHOWMSG_VISUAL

		if("shake")
			message = "<B>[src]</B> shakes \his head."
			m_type = SHOWMSG_VISUAL

		if ("shrug")
			message = "<B>[src]</B> shrugs."
			m_type = SHOWMSG_VISUAL

		if ("signal")
			if (!src.restrained())
				var/t1 = round(text2num(param))
				if (isnum(t1))
					if (t1 <= 5 && (!src.r_hand || !src.l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
					else if (t1 <= 10 && (!src.r_hand && !src.l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
			m_type = SHOWMSG_VISUAL

		if ("smile")
			message = "<B>[src]</B> smiles."
			m_type = SHOWMSG_VISUAL

		if ("shiver")
			message = "<B>[src]</B> shivers."
			m_type = SHOWMSG_AUDIO
			if(miming)
				m_type = SHOWMSG_VISUAL

		if ("pale")
			message = "<B>[src]</B> goes pale for a second."
			m_type = SHOWMSG_VISUAL

		if ("tremble")
			message = "<B>[src]</B> trembles in fear!"
			m_type = SHOWMSG_VISUAL

		if ("sneeze")
			if (miming || HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> sneezes."
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					message = "<B>[src]</B> sneezes."
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a strange noise."
					m_type = SHOWMSG_AUDIO

		if ("sniff")
			message = "<B>[src]</B> sniffs."
			m_type = SHOWMSG_AUDIO
			if(miming || HAS_TRAIT(src, TRAIT_MUTE))
				m_type = SHOWMSG_VISUAL

		if ("snore")
			if (miming || HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> sleeps soundly."
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					message = "<B>[src]</B> snores."
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a noise."
					m_type = SHOWMSG_AUDIO

		if ("whimper")
			if (miming || HAS_TRAIT(src, TRAIT_MUTE))
				message = "<B>[src]</B> appears hurt."
				m_type = SHOWMSG_VISUAL
			else
				if (!muzzled)
					message = "<B>[src]</B> whimpers."
					m_type = SHOWMSG_AUDIO
				else
					message = "<B>[src]</B> makes a weak noise."
					m_type = SHOWMSG_AUDIO

		if ("wink")
			message = "<B>[src]</B> winks."
			m_type = SHOWMSG_VISUAL

		if ("yawn")
			if (!muzzled)
				message = "<B>[src]</B> yawns."
				m_type = SHOWMSG_AUDIO
				if(miming || HAS_TRAIT(src, TRAIT_MUTE))
					m_type = SHOWMSG_VISUAL

		if ("collapse")
			Paralyse(2)
			message = "<B>[src]</B> collapses!"
			m_type = SHOWMSG_AUDIO
			if(miming)
				m_type = SHOWMSG_VISUAL

		if("hug")
			m_type = SHOWMSG_VISUAL
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					message = "<B>[src]</B> hugs [M]."
				else
					message = "<B>[src]</B> hugs \himself."

		if ("handshake")
			m_type = SHOWMSG_VISUAL
			if (!src.restrained() && !src.r_hand)
				var/mob/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if (M.canmove && !M.r_hand && !M.restrained())
						message = "<B>[src]</B> shakes hands with [M]."
					else
						message = "<B>[src]</B> holds out \his hand to [M]."

		if("dap")
			m_type = SHOWMSG_VISUAL
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M)
					message = "<B>[src]</B> gives daps to [M]."
				else
					message = "<B>[src]</B> sadly can't find anybody to give daps to, and daps \himself. Shameful."

		if("pain")
			if(muzzled)
				message = "<B>[src]</B> makes a weak noise."
				m_type = SHOWMSG_VISUAL // Can't we get defines for these?
			else if(auto)
				message = pick("<B>[src]</B> moans in pain.", "<B>[src]</B> slightly winces in pain and moans.", "<B>[src]</B> presses \his lips together in pain and moans.", "<B>[src]</B> twists in pain.")
				m_type = SHOWMSG_AUDIO
				cloud_emote = "cloud-pain"
				if((species.name != SKRELL) && HAS_TRAIT(src, TRAIT_LOW_PAIN_THRESHOLD) && prob(50)) // skrells don't have much emotions to cry in pain, but they can still moan
					playsound(src, pick(gender == FEMALE ? SOUNDIN_FEMALE_WHINER_PAIN : SOUNDIN_MALE_WHINER_PAIN), VOL_EFFECTS_MASTER, null, FALSE)
				else
					playsound(src, pick(gender == FEMALE ? SOUNDIN_FEMALE_PASSIVE_PAIN : SOUNDIN_MALE_PASSIVE_PAIN), VOL_EFFECTS_MASTER, null, FALSE)
			else
				message = "<B>[src]</B> [pick("slightly moans feigning pain.", "appears to be in pain!")]"
				m_type = SHOWMSG_AUDIO

		if ("scream")
			if(miming)
				message = "<B>[src]</B> acts out a scream!"
				m_type = SHOWMSG_VISUAL
			else
				virus_scream = locate(/datum/disease2/effect/scream) in virus2
				if(virus_scream || !(species && species.flags[NO_PAIN]))
					if (!muzzled)
						if (auto)
							if(HAS_TRAIT(src, TRAIT_MUTE))
								message = "<B>[src]</B> twists their face into an agonised expression!"
								m_type = SHOWMSG_VISUAL
							else if(lastSoundEmote <= world.time) // prevent scream spam with things like poly spray
								message = "<B>[src]</B> [pick("screams in agony", "writhes in heavy pain and screams", "screams in pain as much as [gender == FEMALE ? "she" : "he"] can", "screams in pain loudly")]!"
								if (gender == FEMALE) // Females have their own screams. Trannys be damned.
									playsound(src, pick(SOUNDIN_FEMALE_HEAVY_PAIN), VOL_EFFECTS_MASTER, null, FALSE)
								else if(gender == MALE)
									playsound(src, pick(SOUNDIN_MALE_HEAVY_PAIN), VOL_EFFECTS_MASTER, null, FALSE)
								m_type = SHOWMSG_AUDIO
								lastSoundEmote = world.time + 4 SECONDS
						else
							if(!message)
								message = "<B>[src]</B> screams!"
							m_type = SHOWMSG_AUDIO
							if(HAS_TRAIT(src, TRAIT_MUTE))
								message = "<B>[src]</B> opens their mouth like a fish gasping for air!"
								m_type = SHOWMSG_VISUAL
					else
						if(HAS_TRAIT(src, TRAIT_MUTE))
							message = "<B>[src]</B> makes a very hurt expression!"
							m_type = SHOWMSG_VISUAL
						else
							message = "<B>[src]</B> makes a very loud noise."
							m_type = SHOWMSG_AUDIO

			cloud_emote = "cloud-scream"

		if ("help")
			to_chat(src, "blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough,\ncry, custom, deathgasp, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,\ngrin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,\nsigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, tremble, twitch, twitch_s, whimper,\nwink, yawn")

		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")

	if(message)
		log_emote("[key_name(src)] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in observer_list)
			if(!M.client)
				continue //skip leavers
			if((M.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				to_chat(M, message)


		if (m_type & SHOWMSG_VISUAL)
			for (var/mob/O in get_mobs_in_view(world.view,src))
				O.show_message(message, m_type)
		else if (m_type & SHOWMSG_AUDIO)
			for (var/mob/O in (hearers(src.loc, null) | get_mobs_in_view(world.view,src)))
				O.show_message(message, m_type)

	if(cloud_emote)
		var/image/emote_bubble = image('icons/mob/emote.dmi', src, cloud_emote, EMOTE_LAYER)
		flick_overlay(emote_bubble, clients, 30)
		QDEL_IN(emote_bubble, 3 SECONDS)

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

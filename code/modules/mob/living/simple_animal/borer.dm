/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"

/mob/living/captive_brain/say(var/message)

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	message = sanitize(message)

	log_say("[key_name(src)] : [message]")

	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		to_chat(src, "You whisper silently, \"[message]\"")
		to_chat(B.host, "The captive mind of [src] whispers, \"[message]\"")

		for (var/mob/M in player_list)
			if (isnewplayer(M))
				continue
			else if(M.stat == DEAD &&  M.client.prefs.chat_toggles & CHAT_GHOSTEARS)
				to_chat(M, "The captive mind of [src] whispers, \"[message]\"")

/mob/living/captive_brain/emote(act, m_type = SHOWMSG_VISUAL, message, auto)
	return

/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "A small, quivering sluglike creature."
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	response_help  = "pokes the"
	response_disarm = "prods the"
	response_harm   = "stomps on the"
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attacktext = "nips"
	friendly = "prods"
	wander = 0
	pass_flags = PASSTABLE
	ventcrawler = 2

	var/used_dominate
	var/chemicals = 10                      // Chemicals used for reproduction and spitting neurotoxin.
	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Used in human death check.
	var/has_reproduced                      // Whether or not the borer has reproduced, for objective purposes.
	var/docile = 0                          // Sugar can stop borers from acting.
	var/leaving = FALSE

/mob/living/simple_animal/borer/atom_init(mapload, request_ghosts = FALSE)
	. = ..()
	truename = "[pick("Primary","Secondary","Tertiary","Quaternary")] [rand(1000,9999)]"
	real_name = truename
	host_brain = new/mob/living/captive_brain(src)
	if(request_ghosts)
		for(var/mob/dead/observer/O in observer_list)
			try_request_n_transfer(O, "A new Cortical Borer was born. Do you want to be him?", ROLE_ALIEN, IGNORE_BORER)

/mob/living/simple_animal/borer/attack_ghost(mob/dead/observer/O)
	try_request_n_transfer(O, "Cortical Borer, are you sure?", ROLE_ALIEN, , show_warnings = TRUE)

/mob/living/simple_animal/borer/Life()

	..()

	if(host)

		if(!stat && !host.stat)

			if(host.reagents.has_reagent("sugar"))
				if(!docile)
					if(controlling)
						to_chat(host, "<span class='notice'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>")
					else
						to_chat(src, "<span class='notice'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>")
					docile = 1
			else
				if(docile)
					if(controlling)
						to_chat(host, "<span class='notice'>You shake off your lethargy as the sugar leaves your host's blood.</span>")
					else
						to_chat(src, "<span class='notice'>You shake off your lethargy as the sugar leaves your host's blood.</span>")
					docile = 0

			if(chemicals < 250)
				chemicals++
			if(controlling)

				if(docile)
					to_chat(host, "<span class='notice'>You are feeling far too docile to continue controlling your host...</span>")
					host.release_control()
					return

				if(prob(5))
					host.adjustBrainLoss(rand(1,2))

				if(prob(host.brainloss/20))
					host.say("*[pick(list("blink", "choke", "aflap", "drool", "twitch", "gasp"))]")

/mob/living/simple_animal/borer/say(var/message)

	message = capitalize(sanitize(message))

	if(!message)
		return

	log_say("[key_name(src)] : [message]")

	if (stat == DEAD)
		return say_dead(message)

	if (stat)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (message[1] == "*")
		return emote(copytext(message, 2))

	if (message[1] == ";") //Brain borer hivemind.
		return borer_speak(message)

	if(!host)
		to_chat(src, "You have no host to speak to.")
		return //No host, no audible speech.

	to_chat(src, "You drop words into [host]'s mind: \"[message]\"")
	to_chat(host, "Your own thoughts speak: \"[message]\"")

	for (var/mob/M in player_list)
		if (isnewplayer(M))
			continue
		else if(M.stat == DEAD &&  M.client.prefs.chat_toggles & CHAT_GHOSTEARS)
			to_chat(M, "[src.truename] whispers to [host], \"[message]\"")


/mob/living/simple_animal/borer/Stat()
	..()
	if(statpanel("Status"))
		stat("Chemicals", chemicals)

// VERBS!

/mob/living/simple_animal/borer/proc/borer_speak(message)
	if(!message)
		return

	for(var/mob/M in mob_list)
		if(M.mind && (istype(M, /mob/living/simple_animal/borer) || isobserver(M)))
			to_chat(M, "<i>Cortical link, <b>[truename]:</b> [copytext(message, 2)]</i>")

/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Borer"
	set name = "Dominate Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - used_dominate < 300)
		to_chat(src, "You cannot use that ability again so soon.")
		return

	if(host)
		to_chat(src, "You cannot do that from within a host body.")
		return

	if(incapacitated())
		to_chat(src, "You cannot do that in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(3,src))
		if(C.stat != DEAD)
			choices += C

	if(world.time - used_dominate < 300)
		to_chat(src, "You cannot use that ability again so soon.")
		return

	var/mob/living/carbon/M = input(src,"Who do you wish to dominate?") in null|choices

	if(!M || !src) return

	if(M.has_brain_worms())
		to_chat(src, "You cannot infest someone who is already infested!")
		return

	to_chat(src, "<span class='warning'>You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread.</span>")
	to_chat(M, "<span class='warning'>You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing.</span>")
	M.Weaken(3)

	used_dominate = world.time

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Borer"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(incapacitated())
		to_chat(src, "You cannot do that in your current state.")
		return

	if(!host.organs_by_name[O_BRAIN]) //this should only run in admin-weirdness situations, but it's here non the less - RR
		to_chat(src, "<span class='warning'>There is no brain here for us to command!</span>")
		return

	if(docile)
		to_chat(src, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	to_chat(src, "You begin delicately adjusting your connection to the host brain...")

	spawn(300+(host.brainloss*5))

		if(!host || !src || controlling)
			return
		else
			to_chat(src, "<span class='warning'><B>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</B></span>")
			to_chat(host, "<span class='warning'><B>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</B></span>")

			host_brain.ckey = host.ckey
			host.ckey = src.ckey
			controlling = 1

			host.verbs += /mob/living/carbon/proc/release_control
			host.verbs += /mob/living/carbon/proc/punish_host
			host.verbs += /mob/living/carbon/proc/spawn_larvae

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Borer"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(incapacitated())
		to_chat(src, "You cannot secrete chemicals in your current state.")
		return

	if(docile)
		to_chat(src, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	if(chemicals < 50)
		to_chat(src, "You don't have enough chemicals!")

	var/chem = input("Select a chemical to secrete.", "Chemicals") as null|anything in list("bicaridine","tramadol","hyperzine","alkysine")
	if(!chem)
		return

	if(chemicals < 50 || !host || controlling || !src || stat) //Sanity check.
		return

	to_chat(src, "<span class='warning'><B>You squirt a measure of [chem] from your reservoirs into [host]'s bloodstream.</B></span>")
	host.reagents.add_reagent(chem, 15)
	chemicals -= 50

/mob/living/simple_animal/borer/verb/release_host()
	set category = "Borer"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!host)
		to_chat(src, "You are not inside a host body.")
		return

	if(incapacitated())
		to_chat(src, "You cannot leave your host in your current state.")
		return

	if(docile)
		to_chat(src, "<span class='notice'>You are feeling far too docile to do that.</span>")
		return

	if(!host || !src) return

	if(leaving)
		leaving = FALSE
		to_chat(src, "<span class='userdanger'>You decide against leaving your host.</span>")
		return

	to_chat(src, "You begin disconnecting from [host]'s synapses and prodding at their internal ear canal.")

	leaving = TRUE

	addtimer(CALLBACK(src, .proc/let_go), 200)


/mob/living/simple_animal/borer/proc/let_go()

	if(!host.stat)
		to_chat(host, "An odd, uncomfortable pressure begins to build inside your skull, behind your ear...")
	if(!host || !src || QDELETED(host) || QDELETED(src))
		return
	if(!leaving)
		return
	if(controlling)
		return
	if(incapacitated())
		to_chat(src, "You cannot infest a target in your current state.")
		return
	to_chat(src, "You wiggle out of [host]'s ear and plop to the ground.")

	leaving = FALSE

	if(!host.stat)
		to_chat(host, "Something slimy wiggles out of your ear and plops to the ground!")

	detatch()

/mob/living/simple_animal/borer/proc/detatch()

	if(!host) return

	if(istype(host,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = host
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
		BP.implants -= src

	src.loc = get_turf(host)
	controlling = 0

	reset_view(null)
	machine = null

	host.reset_view(null)
	host.machine = null

	host.verbs -= /mob/living/carbon/proc/release_control
	host.verbs -= /mob/living/carbon/proc/punish_host
	host.verbs -= /mob/living/carbon/proc/spawn_larvae

	if(host_brain.ckey)
		src.ckey = host.ckey
		host.ckey = host_brain.ckey
		host_brain.ckey = null
		host_brain.name = "host brain"
		host_brain.real_name = "host brain"
	host.parasites -= src
	host = null

/mob/living/simple_animal/borer/verb/infest()
	set category = "Borer"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	if(host)
		to_chat(src, "You are already within a host.")
		return

	if(incapacitated())
		to_chat(src, "You cannot infest a target in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat != DEAD && src.Adjacent(C))
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to infest?") in null|choices

	if(!M || !src) return

	if(!(src.Adjacent(M))) return

	if(M.has_brain_worms())
		to_chat(src, "You cannot infest someone who is already infested!")
		return

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.check_head_coverage())
			to_chat(src, "You cannot get through that host's protective gear.")
			return
	if(is_busy()) return
	to_chat(M, "Something slimy begins probing at the opening of your ear canal...")
	to_chat(src, "You slither up [M] and begin probing at their ear canal...")

	if(!do_after(src,50,target = M))
		to_chat(src, "As [M] moves away, you are dislodged and fall to the ground.")
		return

	if(!M || !src) return

	if(incapacitated())
		to_chat(src, "You cannot infest a target in your current state.")
		return

	if(M.stat == DEAD)
		to_chat(src, "That is not an appropriate target.")
		return

	if(M in view(1, src))
		to_chat(src, "You wiggle into [M]'s ear.")
		if(!M.stat)
			to_chat(M, "Something disgusting and slimy wiggles into your ear!")

		src.host = M
		src.loc = M

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
			BP.implants += src

		host_brain.name = M.name
		host_brain.real_name = M.real_name
		host.parasites |= src

		return
	else
		to_chat(src, "They are no longer in range!")
		return

//copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/borer/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Borer"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

var/global/list/datum/mind/borers = list()

/mob/living/simple_animal/borer/transfer_personality(client/candidate)

	if(!candidate)
		return

	mind = candidate.mob.mind
	ckey = candidate.ckey
	if(mind)
		mind.assigned_role = "Cortical Borer"
		mind.special_role = "Cortical Borer"
	borers |= mind

	to_chat(src, "Use your Infest power to crawl into the ear of a host and fuse with their brain.")
	to_chat(src, "You can only take control temporarily, and at risk of hurting your host, so be clever and careful; your host is encouraged to help you however they can.")
	to_chat(src, "Talk to your fellow borers with ;")
	var/list/datum/objective/objectives = list(
		new /datum/objective/borer_survive(),
		new /datum/objective/borer_reproduce(),
		new /datum/objective/escape()
		)
	for(var/datum/objective/O in objectives)
		O.owner = mind
	mind.objectives = objectives

	var/obj_count = 1
	to_chat(src, "<span class = 'notice'><B>Your current objectives:</B></span>")
	for(var/datum/objective/objective in mind.objectives)
		to_chat(src, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++

/datum/game_mode/proc/auto_declare_completion_borer()
	var/text = ""
	if(borers.len)
		text += "<b>The borers were:</b>"
		for(var/datum/mind/borer in borers)
			text += printplayerwithicon(borer)

			var/count = 1
			var/borerwin = 1
			if(!config.objectives_disabled)
				for(var/datum/objective/objective in borer.objectives)
					if(objective.check_completion())
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: green; font-weight: bold;'>Success!</span>"
						feedback_add_details("borer_objective","[objective.type]|SUCCESS")
					else
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: red; font-weight: bold;'>Fail.</span>"
						feedback_add_details("borer_objective","[objective.type]|FAIL")
						borerwin = 0
					count++

				if(borer.current && borer.current.stat!=2 && borerwin)
					text += "<br><FONT color='green'><b>The borer was successful!</b></FONT>"
					feedback_add_details("borer_success","SUCCESS")
					score["roleswon"]++
				else
					text += "<br><FONT color='red'><b>The borer has failed!</b></FONT>"
					feedback_add_details("borer_success","FAIL")
				text += "<br>"

	if(text)
		antagonists_completion += list(list("mode" = "borer", "html" = text))
		text = "<div class='block'>[text]</div>"

	return text

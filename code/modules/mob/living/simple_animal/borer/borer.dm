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
	stop_automated_movement = TRUE
	status_flags = CANPUSH
	attacktext = "nips"
	friendly = "prods"
	wander = FALSE
	pass_flags = PASSTABLE
	ventcrawler = 2

	var/truename // Name used for brainworm-speak.
	var/generation = 1
	var/static/list/borer_names = list(
		"Primary", "Secondary", "Tertiary", "Quaternary", "Quinary", "Senary",
		"Septenary", "Octonary", "Novenary", "Decenary", "Undenary", "Duodenary",
		)

	var/dominate_cd = 0                        // Calldown for dominate victim
	var/assuming = FALSE
	var/chemicals = 10                         // Chemicals used for reproduction and spitting neurotoxin.
	var/const/max_chemicals = 250              // Maximum chemicals
	var/mob/living/carbon/host                 // Carbon host for the brain worm.
	var/mob/living/captive_brain/host_brain    // Used for swapping control of the body back and forth.
	var/controlling = FALSE                    // Used in human death check.
	var/docile = FALSE                         // Sugar can stop borers from acting.
	var/leaving = FALSE
	var/has_reproduced = FALSE                 // Whether or not the borer has reproduced, for objective purposes.
	var/upgrade_points = 0                     // Upgrade points left to spend

/mob/living/simple_animal/borer/atom_init(mapload, request_ghosts = FALSE, gen = 1)
	. = ..()
	generation = gen
	truename = "[borer_names[min(generation, borer_names.len)]] [rand(1000, 9999)]"
	real_name = truename

	host_brain = new/mob/living/captive_brain(src)
	if(request_ghosts)
		for(var/mob/dead/observer/O in observer_list)
			try_request_n_transfer(O, "A new Cortical Borer was born. Do you want to be him?", ROLE_ALIEN, IGNORE_BORER)

/mob/living/simple_animal/borer/attack_ghost(mob/dead/observer/O)
	try_request_n_transfer(O, "Cortical Borer, are you sure?", ROLE_ALIEN, , show_warnings = TRUE)

/mob/living/simple_animal/borer/Life()
	..()

	if(!host)
		return

	if(stat != CONSCIOUS && host.stat != CONSCIOUS)
		return

	if(host.reagents.has_reagent("sugar") && !docile)
		docile = TRUE
		var/mob/msg_to = controlling ? host : src
		to_chat(msg_to, "<span class='notice'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>")
	else if(docile)
		docile = FALSE
		var/mob/msg_to = controlling ? host : src
		to_chat(msg_to, "<span class='notice'>You shake off your lethargy as the sugar leaves your host's blood.</span>")

	if(chemicals < max_chemicals)
		chemicals++

	if(controlling)
		if(docile)
			to_chat(host, "<span class='notice'>You are feeling far too docile to continue controlling your host...</span>")
			host.release_control()
			return
		if(prob(5))
			host.adjustBrainLoss(rand(1,2))
		if(prob(host.getBrainLoss() * 0.05))
			host.emote("[pick(list("blink", "choke", "aflap", "drool", "twitch", "gasp"))]")

/mob/living/simple_animal/borer/say(message)

	message = capitalize(sanitize(message))
	if(!message)
		return

	log_say("[key_name(src)] : [message]")

	if (stat == DEAD)
		return say_dead(message)

	if (stat)
		return

	if (client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
		if (client.handle_spam_prevention(message,MUTE_IC))
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
		if(M.stat == DEAD &&  M.client.prefs.chat_toggles & CHAT_GHOSTEARS)
			to_chat(M, "[FOLLOW_LINK(M, src)] [truename] whispers to [host], \"[message]\"")


/mob/living/simple_animal/borer/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Chemicals: [chemicals]/[max_chemicals]")

/mob/living/simple_animal/borer/proc/borer_speak(message)
	if(!message)
		return

	for(var/mob/M in mob_list)
		if(M.mind && (istype(M, /mob/living/simple_animal/borer) || isobserver(M)))
			to_chat(M, "<i>Cortical link, <b>[truename]:</b> [copytext(message, 2)]</i>")

// Borers will not be blind in ventilation
/mob/living/simple_animal/borer/is_vision_obstructed()
	if(istype(loc, /obj/machinery/atmospherics/pipe))
		return FALSE
	return ..()

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

/mob/living/simple_animal/borer/update_sight()
	sight = 0
	if(is_ventcrawling)
		sight |= SEE_TURFS | SEE_OBJS | BLIND

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
		text = "<div class='Section'>[text]</div>"

	return text

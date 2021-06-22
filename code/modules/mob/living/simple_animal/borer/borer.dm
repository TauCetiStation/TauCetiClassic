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

	var/assuming = FALSE
	var/chemicals = 350                        // Chemicals used for reproduction and spitting neurotoxin.
	var/max_chemicals = 250                    // Maximum chemicals
	var/mob/living/carbon/host                 // Carbon host for the brain worm.
	var/mob/living/captive_brain/host_brain    // Used for swapping control of the body back and forth.
	var/controlling = FALSE                    // Used in human death check.
	var/docile = FALSE                         // Sugar can stop borers from acting.
	var/leaving = FALSE
	var/reproduced = 0                         // Times the borer has reproduced.
	var/upgrade_points = 1e6//2                // Upgrade points left to spend

	var/list/obj/effect/proc_holder/upgrades = list()
	var/list/obj/effect/proc_holder/all_upgrades = list()

	var/list/synthable_chems = list()
	var/infest_delay = 5 SECONDS

	var/last_client_poll = 0
	var/client_poll_cd = 1 MINUTE

	var/chemical_regeneration = 1
	var/passive_chemical_regeneration = 0
	var/nutrition_consumption = 0

	var/stealthy = FALSE
	var/recombinate = FALSE

/mob/living/simple_animal/borer/atom_init(mapload, request_ghosts = FALSE, gen = 1, points = 2, list/parent_upgrades)
	. = ..()
	generation = gen
	truename = "[borer_names[min(generation, borer_names.len)]] [rand(1000, 9999)]"
	real_name = truename

	host_brain = new/mob/living/captive_brain(src)
	if(request_ghosts)
		for(var/mob/dead/observer/O in observer_list)
			try_request_n_transfer(O, "A new Cortical Borer was born. Do you want to be him?", ROLE_ALIEN, IGNORE_BORER)
	all_upgrades = sortAtom(init_named_subtypes(/obj/effect/proc_holder/borer))
	for(var/obj/effect/proc_holder/borer/U in all_upgrades)
		if(U.cost == 0)
			upgrades += U
			U.on_gain(src)

	upgrade_points = points

	last_client_poll = world.time // prevent newborn borer from looking for client second time

	if(!parent_upgrades)
		return

	for(var/obj/effect/proc_holder/borer/U in parent_upgrades)
		var/obj/effect/proc_holder/borer/myU = locate(U.type) in all_upgrades
		upgrades |= myU
		myU.on_gain(src)

/mob/living/simple_animal/borer/proc/hasChemicals(amt)
	return amt <= chemicals

/mob/living/simple_animal/borer/proc/adjustChemicals(amt)
	chemicals = clamp(chemicals + amt, 0, max_chemicals)

/mob/living/simple_animal/borer/proc/useChemicals(amt)
	if(hasChemicals(amt))
		adjustChemicals(-amt)
		return TRUE
	return FALSE

/mob/living/simple_animal/borer/proc/getControlling()
	return controlling ? host : src

/mob/living/simple_animal/borer/attack_ghost(mob/dead/observer/O)
	try_request_n_transfer(O, "Cortical Borer, are you sure?", ROLE_ALIEN, , show_warnings = TRUE)

/mob/living/simple_animal/borer/Life()
	..()

	adjustChemicals(passive_chemical_regeneration)
	if(invisibility && chemicals <= 1)
		deactivate_invisibility()

	if(!host)
		return
	// We look only for candidates for hosted borers because hostless ones can be possessed by ghosts normally.
	if(!ckey)
		if(world.time - last_client_poll > client_poll_cd)
			for(var/mob/dead/observer/O in observer_list)
				try_request_n_transfer(O, "A mindless Cortical Borer was found. Do you want to be him?", ROLE_ALIEN, IGNORE_BORER)
				last_client_poll = world.time
	if(stat != CONSCIOUS && host.stat != CONSCIOUS)
		return
	if(host.reagents.has_reagent("sugar") && !host.reagents.has_reagent("sucrase") && !docile)
		docile = TRUE
		var/mob/msg_to = controlling ? host : src
		to_chat(msg_to, "<span class='notice'>You feel the soporific flow of sugar in your host's blood, lulling you into docility.</span>")
	else if(docile)
		docile = FALSE
		var/mob/msg_to = controlling ? host : src
		to_chat(msg_to, "<span class='notice'>You shake off your lethargy as the sugar leaves your host's blood.</span>")

	if(host.stat == CONSCIOUS && chemicals < max_chemicals)
		if(host.nutrition)
			adjustChemicals(chemical_regeneration)
			host.nutrition = max(host.nutrition - nutrition_consumption, 0)
		else
			// if host has no resources we won't regenerate more than 1 unit per tick
			adjustChemicals(min(chemical_regeneration, 1))

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

	if (stat == UNCONSCIOUS)
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
		return borer_speak(copytext(message, 2))

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

/mob/living/simple_animal/borer/proc/stat_abilities(mob/user)
	if(statpanel("Borer"))
		stat(null, "Chemicals: [chemicals]/[max_chemicals]")
		for(var/obj/effect/proc_holder/borer/U in upgrades)
			if(!U.can_use(user))
				continue
			stat(U.get_stat_entry(), U)

/mob/living/simple_animal/borer/proc/borer_speak(message)
	if(!message)
		return

	for(var/mob/M in mob_list)
		var/mob/living/simple_animal/borer/B = M.has_brain_worms()
		if(M.mind && (istype(M, /mob/living/simple_animal/borer) || isobserver(M) || B?.controlling))
			to_chat(M, "<i>Cortical link, <b>[truename]:</b> [message]</i>")

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
	if(is_ventcrawling)
		sight |= SEE_TURFS | SEE_OBJS | BLIND
	else
		sight &= ~(SEE_TURFS | SEE_OBJS | BLIND)

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

/mob/living/simple_animal/borer/has_brain_worms()
	return src

/mob/living/simple_animal/borer/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "IC"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

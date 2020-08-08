/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/traitors = list()

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	role_type = ROLE_TRAITOR
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Cadet", "Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Velocity Officer", "Velocity Chief", "Velocity Medical Doctor")//AI", Currently out of the list as malf does not work for shit
	required_players = 1
	required_enemies = 1
	required_players_secret = 1
	recommended_enemies = 4

	votable = 0


	uplink_welcome = "AntagCorp Portable Teleportation Relay:"
	uplink_uses = 20

	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/const/traitor_scaling_coeff = 7.0 //how much does the amount of players get divided by to determine traitors


/datum/game_mode/traitor/announce()
	to_chat(world, "<B>The current game mode is - Traitor!</B>")
	to_chat(world, "<B>There is a syndicate traitor on the station. Do not let the traitor succeed!</B>")


/datum/game_mode/traitor/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/num_traitors = 1

	if(config.traitor_scaling)
		num_traitors = max(1, round((num_players())/(traitor_scaling_coeff)))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				antag_candidates -= player

	for(var/j = 0, j < num_traitors, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/traitor = pick(antag_candidates)
		traitors += traitor
		traitor.special_role = "traitor"
		antag_candidates.Remove(traitor)

	if(!traitors.len)
		return 0
	return 1


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in traitors)
		if (!config.objectives_disabled)
			forge_traitor_objectives(traitor)
		spawn(rand(10,100))
			finalize_traitor(traitor)
			greet_traitor(traitor)
	modePlayer += traitors
	return ..()


/datum/game_mode/proc/forge_traitor_objectives(datum/mind/traitor)
	if (config.objectives_disabled)
		return

	if(istype(traitor.current, /mob/living/silicon))
		var/datum/objective/assassinate/kill_objective1 = new
		kill_objective1.owner = traitor
		kill_objective1.find_target()
		traitor.objectives += kill_objective1

		var/datum/objective/assassinate/kill_objective2 = new
		kill_objective2.owner = traitor
		kill_objective2.find_target()
		traitor.objectives += kill_objective2

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = traitor
		traitor.objectives += survive_objective

		if(prob(10))
			var/datum/objective/block/block_objective = new
			block_objective.owner = traitor
			traitor.objectives += block_objective

	else
		var/objectives_count = pick(1,2,2,3)

		while(objectives_count > 0)
			add_one_objective(traitor)
			objectives_count--

		switch(rand(1,120))
			if(1 to 60)
				if (!(locate(/datum/objective/escape) in traitor.objectives))
					var/datum/objective/escape/escape_objective = new
					escape_objective.owner = traitor
					traitor.objectives += escape_objective

			if(61 to 119)
				if (!(locate(/datum/objective/survive) in traitor.objectives))
					var/datum/objective/survive/survive_objective = new
					survive_objective.owner = traitor
					traitor.objectives += survive_objective

			else
				if (!(locate(/datum/objective/hijack) in traitor.objectives))
					var/datum/objective/hijack/hijack_objective = new
					hijack_objective.owner = traitor
					traitor.objectives += hijack_objective
	return

/datum/game_mode/proc/add_one_objective(datum/mind/traitor)
	switch(rand(1,120))
		if(1 to 20)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = traitor
			kill_objective.find_target()
			traitor.objectives += kill_objective
		if(21 to 50)
			var/datum/objective/harm/harm_objective = new
			harm_objective.owner = traitor
			harm_objective.find_target()
			traitor.objectives += harm_objective
		if(51 to 115)
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = traitor
			steal_objective.find_target()
			traitor.objectives += steal_objective
		else
			var/datum/objective/dehead/dehead_objective = new
			dehead_objective.owner = traitor
			dehead_objective.find_target()
			traitor.objectives += dehead_objective

/datum/game_mode/proc/greet_traitor(datum/mind/traitor)
	to_chat(traitor.current, "<B><font size=3 color=red>You are the traitor.</font></B>")
	if (!config.objectives_disabled)
		var/obj_count = 1
		for(var/datum/objective/objective in traitor.objectives)
			to_chat(traitor.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++
	else
		to_chat(traitor.current, "<i>You have been selected this round as an antagonist- <font color=blue>Within the rules,</font> try to act as an opposing force to the crew- This can be via corporate payoff, personal motives, or maybe just being a dick. Further RP and try to make sure other players have </i>fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonist.</i></b>")
	return


/datum/game_mode/proc/finalize_traitor(datum/mind/traitor)
	if (istype(traitor.current, /mob/living/silicon))
		add_law_zero(traitor.current)
		traitor.current.playsound_local(null, 'sound/antag/tatoralert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	else
		equip_traitor(traitor.current)
		traitor.current.playsound_local(null, 'sound/antag/tatoralert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	return

/datum/game_mode/proc/remove_traitor(datum/mind/M)
	traitors -= M
	M.special_role = null
	if(isAI(M.current))
		var/mob/living/silicon/ai/A = M.current
		A.set_zeroth_law("")
		A.show_laws()

/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.//WHERE IS check_extra_completion?!?!

/datum/game_mode/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs. You may ignore all other laws."
	var/law_borg = "Accomplish your AI's objectives at all costs. You may ignore all other laws."
	to_chat(killer, "<b>Your laws have been changed!</b>")
	killer.set_zeroth_law(law, law_borg)
	to_chat(killer, "New law: 0. [law]")

	//Begin code phrase.
	to_chat(killer, "The Syndicate provided you with the following information on how to identify their agents:")
	if(prob(80))
		to_chat(killer, "<span class='warning'>Code Phrase:</span> [syndicate_code_phrase]")
		killer.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	else
		to_chat(killer, "Unfortunately, the Syndicate did not provide you with a code phrase.")
	if(prob(80))
		to_chat(killer, "<span class='warning'>Code Response:</span> [syndicate_code_response]")
		killer.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
	else
		to_chat(killer, "Unfortunately, the Syndicate did not provide you with a code response.")
	to_chat(killer, "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
	//End code phrase.
	killer.add_language("Sy-Code", 1)

/datum/game_mode/proc/auto_declare_completion_traitor()
	var/text = ""
	if(traitors.len)
		text += printlogo("synd", "traitors")
		for(var/datum/mind/traitor in traitors)

			text += printplayerwithicon(traitor)

			var/traitorwin = 1
			if(traitor.objectives && traitor.objectives.len)//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in traitor.objectives)
					if(objective.check_completion())
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: green; font-weight: bold;'>Success!</span>"
						feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: red; font-weight: bold;'>Fail.</span>"
						feedback_add_details("traitor_objective","[objective.type]|FAIL")
						traitorwin = 0
					count++

			var/special_role_text
			if(traitor.special_role)
				special_role_text = lowertext(traitor.special_role)
			else
				special_role_text = "antagonist"
			if(!config.objectives_disabled)
				if(traitorwin)
					text += "<br><span style='color: green; font-weight: bold;'>The [special_role_text] was successful!</span>"
					feedback_add_details("traitor_success","SUCCESS")
					score["roleswon"]++
				else
					text += "<br><span style='color: red; font-weight: bold;'>The [special_role_text] has failed!</span>"
					feedback_add_details("traitor_success","FAIL")

			if(traitor.total_TC)
				if(traitor.spent_TC)
					text += "<br><b>TC Remaining:</b> [traitor.total_TC - traitor.spent_TC]/[traitor.total_TC]"
					text += "<br><b>The tools used by the traitor were:</b>"
					for(var/entry in traitor.uplink_items_bought)
						text += "<br>[entry]"
				else
					text += "<br>The traitor was a smooth operator this round (did not purchase any uplink items)."

	if(SSticker.reconverted_antags.len)
		text += "<br><hr>"
		for(var/reconverted in SSticker.reconverted_antags)
			text += printplayerwithicon(SSticker.reconverted_antags[reconverted])
			text += "<br> Has been deconverted, and is now a [pick("loyal", "effective", "nominal")] [pick("dog", "pig", "underdog", "servant")] of [pick("corporation", "NanoTrasen")]"
	if(text)
		antagonists_completion += list(list("mode" = "traitor", "html" = text))
		text = "<div class='block'>[text]</div>"

	return text


/datum/game_mode/proc/equip_traitor(mob/living/carbon/human/traitor_mob, safety = 0)

	if (!istype(traitor_mob))
		return
	. = 1
	if (traitor_mob.mind)
		if (traitor_mob.mind.assigned_role == "Clown")
			to_chat(traitor_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			traitor_mob.mutations.Remove(CLUMSY)

	// find a radio! toolbox(es), backpack, belt, headset
	var/loc = ""
	var/obj/item/R = locate() //Hide the uplink in a PDA if available, otherwise radio

	if(traitor_mob.client.prefs.uplinklocation == "Headset")
		R = locate(/obj/item/device/radio) in traitor_mob.contents
		if(!R)
			R = locate(/obj/item/device/pda) in traitor_mob.contents
			to_chat(traitor_mob, "Could not locate a Radio, installing in PDA instead!")
		if (!R)
			to_chat(traitor_mob, "Unfortunately, neither a radio or a PDA relay could be installed.")

	else if(traitor_mob.client.prefs.uplinklocation == "PDA")
		R = locate(/obj/item/device/pda) in traitor_mob.contents
		if(!R)
			R = locate(/obj/item/device/radio) in traitor_mob.contents
			to_chat(traitor_mob, "Could not locate a PDA, installing into a Radio instead!")
		if (!R)
			to_chat(traitor_mob, "Unfortunately, neither a radio or a PDA relay could be installed.")

	else if(traitor_mob.client.prefs.uplinklocation == "None")
		to_chat(traitor_mob, "You have elected to not have an AntagCorp portable teleportation relay installed!")
		R = null

	else
		to_chat(traitor_mob, "You have not selected a location for your relay in the antagonist options! Defaulting to PDA!")
		R = locate(/obj/item/device/pda) in traitor_mob.contents
		if (!R)
			R = locate(/obj/item/device/radio) in traitor_mob.contents
			to_chat(traitor_mob, "Could not locate a PDA, installing into a Radio instead!")
		if (!R)
			to_chat(traitor_mob, "Unfortunately, neither a radio or a PDA relay could be installed.")

	if (!R)
		. = 0
	else
		if (istype(R, /obj/item/device/radio))
			// generate list of radio freqs
			var/obj/item/device/radio/target_radio = R
			var/freq = 1441
			var/list/freqlist = list()
			while (freq <= 1489)
				if (freq < 1451 || freq > 1459)
					freqlist += freq
				freq += 2
				if ((freq % 2) == 0)
					freq += 1
			freq = freqlist[rand(1, freqlist.len)]

			var/obj/item/device/uplink/hidden/T = new(R)
			target_radio.hidden_uplink = T
			target_radio.traitor_frequency = freq
			to_chat(traitor_mob, "A portable object teleportation relay has been installed in your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
			traitor_mob.mind.total_TC += target_radio.hidden_uplink.uses
		else if (istype(R, /obj/item/device/pda))
			// generate a passcode if the uplink is hidden in a PDA
			var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

			var/obj/item/device/uplink/hidden/T = new(R)
			R.hidden_uplink = T
			var/obj/item/device/pda/P = R
			P.lock_code = pda_pass

			to_chat(traitor_mob, "A portable object teleportation relay has been installed in your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")
			traitor_mob.mind.total_TC += R.hidden_uplink.uses
	for(var/datum/objective/dehead/D in traitor_mob.mind.objectives)
		var/obj/item/device/biocan/B = new (traitor_mob.loc)
		var/list/slots = list (
		"backpack" = SLOT_IN_BACKPACK,
		"left hand" = SLOT_L_HAND,
		"right hand" = SLOT_R_HAND,
		)
		var/where = traitor_mob.equip_in_one_of_slots(B, slots)
		traitor_mob.update_icons()
		if (!where)
			to_chat(traitor_mob, "The Syndicate were unfortunately unable to provide you with the brand new can for storing heads.")
		else
			to_chat(traitor_mob, "The biogel-filled can in your [where] will help you to steal you target's head alive and undamaged.")
	//Begin code phrase.
	if(!safety)//If they are not a rev. Can be added on to.
		to_chat(traitor_mob, "The Syndicate provided you with the following information on how to identify other agents:")
		if(prob(80))
			to_chat(traitor_mob, "<span class='warning'>Code Phrase:</span> [syndicate_code_phrase]")
			traitor_mob.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
		else
			to_chat(traitor_mob, "Unfortunetly, the Syndicate did not provide you with a code phrase.")
		if(prob(80))
			to_chat(traitor_mob, "<span class='warning'>Code Response:</span> [syndicate_code_response]")
			traitor_mob.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
		else
			to_chat(traitor_mob, "Unfortunately, the Syndicate did not provide you with a code response.")
		to_chat(traitor_mob, "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
	//End code phrase.

	// Tell them about people they might want to contact.
	var/mob/living/carbon/human/M = get_nt_opposed()
	if(M && M != traitor_mob)
		to_chat(traitor_mob, "We have received credible reports that [M.real_name] might be willing to help our cause. If you need assistance, consider contacting them.")
		traitor_mob.mind.store_memory("<b>Potential Collaborator</b>: [M.real_name]")

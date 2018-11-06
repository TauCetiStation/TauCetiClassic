var/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

/datum/game_mode
	var/list/datum/mind/changelings = list()


/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	role_type = ROLE_CHANGELING
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Star Vigil Officer", "Star Vigil Sergeant", "Detective", "Star Vigil Commander", "Captain")
	required_players = 2
	required_players_secret = 10
	required_enemies = 1
	recommended_enemies = 4

	votable = 0

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 20

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/changeling_amount = 4

/datum/game_mode/changeling/announce()
	to_chat(world, "<B>The current game mode is - Changeling!</B>")
	to_chat(world, "<B>There are alien changelings on the station. Do not let the changelings succeed!</B>")

/datum/game_mode/changeling/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	for(var/datum/mind/player in antag_candidates)
		if(player.assigned_role in restricted_jobs)	//Removing robots from the list
			antag_candidates -= player

	changeling_amount = 1 + round(num_players() / 10)

	if(antag_candidates.len>0)
		for(var/i = 0, i < changeling_amount, i++)
			if(!antag_candidates.len) break
			var/datum/mind/changeling = pick(antag_candidates)
			antag_candidates -= changeling
			changelings += changeling
			modePlayer += changelings
		return 1
	else
		return 0

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		changeling.special_role = "Changeling"
		if(!config.objectives_disabled)
			forge_changeling_objectives(changeling)
		greet_changeling(changeling)

	return ..()


/datum/game_mode/proc/forge_changeling_objectives(datum/mind/changeling)
	//OBJECTIVES - Always absorb 5 genomes, plus random traitor objectives.
	//If they have two objectives as well as absorb, they must survive rather than escape
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	if (config.objectives_disabled)
		return

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(2, 3)
	changeling.objectives += absorb_objective

	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = changeling
	kill_objective.find_target()
	changeling.objectives += kill_objective

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = changeling
	steal_objective.find_target()
	changeling.objectives += steal_objective


	switch(rand(1,100))
		if(1 to 80)
			if (!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = changeling
				changeling.objectives += escape_objective
		else
			if (!(locate(/datum/objective/survive) in changeling.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = changeling
				changeling.objectives += survive_objective
	return

/datum/game_mode/proc/greet_changeling(datum/mind/changeling, you_are=1)
	if (you_are)
		to_chat(changeling.current, "<B>\red You are a changeling!</B>")
	to_chat(changeling.current, "<b>\red Use say \":g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them.</b>")

	if(config.objectives_disabled)
		to_chat(changeling.current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have </i>fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")

	if (!config.objectives_disabled)
		to_chat(changeling.current, "<B>You must complete the following tasks:</B>")

	if (changeling.current.mind)
		if (changeling.current.mind.assigned_role == "Clown")
			to_chat(changeling.current, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
			changeling.current.mutations.Remove(CLUMSY)

	if (!config.objectives_disabled)
		var/obj_count = 1
		for(var/datum/objective/objective in changeling.objectives)
			to_chat(changeling.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++
		return

/*/datum/game_mode/changeling/check_finished()
	var/changelings_alive = 0
	for(var/datum/mind/changeling in changelings)
		if(!istype(changeling.current,/mob/living/carbon))
			continue
		if(changeling.current.stat==2)
			continue
		changelings_alive++

	if (changelings_alive)
		changelingdeath = 0
		return ..()
	else
		if (!changelingdeath)
			changelingdeathtime = world.time
			changelingdeath = 1
		if(world.time-changelingdeathtime > TIME_TO_GET_REVIVED)
			return 1
		else
			return ..()
	return 0*/

/datum/game_mode/proc/grant_changeling_powers(mob/living/carbon/changeling_mob)
	if(!istype(changeling_mob))	return
	changeling_mob.make_changeling()

/datum/game_mode/changeling/declare_completion()
	var/prefinal_text = ""
	var/final_text = ""
	completion_text += "<B>Changeling mode resume:</B><BR>"

	for(var/datum/mind/changeling in changelings)
		if(changeling.current.stat == DEAD)
			feedback_set_details("round_end_result","loss - changeling killed")
			prefinal_text = "<FONT size = 3>Changeling <b>[changeling.changeling.changelingID]</b><i> ([changeling.key])</I> has been <font color='red'><b>killed</b></font by the crew! The Thing failed again...</FONT><BR>"
		else
			var/failed = 0
			for(var/datum/objective/objective in changeling.objectives)
				if(!objective.check_completion())
					failed = 1
			if(!failed)
				feedback_set_details("round_end_result","win - changeling alive")
				prefinal_text = "<FONT size = 3>Changeling <b>[changeling.changeling.changelingID]</b><i> ([changeling.key])</i> managed to <font color='green'><B>complete</B></font> his mission! All humanity soon will be infested!</FONT><BR>"
			else
				feedback_set_details("round_end_result","loss - changeling alive")
				prefinal_text = "<FONT size = 3>Changeling <b>[changeling.changeling.changelingID]</b><i> ([changeling.key])</i> managed to stay alive, but <font color='red'><B>failed</B></font> his mission! Next time he will come more prepared!</FONT><BR>"
		final_text += "[prefinal_text]"

	completion_text += "[final_text]"
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_changeling()
	var/text = ""
	if(changelings.len)
		var/icon/logoa = icon('icons/mob/mob.dmi', "change-logoa")
		var/icon/logob = icon('icons/mob/mob.dmi', "change-logob")
		end_icons += logoa
		var/tempstatea = end_icons.len
		end_icons += logob
		var/tempstateb = end_icons.len
		text += {"<img src="logo_[tempstatea].png"> <B>The changelings were:</B> <img src="logo_[tempstateb].png">"}

		for(var/datum/mind/changeling in changelings)
			text += printplayerwithicon(changeling)

			var/changelingwin = 1
			if(!changeling.current)
				changelingwin = 0
			//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
			text += "<BR><B>Changeling ID:</B> [changeling.changeling.changelingID]"
			text += "<BR><B>Genomes Absorbed:</B> [changeling.changeling.absorbedcount]"
			text +="<BR><B>Stored Essences:</B>"
			for(var/mob/living/parasite/essence/E in changeling.changeling.essences)
				text += printplayerwithicon(E.mind)
				text += "<BR>"
			if(!config.objectives_disabled)
				if(changeling.objectives.len)
					var/count = 1
					for(var/datum/objective/objective in changeling.objectives)
						if(objective.check_completion())
							text += "<BR><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
							feedback_add_details("changeling_objective","[objective.type]|SUCCESS")
						else
							text += "<BR><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
							feedback_add_details("changeling_objective","[objective.type]|FAIL")
							changelingwin = 0
						count++
					if(changelingwin)
						text += "<BR><FONT color='green'><B>The changeling was successful!</B></FONT>"
						feedback_add_details("changeling_success","SUCCESS")
						score["roleswon"]++
					else
						text += "<BR><FONT color='red'><B>The changeling has failed.</B></FONT>"
						feedback_add_details("changeling_success","FAIL")
					if(changeling.current && changeling.changeling.purchasedpowers)
						text += "<BR><B>[changeling.changeling.changelingID] used the following abilities: </B>"
						var/i = 0
						for(var/obj/effect/proc_holder/changeling/C in changeling.changeling.purchasedpowers)
							if(C.genomecost >= 1)
								text += "<BR><B>#[++i]</B>: [C.name]"
						if(!i)
							text += "<BR>Changeling was too autistic and did't buy anything."


			if(changeling.total_TC)
				if(changeling.spent_TC)
					text += "<BR><B>TC Remaining:</B> [changeling.total_TC - changeling.spent_TC]/[changeling.total_TC]"
					text += "<BR><B>The tools used by the Changeling were:</B>"
					for(var/entry in changeling.uplink_items_bought)
						text += "<BR>[entry]"
				else
					text += "<BR>The Changeling was a smooth operator this round (did not purchase any uplink items)"
		text += "<BR><HR>"
	return text

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/absorbed_dna = list()
	var/list/absorbed_species = list()
	var/list/absorbed_languages = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 1
	var/chem_storage = 50
	var/chem_recharge_slowdown = 0
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 5
	var/list/purchasedpowers = list()
	var/mimicing = ""
	var/datum/dna/chosen_dna
	var/obj/effect/proc_holder/changeling/sting/chosen_sting
	var/space_suit_active = 0
	var/instatis = 0
	var/strained_muscles = 0
	var/list/essences = list()
	var/mob/living/parasite/essence/trusted_entity
	var/mob/living/parasite/essence/controled_by
	var/delegating = FALSE

/datum/changeling/New(var/gender=FEMALE)
	..()
	var/honorific
	if(gender == FEMALE)	honorific = "Ms."
	else					honorific = "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"

/datum/changeling/Destroy()
	trusted_entity = null
	controled_by = null
	QDEL_LIST(essences)
	return ..()

/datum/changeling/proc/regenerate()
	chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), chem_storage)
	geneticdamage = max(0, geneticdamage-1)


/datum/changeling/proc/GetDNA(dna_owner)
	var/datum/dna/chosen_dna
	for(var/datum/dna/DNA in absorbed_dna)
		if(dna_owner == DNA.real_name)
			chosen_dna = DNA
			break
	return chosen_dna
/*
//Checks if the target DNA is valid and absorbable.
/datum/changeling/proc/can_absorb_dna(mob/living/carbon/T, mob/living/carbon/U)
	if(T)
		if(NOCLONE in T.mutations || HUSK in T.mutations)
			to_chat(U, "<span class='warning'>DNA of [T] is ruined beyond usability!</span>")
			return 0

		if(T:species.flags[IS_SYNTHETIC] || T:species.flags[IS_PLANT])
			to_chat(U, "<span class='warning'>[T] is not compatible with our biology.</span>")
			return 0

		if(T:species.flags[NO_SCAN])
			to_chat(src, "<span class='warning'>We do not know how to parse this creature's DNA!</span>")
			return 0

		for(var/datum/dna/D in absorbed_dna)
			if(T.dna.uni_identity == D.uni_identity)
				if(T.dna.struc_enzymes == D.struc_enzymes)
					if(T.dna.real_name == D.real_name)
						if(T.dna.mutantrace == D.mutantrace)
							to_chat(U, "<span class='warning'>We already have that DNA in storage.</span>")
							return 0
	return 1 */

/datum/game_mode/var/list/datum/mind/ninjas = list()
// Keep in mind ninja-procs that aren't here will be where the event's defined
/datum/game_mode/ninja
	name = "ninja"
	config_tag = "ninja"
	role_type = ROLE_NINJA
	restricted_jobs = list("Cyborg", "AI")
	required_players = 10 //Can be adjusted later, should suffice for now.
	required_players_secret = 15
	required_enemies = 2
	recommended_enemies = 2

	votable = 0

	var/finished = 0

/datum/game_mode/ninja/announce()
	to_chat(world, "<B>The current game mode is Ninja!</B>")

/datum/game_mode/ninja/can_start()
	if (!..())
		return FALSE
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "carpspawn")
			return TRUE
	return FALSE

/datum/game_mode/ninja/assign_outsider_antag_roles()
	if(!..())
		return FALSE
	var/ninja_number = required_enemies
	if (antag_candidates.len <= recommended_enemies)
		ninja_number = antag_candidates.len
	while(ninja_number > 0)
		var/datum/mind/ninja = pick(antag_candidates)
		if(ninja_number == 1)
			ninja.protector_role = TRUE
		ninjas += ninja
		modePlayer += ninja
		ninja.assigned_role = "MODE" //So they aren't chosen for other jobs.
		ninja.special_role = "Ninja"
		ninja.original = ninja.current
		antag_candidates -= ninja //So it doesn't pick the same guy each time.
		ninja_number--
	return TRUE

/datum/game_mode/ninja/pre_setup()
	//Until such a time as people want to place ninja spawn points, carpspawn will do fine.
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "carpspawn")
			ninjastart.Add(L)
	for(var/datum/mind/ninja in ninjas)
		ninja.current << browse(null, "window=playersetup")
		var/start_point = pick(ninjastart)
		ninjastart -= start_point
		//ninja.current = create_space_ninja(pick(ninjastart.len ? ninjastart : latejoin))
		ninja.current = create_space_ninja(start_point)
		ninja.current.ckey = ninja.key
	return TRUE

/datum/game_mode/ninja/post_setup()
	for(var/datum/mind/ninja in ninjas)
		if(ninja.current && !(istype(ninja.current,/mob/living/carbon/human))) return 0
		if(!config.objectives_disabled)
			forge_ninja_objectives(ninja)
		else
			to_chat(ninja.current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")
		var/mob/living/carbon/human/N = ninja.current
		N.internal = N.s_store
		N.internals.icon_state = "internal1"
		if(N.wear_suit && istype(N.wear_suit,/obj/item/clothing/suit/space/space_ninja))
			var/obj/item/clothing/suit/space/space_ninja/S = N.wear_suit
			S:randomize_param()
	return ..()

/datum/game_mode/ninja/check_finished()
	if(config.continous_rounds)
		return ..()
	var/ninjas_alive = 0
	for(var/datum/mind/ninja in ninjas)
		if(!istype(ninja.current,/mob/living/carbon/human))
			continue
		if(ninja.current.stat==2)
			continue
		ninjas_alive++
	if (ninjas_alive)
		return ..()
	else
		finished = 1
		return 1

/datum/game_mode/ninja/proc/forge_ninja_objectives(datum/mind/ninja)
	if (config.objectives_disabled)
		return

	if(!ninja.protector_role)
		//var/objective_list = list(1,2,3,4,5)
		var/objective_list = list(1,2,3,4)
		for(var/i=rand(2,4),i>0,i--)
			switch(pick(objective_list))
				if(1)//Kill
					var/datum/objective/assassinate/ninja_objective = new
					ninja_objective.owner = ninja
					ninja_objective.target = ninja_objective.find_target()
					if(ninja_objective.target != "Free Objective")
						ninja.objectives += ninja_objective
					else
						i++
					objective_list -= 1 // No more than one kill objective
				if(2)//Steal
					var/datum/objective/steal/ninja_objective = new
					ninja_objective.owner = ninja
					ninja_objective.target = ninja_objective.find_target()
					ninja.objectives += ninja_objective
				/*if(3)//Protect
					var/datum/objective/protect/ninja_objective = new
					ninja_objective.owner = ninja
					ninja_objective.target = ninja_objective.find_target()
					if(ninja_objective.target != "Free Objective")
						ninja.objectives += ninja_objective
					else
						i++
						objective_list -= 3*/
				//if(4)//Download
				if(3)//Download
					var/datum/objective/download/ninja_objective = new
					ninja_objective.owner = ninja
					ninja_objective.gen_amount_goal()
					ninja.objectives += ninja_objective
					//objective_list -= 4
					objective_list -= 3
				//if(5)//Harm
				if(4)//Harm
					var/datum/objective/harm/ninja_objective = new
					ninja_objective.owner = ninja
					ninja_objective.target = ninja_objective.find_target()
					if(ninja_objective.target != "Free Objective")
						ninja.objectives += ninja_objective
					else
						i++
						//objective_list -= 5
						objective_list -= 4
	else
		for(var/datum/mind/ninja_p in ninjas)
			if(!ninja_p.protector_role)
				for(var/datum/objective/objective_p in ninja_p.objectives)
					if(istype(objective_p, /datum/objective/assassinate))
						if(objective_p.target.current == ninja_p.current)
							continue
						if(objective_p.target.current == ninja.current)
							continue
						var/datum/objective/protect/ninja_objective = new
						ninja_objective.owner = ninja

						ninja_objective.target = objective_p.target
						ninja_objective.explanation_text = "Protect [objective_p.target.current.real_name], the [objective_p.target.assigned_role]."

						ninja.objectives += ninja_objective

					if(istype(objective_p, /datum/objective/steal))
						var/datum/objective/steal/ninja_objective = new
						ninja_objective.owner = ninja

						ninja_objective.target = objective_p.target
						ninja_objective.steal_target = objective_p.target
						ninja_objective.explanation_text = objective_p.explanation_text

						ninja.objectives += ninja_objective

					if(istype(objective_p, /datum/objective/download))
						var/datum/objective/download/ninja_objective = new
						ninja_objective.owner = ninja
						ninja_objective.target_amount = objective_p.target_amount
						ninja_objective.explanation_text = objective_p.explanation_text
						ninja.objectives += ninja_objective

					if(istype(objective_p, /datum/objective/harm))
						if(objective_p.target.current == ninja_p.current)
							continue
						if(objective_p.target.current == ninja.current)
							continue
						var/datum/objective/protect/ninja_objective = new
						ninja_objective.owner = ninja
						ninja_objective.target = objective_p.target
						ninja_objective.explanation_text = objective_p.explanation_text
						ninja.objectives += ninja_objective

				var/datum/objective/assassinate/ninja_objective = new
				ninja_objective.owner = ninja
				ninja_objective.target = ninja_p
				ninja_objective.explanation_text = "Assassinate [ninja_p.current.real_name], the [ninja_p.special_role]."
				ninja.objectives += ninja_objective

	var/datum/objective/survive/ninja_objective = new
	ninja_objective.owner = ninja
	ninja.objectives += ninja_objective
	ninja.current.mind = ninja

	var/directive = generate_ninja_directive("heel")//Only hired by antags, not NT
	to_chat(ninja.current, "<span class = 'info'><B>You are <font color='red'>Ninja</font>!</B></span>")
	to_chat(ninja.current, "You are an elite mercenary assassin of the Spider Clan, [ninja.current.real_name]. You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor")
	to_chat(ninja.current, "Your current directive is: <span class = 'red'><B>[directive]</B></span>")
	to_chat(ninja.current, "<span class = 'info'>Try your best to adhere to this.</span>")
	ninja.store_memory("<B>Directive:</B> <span class='red'>[directive]</span><br>")

	var/obj_count = 1
	to_chat(ninja.current, "<span class = 'info'><B>Your current objectives:</B></span>")
	for(var/datum/objective/objective in ninja.objectives)
		to_chat(ninja.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++

/datum/game_mode/proc/auto_declare_completion_ninja()
	var/text = ""
	if(ninjas.len)
		text += printlogo("ninja", "ninjas")
		for(var/datum/mind/ninja in ninjas)
			text += printplayerwithicon(ninja)

			var/ninjawin = 1
			if(ninja.objectives.len)//If the ninja had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in ninja.objectives)
					if(objective.check_completion())
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: green; font-weight: bold;'>Success!</span>"
						feedback_add_details("ninja_objective","[objective.type]|SUCCESS")
					else
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span style='color: red; font-weight: bold;'>Fail.</span>"
						feedback_add_details("ninja_objective","[objective.type]|FAIL")
						ninjawin = 0
					count++

			var/special_role_text
			if(ninja.special_role)
				special_role_text = lowertext(ninja.special_role)
			else
				special_role_text = "antagonist"

			if(!config.objectives_disabled)
				if(ninjawin)
					text += "<br><span style='color: green; font-weight: bold;'>The [special_role_text] was successful!</span>"
					feedback_add_details("traitor_success","SUCCESS")
					score["roleswon"]++
				else
					text += "<br><span style='color: green; font-weight: bold;'>The [special_role_text] has failed!</span>"
					feedback_add_details("traitor_success","FAIL")

	if(text)
		antagonists_completion += list(list("mode" = "ninja", "html" = text))
		text = "<div class='block'>[text]</div>"

	return text

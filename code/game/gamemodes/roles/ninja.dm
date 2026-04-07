/datum/role/ninja
	name = NINJA
	id = NINJA
	required_pref = ROLE_NINJA
	disallow_job = TRUE

	antag_hud_type = ANTAG_HUD_NINJA
	antag_hud_name = "hudninja"

	restricted_jobs = list("Cyborg", "AI")
	logo_state = "ninja-logo"
	skillset_type = /datum/skillset/max

/datum/role/ninja/OnPostSetup(laterole)
	. = ..()
	var/mob/living/carbon/human/ninja = antag.current
	ninja.real_name = "[pick(ninja_titles)] [pick(ninja_names)]"
	ninja.dna.ready_dna(ninja)
	ninja.equip_space_ninja(TRUE)
	ninja.internal = ninja.s_store
	if(ninja.wear_suit && istype(ninja.wear_suit,/obj/item/clothing/suit/space/space_ninja))
		var/obj/item/clothing/suit/space/space_ninja/S = ninja.wear_suit
		S.randomize_param()

/datum/role/ninja/proc/get_other_ninja()
	for(var/datum/role/R in faction.members)
		if(R != src)
			return R

/datum/role/ninja/forgeObjectives()
	if(!..())
		return FALSE
	var/datum/role/second_ninja = get_other_ninja()
	if(!antag.protector_role && !second_ninja)
		var/objective_list = list(1,2,3)
		for(var/i = rand(2,3), i > 0, i--)
			switch(pick(objective_list))
				if(1)
					AppendObjective(/datum/objective/target/assassinate)
					objective_list -= 1
				if(2)
					AppendObjective(/datum/objective/steal)
				if(3)
					AppendObjective(/datum/objective/target/harm)
	else
		if(!second_ninja.antag.protector_role)
			for(var/datum/objective/target/objective_p in second_ninja.objectives.GetObjectives())
				if(istype(objective_p, /datum/objective/target/assassinate))
					if(objective_p.target.current == antag.current)
						continue
					if(objective_p.target.current == second_ninja.antag.current)
						continue
					var/datum/objective/target/protect/ninja_objective = AppendObjective(/datum/objective/target/protect)
					if(ninja_objective)
						ninja_objective.target = objective_p.target
						ninja_objective.explanation_text = "Protect [objective_p.target.current.real_name], the [objective_p.target.assigned_role]."

				if(istype(objective_p, /datum/objective/steal))
					var/datum/objective/steal/ninja_objective = AppendObjective(/datum/objective/steal)

					if(ninja_objective)
						ninja_objective.steal_target = objective_p.target
						ninja_objective.explanation_text = objective_p.explanation_text

				if(istype(objective_p, /datum/objective/target/harm))
					if(objective_p.target.current == antag.current)
						continue
					if(objective_p.target.current == second_ninja.antag.current)
						continue
					var/datum/objective/target/protect/ninja_objective = AppendObjective(/datum/objective/target/protect)
					if(ninja_objective)
						ninja_objective.target = objective_p.target
						ninja_objective.explanation_text = objective_p.explanation_text

			var/datum/objective/target/assassinate/ninja_objective = AppendObjective(/datum/objective/target/assassinate)
			if(ninja_objective)
				ninja_objective.target = second_ninja.antag
				ninja_objective.explanation_text = "Assassinate [second_ninja.antag.current.real_name], the [second_ninja.antag.special_role]."

	return TRUE

/datum/role/ninja/Greet(greeting, custom)
	. = ..()
	var/directive = generate_ninja_directive("heel") //Only hired by antags, not NT
	to_chat(antag.current, "<span class = 'info'><B>You are <font color='red'>Ninja</font>!</B></span>")
	to_chat(antag.current, "You are an elite mercenary assassin of the Spider Clan, [antag.current.real_name]. You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor")
	to_chat(antag.current, "Your current directive is: <span class = 'red'><B>[directive]</B></span>")
	to_chat(antag.current, "<span class = 'info'>Try your best to adhere to this.</span>")
	antag.store_memory("<B>Directive:</B> <span class='red'>[directive]</span><br>")

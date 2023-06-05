/datum/skillset/jack_of_all_trades
	name = "Jack of All Trades"
	initial_skills = list(
		/datum/skill/police = SKILL_LEVEL_TRAINED,
		/datum/skill/firearms = SKILL_LEVEL_TRAINED,
		/datum/skill/melee = SKILL_LEVEL_TRAINED,
		/datum/skill/engineering = SKILL_LEVEL_TRAINED,
		/datum/skill/construction = SKILL_LEVEL_TRAINED,
		/datum/skill/atmospherics = SKILL_LEVEL_TRAINED,
		/datum/skill/civ_mech = SKILL_LEVEL_TRAINED,
		/datum/skill/combat_mech = SKILL_LEVEL_TRAINED,
		/datum/skill/surgery = SKILL_LEVEL_TRAINED,
		/datum/skill/medical = SKILL_LEVEL_TRAINED,
		/datum/skill/chemistry = SKILL_LEVEL_TRAINED,
		/datum/skill/research = SKILL_LEVEL_TRAINED,
		/datum/skill/command = SKILL_LEVEL_TRAINED
	)

/datum/skillset/random
	name = "Random skillset"
	var/skill_max = 2
	var/skillpoints_total = 5
	initial_skills = list()
	skills = list()

/datum/skillset/random/New()
	skills = list()
	for(var/i in 1 to skillpoints_total)
		var/skill_improvement = pick(default_skills_list)
		skills[skill_improvement] += 1
		if(skills[skill_improvement] >= skill_max)
			skills -= skill_improvement
	..()

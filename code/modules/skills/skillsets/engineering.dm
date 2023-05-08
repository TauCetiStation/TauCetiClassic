/datum/skillset/ce
	name = "Chief Engineer"
	initial_skills = list(
		/datum/skill/construction = SKILL_LEVEL_MASTER,
		/datum/skill/command = SKILL_LEVEL_PRO,
		/datum/skill/engineering = SKILL_LEVEL_MASTER,
		/datum/skill/atmospherics = SKILL_LEVEL_MASTER,
		/datum/skill/research = SKILL_LEVEL_NOVICE,
		/datum/skill/medical = SKILL_LEVEL_NOVICE,
		/datum/skill/civ_mech = SKILL_LEVEL_MASTER,
	)

/datum/skillset/engineer
	name = "Station Engineer"
	initial_skills = list(
		/datum/skill/construction = SKILL_LEVEL_PRO,
		/datum/skill/engineering = SKILL_LEVEL_PRO,
		/datum/skill/atmospherics = SKILL_LEVEL_TRAINED,
		/datum/skill/civ_mech = SKILL_LEVEL_TRAINED
	)

/datum/skillset/atmostech
	name = "Atmospheric Technician"
	initial_skills = list(
		/datum/skill/atmospherics = SKILL_LEVEL_MASTER,
		/datum/skill/construction = SKILL_LEVEL_PRO,
		/datum/skill/engineering = SKILL_LEVEL_TRAINED,
		/datum/skill/melee = SKILL_LEVEL_TRAINED,
		/datum/skill/civ_mech = SKILL_LEVEL_TRAINED
	)

/datum/skillset/technicassistant
	name = "Technical Assistant"
	initial_skills = list(
		/datum/skill/construction = SKILL_LEVEL_TRAINED,
		/datum/skill/engineering = SKILL_LEVEL_TRAINED,
		/datum/skill/atmospherics = SKILL_LEVEL_NOVICE,
		/datum/skill/civ_mech = SKILL_LEVEL_NOVICE
	)

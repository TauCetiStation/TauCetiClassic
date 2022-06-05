/datum/skillset/ce
	name = "Chief Engineer"
	initial_skills = list(
		/datum/skill/construction/master,
		/datum/skill/command/pro,
		/datum/skill/engineering/master,
		/datum/skill/atmospherics/master,
		/datum/skill/research/novice,
		/datum/skill/medical/novice,
		/datum/skill/civ_mech/master,
	)

/datum/skillset/engineer
	name = "Station Engineer"
	initial_skills = list(
		/datum/skill/construction/pro,
		/datum/skill/engineering/pro,
		/datum/skill/atmospherics/trained,
		/datum/skill/civ_mech/trained
	)

/datum/skillset/atmostech
	name = "Atmospheric Technician"
	initial_skills = list(
		/datum/skill/atmospherics/master,
		/datum/skill/construction/pro,
		/datum/skill/engineering/trained,
		/datum/skill/melee/trained,
		/datum/skill/civ_mech/trained
	)

/datum/skillset/technicassistant
	name = "Technical Assistant"
	initial_skills = list(
		/datum/skill/construction/trained,
		/datum/skill/engineering/trained,
		/datum/skill/atmospherics/novice,
		/datum/skill/civ_mech/novice
	)

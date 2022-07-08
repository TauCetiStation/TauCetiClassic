/datum/skill
	var/name
	var/hint
	var/list/custom_ranks = list(
		"Untrained",
		"Novice",
		"Trained",
		"Professional",
		"Master",
		"Robust"
	)

/datum/skill/civ_mech
	name =  SKILL_CIV_MECH
	hint = "Faster moving speed of piloted civilian exosuits: Ripley and Odysseus."
	custom_ranks = list(
		"Untrained",
		"Novice",
		"Trained",
		"Professional",
		"Forklift certified",
		"Racer"
	)


/datum/skill/combat_mech
	name = SKILL_COMBAT_MECH
	hint = "Faster moving speed of piloted combat exosuits."
	custom_ranks = list(
		"Untrained",
		"Novice",
		"Trained",
		"Professional",
		"Master",
		"Certified combat driver"
	)

/datum/skill/police
	name = SKILL_POLICE
	hint = "Usage of tasers and stun batons. Higher levels allows for faster handcuffing."
	custom_ranks = list(
		"Untrained",
		"Novice",
		"Trained",
		"Veteran",
		"Master",
		"First Lieutenant"
	)


/datum/skill/firearms
	name = SKILL_FIREARMS
	hint = "Affects recoil from firearms. Proficiency in firearms allows for tactical reloads. Usage of mines and explosives."
	custom_ranks = list(
		"Untrained",
		"Novice",
		"Trained",
		"Professional",
		"Firearms master",
		"Godlike sniper"
	)

/datum/skill/melee
	name = SKILL_MELEE
	hint = "Higher levels means more damage with melee weapons."
	custom_ranks = list(
		"Untrained",
		"Novice",
		"Trained",
		"Professional",
		"Black belt",
		"CQC god"
	)

/datum/skill/atmospherics
	name = SKILL_ATMOS
	hint = "Interacting with atmos related devices: pumps, scrubbers and filters. Usage of atmospherics computers. Faster pipes unwrenching."
	custom_ranks = list(
		"Untrained",
		"Novice",
		"Trained",
		"Professional",
		"Master",
		"God of pipes"
	)

/datum/skill/construction
	name = SKILL_CONSTRUCTION
	hint = "Construction of walls, windows, computers and crafting."

/datum/skill/chemistry
	name = SKILL_CHEMISTRY
	hint = "Chemistry related machinery: grinders, chem dispensers and chem robusts. You can recognize reagents in pills and bottles."

/datum/skill/research
	name = SKILL_RESEARCH
	hint = "Usage of complex machinery and computers. AI law modification, xenoarcheology and xenobiology consoles, exosuit fabricators."
	custom_ranks = list(
		"Dumb",
		"High school diploma",
		"Associate's degree",
		"Bachelor's degree",
		"Master's degree",
		"Ph.D."
	)

/datum/skill/medical
	name = SKILL_MEDICAL
	hint = "Faster usage of syringes. Proficiency with defibrilators, medical scanners, cryo tubes, sleepers and life support machinery."
	custom_ranks = list(
		"Untrained",
		"Novice",
		"Intern",
		"Professional",
		"Master",
		"Asclepius"
	)

/datum/skill/surgery
	name = SKILL_SURGERY
	hint = "Higher level means faster surgical operations."

/datum/skill/command
	name = SKILL_COMMAND
	hint = "Usage of identification computers, communication consoles and fax."
	custom_ranks = list(
		"Untrained",
		"Novice",
		"Trained",
		"Professional",
		"Master",
		"True leader"
	)

/datum/skill/engineering
	name = SKILL_ENGINEERING
	hint = "Tools usage, hacking, wall repairs and deconstruction. Engine related tasks and configuring of telecommunications."
	custom_ranks = list(
		"Untrained",
		"Novice",
		"Trained",
		"Professional",
		"Master",
		"God of engineering"
	)

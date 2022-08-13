/datum/skillset/cmo
	name = "Chief Medical Officer"
	initial_skills = list(
		/datum/skill/medical = SKILL_LEVEL_MASTER,
		/datum/skill/surgery = SKILL_LEVEL_MASTER,
		/datum/skill/chemistry = SKILL_LEVEL_MASTER,
		/datum/skill/command = SKILL_LEVEL_PRO,
		/datum/skill/civ_mech = SKILL_LEVEL_MASTER,
		/datum/skill/research = SKILL_LEVEL_TRAINED
	)


/datum/skillset/doctor
	name = "Medical Doctor"
	initial_skills = list(
		/datum/skill/medical = SKILL_LEVEL_PRO,
		/datum/skill/surgery = SKILL_LEVEL_PRO,
		/datum/skill/civ_mech = SKILL_LEVEL_TRAINED,
		/datum/skill/chemistry = SKILL_LEVEL_PRO
	)

/datum/skillset/doctor/surgeon
	name = "Surgeon"
	initial_skills = list(
		/datum/skill/surgery = SKILL_LEVEL_MASTER,
		/datum/skill/medical = SKILL_LEVEL_PRO,
		/datum/skill/chemistry = SKILL_LEVEL_TRAINED,
		/datum/skill/civ_mech = SKILL_LEVEL_NOVICE
	)

/datum/skillset/doctor/nurse
	name = "Nurse"
	initial_skills = list(
		/datum/skill/surgery = SKILL_LEVEL_TRAINED,
		/datum/skill/medical = SKILL_LEVEL_MASTER,
		/datum/skill/chemistry = SKILL_LEVEL_PRO,
		/datum/skill/civ_mech = SKILL_LEVEL_NOVICE
	)

/datum/skillset/virologist
	name = "Virologist"
	initial_skills = list(
		/datum/skill/chemistry = SKILL_LEVEL_TRAINED,
		/datum/skill/research = SKILL_LEVEL_TRAINED,
		/datum/skill/medical = SKILL_LEVEL_PRO,
		/datum/skill/surgery = SKILL_LEVEL_NOVICE,
		/datum/skill/civ_mech = SKILL_LEVEL_NOVICE
	)

/datum/skillset/chemist
	name = "Chemist"
	initial_skills = list(
		/datum/skill/chemistry = SKILL_LEVEL_MASTER,
		/datum/skill/medical = SKILL_LEVEL_PRO,
		/datum/skill/surgery = SKILL_LEVEL_NOVICE,
		/datum/skill/civ_mech = SKILL_LEVEL_NOVICE
	)

/datum/skillset/paramedic
	name = "Paramedic"
	initial_skills = list(
		/datum/skill/medical = SKILL_LEVEL_PRO,
		/datum/skill/surgery = SKILL_LEVEL_TRAINED,
		/datum/skill/civ_mech = SKILL_LEVEL_MASTER,
		/datum/skill/chemistry = SKILL_LEVEL_TRAINED
	)

/datum/skillset/psychiatrist
	name = "Psychiatrist"
	initial_skills = list(
		/datum/skill/medical = SKILL_LEVEL_TRAINED,
		/datum/skill/command = SKILL_LEVEL_NOVICE,
		/datum/skill/chemistry = SKILL_LEVEL_TRAINED,
		/datum/skill/surgery = SKILL_LEVEL_NOVICE
	)

/datum/skillset/geneticist
	name = "Geneticist"
	initial_skills = list(
		/datum/skill/research = SKILL_LEVEL_TRAINED,
		/datum/skill/medical = SKILL_LEVEL_PRO,
		/datum/skill/surgery = SKILL_LEVEL_NOVICE,
		/datum/skill/chemistry = SKILL_LEVEL_NOVICE,
		/datum/skill/civ_mech = SKILL_LEVEL_NOVICE,
	)

/datum/skillset/intern
	name = "Medical intern"
	initial_skills = list(
		/datum/skill/medical = SKILL_LEVEL_TRAINED,
		/datum/skill/surgery = SKILL_LEVEL_TRAINED,
		/datum/skill/chemistry = SKILL_LEVEL_TRAINED,
		/datum/skill/civ_mech = SKILL_LEVEL_TRAINED
	)

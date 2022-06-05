/datum/skillset/cmo
	name = "Chief Medical Officer"
	initial_skills = list(
		/datum/skill/medical/master,
		/datum/skill/surgery/master,
		/datum/skill/chemistry/master,
		/datum/skill/command/pro,
		/datum/skill/civ_mech/master,
		/datum/skill/research/trained
	)


/datum/skillset/doctor
	name = "Medical Doctor"
	initial_skills = list(
		/datum/skill/medical/pro,
		/datum/skill/surgery/pro,
		/datum/skill/civ_mech/trained,
		/datum/skill/chemistry/pro
	)

/datum/skillset/doctor/surgeon
	name = "Surgeon"
	initial_skills = list(
		/datum/skill/surgery/master,
		/datum/skill/medical/pro,
		/datum/skill/chemistry/trained,
		/datum/skill/civ_mech/novice
	)

/datum/skillset/doctor/nurse
	name = "Nurse"
	initial_skills = list(
		/datum/skill/surgery/trained,
		/datum/skill/medical/master,
		/datum/skill/chemistry/pro,
		/datum/skill/civ_mech/novice
	)

/datum/skillset/virologist
	name = "Virologist"
	initial_skills = list(
		/datum/skill/chemistry/trained,
		/datum/skill/research/trained,
		/datum/skill/medical/pro,
		/datum/skill/surgery/novice,
		/datum/skill/civ_mech/novice
	)

/datum/skillset/chemist
	name = "Chemist"
	initial_skills = list(
		/datum/skill/chemistry/master,
		/datum/skill/medical/pro,
		/datum/skill/surgery/novice,
		/datum/skill/civ_mech/novice
	)

/datum/skillset/paramedic
	name = "Paramedic"
	initial_skills = list(
		/datum/skill/medical/pro,
		/datum/skill/surgery/trained,
		/datum/skill/civ_mech/master,
		/datum/skill/chemistry/trained
	)

/datum/skillset/psychiatrist
	name = "Psychiatrist"
	initial_skills = list(
		/datum/skill/medical/trained,
		/datum/skill/command/novice,
		/datum/skill/chemistry/trained,
		/datum/skill/surgery/novice
	)

/datum/skillset/geneticist
	name = "Geneticist"
	initial_skills = list(
		/datum/skill/research/trained,
		/datum/skill/medical/pro,
		/datum/skill/surgery/novice,
		/datum/skill/chemistry/novice,
		/datum/skill/civ_mech/novice,
	)

/datum/skillset/intern
	name = "Medical intern"
	initial_skills = list(
		/datum/skill/medical/trained,
		/datum/skill/surgery/trained,
		/datum/skill/chemistry/trained,
		/datum/skill/civ_mech/trained
	)

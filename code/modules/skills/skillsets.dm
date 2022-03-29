

//medical

/datum/skillset/cmo
	initial_skills = list(
		/datum/skill/medical/master,
		/datum/skill/surgery/master,
		/datum/skill/chemistry/master,
		/datum/skill/command/pro,
		/datum/skill/civ_mech/master,
		/datum/skill/police/trained,
	)


/datum/skillset/doctor
	initial_skills = list(
		/datum/skill/medical/expert,
		/datum/skill/surgery/pro,
		/datum/skill/civ_mech/trained,
		/datum/skill/chemistry/trained
	)

/datum/skillset/doctor/surgeon
	initial_skills = list(
		/datum/skill/surgery/master,
		/datum/skill/medical/pro,
		/datum/skill/chemistry/novice
	)

/datum/skillset/doctor/nurse
	initial_skills = list(
		/datum/skill/surgery/trained,
		/datum/skill/medical/master,
		/datum/skill/chemistry/novice
	)

/datum/skillset/virologist
	initial_skills = list(
		/datum/skill/chemistry/trained,
		/datum/skill/research/novice,
		/datum/skill/medical/pro,
		/datum/skill/surgery/novice,
		/datum/skill/civ_mech/novice
	)

/datum/skillset/chemist
	initial_skills = list(
		/datum/skill/chemistry/master,
		/datum/skill/medical/pro,
		/datum/skill/surgery/novice,
		/datum/skill/civ_mech/novice
	)

/datum/skillset/paramedic
	initial_skills = list(
		/datum/skill/medical/expert,
		/datum/skill/surgery/trained,
		/datum/skill/civ_mech/pro,
		/datum/skill/chemistry/novice
	)

/datum/skillset/psychiatrist
	initial_skills = list(
		/datum/skill/medical/pro,
		/datum/skill/command/novice,
		/datum/skill/chemistry/trained,
		/datum/skill/surgery/novice
	)

/datum/skillset/geneticist
	initial_skills = list(
		/datum/skill/research/trained,
		/datum/skill/medical/pro,
		/datum/skill/surgery/novice,
		/datum/skill/chemistry/novice,
		/datum/skill/civ_mech/novice,
	)

/datum/skillset/intern
	initial_skills = list(
		/datum/skill/medical/pro,
		/datum/skill/surgery/trained,
		/datum/skill/chemistry/trained,
		/datum/skill/civ_mech/trained
	)

//engineering
/datum/skillset/ce
	initial_skills = list(
		/datum/skill/construction/master,
		/datum/skill/command/pro,
		/datum/skill/engineering/master,
		/datum/skill/atmospherics/master,
		/datum/skill/civ_mech/master,
		/datum/skill/police/trained
	)

/datum/skillset/engineer
	initial_skills = list(
		/datum/skill/construction/pro,
		/datum/skill/engineering/pro,
		/datum/skill/atmospherics/trained,
		/datum/skill/civ_mech/trained
	)

/datum/skillset/atmostech
	initial_skills = list(
		/datum/skill/atmospherics/master,
		/datum/skill/construction/pro,
		/datum/skill/engineering/trained,
		/datum/skill/melee/trained,
		/datum/skill/civ_mech/trained
	)

/datum/skillset/technicassistant
	initial_skills = list(
		/datum/skill/construction/trained,
		/datum/skill/engineering/trained,
		/datum/skill/atmospherics/novice,
		/datum/skill/civ_mech/novice
	)

//security
/datum/skillset/hos
	initial_skills = list(
		/datum/skill/firearms/master,
		/datum/skill/command/pro,
		/datum/skill/police/master,
		/datum/skill/melee/master,
		/datum/skill/medical/trained,
		/datum/skill/combat_mech/master
	)

/datum/skillset/warden
	initial_skills = list(
		/datum/skill/firearms/master,
		/datum/skill/command/trained,
		/datum/skill/police/master,
		/datum/skill/melee/master,
		/datum/skill/medical/novice,
		/datum/skill/combat_mech/trained
	)

/datum/skillset/officer
	initial_skills = list(
		/datum/skill/firearms/master,
		/datum/skill/police/master,
		/datum/skill/melee/master,
		/datum/skill/combat_mech/trained,
		/datum/skill/command/novice
	)

/datum/skillset/cadet
	initial_skills = list(
		/datum/skill/firearms/trained,
		/datum/skill/police/trained,
		/datum/skill/melee/trained
	)

/datum/skillset/forensic
	initial_skills = list(
		/datum/skill/surgery/pro,
		/datum/skill/medical/trained,
		/datum/skill/research/novice,
		/datum/skill/chemistry/novice
	)

/datum/skillset/detective
	initial_skills = list(
		/datum/skill/police/trained,
		/datum/skill/firearms/master,
		/datum/skill/medical/novice,
		/datum/skill/surgery/novice,
		/datum/skill/melee/trained,
	)

//science
/datum/skillset/rd
	initial_skills = list(
		/datum/skill/research/master,
		/datum/skill/command/pro,
		/datum/skill/atmospherics/trained,
		/datum/skill/construction/pro,
		/datum/skill/chemistry/trained,
		/datum/skill/medical/pro,
		/datum/skill/civ_mech/master,
		/datum/skill/combat_mech/master,
		/datum/skill/police/trained,
		/datum/skill/surgery/pro,
		/datum/skill/engineering/master
	)

/datum/skillset/scientist
	initial_skills = list(
		/datum/skill/research/pro,
		/datum/skill/atmospherics/novice,
		/datum/skill/construction/trained,
		/datum/skill/engineering/novice,
		/datum/skill/chemistry/novice,
		/datum/skill/medical/novice,
		/datum/skill/surgery/novice,
		/datum/skill/civ_mech/novice
	)
/datum/skillset/scientist/phoron
	initial_skills = list(
		/datum/skill/research/trained,
		/datum/skill/atmospherics/trained,
		/datum/skill/construction/novice,
		/datum/skill/engineering/novice,
		/datum/skill/chemistry/trained,
		/datum/skill/medical/novice,
		/datum/skill/surgery/novice,
		/datum/skill/civ_mech/novice
	)

/datum/skillset/roboticist
	initial_skills = list(
		/datum/skill/research/pro,
		/datum/skill/surgery/trained,
		/datum/skill/medical/trained,
		/datum/skill/construction/trained,
		/datum/skill/engineering/novice,
		/datum/skill/civ_mech/pro,
		/datum/skill/combat_mech/trained
	)

/datum/skillset/roboticist/bio
	initial_skills = list(
		/datum/skill/research/pro,
		/datum/skill/surgery/pro,
		/datum/skill/medical/pro,
		/datum/skill/construction/trained,
		/datum/skill/engineering/novice,
		/datum/skill/civ_mech/trained,
		/datum/skill/combat_mech/trained
	)

/datum/skillset/roboticist/mecha
	initial_skills = list(
		/datum/skill/research/pro,
		/datum/skill/surgery/novice,
		/datum/skill/medical/novice,
		/datum/skill/construction/pro,
		/datum/skill/engineering/trained,
		/datum/skill/civ_mech/master,
		/datum/skill/combat_mech/master
	)

/datum/skillset/xenoarchaeologist
	initial_skills = list(
		/datum/skill/chemistry/trained,
		/datum/skill/research/trained,
		/datum/skill/civ_mech/trained,
		/datum/skill/medical/trained
	)

/datum/skillset/xenobiologist
	initial_skills = list(
		/datum/skill/research/trained,
		/datum/skill/surgery/novice,
		/datum/skill/medical/trained,
		/datum/skill/chemistry/novice
	)

/datum/skillset/research_assistant
	initial_skills = list(
		/datum/skill/research/novice,
		/datum/skill/medical/novice,
		/datum/skill/surgery/novice,
		/datum/skill/construction/novice,
		/datum/skill/engineering/novice,
		/datum/skill/civ_mech/novice
	)

//cargo
/datum/skillset/quartermaster
	initial_skills = list(
		/datum/skill/civ_mech/master,
		/datum/skill/police/trained,
		/datum/skill/construction/novice,
		/datum/skill/command/trained
	)

/datum/skillset/miner
	initial_skills = list(
		/datum/skill/civ_mech/master,
		/datum/skill/firearms/trained,
		/datum/skill/research/novice
	)

/datum/skillset/cargotech
	initial_skills = list(
	/datum/skill/civ_mech/pro,
	/datum/skill/construction/novice
	)

/datum/skillset/recycler
	initial_skills = list(
	/datum/skill/civ_mech/pro,
	/datum/skill/construction/novice
	)

//civilians
/datum/skillset/captain
	initial_skills = list(
	/datum/skill/command/master,
	/datum/skill/police/master,
	/datum/skill/firearms/master,
	/datum/skill/melee/trained,
	/datum/skill/engineering/novice,
	/datum/skill/construction/novice,
	/datum/skill/research/novice,
	/datum/skill/medical/novice,
	/datum/skill/civ_mech/trained,
	/datum/skill/combat_mech/trained
	)

/datum/skillset/hop
	initial_skills = list(
	/datum/skill/command/pro,
	/datum/skill/police/trained,
	/datum/skill/firearms/trained,
	/datum/skill/civ_mech/trained
	)

/datum/skillset/internal_affairs
	initial_skills = list(
	/datum/skill/police/trained,
	/datum/skill/command/trained
	)

/datum/skillset/bartender
	initial_skills = list(
	/datum/skill/firearms/trained,
	/datum/skill/police/trained,
	/datum/skill/chemistry/novice
	)

/datum/skillset/botanist
	initial_skills = list(
	/datum/skill/melee/trained,
	/datum/skill/chemistry/novice
	)

/datum/skillset/chef
	initial_skills = list(
	/datum/skill/melee/master,
	/datum/skill/surgery/novice,
	/datum/skill/medical/novice,
	/datum/skill/chemistry/novice
	)

/datum/skillset/librarian
	initial_skills = list(
	/datum/skill/research/novice,
	/datum/skill/chemistry/novice,
	/datum/skill/command/novice
	)

/datum/skillset/barber
	initial_skills = list(
	/datum/skill/medical/novice
	)

/datum/skillset/chaplain
	initial_skills = list(
	/datum/skill/command/pro,
	/datum/skill/melee/master
	)

/datum/skillset/mime
	initial_skills = list(
		/datum/skill/melee/weak
	)

/datum/skillset/clown
	initial_skills = list(
		/datum/skill/melee/weak
	)

/datum/skillset/janitor
/datum/skillset/test_subject
/datum/skillset/test_subject/lawyer
	initial_skills = list(
	/datum/skill/command/novice
	)

/datum/skillset/test_subject/mecha
	initial_skills = list(
		/datum/skill/civ_mech/master,
		/datum/skill/combat_mech/trained
	)

/datum/skillset/test_subject/detective
	initial_skills = list(
		/datum/skill/firearms/trained
	)

/datum/skillset/test_subject/reporter
	initial_skills = list(
		/datum/skill/command/novice
	)

/datum/skillset/test_subject/waiter
	initial_skills = list(
		/datum/skill/chemistry/novice,
		/datum/skill/police/trained
	)

/datum/skillset/test_subject/vice_officer
	initial_skills = list(
		/datum/skill/command/trained,
		/datum/skill/police/trained
	)

/datum/skillset/test_subject/paranormal
	initial_skills = list(
		/datum/skill/research/novice,
		/datum/skill/medical/novice
	)


//antagonists
/datum/skillset/max
	initial_skills = list(
		/datum/skill/police/master,
		/datum/skill/firearms/master,
		/datum/skill/melee/master,
		/datum/skill/engineering/master,
		/datum/skill/construction/master,
		/datum/skill/atmospherics/master,
		/datum/skill/civ_mech/master,
		/datum/skill/combat_mech/master,
		/datum/skill/surgery/master,
		/datum/skill/medical/master,
		/datum/skill/chemistry/master,
		/datum/skill/research/master,
		/datum/skill/command/master
	)

/datum/skillset/revolutionary
	initial_skills = list(
		/datum/skill/police/trained,
		/datum/skill/firearms/trained,
		/datum/skill/command/novice,
		/datum/skill/melee/trained
	)

/datum/skillset/gangster
	initial_skills = list(
		/datum/skill/firearms/master,
		/datum/skill/melee/master
	)

/datum/skillset/cultist
	initial_skills = list(
		/datum/skill/melee/master,
		/datum/skill/surgery/master,
		/datum/skill/medical/master,
		/datum/skill/chemistry/novice,
		/datum/skill/research/novice
	)

/datum/skillset/cultist/leader
	initial_skills = list(
		/datum/skill/command/pro,
		/datum/skill/police/trained,
		/datum/skill/firearms/trained,
		/datum/skill/chemistry/trained,
		/datum/skill/combat_mech/trained,
		/datum/skill/civ_mech/trained,
		/datum/skill/research/trained
	)

/datum/skillset/abductor/agent
	initial_skills = list(
		/datum/skill/melee/master,
		/datum/skill/firearms/master,
		/datum/skill/police/master,
		/datum/skill/medical/trained,
		/datum/skill/surgery/novice,
		/datum/skill/research/novice
	)

/datum/skillset/abductor/scientist
	initial_skills = list(
		/datum/skill/surgery/master,
		/datum/skill/medical/master,
		/datum/skill/research/pro,
		/datum/skill/police/trained,
		/datum/skill/firearms/trained
	)


/datum/skillset/wizard
	initial_skills = list(
		/datum/skill/melee/master,
		/datum/skill/medical/master,
		/datum/skill/surgery/master,
		/datum/skill/chemistry/master,
		/datum/skill/command/trained
	)

/datum/skillset/undercover
	initial_skills = list(
		/datum/skill/police/master,
		/datum/skill/firearms/master,
		/datum/skill/command/trained,
		/datum/skill/combat_mech/trained,
		/datum/skill/melee/trained
	)

/datum/skillset/cop
	initial_skills = list(
		/datum/skill/police/master,
		/datum/skill/firearms/master,
		/datum/skill/combat_mech/master,
		/datum/skill/command/pro,
		/datum/skill/melee/master
	)

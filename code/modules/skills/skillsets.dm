

//medical

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
		/datum/skill/medical/expert,
		/datum/skill/surgery/pro,
		/datum/skill/civ_mech/trained,
		/datum/skill/chemistry/trained
	)

/datum/skillset/doctor/surgeon
	name = "Surgeon"
	initial_skills = list(
		/datum/skill/surgery/master,
		/datum/skill/medical/pro,
		/datum/skill/chemistry/novice
	)

/datum/skillset/doctor/nurse
	name = "Nurse"
	initial_skills = list(
		/datum/skill/surgery/trained,
		/datum/skill/medical/master,
		/datum/skill/chemistry/novice
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
		/datum/skill/medical/expert,
		/datum/skill/surgery/trained,
		/datum/skill/civ_mech/master,
		/datum/skill/chemistry/novice
	)

/datum/skillset/psychiatrist
	name = "Psychiatrist"
	initial_skills = list(
		/datum/skill/medical/pro,
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
		/datum/skill/medical/pro,
		/datum/skill/surgery/trained,
		/datum/skill/chemistry/trained,
		/datum/skill/civ_mech/trained
	)

//engineering
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

//security
/datum/skillset/hos
	name = "Head of Security"
	initial_skills = list(
		/datum/skill/firearms/master,
		/datum/skill/command/pro,
		/datum/skill/police/master,
		/datum/skill/melee/master,
		/datum/skill/medical/trained,
		/datum/skill/research/novice,
		/datum/skill/combat_mech/master
	)

/datum/skillset/warden
	name = "Warden"
	initial_skills = list(
		/datum/skill/firearms/master,
		/datum/skill/command/trained,
		/datum/skill/police/master,
		/datum/skill/melee/master,
		/datum/skill/medical/novice,
		/datum/skill/combat_mech/trained
	)

/datum/skillset/officer
	name = "Security Officer"
	initial_skills = list(
		/datum/skill/firearms/master,
		/datum/skill/police/master,
		/datum/skill/melee/master,
		/datum/skill/combat_mech/trained,
		/datum/skill/command/novice
	)

/datum/skillset/cadet
	name = "Security Cadet"
	initial_skills = list(
		/datum/skill/firearms/trained,
		/datum/skill/police/master,
		/datum/skill/melee/trained
	)

/datum/skillset/forensic
	name = "Forensic Technician"
	initial_skills = list(
		/datum/skill/surgery/pro,
		/datum/skill/medical/trained,
		/datum/skill/research/novice,
		/datum/skill/chemistry/novice
	)

/datum/skillset/detective
	name = "Detective"
	initial_skills = list(
		/datum/skill/police/trained,
		/datum/skill/firearms/master,
		/datum/skill/medical/novice,
		/datum/skill/surgery/novice,
		/datum/skill/melee/trained,
	)

//science
/datum/skillset/rd
	name = "Research Director"
	initial_skills = list(
		/datum/skill/research/master,
		/datum/skill/command/pro,
		/datum/skill/atmospherics/trained,
		/datum/skill/construction/pro,
		/datum/skill/chemistry/trained,
		/datum/skill/medical/pro,
		/datum/skill/civ_mech/master,
		/datum/skill/combat_mech/master,
		/datum/skill/surgery/pro,
		/datum/skill/engineering/master
	)

/datum/skillset/scientist
	name = "Scientist"
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
	name = "Phoron Researcher"
	initial_skills = list(
		/datum/skill/research/pro,
		/datum/skill/atmospherics/trained,
		/datum/skill/construction/novice,
		/datum/skill/engineering/novice,
		/datum/skill/chemistry/trained,
		/datum/skill/medical/novice,
		/datum/skill/civ_mech/novice
	)

/datum/skillset/roboticist
	name = "Roboticist"
	initial_skills = list(
		/datum/skill/research/pro,
		/datum/skill/surgery/trained,
		/datum/skill/medical/trained,
		/datum/skill/construction/trained,
		/datum/skill/engineering/trained,
		/datum/skill/civ_mech/pro,
		/datum/skill/combat_mech/master
	)

/datum/skillset/roboticist/bio
	name = "Biomechanical Engineer"
	initial_skills = list(
		/datum/skill/research/pro,
		/datum/skill/surgery/pro,
		/datum/skill/medical/pro,
		/datum/skill/construction/trained,
		/datum/skill/engineering/trained,
		/datum/skill/civ_mech/trained,
		/datum/skill/combat_mech/trained
	)

/datum/skillset/roboticist/mecha
	name = "Mechatronic Engineer"
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
	name = "Xenoarchaeologist"
	initial_skills = list(
		/datum/skill/chemistry/trained,
		/datum/skill/research/trained,
		/datum/skill/civ_mech/trained,
		/datum/skill/medical/trained
	)

/datum/skillset/xenobiologist
	name = "Xenobiologist"
	initial_skills = list(
		/datum/skill/research/trained,
		/datum/skill/surgery/pro,
		/datum/skill/medical/trained,
		/datum/skill/chemistry/trained
	)

/datum/skillset/research_assistant
	name = "Research Assistant"
	initial_skills = list(
		/datum/skill/research/trained,
		/datum/skill/medical/novice,
		/datum/skill/surgery/novice,
		/datum/skill/construction/novice,
		/datum/skill/engineering/novice,
		/datum/skill/civ_mech/novice
	)

//cargo
/datum/skillset/quartermaster
	name = "Quartermaster"
	initial_skills = list(
		/datum/skill/civ_mech/master,
		/datum/skill/construction/novice,
		/datum/skill/command/trained
	)

/datum/skillset/miner
	name = "Shaft Miner"
	initial_skills = list(
		/datum/skill/civ_mech/master,
		/datum/skill/firearms/trained,
		/datum/skill/research/novice
	)

/datum/skillset/cargotech
	name = "Cargo Technician"
	initial_skills = list(
	/datum/skill/civ_mech/pro,
	/datum/skill/construction/novice
	)

/datum/skillset/recycler
	name = "Recycler"
	initial_skills = list(
	/datum/skill/civ_mech/pro,
	/datum/skill/construction/novice
	)

//civilians
/datum/skillset/captain
	name = "Captain"
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
	name = "Head of Personnel"
	initial_skills = list(
	/datum/skill/command/pro,
	/datum/skill/firearms/trained,
	/datum/skill/civ_mech/trained
	)

/datum/skillset/internal_affairs
	name = "Internal Affairs Agent"
	initial_skills = list(
	/datum/skill/command/trained
	)

/datum/skillset/bartender
	name = "Bartender"
	initial_skills = list(
	/datum/skill/firearms/trained,
	/datum/skill/chemistry/novice
	)

/datum/skillset/botanist
	name = "Botanist"
	initial_skills = list(
	/datum/skill/melee/trained,
	/datum/skill/chemistry/novice
	)

/datum/skillset/chef
	name = "Chef"
	initial_skills = list(
	/datum/skill/melee/master,
	/datum/skill/surgery/novice,
	/datum/skill/medical/novice,
	/datum/skill/chemistry/novice
	)

/datum/skillset/librarian
	name = "Librarian"
	initial_skills = list(
	/datum/skill/research/novice,
	/datum/skill/chemistry/novice,
	/datum/skill/command/novice
	)

/datum/skillset/barber
	name = "Barber"
	initial_skills = list(
	/datum/skill/medical/novice
	)

/datum/skillset/chaplain
	name = "Chaplain"
	initial_skills = list(
	/datum/skill/command/pro,
	/datum/skill/melee/master
	)

/datum/skillset/mime
	name = "Mime"
	initial_skills = list(
		/datum/skill/melee/weak
	)

/datum/skillset/clown
	name = "Clown"
	initial_skills = list(
		/datum/skill/melee/weak
	)

/datum/skillset/janitor
	name = "Janitor"
/datum/skillset/test_subject
	name = "Test Subject"
/datum/skillset/test_subject/lawyer
	name = "Lawyer"
	initial_skills = list(
	/datum/skill/command/novice
	)

/datum/skillset/test_subject/mecha
	name = "Mecha Operator"
	initial_skills = list(
		/datum/skill/civ_mech/master,
		/datum/skill/combat_mech/trained
	)

/datum/skillset/test_subject/detective
	name = "Private Eye"
	initial_skills = list(
		/datum/skill/firearms/trained
	)

/datum/skillset/test_subject/reporter
	name = "Reporter"
	initial_skills = list(
		/datum/skill/command/novice
	)

/datum/skillset/test_subject/waiter
	name = "Waiter"
	initial_skills = list(
		/datum/skill/chemistry/novice,
		/datum/skill/police/trained
	)

/datum/skillset/test_subject/vice_officer
	name = "Vice Officer"
	initial_skills = list(
		/datum/skill/command/trained,
		/datum/skill/police/trained
	)

/datum/skillset/test_subject/paranormal
	name = "Paranormal Investigator"
	initial_skills = list(
		/datum/skill/research/novice,
		/datum/skill/medical/novice
	)


//antagonists
/datum/skillset/max
	name = "Maximum skillset"
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
	name = REV
	initial_skills = list(
		/datum/skill/police/trained,
		/datum/skill/firearms/trained,
		/datum/skill/command/novice,
		/datum/skill/melee/trained
	)

/datum/skillset/gangster
	name = GANGSTER
	initial_skills = list(
		/datum/skill/firearms/master,
		/datum/skill/melee/master
	)

/datum/skillset/cultist
	name = CULTIST
	initial_skills = list(
		/datum/skill/melee/master,
		/datum/skill/surgery/master,
		/datum/skill/medical/master,
		/datum/skill/chemistry/novice,
		/datum/skill/research/novice
	)

/datum/skillset/cultist/leader
	name = CULT_LEADER
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
	name = ABDUCTOR_AGENT
	initial_skills = list(
		/datum/skill/melee/master,
		/datum/skill/firearms/master,
		/datum/skill/police/master,
		/datum/skill/medical/trained,
		/datum/skill/surgery/novice,
		/datum/skill/research/novice
	)

/datum/skillset/abductor/scientist
	name = ABDUCTOR_SCI
	initial_skills = list(
		/datum/skill/surgery/master,
		/datum/skill/medical/master,
		/datum/skill/research/pro,
		/datum/skill/police/trained,
		/datum/skill/firearms/trained
	)


/datum/skillset/wizard
	name = WIZARD
	initial_skills = list(
		/datum/skill/melee/master,
		/datum/skill/medical/master,
		/datum/skill/surgery/master,
		/datum/skill/chemistry/master,
		/datum/skill/command/trained
	)

/datum/skillset/undercover
	name = UNDERCOVER_COP
	initial_skills = list(
		/datum/skill/police/master,
		/datum/skill/firearms/master,
		/datum/skill/command/trained,
		/datum/skill/combat_mech/trained,
		/datum/skill/melee/trained
	)

/datum/skillset/cop
	name = SPACE_COP
	initial_skills = list(
		/datum/skill/police/master,
		/datum/skill/firearms/master,
		/datum/skill/combat_mech/master,
		/datum/skill/command/pro,
		/datum/skill/melee/master
	)

/datum/skillset/cyborg
	initial_skills = list(
		/datum/skill/police/master,
		/datum/skill/firearms/master,
		/datum/skill/engineering/master,
		/datum/skill/construction/pro,
		/datum/skill/atmospherics/master,
		/datum/skill/civ_mech/master,
		/datum/skill/combat_mech/master,
		/datum/skill/surgery/pro,
		/datum/skill/medical/expert,
		/datum/skill/chemistry/master,
		/datum/skill/research/pro,
		/datum/skill/command/novice
	)

/datum/skillset/golem
	initial_skills = list(
		/datum/skill/engineering/pro,
		/datum/skill/construction/trained,
		/datum/skill/atmospherics/master,
		/datum/skill/surgery/pro,
		/datum/skill/medical/pro,
		/datum/skill/chemistry/master,
		/datum/skill/research/trained,
		/datum/skill/melee/weak // beacause fuck golems
	)

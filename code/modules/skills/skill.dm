/datum/skill
	var/name
	var/rank_name = "Untrained"
	var/min_value = 0
	var/max_value
	var/value
	var/hint

/datum/skill/civ_mech
	name =  SKILL_CIV_MECH
	max_value = 4
	hint = "Faster moving speed of piloted civilian exosuits: Ripley and Odysseus."

/datum/skill/civ_mech/default
	value = 0

/datum/skill/civ_mech/novice
	rank_name = "Novice"
	value = 1

/datum/skill/civ_mech/trained
	rank_name = "Trained"
	value = 2 //engineer, medical intern, scientist, medical doctor

/datum/skill/civ_mech/pro
	rank_name = "Professional"
	value = 3 //cargo techincian, recycler, robotech, paramedic, mecha operator

/datum/skill/civ_mech/master
	rank_name = "Forklift certified"
	value = 4 //RD, miner, QM, CE, CMO

/datum/skill/combat_mech
	name = SKILL_COMBAT_MECH
	max_value = 2
	hint = "Faster moving speed of piloted combat exosuits."

/datum/skill/combat_mech/default
	value = 0

/datum/skill/combat_mech/trained
	rank_name = "Trained"
	value = 1 //mecha operator, security

/datum/skill/combat_mech/master
	rank_name = "Master"
	value = 2 //nuclear,  HoS, RD

/datum/skill/police
	name = SKILL_POLICE
	max_value = 2
	hint = "Usage of tasers and stun batons. Higher levels allows for faster handcuffing."

/datum/skill/police/default
	value = 0

/datum/skill/police/trained
	rank_name = "Trained"
	value = 1 //heads of staff

/datum/skill/police/master
	rank_name = "Master"
	value = 2 //security

/datum/skill/firearms
	name = SKILL_FIREARMS
	max_value = 2
	hint = "Affects recoil from firearms. Proficiency in firearms allows for tactical reloads. Usage of mines and explosives."

/datum/skill/firearms/default
	value = 0

/datum/skill/firearms/trained
	rank_name = "Trained"
	value = 1 //less recoil from firearms, usage of mines and c4

/datum/skill/firearms/master
	rank_name = "Master"
	value = 2 //security, nuclear, ERT, gangsters

/datum/skill/melee
	name = SKILL_MELEE
	min_value = -1
	max_value = 2
	hint = "Higher levels means more damage with melee weapons."

/datum/skill/melee/weak
	rank_name = "Clowny"
	value = -1

/datum/skill/melee/default
	value = 0

/datum/skill/melee/trained
	rank_name = "Trained"
	value = 1 //botanist, atmospheric techician

/datum/skill/melee/master
	rank_name = "Black belt"
	value = 2 // chaplain, security, cook

/datum/skill/atmospherics
	name = SKILL_ATMOS
	max_value = 3
	hint = "Interacting with atmos related devices: pumps, scrubbers and filters. Usage of atmospherics computers. Faster pipes unwrenching."

/datum/skill/atmospherics/default
	value = 0

/datum/skill/atmospherics/novice
	rank_name = "Novice"
	value = 1 //scientist

/datum/skill/atmospherics/trained
	rank_name = "Trained"
	value = 2 //engineer, RD

/datum/skill/atmospherics/master
	rank_name = "Master"
	value = 3 //CE, atmospheric techincian

/datum/skill/construction
	name = SKILL_CONSTRUCTION
	max_value = 4
	hint = "Construction of walls, windows, computers and crafting."

/datum/skill/construction/default
	value = 0

/datum/skill/construction/novice
	rank_name = "Novice"
	value = 1 //windows

/datum/skill/construction/trained
	rank_name = "Trained"
	value = 2 //walls, reinforced glass, RCD usage(scientist, robotech)

/datum/skill/construction/pro
	rank_name = "Professional"
	value = 3 //computer, machine frames,  RD, engineer, reinforced walls

/datum/skill/construction/master
	rank_name = "Master"
	value = 4 //CE - AI core and reinforced phoron windows

/datum/skill/chemistry
	name = SKILL_CHEMISTRY
	max_value = 3
	hint = "Chemistry related machinery: grinders, chem dispensers and chem masters. You can recognize reagents in pills and bottles."

/datum/skill/chemistry/default
	value = 0

/datum/skill/chemistry/novice
	rank_name = "Novice"
	value = 1 //intern, scientist, botanist

/datum/skill/chemistry/trained
	rank_name = "Trained"
	value = 2 //medical doctor, surgeon, RD

/datum/skill/chemistry/master
	rank_name = "Master"
	value = 3 //chemist, CMO

/datum/skill/research
	name = SKILL_RESEARCH
	max_value = 4
	hint = "Usage of complex machinery and computers. AI law modification, xenoarcheology and xenobiology consoles, exosuit fabricators."

/datum/skill/research/default
	value = 0

/datum/skill/research/novice
	rank_name = "Novice"
	value = 1

/datum/skill/research/trained
	rank_name = "Trained"
	value = 2 //RnD console, xenoarch consoles, genetics

/datum/skill/research/pro
	rank_name = "Professional"
	value = 3 // AI law modification, telescience console. Scientist, roboticisit

/datum/skill/research/master
	rank_name = "Master"
	value = 4 //AI creation, RD

/datum/skill/medical
	name = SKILL_MEDICAL
	max_value = 5
	hint = "Faster usage of syringes. Proficiency with defibrilators, medical scanners, cryo tubes, sleepers and life support machinery."

/datum/skill/medical/default
	value = 0

/datum/skill/medical/novice
	rank_name = "Novice"
	value = 1

/datum/skill/medical/trained
	rank_name = "Trained"
	value = 2

/datum/skill/medical/pro
	rank_name = "Professional"
	value = 3 //intern

/datum/skill/medical/expert
	rank_name = "Expert"
	value = 4 //doctor, paramedic

/datum/skill/medical/master
	rank_name = "Master"
	value = 5 //CMO, nurse

/datum/skill/surgery
	name = SKILL_SURGERY
	max_value = 4
	hint = "Higher level means faster surgical operations."

/datum/skill/surgery/default
	value = 0

/datum/skill/surgery/novice
	rank_name = "Novice"
	value = 1 //intern, scientist, cook

/datum/skill/surgery/trained
	rank_name = "Trained"
	value = 2 //paramedic, roboticist

/datum/skill/surgery/pro
	rank_name = "Professional"
	value = 3 //doctor, RD

/datum/skill/surgery/master
	rank_name = "Master"
	value = 4 //CMO, surgeon

/datum/skill/command
	name = SKILL_COMMAND
	max_value = 4
	hint = "Usage of identification computers, communication consoles and fax."

/datum/skill/command/default
	value = 0

/datum/skill/command/novice
	rank_name = "Novice"
	value = 1 //officers, psychatrist, lawyer - easier paperwork, quest passes

/datum/skill/command/trained
	rank_name = "Trained"
	value = 2 //internal affairs, QM -   auth devices, access modification

/datum/skill/command/pro
	rank_name = "Professional"
	value = 3 //heads, cult leaders, gang leaders, ERT

/datum/skill/command/master
	rank_name = "Master"
	value = 4  //captain, nuclear and strike team leaders

/datum/skill/engineering
	name = SKILL_ENGINEERING
	max_value = 4
	hint = "Tools usage, hacking, wall repairs and deconstruction. Engine related tasks and configuring of telecommunications."

/datum/skill/engineering/default
	value = 0

/datum/skill/engineering/novice
	rank_name = "Novice"
	value = 1 //hacking

/datum/skill/engineering/trained
	rank_name = "Trained"
	value = 2 //techincal assistant, atmospheric technician

/datum/skill/engineering/pro
	rank_name = "Professional"
	value = 3 //bubble shield generators, singularity computer ,engineer

/datum/skill/engineering/master
	rank_name = "Master"
	value = 4 //Telecomms, CE, RD


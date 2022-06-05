/datum/skill
	var/name
	var/rank_name = "Untrained"
	var/value
	var/hint

/datum/skill/civ_mech
	name =  SKILL_CIV_MECH
	hint = "Faster moving speed of piloted civilian exosuits: Ripley and Odysseus."

/datum/skill/civ_mech/none
	value = SKILL_MIN_LEVEL

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

/datum/skill/civ_mech/robust
	rank_name = "Racer"
	value = SKILL_MAX_LEVEL 

/datum/skill/combat_mech
	name = SKILL_COMBAT_MECH
	hint = "Faster moving speed of piloted combat exosuits."

/datum/skill/combat_mech/none
	value = SKILL_MIN_LEVEL

/datum/skill/combat_mech/novice
	rank_name = "Novice"
	value = 1

/datum/skill/combat_mech/trained
	rank_name = "Trained"
	value = 2 //mecha operator, security

/datum/skill/combat_mech/pro
	rank_name = "Professional"
	value = 3 // warden

/datum/skill/combat_mech/master
	rank_name = "Master"
	value = 4 // Hos, RD, nuclear

/datum/skill/combat_mech/robust
	rank_name = "Certified combat driver"
	value = SKILL_MAX_LEVEL

/datum/skill/police
	name = SKILL_POLICE
	hint = "Usage of tasers and stun batons. Higher levels allows for faster handcuffing."

/datum/skill/police/none
	value = SKILL_MIN_LEVEL

/datum/skill/police/novice
	rank_name = "Novice"
	value = 1

/datum/skill/police/trained
	rank_name = "Trained"
	value = 2 // heads

/datum/skill/police/pro
	rank_name = "Professional"
	value = 3 // security

/datum/skill/police/master
	rank_name = "Master"
	value = 4 // Hos, warden

/datum/skill/police/robust
	rank_name = "First Lieutenant"
	value = SKILL_MAX_LEVEL

/datum/skill/firearms
	name = SKILL_FIREARMS
	hint = "Affects recoil from firearms. Proficiency in firearms allows for tactical reloads. Usage of mines and explosives."

/datum/skill/firearms/none
	value = SKILL_MIN_LEVEL

/datum/skill/firearms/novice
	rank_name = "Novice"
	value = 1

/datum/skill/firearms/trained
	rank_name = "Trained"
	value = 2 // less recoil from firearms, usage of mines and c4

/datum/skill/firearms/pro
	rank_name = "Professional"
	value = 3 

/datum/skill/firearms/master
	rank_name = "Firearms master"
	value = 4 //security, nuclear, ERT, gangsters

/datum/skill/firearms/robust
	rank_name = "Godlike sniper"
	value = SKILL_MAX_LEVEL 

/datum/skill/melee
	name = SKILL_MELEE
	hint = "Higher levels means more damage with melee weapons."

/datum/skill/melee/none
	value = SKILL_MIN_LEVEL // clown, mime, golem

/datum/skill/melee/novice
	rank_name = "Novice"
	value = 1 

/datum/skill/melee/trained
	rank_name = "Trained"
	value = 2 // botanist

/datum/skill/melee/pro
	rank_name = "Professional"
	value = 3 //cook, atmospheric technician, sec officer

/datum/skill/melee/master
	rank_name = "Black belt"
	value = 4 // Hos, warden 

/datum/skill/melee/robust
	rank_name = "CQC god"
	value = SKILL_MAX_LEVEL

/datum/skill/atmospherics
	name = SKILL_ATMOS
	hint = "Interacting with atmos related devices: pumps, scrubbers and filters. Usage of atmospherics computers. Faster pipes unwrenching."

/datum/skill/atmospherics/none
	value = SKILL_MIN_LEVEL

/datum/skill/atmospherics/novice
	rank_name = "Novice"
	value = 1 // science assistant

/datum/skill/atmospherics/trained
	rank_name = "Trained"
	value = 2 //scientist, technical assistant

/datum/skill/atmospherics/pro
	rank_name = "Professional"
	value = 3  //engineer, RD, phoron researcher

/datum/skill/atmospherics/master
	rank_name = "Master"
	value = 4  //CE, atmospheric techincian

/datum/skill/atmospherics/robust
	rank_name = "God of pipes"
	value = SKILL_MAX_LEVEL

/datum/skill/construction
	name = SKILL_CONSTRUCTION
	hint = "Construction of walls, windows, computers and crafting."

/datum/skill/construction/none
	value = SKILL_MIN_LEVEL

/datum/skill/construction/novice
	rank_name = "Novice"
	value = 1 //windows

/datum/skill/construction/trained
	rank_name = "Trained"
	value = 2 // walls, reinforced glass, RCD usage(scientist, robotech)

/datum/skill/construction/pro
	rank_name = "Professional"
	value = 3 // computer, machine frames,  RD, engineer, reinforced walls

/datum/skill/construction/master
	rank_name = "Master"
	value = 4 // CE - AI core and reinforced phoron windows

/datum/skill/construction/robust
	rank_name = "Robust"
	value = SKILL_MAX_LEVEL 

/datum/skill/chemistry
	name = SKILL_CHEMISTRY
	hint = "Chemistry related machinery: grinders, chem dispensers and chem robusts. You can recognize reagents in pills and bottles."

/datum/skill/chemistry/none
	value = SKILL_MIN_LEVEL

/datum/skill/chemistry/novice
	rank_name = "Novice"
	value = 1 // botanist, bartender, cook

/datum/skill/chemistry/trained
	rank_name = "Trained"
	value = 2 // intern, xenoarcheologist 

/datum/skill/chemistry/pro
	rank_name = "Professional"
	value = 3 // medical doctor, nurse, surgeon

/datum/skill/chemistry/master
	rank_name = "Master"
	value = 4   //chemist, CMO

/datum/skill/chemistry/robust
	rank_name = "Robust"
	value = SKILL_MAX_LEVEL 

/datum/skill/research
	name = SKILL_RESEARCH
	hint = "Usage of complex machinery and computers. AI law modification, xenoarcheology and xenobiology consoles, exosuit fabricators."

/datum/skill/research/none
	value = SKILL_MIN_LEVEL

/datum/skill/research/novice
	rank_name = "High school diploma"
	value = 1

/datum/skill/research/trained
	rank_name = "Associate's degree"
	value = 2 //RnD console, xenoarch consoles, genetics

/datum/skill/research/pro
	rank_name = "Bachelor's degree"
	value = 3 // AI law modification, telescience console. Scientist, roboticisit

/datum/skill/research/master
	rank_name = "Master's degree"
	value = 4 // AI creation, RD

/datum/skill/research/robust
	rank_name = "Ph.D."
	value = SKILL_MAX_LEVEL 

/datum/skill/medical
	name = SKILL_MEDICAL
	hint = "Faster usage of syringes. Proficiency with defibrilators, medical scanners, cryo tubes, sleepers and life support machinery."

/datum/skill/medical/none
	value = SKILL_MIN_LEVEL

/datum/skill/medical/novice
	rank_name = "Novice"
	value = 1 // cook

/datum/skill/medical/trained
	rank_name = "Trained"
	value = 2 // intern

/datum/skill/medical/pro
	rank_name = "Professional"
	value = 3 // doctor, paramedic

/datum/skill/medical/master
	rank_name = "Master"
	value = 4  // CMO, nurse

/datum/skill/medical/robust
	rank_name = "Robust"
	value = SKILL_MAX_LEVEL 

/datum/skill/surgery
	name = SKILL_SURGERY
	hint = "Higher level means faster surgical operations."

/datum/skill/surgery/none
	value = SKILL_MIN_LEVEL

/datum/skill/surgery/novice
	rank_name = "Novice"
	value = 1 // intern, scientist, cook

/datum/skill/surgery/trained
	rank_name = "Trained"
	value = 2 //paramedic, roboticist

/datum/skill/surgery/pro
	rank_name = "Professional"
	value = 3 //doctor, RD

/datum/skill/surgery/master
	rank_name = "Master"
	value = 4 //CMO, surgeon

/datum/skill/surgery/robust
	rank_name = "Robust"
	value = SKILL_MAX_LEVEL 

/datum/skill/command
	name = SKILL_COMMAND
	hint = "Usage of identification computers, communication consoles and fax."

/datum/skill/command/none
	value = SKILL_MIN_LEVEL

/datum/skill/command/novice
	rank_name = "Novice"
	value = 1 // officers, psychatrist, lawyer - easier paperwork

/datum/skill/command/trained
	rank_name = "Trained"
	value = 2 // internal affairs, QM - auth devices, access modification

/datum/skill/command/pro
	rank_name = "Professional"
	value = 3 //heads, cult leaders, gang leaders, ERT

/datum/skill/command/master
	rank_name = "Master"
	value = 4 // HoP, nuclear and strike team leaders

/datum/skill/command/robust
	rank_name = "True leader"
	value = SKILL_MAX_LEVEL  // captain

/datum/skill/engineering
	name = SKILL_ENGINEERING
	hint = "Tools usage, hacking, wall repairs and deconstruction. Engine related tasks and configuring of telecommunications."

/datum/skill/engineering/none
	value = SKILL_MIN_LEVEL

/datum/skill/engineering/novice
	rank_name = "Novice"
	value = 1 //hacking

/datum/skill/engineering/trained
	rank_name = "Trained"
	value = 2 // techincal assistant, atmospheric technician

/datum/skill/engineering/pro
	rank_name = "Professional"
	value = 3 // bubble shield generators, singularity computer ,engineer

/datum/skill/engineering/master
	rank_name = "Master"
	value = 4 // Telecomms, CE, RD

/datum/skill/engineering/robust
	rank_name = "God of engineering"
	value = SKILL_MAX_LEVEL 


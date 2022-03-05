

// /datum/skills_modifier/default
// 	var/skills = list(
// 		/datum/skill/melee/weak
// 	)


// //medical


// /datum/skills_modifier/cmo
// 	var/skills = list(
// 		/datum/skill/chemistry/trained,
// 		/datum/skill/chemistry/trained
// 		/datum/skill/research/trained
// 		/datum/skill/police/trained
// 	)


// /datum/skills_modifier/doctor
// 	medical = SKILL_MEDICAL_EXPERT
// 	surgery = SKILL_SURGERY_PROFESSIONAL
// 	civ_mech = SKILL_CIV_MECH_TRAINED
// 	chemistry = SKILL_CHEMISTRY_COMPETENT

// /datum/skills_modifier/doctor/surgeon
// 	surgery = SKILL_SURGERY_EXPERT
// 	medical = SKILL_MEDICAL_EXPERT

// /datum/skills_modifier/doctor/nurse
// 	surgery = SKILL_SURGERY_PROFESSIONAL
// 	medical = SKILL_MEDICAL_MASTER
// 	chemistry = SKILL_CHEMISTRY_PRACTICED

// /datum/skills_modifier/virologist
// 	chemistry = SKILL_CHEMISTRY_COMPETENT
// 	research = SKILL_RESEARCH_TRAINED
// 	medical = SKILL_MEDICAL_COMPETENT
// 	surgery = SKILL_SURGERY_AMATEUR
// 	civ_mech = SKILL_CIV_MECH_NOVICE

// /datum/skills_modifier/chemist
// 	chemistry = SKILL_CHEMISTRY_EXPERT
// 	medical = SKILL_MEDICAL_COMPETENT
// 	surgery = SKILL_SURGERY_AMATEUR
// 	civ_mech = SKILL_CIV_MECH_NOVICE

// /datum/skills_modifier/paramedic
// 	medical = SKILL_MEDICAL_EXPERT
// 	surgery = SKILL_SURGERY_TRAINED
// 	civ_mech = SKILL_CIV_MECH_PRO
// 	chemistry = SKILL_CHEMISTRY_PRACTICED

// /datum/skills_modifier/psychiatrist
// 	medical = SKILL_MEDICAL_COMPETENT
// 	command = SKILL_COMMAND_BEGINNER
// 	chemistry = SKILL_CHEMISTRY_COMPETENT
// 	surgery = SKILL_SURGERY_AMATEUR

// /datum/skills_modifier/geneticist
// 	research = SKILL_RESEARCH_PROFESSIONAL
// 	medical = SKILL_MEDICAL_COMPETENT
// 	surgery = SKILL_SURGERY_AMATEUR
// 	chemistry = SKILL_CHEMISTRY_PRACTICED
// 	civ_mech = SKILL_CIV_MECH_NOVICE
// 	atmospherics = SKILL_ATMOS_TRAINED

// /datum/skills_modifier/intern
// 	medical = SKILL_MEDICAL_COMPETENT
// 	surgery = SKILL_SURGERY_AMATEUR
// 	chemistry = SKILL_CHEMISTRY_PRACTICED
// 	civ_mech = SKILL_CIV_MECH_TRAINED

// //engineering
// /datum/skills_modifier/ce
// 	construction = SKILL_CONSTRUCTION_MASTER
// 	command = SKILL_COMMAND_EXPERT
// 	engineering =  SKILL_ENGINEERING_MASTER
// 	atmospherics = SKILL_ATMOS_MASTER
// 	civ_mech = SKILL_CIV_MECH_MASTER
// 	police = SKILL_POLICE_TRAINED

// /datum/skills_modifier/engineer
// 	construction = SKILL_CONSTRUCTION_ADVANCED
// 	engineering =  SKILL_ENGINEERING_PRO
// 	atmospherics = SKILL_ATMOS_PRO
// 	civ_mech = SKILL_CIV_MECH_TRAINED

// /datum/skills_modifier/atmostech
// 	atmospherics = SKILL_ATMOS_MASTER
// 	construction = SKILL_CONSTRUCTION_ADVANCED
// 	engineering =  SKILL_ENGINEERING_TRAINED
// 	melee = SKILL_MELEE_TRAINED
// 	civ_mech = SKILL_CIV_MECH_TRAINED

// /datum/skills_modifier/technicassistant
// 	construction = SKILL_CONSTRUCTION_TRAINED
// 	engineering =  SKILL_ENGINEERING_TRAINED
// 	atmospherics = SKILL_ATMOS_TRAINED
// 	civ_mech = SKILL_CIV_MECH_NOVICE

// //security
// /datum/skills_modifier/hos
// 	firearms = SKILL_FIREARMS_PRO
// 	command = SKILL_COMMAND_EXPERT
// 	police = SKILL_POLICE_PRO
// 	melee = SKILL_MELEE_MASTER
// 	medical = SKILL_MEDICAL_PRACTICED
// 	combat_mech = SKILL_COMBAT_MECH_PRO

// /datum/skills_modifier/warden
// 	firearms = SKILL_FIREARMS_PRO
// 	command = SKILL_COMMAND_TRAINED
// 	police = SKILL_POLICE_PRO
// 	melee = SKILL_MELEE_MASTER
// 	medical = SKILL_MEDICAL_NOVICE
// 	combat_mech = SKILL_COMBAT_MECH_NOVICE

// /datum/skills_modifier/officer
// 	firearms = SKILL_FIREARMS_PRO
// 	police = SKILL_POLICE_PRO
// 	melee = SKILL_MELEE_MASTER
// 	combat_mech = SKILL_COMBAT_MECH_NOVICE
// 	command = SKILL_COMMAND_BEGINNER

// /datum/skills_modifier/cadet
// 	firearms = SKILL_FIREARMS_TRAINED
// 	police = SKILL_POLICE_TRAINED
// 	melee = SKILL_MELEE_TRAINED

// /datum/skills_modifier/forensic
// 	police = SKILL_POLICE_TRAINED
// 	surgery = SKILL_SURGERY_TRAINED
// 	medical = SKILL_MEDICAL_COMPETENT
// 	research = SKILL_RESEARCH_TRAINED
// 	firearms = SKILL_FIREARMS_TRAINED

// /datum/skills_modifier/detective
// 	police = SKILL_POLICE_TRAINED
// 	firearms = SKILL_FIREARMS_PRO
// 	medical = SKILL_MEDICAL_NOVICE
// 	melee = SKILL_MELEE_TRAINED

// //science
// /datum/skills_modifier/rd
// 	research = SKILL_RESEARCH_EXPERT
// 	command = SKILL_COMMAND_EXPERT
// 	atmospherics = SKILL_ATMOS_TRAINED
// 	construction =  SKILL_CONSTRUCTION_ADVANCED
// 	chemistry =  SKILL_CHEMISTRY_COMPETENT
// 	medical = SKILL_MEDICAL_COMPETENT
// 	civ_mech = SKILL_CIV_MECH_MASTER
// 	combat_mech = SKILL_COMBAT_MECH_PRO
// 	police = SKILL_POLICE_TRAINED
// 	surgery = SKILL_SURGERY_PROFESSIONAL
// 	engineering = SKILL_ENGINEERING_MASTER

// /datum/skills_modifier/scientist
// 	research = SKILL_RESEARCH_EXPERT
// 	atmospherics = SKILL_ATMOS_TRAINED
// 	construction =  SKILL_CONSTRUCTION_TRAINED
// 	engineering = SKILL_ENGINEERING_NOVICE
// 	chemistry =  SKILL_CHEMISTRY_PRACTICED
// 	medical = SKILL_MEDICAL_NOVICE
// 	surgery = SKILL_SURGERY_AMATEUR
// 	civ_mech = SKILL_CIV_MECH_NOVICE
// /datum/skills_modifier/scientist/phoron
// 	atmospherics = SKILL_ATMOS_PRO
// 	research = SKILL_RESEARCH_PROFESSIONAL
// 	chemistry = SKILL_CHEMISTRY_COMPETENT

// /datum/skills_modifier/roboticist
// 	research = SKILL_RESEARCH_EXPERT
// 	surgery = SKILL_SURGERY_TRAINED
// 	medical = SKILL_MEDICAL_PRACTICED
// 	construction = SKILL_CONSTRUCTION_TRAINED
// 	engineering = SKILL_ENGINEERING_NOVICE
// 	civ_mech = SKILL_CIV_MECH_PRO
// 	combat_mech = SKILL_COMBAT_MECH_NOVICE

// /datum/skills_modifier/roboticist/bio
// 	surgery = SKILL_SURGERY_PROFESSIONAL
// 	civ_mech = SKILL_CIV_MECH_TRAINED

// /datum/skills_modifier/roboticist/mecha
// 	construction = SKILL_CONSTRUCTION_ADVANCED
// 	combat_mech = SKILL_COMBAT_MECH_PRO
// 	civ_mech = SKILL_CIV_MECH_MASTER
// 	surgery = SKILL_SURGERY_AMATEUR

// /datum/skills_modifier/xenoarchaeologist
// 	chemistry = SKILL_CHEMISTRY_COMPETENT
// 	research = SKILL_RESEARCH_PROFESSIONAL
// 	civ_mech = SKILL_CIV_MECH_TRAINED

// /datum/skills_modifier/xenobiologist
// 	research = SKILL_RESEARCH_PROFESSIONAL
// 	surgery = SKILL_SURGERY_AMATEUR
// 	medical = SKILL_MEDICAL_PRACTICED
// 	chemistry = SKILL_CHEMISTRY_PRACTICED

// /datum/skills_modifier/research_assistant
// 	research = SKILL_RESEARCH_TRAINED
// 	medical = SKILL_MEDICAL_NOVICE
// 	surgery = SKILL_SURGERY_AMATEUR
// 	construction = SKILL_CONSTRUCTION_NOVICE
// 	engineering =  SKILL_ENGINEERING_NOVICE
// 	civ_mech = SKILL_CIV_MECH_NOVICE

// //cargo
// /datum/skills_modifier/quartermaster
// 	civ_mech = SKILL_CIV_MECH_MASTER
// 	police = SKILL_POLICE_TRAINED
// 	construction = SKILL_CONSTRUCTION_NOVICE
// 	command = SKILL_COMMAND_TRAINED

// /datum/skills_modifier/miner
// 	civ_mech = SKILL_CIV_MECH_MASTER
// 	firearms  = SKILL_FIREARMS_TRAINED

// /datum/skills_modifier/cargotech
// 	civ_mech = SKILL_CIV_MECH_PRO
// 	construction = SKILL_CONSTRUCTION_NOVICE
// /datum/skills_modifier/recycler
// 	civ_mech = SKILL_CIV_MECH_PRO
// 	construction = SKILL_CONSTRUCTION_NOVICE

// //civilians
// /datum/skills_modifier/captain
// 	command = SKILL_COMMAND_MASTER
// 	police = SKILL_POLICE_PRO
// 	firearms = SKILL_FIREARMS_PRO
// 	melee = SKILL_MELEE_TRAINED
// 	engineering =  SKILL_ENGINEERING_NOVICE
// 	construction = SKILL_CONSTRUCTION_NOVICE
// 	research = SKILL_RESEARCH_TRAINED
// 	medical = SKILL_MEDICAL_NOVICE
// 	civ_mech = SKILL_CIV_MECH_TRAINED
// 	combat_mech = SKILL_COMBAT_MECH_NOVICE

// /datum/skills_modifier/hop
// 	command = SKILL_COMMAND_EXPERT
// 	police = SKILL_POLICE_TRAINED
// 	firearms = SKILL_FIREARMS_TRAINED
// 	civ_mech = SKILL_CIV_MECH_TRAINED

// /datum/skills_modifier/internal_affairs
// 	police = SKILL_POLICE_TRAINED
// 	command = SKILL_COMMAND_TRAINED

// /datum/skills_modifier/bartender
// 	firearms = SKILL_FIREARMS_TRAINED
// 	police = SKILL_POLICE_TRAINED
// 	chemistry = SKILL_CHEMISTRY_PRACTICED

// /datum/skills_modifier/botanist
// 	melee = SKILL_MELEE_TRAINED
// 	chemistry = SKILL_CHEMISTRY_PRACTICED

// /datum/skills_modifier/chef
// 	melee = SKILL_MELEE_MASTER
// 	surgery = SKILL_SURGERY_AMATEUR
// 	medical = SKILL_MEDICAL_NOVICE
// 	chemistry = SKILL_CHEMISTRY_PRACTICED

// /datum/skills_modifier/librarian
// 	research = SKILL_RESEARCH_TRAINED
// 	chemistry = SKILL_CHEMISTRY_PRACTICED
// 	command = SKILL_COMMAND_BEGINNER

// /datum/skills_modifier/barber
// 	medical = SKILL_MEDICAL_NOVICE

// /datum/skills_modifier/chaplain
// 	command = SKILL_COMMAND_EXPERT
// 	melee = SKILL_MELEE_MASTER

// /datum/skills_modifier/janitor
// /datum/skills_modifier/test_subject
// /datum/skills_modifier/test_subject/lawyer
// 	command = SKILL_COMMAND_BEGINNER

// /datum/skills_modifier/test_subject/mecha
// 	civ_mech = SKILL_CIV_MECH_MASTER
// 	combat_mech = SKILL_COMBAT_MECH_NOVICE

// /datum/skills_modifier/test_subject/detective
// 	firearms = SKILL_FIREARMS_TRAINED

// /datum/skills_modifier/test_subject/reporter
// 	command = SKILL_COMMAND_BEGINNER

// /datum/skills_modifier/test_subject/waiter
// 	chemistry = SKILL_CHEMISTRY_PRACTICED
// 	police = SKILL_POLICE_TRAINED

// /datum/skills_modifier/test_subject/vice_officer
// 	command = SKILL_COMMAND_TRAINED
// 	police = SKILL_POLICE_TRAINED

// /datum/skills_modifier/test_subject/paranormal
// 	research = SKILL_RESEARCH_TRAINED
// 	medical = SKILL_MEDICAL_NOVICE


// //antagonists
// /datum/skills_modifier/max
// 	police = SKILL_POLICE_PRO
// 	firearms = SKILL_FIREARMS_PRO
// 	melee = SKILL_MELEE_MASTER
// 	engineering = SKILL_ENGINEERING_MASTER
// 	construction = SKILL_CONSTRUCTION_MASTER
// 	atmospherics = SKILL_ATMOS_MASTER
// 	civ_mech = SKILL_CIV_MECH_MASTER
// 	combat_mech = SKILL_CIV_MECH_PRO
// 	surgery = SKILL_SURGERY_EXPERT
// 	medical = SKILL_MEDICAL_MASTER
// 	chemistry = SKILL_CHEMISTRY_EXPERT
// 	research = SKILL_RESEARCH_EXPERT
// 	command = SKILL_COMMAND_MASTER

// /datum/skills_modifier/revolutionary
// 	police = SKILL_POLICE_TRAINED
// 	firearms = SKILL_FIREARMS_TRAINED
// 	command = SKILL_COMMAND_BEGINNER
// 	melee = SKILL_MELEE_TRAINED

// /datum/skills_modifier/gangster
// 	firearms = SKILL_FIREARMS_PRO
// 	melee = SKILL_MELEE_MASTER

// /datum/skills_modifier/cultist
// 	melee = SKILL_MELEE_MASTER
// 	surgery = SKILL_SURGERY_EXPERT
// 	medical = SKILL_MEDICAL_MASTER
// 	chemistry = SKILL_CHEMISTRY_PRACTICED
// 	research = SKILL_RESEARCH_TRAINED

// /datum/skills_modifier/cultist/leader
// 	command = SKILL_COMMAND_EXPERT
// 	police = SKILL_POLICE_TRAINED
// 	firearms = SKILL_FIREARMS_TRAINED
// 	chemistry = SKILL_CHEMISTRY_COMPETENT
// 	combat_mech = SKILL_COMBAT_MECH_NOVICE
// 	civ_mech = SKILL_CIV_MECH_TRAINED
// 	research = SKILL_RESEARCH_PROFESSIONAL

// /datum/skills_modifier/abductor
// 	medical = SKILL_MEDICAL_PRACTICED
// 	surgery = SKILL_SURGERY_AMATEUR
// 	firearms = SKILL_FIREARMS_TRAINED
// 	police = SKILL_POLICE_TRAINED
// 	research = SKILL_RESEARCH_TRAINED

// /datum/skills_modifier/abductor/agent
// 	melee = SKILL_MELEE_MASTER
// 	firearms = SKILL_FIREARMS_PRO
// 	police = SKILL_POLICE_PRO

// /datum/skills_modifier/abductor/scientist
// 	surgery = SKILL_SURGERY_EXPERT
// 	medical = SKILL_MEDICAL_MASTER
// 	research = SKILL_RESEARCH_EXPERT


// /datum/skills_modifier/wizard
// 	melee = SKILL_MELEE_MASTER
// 	medical = SKILL_MEDICAL_MASTER
// 	surgery = SKILL_SURGERY_EXPERT
// 	chemistry = SKILL_CHEMISTRY_EXPERT
// 	command = SKILL_COMMAND_TRAINED

// /datum/skills_modifier/undercover
// 	police = SKILL_POLICE_PRO
// 	firearms = SKILL_FIREARMS_PRO
// 	command = SKILL_COMMAND_TRAINED
// 	combat_mech = SKILL_COMBAT_MECH_NOVICE
// 	melee = SKILL_MELEE_TRAINED

// /datum/skills_modifier/cop
// 	police = SKILL_POLICE_PRO
// 	firearms = SKILL_FIREARMS_PRO
// 	combat_mech = SKILL_COMBAT_MECH_PRO
// 	command = SKILL_COMMAND_EXPERT
// 	melee = SKILL_MELEE_MASTER

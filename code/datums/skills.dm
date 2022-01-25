
#define SKILLSID "skills-[police]\
-[firearms]-[melee]-[engineering]-[construction]-[atmospherics]-[civ_mech]\
-[combat_mech]-[surgery]-[medical]-[chemistry]-[research]-[command]"

#define SKILLSIDSRC(S) "skills-[S.police]\
-[S.firearms]-[S.melee]-[S.engineering]-[S.construction]-[S.atmospherics]-[S.civ_mech]\
-[S.combat_mech]-[S.surgery]-[S.medical]-[S.chemistry]-[S.research]-[S.command]"


/proc/getSkills(police = 0, firearms = 0,\
melee = 0, engineering = 0, construction = 0, atmospherics = 0, civ_mech = 0, combat_mech = 0, surgery = 0,\
medical = 0, chemistry = 0, research = 0, command = 0)
	. = locate(SKILLSID)
	if(!.)
		. = new /datum/skills(police = 0, firearms = 0,\
			melee = 0, engineering = 0, construction = 0, atmospherics = 0, civ_mech = 0, combat_mech = 0, surgery = 0,\
			medical = 0, chemistry = 0, research = 0, command = 0)



/proc/getSkillsType(skills_type = /datum/skills)
	var/datum/skills/new_skill = skills_type
	var/police = initial(new_skill.police)
	var/firearms = initial(new_skill.firearms)
	var/melee = initial(new_skill.melee)
	var/engineering = initial(new_skill.engineering)
	var/construction = initial(new_skill.construction)
	var/atmospherics = initial(new_skill.atmospherics)
	var/civ_mech = initial(new_skill.civ_mech)
	var/combat_mech = initial(new_skill.combat_mech)
	var/surgery = initial(new_skill.surgery)
	var/medical = initial(new_skill.medical)
	var/chemistry = initial(new_skill.chemistry)
	var/research = initial(new_skill.research)
	var/command = initial(new_skill.command)
	. = locate(SKILLSID)
	if(!.)
		. = new skills_type


/datum/skills
	var/police = SKILL_POLICE_UNTRAINED
	var/firearms = SKILL_FIREARMS_UNTRAINED
	var/melee = SKILL_MELEE_DEFAULT
	var/engineering = SKILL_ENGINEERING_DEFAULT
	var/construction = SKILL_CONSTRUCTION_DEFAULT
	var/atmospherics = SKILL_ATMOS_DEFAULT
	var/civ_mech = SKILL_CIV_MECH_DEFAULT
	var/combat_mech = SKILL_COMBAT_MECH_UNTRAINED
	var/surgery = SKILL_SURGERY_DEFAULT
	var/medical = SKILL_MEDICAL_UNTRAINED
	var/chemistry = SKILL_CHEMISTRY_UNTRAINED
	var/research = SKILL_RESEARCH_DEFAULT
	var/command = SKILL_COMMAND_DEFAULT

/datum/skills/New(police, firearms,\
melee, engineering, construction, atmospherics, civ_mech, combat_mech, surgery,\
medical, chemistry, research, command)
	if(!isnull(police))
		src.police = police
	if(!isnull(firearms))
		src.firearms = firearms
	if(!isnull(melee))
		src.melee = melee
	if(!isnull(engineering))
		src.engineering = engineering
	if(!isnull(construction))
		src.construction = construction
	if(!isnull(atmospherics))
		src.atmospherics = atmospherics
	if(!isnull(civ_mech))
		src.civ_mech = civ_mech
	if(!isnull(combat_mech))
		src.combat_mech = combat_mech
	if(!isnull(surgery))
		src.surgery = surgery
	if(!isnull(medical))
		src.medical = medical
	if(!isnull(chemistry))
		src.chemistry = chemistry
	if(!isnull(research))
		src.research = research
	if(!isnull(command))
		src.research = command
	tag = SKILLSIDSRC(src)



#undef SKILLSID


/datum/skills/proc/getRating(skill)
	return vars[rating]

/datum/skills/proc/getList()
	return list("Command" = command,\
		"Police" = police,\
		"Firearms" = firearms,\
		"Melee" = melee,\
		"Engineering" = engineering,\
		"Construction" = construction,\
		"Atmospherics" = atmospherics,\
		"Civilian Exosuits" = civ_mech,\
		"Combat Exosuits" = combat_mech,\
		"Surgery" = surgery,\
		"Medical" = medical,\
		"Chemistry" = chemistry,\
		"Research" = research,\
		"Medical" = medical)



//science
/datum/skills/rd
	research = SKILL_RESEARCH_EXPERT
	command = SKILL_COMMAND_EXPERT
	atmospherics = SKILL_ATMOS_TRAINED
	construction =  SKILL_CONSTRUCTION_ADVANCED
	chemistry =  SKILL_CHEMISTRY_COMPETENT
	medical = SKILL_MEDICAL_COMPETENT
	civ_mech = SKILL_CIV_MECH_MASTER
	combat_mech = SKILL_COMBAT_MECH_PRO
	police = SKILL_POLICE_TRAINED
	surgery = SKILL_SURGERY_PROFESSIONAL
	engineering = SKILL_ENGINEERING_MASTER

/datum/skills/scientist
	research = SKILL_RESEARCH_EXPERT
	atmospherics = SKILL_ATMOS_TRAINED
	construction =  SKILL_CONSTRUCTION_TRAINED
	engineering = SKILL_ENGINEERING_NOVICE
	chemistry =  SKILL_CHEMISTRY_PRACTICED
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR
	civ_mech = SKILL_CIV_MECH_NOVICE
/datum/skills/scientist/phoron
	atmospherics = SKILL_ATMOS_PRO
	research = SKILL_RESEARCH_PROFESSIONAL
	chemistry = SKILL_CHEMISTRY_COMPETENT


/datum/skills/roboticist
	research = SKILL_RESEARCH_EXPERT
	surgery = SKILL_SURGERY_TRAINED
	medical = SKILL_MEDICAL_PRACTICED
	construction = SKILL_CONSTRUCTION_TRAINED
	engineering = SKILL_ENGINEERING_NOVICE
	civ_mech = SKILL_CIV_MECH_PRO
	combat_mech = SKILL_COMBAT_MECH_NOVICE
/datum/skills/roboticist/bio
	surgery = SKILL_SURGERY_PROFESSIONAL
	civ_mech = SKILL_CIV_MECH_TRAINED

/datum/skills/roboticist/mecha
	construction = SKILL_CONSTRUCTION_ADVANCED
	combat_mech = SKILL_COMBAT_MECH_PRO
	civ_mech = SKILL_CIV_MECH_MASTER
	surgery = SKILL_SURGERY_AMATEUR

/datum/skills/xenoarchaeologist
	chemistry = SKILL_CHEMISTRY_COMPETENT
	research = SKILL_RESEARCH_PROFESSIONAL
	civ_mech = SKILL_CIV_MECH_TRAINED

/datum/skills/xenobiologist
	research = SKILL_RESEARCH_PROFESSIONAL
	surgery = SKILL_SURGERY_AMATEUR
	medical = SKILL_MEDICAL_PRACTICED
/datum/skills/research_assistant
	research = SKILL_RESEARCH_TRAINED
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR
	construction = SKILL_CONSTRUCTION_NOVICE
	engineering =  SKILL_ENGINEERING_NOVICE
	civ_mech = SKILL_CIV_MECH_NOVICE

//medical
/datum/skills/cmo
	chemistry = SKILL_CHEMISTRY_EXPERT
	command = SKILL_COMMAND_EXPERT
	medical = SKILL_MEDICAL_MASTER
	surgery = SKILL_SURGERY_EXPERT
	police = SKILL_POLICE_TRAINED
	research = SKILL_RESEARCH_TRAINED
	civ_mech = SKILL_CIV_MECH_MASTER

/datum/skills/doctor
	medical = SKILL_MEDICAL_EXPERT
	surgery = SKILL_SURGERY_PROFESSIONAL
	civ_mech = SKILL_CIV_MECH_TRAINED
	chemistry = SKILL_CHEMISTRY_COMPETENT

/datum/skills/doctor/surgeon
	surgery = SKILL_SURGERY_EXPERT
	medical = SKILL_MEDICAL_EXPERT
/datum/skills/doctor/nurse
	surgery = SKILL_SURGERY_PROFESSIONAL
	medical = SKILL_MEDICAL_MASTER
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills/virologist
	chemistry = SKILL_CHEMISTRY_COMPETENT
	research = SKILL_RESEARCH_TRAINED
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_AMATEUR
	civ_mech = SKILL_CIV_MECH_NOVICE

/datum/skills/chemist
	chemistry = SKILL_CHEMISTRY_EXPERT
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_AMATEUR
	civ_mech = SKILL_CIV_MECH_NOVICE

/datum/skills/paramedic
	medical = SKILL_MEDICAL_EXPERT
	surgery = SKILL_SURGERY_TRAINED
	civ_mech = SKILL_CIV_MECH_PRO
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills/psychiatrist
	medical = SKILL_MEDICAL_COMPETENT
	command = SKILL_COMMAND_BEGINNER
	chemistry = SKILL_CHEMISTRY_COMPETENT
	surgery = SKILL_SURGERY_AMATEUR

/datum/skills/geneticist
	research = SKILL_RESEARCH_PROFESSIONAL
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_AMATEUR
	chemistry = SKILL_CHEMISTRY_PRACTICED
	civ_mech = SKILL_CIV_MECH_NOVICE
	atmospherics = SKILL_ATMOS_TRAINED

/datum/skills/intern
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_AMATEUR
	chemistry = SKILL_CHEMISTRY_PRACTICED
	civ_mech = SKILL_CIV_MECH_TRAINED

//engineering
/datum/skills/ce
	construction = SKILL_CONSTRUCTION_MASTER
	command = SKILL_COMMAND_EXPERT
	engineering =  SKILL_ENGINEERING_MASTER
	atmospherics = SKILL_ATMOS_MASTER
	civ_mech = SKILL_CIV_MECH_MASTER
	police = SKILL_POLICE_TRAINED

/datum/skills/engineer
	construction = SKILL_CONSTRUCTION_ADVANCED
	engineering =  SKILL_ENGINEERING_PRO
	atmospherics = SKILL_ATMOS_PRO
	civ_mech = SKILL_CIV_MECH_TRAINED

/datum/skills/atmostech
	atmospherics = SKILL_ATMOS_MASTER
	construction = SKILL_CONSTRUCTION_ADVANCED
	engineering =  SKILL_ENGINEERING_TRAINED
	melee = SKILL_MELEE_TRAINED
	civ_mech = SKILL_CIV_MECH_TRAINED
/datum/skills/technicassistant
	construction = SKILL_CONSTRUCTION_TRAINED
	engineering =  SKILL_ENGINEERING_TRAINED
	atmospherics = SKILL_ATMOS_TRAINED
	civ_mech = SKILL_CIV_MECH_NOVICE


//security
/datum/skills/hos
	firearms = SKILL_FIREARMS_PRO
	command = SKILL_COMMAND_EXPERT
	police = SKILL_POLICE_PRO
	melee = SKILL_MELEE_MASTER
	medical = SKILL_MEDICAL_PRACTICED
	combat_mech = SKILL_COMBAT_MECH_PRO

/datum/skills/warden
	firearms = SKILL_FIREARMS_PRO
	command = SKILL_COMMAND_TRAINED
	police = SKILL_POLICE_PRO
	melee = SKILL_MELEE_MASTER
	medical = SKILL_MEDICAL_NOVICE
	combat_mech = SKILL_COMBAT_MECH_NOVICE

/datum/skills/officer
	firearms = SKILL_FIREARMS_PRO
	police = SKILL_POLICE_PRO
	melee = SKILL_MELEE_MASTER
	combat_mech = SKILL_COMBAT_MECH_NOVICE
	command = SKILL_COMMAND_BEGINNER

/datum/skills/cadet
	firearms = SKILL_FIREARMS_TRAINED
	police = SKILL_POLICE_TRAINED
	melee = SKILL_MELEE_TRAINED

/datum/skills/forensic
	police = SKILL_POLICE_TRAINED
	surgery = SKILL_SURGERY_TRAINED
	medical = SKILL_MEDICAL_COMPETENT
	research = SKILL_RESEARCH_TRAINED

/datum/skills/detective
	police = SKILL_POLICE_TRAINED
	firearms = SKILL_FIREARMS_PRO
	medical = SKILL_MEDICAL_NOVICE
	melee = SKILL_MELEE_TRAINED

//cargo
/datum/skills/quartermaster
	civ_mech = SKILL_CIV_MECH_MASTER
	police = SKILL_POLICE_TRAINED
	construction = SKILL_CONSTRUCTION_NOVICE
	command = SKILL_COMMAND_TRAINED
/datum/skills/miner
	civ_mech = SKILL_CIV_MECH_MASTER
	firearms  = SKILL_FIREARMS_TRAINED 
/datum/skills/cargotech
	civ_mech = SKILL_CIV_MECH_PRO
	construction = SKILL_CONSTRUCTION_NOVICE
/datum/skills/recycler
	civ_mech = SKILL_CIV_MECH_PRO
	construction = SKILL_CONSTRUCTION_NOVICE


//civilians
/datum/skills/captain
	police = SKILL_POLICE_PRO
	firearms = SKILL_FIREARMS_PRO
	melee = SKILL_MELEE_TRAINED
	engineering =  SKILL_ENGINEERING_NOVICE
	construction = SKILL_CONSTRUCTION_NOVICE
	research = SKILL_RESEARCH_TRAINED
	medical = SKILL_MEDICAL_NOVICE
	civ_mech = SKILL_CIV_MECH_TRAINED
	combat_mech = SKILL_COMBAT_MECH_NOVICE


/datum/skills/hop
	police = SKILL_POLICE_TRAINED
	firearms = SKILL_FIREARMS_TRAINED
	civ_mech = SKILL_CIV_MECH_TRAINED
	command = SKILL_COMMAND_EXPERT

/datum/skills/internal_affairs
	police = SKILL_POLICE_TRAINED
	command = SKILL_COMMAND_TRAINED

/datum/skills/bartender
	firearms = SKILL_FIREARMS_TRAINED
	police = SKILL_POLICE_TRAINED
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills/botanist
	melee = SKILL_MELEE_TRAINED
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills/chef
	melee = SKILL_MELEE_MASTER
	surgery = SKILL_SURGERY_AMATEUR
	medical = SKILL_MEDICAL_NOVICE
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills/librarian
	research = SKILL_RESEARCH_TRAINED
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills/barber
	medical = SKILL_MEDICAL_NOVICE

/datum/skills/clown
	melee = SKILL_MELEE_TRAINED

/datum/skills/chaplain
	command = SKILL_COMMAND_EXPERT
	melee = SKILL_MELEE_MASTER

/datum/skills/mime
/datum/skills/janitor


/datum/skills/lawyer
	command = SKILL_COMMAND_TRAINED
	police = SKILL_POLICE_TRAINED

/datum/skills/test_subject
/datum/skills/test_subject/lawyer
	command = SKILL_COMMAND_BEGINNER
/datum/skills/test_subject/mecha
	civ_mech = SKILL_CIV_MECH_PRO
	combat_mech = SKILL_COMBAT_MECH_NOVICE
/datum/skills/test_subject/detective
	firearms = SKILL_FIREARMS_TRAINED
/datum/skills/test_subject/reporter

/datum/skills/test_subject/waiter
/datum/skills/test_subject/vice_officer
	command = SKILL_COMMAND_BEGINNER
/datum/skills/test_subject/paranormal
	research = SKILL_RESEARCH_TRAINED
	medical = SKILL_MEDICAL_NOVICE


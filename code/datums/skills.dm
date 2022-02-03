
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
		src.command = command
	tag = SKILLSIDSRC(src)

#undef SKILLSID


/datum/skills/proc/getRating(skill)
	return vars[skill]

/datum/skills/proc/mergeSkills(datum/skills/other)
	var/datum/skills/result = new /datum/skills()
	for(var/skill in SKILL_BOUNDS)
		var/skill_value = max(getRating(skill), other.getRating(skill))
		skill_value = max(skill_value, getSkillMinimum(skill))
		skill_value = min(skill_value, getSkillMaximum(skill))
		result.vars[skill] = skill_value
	return result

/proc/cloneSkills(datum/skills/original)
	var/datum/skills/result = new /datum/skills()
	for(var/skill in SKILL_BOUNDS)
		result.vars[skill] = max(getSkillMinimum(skill), min(original.getRating(skill), getSkillMaximum(skill)))
	return result

/proc/getSkillMinimum(skill)
	return SKILL_BOUNDS[skill][1]

/proc/getSkillMaximum(skill)
	return SKILL_BOUNDS[skill][2]




/proc/applySkillModifier(mob/user, value, required_skill, required_proficiency, penalty = 0.5, bonus = 0.4)
	if(user.mind.getSkillRating(required_skill) < required_proficiency)
		return  value + value * penalty * (required_proficiency - user.mind.getSkillRating(required_skill))
	if(user.mind.getSkillRating(required_skill) > required_proficiency)
		return value - value * bonus * (user.mind.getSkillRating(required_skill) - required_proficiency)
	return value

/proc/handle_fumbling(mob/user, atom/target, delay, required_skill, required_proficiency, time_bonus = SKILL_TASK_TRIVIAL, message_self = "", message_others = "", visual = TRUE)
	if(user.mind.getSkillRating(required_skill) >= required_proficiency)
		return TRUE
	var/display_message_self = message_self
	var/display_message_others = message_others
	if(!message_self)
		display_message_self = "<span class='notice'>You fumble around figuring out how to use the [target].</span>"
	if(!message_others && visual)
		display_message_others = "<span class='notice'>[user] fumbles around figuring out how to use [target].</span>"

	if(visual)
		user.visible_message(display_message_others, display_message_self)
	else
		to_chat(user, display_message_self)

	var/required_time = delay - time_bonus * user.mind.getSkillRating(required_skill)
	if(!do_after(user, required_time, target = target))
		return FALSE
	return TRUE

/proc/isSkillCompetent(mob/user, required_skill, required_proficiency)
	return user?.mind?.getSkillRating(required_skill) >= required_proficiency



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
	firearms = SKILL_FIREARMS_TRAINED

/datum/skills/detective
	police = SKILL_POLICE_TRAINED
	firearms = SKILL_FIREARMS_PRO
	medical = SKILL_MEDICAL_NOVICE
	melee = SKILL_MELEE_TRAINED

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
	chemistry = SKILL_CHEMISTRY_PRACTICED
/datum/skills/research_assistant
	research = SKILL_RESEARCH_TRAINED
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR
	construction = SKILL_CONSTRUCTION_NOVICE
	engineering =  SKILL_ENGINEERING_NOVICE
	civ_mech = SKILL_CIV_MECH_NOVICE

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
	command = SKILL_COMMAND_BEGINNER

/datum/skills/barber
	medical = SKILL_MEDICAL_NOVICE

/datum/skills/clown
	melee = SKILL_MELEE_WEAK
/datum/skills/mime
	melee = SKILL_MELEE_WEAK

/datum/skills/chaplain
	command = SKILL_COMMAND_EXPERT
	melee = SKILL_MELEE_MASTER

/datum/skills/janitor
/datum/skills/test_subject
/datum/skills/test_subject/lawyer
	command = SKILL_COMMAND_BEGINNER

/datum/skills/test_subject/mecha
	civ_mech = SKILL_CIV_MECH_MASTER
	combat_mech = SKILL_COMBAT_MECH_NOVICE

/datum/skills/test_subject/detective
	firearms = SKILL_FIREARMS_TRAINED

/datum/skills/test_subject/reporter
	command = SKILL_COMMAND_BEGINNER

/datum/skills/test_subject/waiter
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills/test_subject/vice_officer
	command = SKILL_COMMAND_TRAINED

/datum/skills/test_subject/paranormal
	research = SKILL_RESEARCH_TRAINED
	medical = SKILL_MEDICAL_NOVICE


//antagonists
/datum/skills/traitor
	police = SKILL_POLICE_PRO
	firearms = SKILL_FIREARMS_PRO
	melee = SKILL_MELEE_MASTER
	engineering = SKILL_ENGINEERING_MASTER
	construction = SKILL_CONSTRUCTION_MASTER
	atmospherics = SKILL_ATMOS_MASTER
	civ_mech = SKILL_CIV_MECH_MASTER
	combat_mech = SKILL_CIV_MECH_PRO
	surgery = SKILL_SURGERY_EXPERT
	medical = SKILL_MEDICAL_MASTER
	chemistry = SKILL_CHEMISTRY_EXPERT
	research = SKILL_RESEARCH_EXPERT
	command = SKILL_COMMAND_MASTER

/datum/skills/revolutionary
	police = SKILL_POLICE_TRAINED
	firearms = SKILL_FIREARMS_TRAINED
	command = SKILL_COMMAND_BEGINNER
	melee = SKILL_MELEE_TRAINED

/datum/skills/gangster
	firearms = SKILL_FIREARMS_PRO
	melee = SKILL_MELEE_MASTER

/datum/skills/cultist
	melee = SKILL_MELEE_MASTER
	surgery = SKILL_SURGERY_EXPERT
	medical = SKILL_MEDICAL_MASTER
	chemistry = SKILL_CHEMISTRY_PRACTICED
	research = SKILL_RESEARCH_TRAINED

/datum/skills/cultist/leader
	command = SKILL_COMMAND_EXPERT
	police = SKILL_POLICE_TRAINED
	firearms = SKILL_FIREARMS_TRAINED
	chemistry = SKILL_CHEMISTRY_COMPETENT
	combat_mech = SKILL_COMBAT_MECH_NOVICE
	civ_mech = SKILL_CIV_MECH_TRAINED
	research = SKILL_RESEARCH_PROFESSIONAL

/datum/skills/abductor
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_AMATEUR
	firearms = SKILL_FIREARMS_TRAINED
	police = SKILL_POLICE_TRAINED
	research = SKILL_RESEARCH_TRAINED

/datum/skills/abductor/agent
	melee = SKILL_MELEE_MASTER
	firearms = SKILL_FIREARMS_PRO
	police = SKILL_POLICE_PRO

/datum/skills/abductor/scientist
	surgery = SKILL_SURGERY_EXPERT
	medical = SKILL_MEDICAL_MASTER
	research = SKILL_RESEARCH_EXPERT


/datum/skills/wizard
	melee = SKILL_MELEE_MASTER
	medical = SKILL_MEDICAL_MASTER
	surgery = SKILL_SURGERY_EXPERT
	chemistry = SKILL_CHEMISTRY_EXPERT
	command = SKILL_COMMAND_TRAINED

/datum/skills/undercover
	police = SKILL_POLICE_PRO
	firearms = SKILL_FIREARMS_PRO
	command = SKILL_COMMAND_TRAINED
	combat_mech = SKILL_COMBAT_MECH_NOVICE
	melee = SKILL_MELEE_TRAINED

/datum/skills/cop
	police = SKILL_POLICE_PRO
	firearms = SKILL_FIREARMS_PRO
	combat_mech = SKILL_COMBAT_MECH_PRO
	command = SKILL_COMMAND_EXPERT
	melee = SKILL_MELEE_MASTER
	




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
		. = new /datum/skills_modifier(police = 0, firearms = 0,\
			melee = 0, engineering = 0, construction = 0, atmospherics = 0, civ_mech = 0, combat_mech = 0, surgery = 0,\
			medical = 0, chemistry = 0, research = 0, command = 0)

/proc/getSkillsType(skills_type = /datum/skills_modifier)
	var/datum/skills_modifier/new_skill = skills_type
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

/datum/skills_modifier
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

/datum/skills_modifier/New(police, firearms,\
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


/datum/skills_modifier/proc/get_value(skill)
	if(skill in SKILL_BOUNDS)
		return vars[skill]

/proc/get_skill_minimum(skill)
	if(skill in SKILL_BOUNDS)
		return SKILL_BOUNDS[skill][1]

/proc/get_skill_maximum(skill)
	if(skill in SKILL_BOUNDS)
		return SKILL_BOUNDS[skill][2]

/proc/applySkillBonus(mob/user, value, required_skill, required_proficiency, penalty = 0.5, bonus = 0.4)
	if(user.mind.skills.get_value(required_skill) < required_proficiency)
		return  value + value * penalty * (required_proficiency - user.mind.skills.get_value(required_skill))
	if(user.mind.skills.get_value(required_skill) > required_proficiency)
		return value - value * bonus * (user.mind.skills.get_value(required_skill) - required_proficiency)
	return value

/proc/do_skilled(mob/user, atom/target,  delay, required_skill, required_proficiency, penalty = 0.5, bonus = 0.4)
	return do_after(user, delay = applySkillBonus(user, delay, required_skill, required_proficiency, penalty, bonus), target = target)

/proc/handle_fumbling(mob/user, atom/target, delay, required_skill, required_proficiency, time_bonus = SKILL_TASK_TRIVIAL, message_self = "", message_others = "", text_target = null)
	if(isSkillCompetent(user, required_skill, required_proficiency))
		return TRUE
	var/display_message_self = message_self
	var/used_item = target
	if(text_target)
		used_item = text_target
	if(!message_self)
		display_message_self = "<span class='notice'>You fumble around figuring out how to use the [used_item].</span>"
	to_chat(user, display_message_self)

	var/required_time = max(time_bonus, delay - time_bonus * user.mind.skills.get_value(required_skill))
	return do_after(user, required_time, target = target)

/proc/isSkillCompetent(mob/user, required_skill, required_proficiency)
	return user?.mind?.skills.get_value(required_skill) >= required_proficiency


/datum/skills
	var/skillset/active_skillset = new /skillset()
	var/skillset/available_skillset = new /skillset()

	var/list/skills_modifiers = list()

/datum/skills/proc/get_value(skill, user = usr)
	return min(active_skillset.get_value(skill), available_skillset.get_value(skill))

/datum/skills/proc/get_max_value(skill)
	return available_skillset.get_value(skill)

/datum/skills/proc/update_available_skillset()
	available_skillset = new /skillset()
	available_skillset.init_from_datum(skills_modifiers[1])
	for(var/datum/skills_modifier/skills in skills_modifiers)
		available_skillset.merge(skills)

/datum/skills/proc/remove_skills_modifier(datum/skills/removable)
	for(var/datum/skills_modifier/s in skills_modifiers)
		if(s.tag == removable.tag)
			skills_modifiers.Remove(s)
	update_available_skillset()

/datum/skills/proc/transfer_skills(datum/mind/target)
	for(var/datum/skills_modifier/s in target.skills.skills_modifiers)
		add_skills_modifier(s)

/datum/skills/proc/add_skills_modifier(datum/skills/new_skills)
	skills_modifiers += new_skills
	update_available_skillset()
	active_skillset.skills = available_skillset.skills.Copy()

/datum/skills/proc/set_value(skill,value)
	if (value > get_skill_maximum(skill) || value < get_skill_minimum(skill))
		return
	if (value > available_skillset.get_value(skill))
		return
	if (value == get_value(skill))
		return
	to_chat(usr, "<span class='notice'>You changed your skill proficiency in [skill] from [active_skillset.get_value(skill)] to [value].</span>")
	active_skillset.set_value(skill, value)


//skillset
/skillset
	var/list/skills = list()

/skillset/proc/init_from_datum(datum/skills_modifier/initial)
	for(var/skill in SKILL_BOUNDS)
		skills[skill] = max(get_skill_minimum(skill), initial.get_value(skill))

/skillset/proc/merge(datum/skills/other)
	for(var/skill in skills)
		set_value(skill, max(other.get_value(skill), get_value(skill)))

/skillset/proc/get_value(skill)
	if(skill in skills)
		return skills[skill]

/skillset/proc/set_value(skill, value)
	if(skill in skills)
		skills[skill] = max(min(get_skill_maximum(skill), value), get_skill_minimum(skill))


//medical
/datum/skills_modifier/cmo
	chemistry = SKILL_CHEMISTRY_EXPERT
	command = SKILL_COMMAND_EXPERT
	medical = SKILL_MEDICAL_MASTER
	surgery = SKILL_SURGERY_EXPERT
	police = SKILL_POLICE_TRAINED
	research = SKILL_RESEARCH_TRAINED
	civ_mech = SKILL_CIV_MECH_MASTER

/datum/skills_modifier/doctor
	medical = SKILL_MEDICAL_EXPERT
	surgery = SKILL_SURGERY_PROFESSIONAL
	civ_mech = SKILL_CIV_MECH_TRAINED
	chemistry = SKILL_CHEMISTRY_COMPETENT

/datum/skills_modifier/doctor/surgeon
	surgery = SKILL_SURGERY_EXPERT
	medical = SKILL_MEDICAL_EXPERT

/datum/skills_modifier/doctor/nurse
	surgery = SKILL_SURGERY_PROFESSIONAL
	medical = SKILL_MEDICAL_MASTER
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills_modifier/virologist
	chemistry = SKILL_CHEMISTRY_COMPETENT
	research = SKILL_RESEARCH_TRAINED
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_AMATEUR
	civ_mech = SKILL_CIV_MECH_NOVICE

/datum/skills_modifier/chemist
	chemistry = SKILL_CHEMISTRY_EXPERT
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_AMATEUR
	civ_mech = SKILL_CIV_MECH_NOVICE

/datum/skills_modifier/paramedic
	medical = SKILL_MEDICAL_EXPERT
	surgery = SKILL_SURGERY_TRAINED
	civ_mech = SKILL_CIV_MECH_PRO
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills_modifier/psychiatrist
	medical = SKILL_MEDICAL_COMPETENT
	command = SKILL_COMMAND_BEGINNER
	chemistry = SKILL_CHEMISTRY_COMPETENT
	surgery = SKILL_SURGERY_AMATEUR

/datum/skills_modifier/geneticist
	research = SKILL_RESEARCH_PROFESSIONAL
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_AMATEUR
	chemistry = SKILL_CHEMISTRY_PRACTICED
	civ_mech = SKILL_CIV_MECH_NOVICE
	atmospherics = SKILL_ATMOS_TRAINED

/datum/skills_modifier/intern
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_AMATEUR
	chemistry = SKILL_CHEMISTRY_PRACTICED
	civ_mech = SKILL_CIV_MECH_TRAINED

//engineering
/datum/skills_modifier/ce
	construction = SKILL_CONSTRUCTION_MASTER
	command = SKILL_COMMAND_EXPERT
	engineering =  SKILL_ENGINEERING_MASTER
	atmospherics = SKILL_ATMOS_MASTER
	civ_mech = SKILL_CIV_MECH_MASTER
	police = SKILL_POLICE_TRAINED

/datum/skills_modifier/engineer
	construction = SKILL_CONSTRUCTION_ADVANCED
	engineering =  SKILL_ENGINEERING_PRO
	atmospherics = SKILL_ATMOS_PRO
	civ_mech = SKILL_CIV_MECH_TRAINED

/datum/skills_modifier/atmostech
	atmospherics = SKILL_ATMOS_MASTER
	construction = SKILL_CONSTRUCTION_ADVANCED
	engineering =  SKILL_ENGINEERING_TRAINED
	melee = SKILL_MELEE_TRAINED
	civ_mech = SKILL_CIV_MECH_TRAINED

/datum/skills_modifier/technicassistant
	construction = SKILL_CONSTRUCTION_TRAINED
	engineering =  SKILL_ENGINEERING_TRAINED
	atmospherics = SKILL_ATMOS_TRAINED
	civ_mech = SKILL_CIV_MECH_NOVICE

//security
/datum/skills_modifier/hos
	firearms = SKILL_FIREARMS_PRO
	command = SKILL_COMMAND_EXPERT
	police = SKILL_POLICE_PRO
	melee = SKILL_MELEE_MASTER
	medical = SKILL_MEDICAL_PRACTICED
	combat_mech = SKILL_COMBAT_MECH_PRO

/datum/skills_modifier/warden
	firearms = SKILL_FIREARMS_PRO
	command = SKILL_COMMAND_TRAINED
	police = SKILL_POLICE_PRO
	melee = SKILL_MELEE_MASTER
	medical = SKILL_MEDICAL_NOVICE
	combat_mech = SKILL_COMBAT_MECH_NOVICE

/datum/skills_modifier/officer
	firearms = SKILL_FIREARMS_PRO
	police = SKILL_POLICE_PRO
	melee = SKILL_MELEE_MASTER
	combat_mech = SKILL_COMBAT_MECH_NOVICE
	command = SKILL_COMMAND_BEGINNER

/datum/skills_modifier/cadet
	firearms = SKILL_FIREARMS_TRAINED
	police = SKILL_POLICE_TRAINED
	melee = SKILL_MELEE_TRAINED

/datum/skills_modifier/forensic
	police = SKILL_POLICE_TRAINED
	surgery = SKILL_SURGERY_TRAINED
	medical = SKILL_MEDICAL_COMPETENT
	research = SKILL_RESEARCH_TRAINED
	firearms = SKILL_FIREARMS_TRAINED

/datum/skills_modifier/detective
	police = SKILL_POLICE_TRAINED
	firearms = SKILL_FIREARMS_PRO
	medical = SKILL_MEDICAL_NOVICE
	melee = SKILL_MELEE_TRAINED

//science
/datum/skills_modifier/rd
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

/datum/skills_modifier/scientist
	research = SKILL_RESEARCH_EXPERT
	atmospherics = SKILL_ATMOS_TRAINED
	construction =  SKILL_CONSTRUCTION_TRAINED
	engineering = SKILL_ENGINEERING_NOVICE
	chemistry =  SKILL_CHEMISTRY_PRACTICED
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR
	civ_mech = SKILL_CIV_MECH_NOVICE
/datum/skills_modifier/scientist/phoron
	atmospherics = SKILL_ATMOS_PRO
	research = SKILL_RESEARCH_PROFESSIONAL
	chemistry = SKILL_CHEMISTRY_COMPETENT

/datum/skills_modifier/roboticist
	research = SKILL_RESEARCH_EXPERT
	surgery = SKILL_SURGERY_TRAINED
	medical = SKILL_MEDICAL_PRACTICED
	construction = SKILL_CONSTRUCTION_TRAINED
	engineering = SKILL_ENGINEERING_NOVICE
	civ_mech = SKILL_CIV_MECH_PRO
	combat_mech = SKILL_COMBAT_MECH_NOVICE

/datum/skills_modifier/roboticist/bio
	surgery = SKILL_SURGERY_PROFESSIONAL
	civ_mech = SKILL_CIV_MECH_TRAINED

/datum/skills_modifier/roboticist/mecha
	construction = SKILL_CONSTRUCTION_ADVANCED
	combat_mech = SKILL_COMBAT_MECH_PRO
	civ_mech = SKILL_CIV_MECH_MASTER
	surgery = SKILL_SURGERY_AMATEUR

/datum/skills_modifier/xenoarchaeologist
	chemistry = SKILL_CHEMISTRY_COMPETENT
	research = SKILL_RESEARCH_PROFESSIONAL
	civ_mech = SKILL_CIV_MECH_TRAINED

/datum/skills_modifier/xenobiologist
	research = SKILL_RESEARCH_PROFESSIONAL
	surgery = SKILL_SURGERY_AMATEUR
	medical = SKILL_MEDICAL_PRACTICED
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills_modifier/research_assistant
	research = SKILL_RESEARCH_TRAINED
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR
	construction = SKILL_CONSTRUCTION_NOVICE
	engineering =  SKILL_ENGINEERING_NOVICE
	civ_mech = SKILL_CIV_MECH_NOVICE

//cargo
/datum/skills_modifier/quartermaster
	civ_mech = SKILL_CIV_MECH_MASTER
	police = SKILL_POLICE_TRAINED
	construction = SKILL_CONSTRUCTION_NOVICE
	command = SKILL_COMMAND_TRAINED

/datum/skills_modifier/miner
	civ_mech = SKILL_CIV_MECH_MASTER
	firearms  = SKILL_FIREARMS_TRAINED

/datum/skills_modifier/cargotech
	civ_mech = SKILL_CIV_MECH_PRO
	construction = SKILL_CONSTRUCTION_NOVICE
/datum/skills_modifier/recycler
	civ_mech = SKILL_CIV_MECH_PRO
	construction = SKILL_CONSTRUCTION_NOVICE

//civilians
/datum/skills_modifier/captain
	command = SKILL_COMMAND_MASTER
	police = SKILL_POLICE_PRO
	firearms = SKILL_FIREARMS_PRO
	melee = SKILL_MELEE_TRAINED
	engineering =  SKILL_ENGINEERING_NOVICE
	construction = SKILL_CONSTRUCTION_NOVICE
	research = SKILL_RESEARCH_TRAINED
	medical = SKILL_MEDICAL_NOVICE
	civ_mech = SKILL_CIV_MECH_TRAINED
	combat_mech = SKILL_COMBAT_MECH_NOVICE

/datum/skills_modifier/hop
	command = SKILL_COMMAND_EXPERT
	police = SKILL_POLICE_TRAINED
	firearms = SKILL_FIREARMS_TRAINED
	civ_mech = SKILL_CIV_MECH_TRAINED

/datum/skills_modifier/internal_affairs
	police = SKILL_POLICE_TRAINED
	command = SKILL_COMMAND_TRAINED

/datum/skills_modifier/bartender
	firearms = SKILL_FIREARMS_TRAINED
	police = SKILL_POLICE_TRAINED
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills_modifier/botanist
	melee = SKILL_MELEE_TRAINED
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills_modifier/chef
	melee = SKILL_MELEE_MASTER
	surgery = SKILL_SURGERY_AMATEUR
	medical = SKILL_MEDICAL_NOVICE
	chemistry = SKILL_CHEMISTRY_PRACTICED

/datum/skills_modifier/librarian
	research = SKILL_RESEARCH_TRAINED
	chemistry = SKILL_CHEMISTRY_PRACTICED
	command = SKILL_COMMAND_BEGINNER

/datum/skills_modifier/barber
	medical = SKILL_MEDICAL_NOVICE

/datum/skills_modifier/clown
	melee = SKILL_MELEE_WEAK
/datum/skills_modifier/mime
	melee = SKILL_MELEE_WEAK

/datum/skills_modifier/chaplain
	command = SKILL_COMMAND_EXPERT
	melee = SKILL_MELEE_MASTER

/datum/skills_modifier/janitor
/datum/skills_modifier/test_subject
/datum/skills_modifier/test_subject/lawyer
	command = SKILL_COMMAND_BEGINNER

/datum/skills_modifier/test_subject/mecha
	civ_mech = SKILL_CIV_MECH_MASTER
	combat_mech = SKILL_COMBAT_MECH_NOVICE

/datum/skills_modifier/test_subject/detective
	firearms = SKILL_FIREARMS_TRAINED

/datum/skills_modifier/test_subject/reporter
	command = SKILL_COMMAND_BEGINNER

/datum/skills_modifier/test_subject/waiter
	chemistry = SKILL_CHEMISTRY_PRACTICED
	police = SKILL_POLICE_TRAINED

/datum/skills_modifier/test_subject/vice_officer
	command = SKILL_COMMAND_TRAINED
	police = SKILL_POLICE_TRAINED

/datum/skills_modifier/test_subject/paranormal
	research = SKILL_RESEARCH_TRAINED
	medical = SKILL_MEDICAL_NOVICE


//antagonists
/datum/skills_modifier/max
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

/datum/skills_modifier/revolutionary
	police = SKILL_POLICE_TRAINED
	firearms = SKILL_FIREARMS_TRAINED
	command = SKILL_COMMAND_BEGINNER
	melee = SKILL_MELEE_TRAINED

/datum/skills_modifier/gangster
	firearms = SKILL_FIREARMS_PRO
	melee = SKILL_MELEE_MASTER

/datum/skills_modifier/cultist
	melee = SKILL_MELEE_MASTER
	surgery = SKILL_SURGERY_EXPERT
	medical = SKILL_MEDICAL_MASTER
	chemistry = SKILL_CHEMISTRY_PRACTICED
	research = SKILL_RESEARCH_TRAINED

/datum/skills_modifier/cultist/leader
	command = SKILL_COMMAND_EXPERT
	police = SKILL_POLICE_TRAINED
	firearms = SKILL_FIREARMS_TRAINED
	chemistry = SKILL_CHEMISTRY_COMPETENT
	combat_mech = SKILL_COMBAT_MECH_NOVICE
	civ_mech = SKILL_CIV_MECH_TRAINED
	research = SKILL_RESEARCH_PROFESSIONAL

/datum/skills_modifier/abductor
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_AMATEUR
	firearms = SKILL_FIREARMS_TRAINED
	police = SKILL_POLICE_TRAINED
	research = SKILL_RESEARCH_TRAINED

/datum/skills_modifier/abductor/agent
	melee = SKILL_MELEE_MASTER
	firearms = SKILL_FIREARMS_PRO
	police = SKILL_POLICE_PRO

/datum/skills_modifier/abductor/scientist
	surgery = SKILL_SURGERY_EXPERT
	medical = SKILL_MEDICAL_MASTER
	research = SKILL_RESEARCH_EXPERT


/datum/skills_modifier/wizard
	melee = SKILL_MELEE_MASTER
	medical = SKILL_MEDICAL_MASTER
	surgery = SKILL_SURGERY_EXPERT
	chemistry = SKILL_CHEMISTRY_EXPERT
	command = SKILL_COMMAND_TRAINED

/datum/skills_modifier/undercover
	police = SKILL_POLICE_PRO
	firearms = SKILL_FIREARMS_PRO
	command = SKILL_COMMAND_TRAINED
	combat_mech = SKILL_COMBAT_MECH_NOVICE
	melee = SKILL_MELEE_TRAINED

/datum/skills_modifier/cop
	police = SKILL_POLICE_PRO
	firearms = SKILL_FIREARMS_PRO
	combat_mech = SKILL_COMBAT_MECH_PRO
	command = SKILL_COMMAND_EXPERT
	melee = SKILL_MELEE_MASTER




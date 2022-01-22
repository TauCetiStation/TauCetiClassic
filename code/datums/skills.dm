
#define SKILLSID "skills-[police]\
-[firearms]-[melee]-[engineering]-[construction]-[atmospherics]-[civ_mech]\
-[combat_mech]-[surgery]-[medical]-[chemistry]-[research]"

#define SKILLSIDSRC(S) "skills-[S.police]\
-[S.firearms]-[S.melee]-[S.engineering]-[S.construction]-[S.atmospherics]-[S.civ_mech]\
-[S.combat_mech]-[S.surgery]-[S.medical]-[S.chemistry]-[S.research]"


/proc/getSkills(police = 0, firearms = 0,\
melee = 0, engineering = 0, construction = 0, atmospherics = 0, civ_mech = 0, combat_mech = 0, surgery = 0,\
medical = 0, chemistry = 0, research = 0)
	. = locate(SKILLSID)
	if(!.)
		. = new /datum/skills(police = 0, firearms = 0,\
			melee = 0, engineering = 0, construction = 0, atmospherics = 0, civ_mech = 0, combat_mech = 0, surgery = 0,\
			medical = 0, chemistry = 0, research = 0)



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
	. = locate(SKILLSID)
	if(!.)
		. = new skills_type


/datum/skills
	var/police = SKILL_POLICE_UNTRAINED
	var/firearms = SKILL_FIREARMS_UNTRAINED
	var/melee = SKILL_MELEE_DEFAULT
	var/engineering = SKILL_ENGINEER_DEFAULT
	var/construction = SKILL_CONSTRUCTION_DEFAULT
	var/atmospherics = SKILL_ATMOS_DEFAULT
	var/civ_mech = SKILL_CIV_MECH_DEFAULT
	var/combat_mech = SKILL_COMBAT_MECH_UNTRAINED
	var/surgery = SKILL_SURGERY_DEFAULT
	var/medical = SKILL_MEDICAL_UNTRAINED
	var/chemistry = SKILL_CHEMISTRY_UNTRAINED
	var/research = SKILL_RESEARCH_DEFAULT

/datum/skills/New(police, firearms,\
melee, engineering, construction, atmospherics, civ_mech, combat_mech, surgery,\
medical, chemistry, research)
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
	tag = SKILLSIDSRC(src)



#undef SKILLSID


/datum/skills/proc/getRating(rating)
	return vars[rating]


/datum/skills/scientist
	atmospherics = SKILL_ATMOS_TRAINED
	construction =  SKILL_CONSTRUCTION_TRAINED
	chemistry =  SKILL_CHEMISTRY_PRACTICED
	research = SKILL_RESEARCH_PROFESSIONAL
	medical = SKILL_MEDICAL_PRACTICED
	
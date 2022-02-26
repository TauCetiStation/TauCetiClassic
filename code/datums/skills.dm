
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

/proc/get_skills_type(skills_type = /datum/skills_modifier)
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

/datum/skills
	var/datum/skillset/active_skillset = new /datum/skillset
	var/datum/skillset/available_skillset = new /datum/skillset

	var/list/modifiers = list()

/datum/skills/proc/get_value(skill, user = usr)
	return min(active_skillset.get_value(skill), available_skillset.get_value(skill))

/datum/skills/proc/get_max(skill)
	return available_skillset.get_value(skill)

/datum/skills/proc/update_available()
	available_skillset = new /datum/skillset()
	available_skillset.init_from_datum(modifiers[1])
	for(var/datum/skills_modifier/skills in modifiers)
		available_skillset.merge(skills)

/datum/skills/proc/remove_modifier(datum/skills/removable)
	for(var/datum/skills_modifier/s as anything in modifiers)
		if(s.tag == removable.tag)
			LAZYREMOVE(modifiers, s)
			break
	update_available()

/datum/skills/proc/transfer_skills(datum/mind/target)
	for(var/datum/skills_modifier/s as anything in target.skills.modifiers)
		add_modifier(s)

/datum/skills/proc/add_modifier(datum/skills/new_skills)
	LAZYADD(modifiers, new_skills)
	update_available()
	active_skillset.skills = available_skillset.skills.Copy()

/datum/skills/proc/set_value(skill,value)
	if (value > get_skill_absolute_maximum(skill) || value < get_skill_absolute_minimum(skill))
		return
	if (value > available_skillset.get_value(skill))
		return
	if (value == get_value(skill))
		return
	to_chat(usr, "<span class='notice'>You changed your skill proficiency in [skill] from [active_skillset.get_value(skill)] to [value].</span>")
	active_skillset.set_value(skill, value)

/datum/skillset
	var/name
	var/list/skills
	var/list/initial_skills

/datum/skillset/New()
	for(var/skill in initial_skills)
		LAZYSET(skills, skill, initial_skills[skill])
	for(var/skill in all_skills)
		if(!(skill in skills))
			var/default_value = default_skills_list[skill]
			LAZYSET(skills, skill, default_value)

/datum/skillset/proc/merge(datum/skillset/other_skillset)
	for(var/skill in skills)
		var/new_value = max(other_skillset.get_value(skill), get_value(skill))
		set_value(skill, new_value)

/datum/skillset/proc/get_value(skill)
	return LAZYACCESS(skills, skill)

/datum/skillset/proc/set_value(skill, value)
	if(value > SKILL_LEVEL_MAX || value < SKILL_LEVEL_MIN)
		throw "Skill level must be in range from [SKILL_LEVEL_MIN] to [SKILL_LEVEL_MAX]"
	LAZYSET(skills, skill, value)

/datum/skillset/proc/get_command_modifier()
	return 1 + get_value(/datum/skill/command) / SKILL_LEVEL_MAX

/datum/skillset/proc/get_help_additive(skill)
	var/skill_value = get_value(skill)
	if (skill_value == SKILL_LEVEL_MIN)
		return skill_value + 0.5
	return skill_value

/datum/skillset
	var/name
	var/list/skills
	var/list/initial_skills

/datum/skillset/New()
	for(var/datum/skill/s in initial_skills)
		var/datum/skill/original = all_skills[s]
		LAZYSET(skills, original, initial_skills[s])
	for(var/datum/skill/skill in all_skills)
		var/datum/skill/default = all_skills[skill]
		if(!(default.name in skills))
			LAZYSET(skills, default, SKILL_LEVEL_MIN)

/datum/skillset/proc/merge(datum/skillset/other_skillset)
	for(var/skill in skills)
		var/new_value = max(other_skillset.get_value(skill), get_value(skill))
		set_value(skill, new_value)

/datum/skillset/proc/get_value(datum/skill/skill)
	return skills[skill]

/datum/skillset/proc/set_value(datum/skill/skill, value)
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

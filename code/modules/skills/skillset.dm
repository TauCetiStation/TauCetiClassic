/datum/skillset
	var/name
	var/list/skills
	var/list/initial_skills

/datum/skillset/New()
	for(var/datum/skill/s as anything in initial_skills)
		var/datum/skill/original = all_skills[s]
		LAZYSET(skills, original.name, all_skills[s])
	for(var/datum/skill/skill as anything in default_skills_list)
		var/datum/skill/default = all_skills[skill]
		if(!(default.name in skills))
			LAZYSET(skills, default.name, default)

/datum/skillset/proc/merge(datum/skillset/other_skillset)
	for(var/skill in skills)
		var/new_value = max(other_skillset.get_value(skill), get_value(skill))
		set_value(skill, new_value)

/datum/skillset/proc/get_value(skill)
	var/datum/skill/s = get_skill(skill)
	return s.value

/datum/skillset/proc/set_value(skill, value)
	var/datum/skill/s = get_skill(skill)
	s.value = value

/datum/skillset/proc/get_skill(skill)
	return skills[skill]

/datum/skillset/proc/copy_skills()
	var/result = list()
	for(var/skill_name in skills)
		var/datum/skill/original = get_skill(skill_name)
		var/datum/skill/skill_copy = new original.type
		result[skill_name] = skill_copy
	return result

/datum/skillset/proc/get_command_modifier()
	var/datum/skill/command = get_skill(SKILL_COMMAND)
	return 1 + command.value / command.max_value

/datum/skillset/proc/get_help_additive(skill_name)
	var/datum/skill/skill = get_skill(skill_name)
	if (skill.value == skill.min_value)
		return skill.value + 0.5
	if (skill.value == skill.max_value)
		return skill.value - 1
	return skill.value

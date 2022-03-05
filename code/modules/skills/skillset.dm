/datum/skillset
	var/list/skills = list()
	var/list/initial_skills

/datum/skillset/New()
	for(var/datum/skill/s in initial_skills)
		skills[s.name] = s

	for(var/datum/skill/skill in skills_list)
		if(!(skill in skills))
			skills[skill.name] = new skill

/datum/skillset/proc/merge(datum/skillset/other)
	for(var/skill in skills)
		var/new_value = max(other.get_value(skill), get_value(skill))
		set_value(skill, new_value)


/datum/skillset/proc/get_value(skill)
	var/datum/skill/s = get_skill(skill)
	return s.value

/datum/skillset/proc/set_value(skill, value)
	var/datum/skill/s = get_skill(skill)
	s.value = value

/datum/skillset/proc/get_skill(skill)
	if(skill in skills)
		return skills[skill]




/datum/skillset
	var/list/skills
	var/list/initial_skills

/datum/skillset/New()
	for(var/datum/skill/s as anything in initial_skills)
		LAZYSET(skills, initial(s.name), new s)
	for(var/datum/skill/skill as anything in skills_list)
		if(!(initial(skill.name) in skills))
			LAZYSET(skills, initial(skill.name), new skill)

/datum/skillset/proc/merge(datum/skillset/skillset_type)
	var/datum/skillset/other_skillset = new skillset_type
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




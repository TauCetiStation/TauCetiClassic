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

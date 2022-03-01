/datum/skillset
	var/list/skills = list()

/datum/skillset/New()
	var/datum/skills_modifier/default/default_skillset = new
	for(var/skill in SKILL_BOUNDS)
		skills[skill] = max(get_skill_absolute_minimum(skill), default_skillset.get_value(skill))

/datum/skillset/proc/merge(datum/skills/other)
	for(var/skill in skills)
		set_value(skill, max(other.get_value(skill), get_value(skill)))

/datum/skillset/proc/get_value(skill)
	if(skill in skills)
		return skills[skill]

/datum/skillset/proc/set_value(skill, value)
	if(skill in skills)
		skills[skill] = max(min(get_skill_absolute_maximum(skill), value), get_skill_absolute_minimum(skill))

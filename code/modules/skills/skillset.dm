/datum/skillset
	var/list/skills = list()
	var/list/initial_skills

/datum/skillset/New()
	for(var/datum/skill/s in initial_skills)
		skills[s.name] = new skill

	for(var/datum/skill/skill in skills_list)
		if(!(skill in skills))
			skills[skill.name] = new skill

/datum/skillset/proc/merge(datum/skillset/other)
	for(var/skill in skills)
		var/new_value = max(other.get_value(skill), get_value(skill))
		set_value(skill, new_value)


/datum/skillset/proc/get_value(skill)
	var/datum/skill/skill = get_skill(skill)
	return skill.value

/datum/skillset/proc/set_value(skill, value)
	var/datum/skill/skill = get_skill(skill)
	skill.value = value

/datum/skillset/proc/get_skill(skill)
	if(skill in skills)
		return skills[skill]

/datum/skillset/cmo
	initial_skills = list(
		/datum/skill/chemistry/trained,
		/datum/skill/research/trained,
		/datum/skill/police/trained
	)
/datum/skillset/test_subject
	initial_skills = list (/datum/melee/weak)


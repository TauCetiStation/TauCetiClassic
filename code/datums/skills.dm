/datum/skills
	var/datum/skillset/active = new
	var/datum/skillset/available = new

	var/list/available_skillsets

/datum/skills/proc/get_value(skill)
	return active.get_value(skill)

/datum/skills/proc/get_max(skill)
	return available.get_value(skill)

/datum/skills/proc/update_available()
	for(var/datum/skillset/sk_set as anything in available_skillsets)
		available.merge(sk_set)
	for(var/skill in available.skills)
		active.set_value(skill, min(active.get_value(skill), available.get_value(skill)))

/datum/skills/proc/maximize_active_skills()
	for(var/skill in available.skills)
		active.set_value(skill, available.get_value(skill))

/datum/skills/proc/add_available_skillset(datum/skillset/new_skillset)
	LAZYADD(available_skillsets, new_skillset)
	update_available()

/datum/skills/proc/remove_available_skillset(datum/skillset/skillset_type)
	for(var/datum/skillset/s as anything in available_skillsets)
		if(s.initial_skills == skillset_type.initial_skills)
			LAZYREMOVE(available_skillsets, s)
			break
	update_available()

/datum/skills/proc/transfer_skills(datum/mind/target)
	for(var/datum/skillset/s as anything in target.skills.available_skillsets)
		add_available_skillset(s)


/datum/skills/proc/choose_value(skill_name,value)
	var/list/allowed_skill_names = list()
	for(var/skill in skills_list)
		allowed_skill_names.Add(initial(skill.name))
	if(!(skill_name in allowed_skill_names))
		return
	var/datum/skill/skill = active.get_skill(skill_name)
	if (value > skill.max_value || value < skill.min_value)
		return
	if (value > available.get_value(skill_name))
		return
	if (value == get_value(skill_name))
		return
	to_chat(usr, "<span class='notice'>You changed your skill proficiency in [skill_name] from [active.get_value(skill_name)] to [value].</span>")
	active.set_value(skill_name, value)

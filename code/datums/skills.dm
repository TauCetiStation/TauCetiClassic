/datum/skills
	var/datum/skillset/active = new
	var/datum/skillset/available = new

	var/list/available_skillsets

/datum/skills/New()
	for(var/skill_name in active.skills)
		var/datum/skill/original = active.get_skill(skill_name)
		var/datum/skill/skill_copy = new original.type  // new instance of skill because we will change the skills in active skillset
		LAZYSET(active.skills, skill_name, skill_copy)

/datum/skills/proc/get_value(skill)
	return active.get_value(skill)

/datum/skills/proc/get_max(skill)
	return available.get_value(skill)

/datum/skills/proc/update_available()
	var/datum/skillset/temporary = new //we want different instance beceause of merging proc
	if(length(available_skillsets) == 1)
		temporary = LAZYACCESS(available_skillsets, 1)
	for(var/datum/skillset/sk_set as anything in available_skillsets)
		temporary.merge(sk_set)
	available = temporary
	for(var/skill in available.skills)
		active.set_value(skill, min(active.get_value(skill), available.get_value(skill)))

/datum/skills/proc/maximize_active_skills()
	for(var/skill in available.skills)
		active.set_value(skill, available.get_value(skill))

/datum/skills/proc/add_available_skillset(skillset_type)
    LAZYADD(available_skillsets, global.all_skillsets[skillset_type])
    update_available()

/datum/skills/proc/remove_available_skillset(skillset_type)
	for(var/datum/skillset/s as anything in available_skillsets)
		if(s.type == skillset_type)
			LAZYREMOVE(available_skillsets, s)
			break
	update_available()

/datum/skills/proc/transfer_skills(datum/mind/target)
	for(var/datum/skillset/s as anything in target.skills.available_skillsets)
		add_available_skillset(s)


/datum/skills/proc/choose_value(skill_name,value)
	var/datum/skill/skill = active.get_skill(skill_name)
	if (!skill || value > skill.max_value || value < skill.min_value)
		return
	if (value > available.get_value(skill_name))
		return
	if (value == get_value(skill_name))
		return
	to_chat(usr, "<span class='notice'>You changed your skill proficiency in [skill_name] from [active.get_value(skill_name)] to [value].</span>")
	active.set_value(skill_name, value)

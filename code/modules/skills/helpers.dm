/proc/is_skill_competent(mob/user, required_skills)
	for(var/datum/skill/required_skill as anything in required_skills)
		var/datum/skill/skill = all_skills[required_skill]
		if(user.mind.skills.get_value(skill.name) < skill.value)
			return FALSE
	return TRUE

/proc/apply_skill_bonus(mob/user, value, required_skills, multiplier)
	var/result = value
	for(var/datum/skill/required_skill as anything in required_skills)
		var/datum/skill/skill = all_skills[required_skill]
		result += value * multiplier * (user.mind.skills.get_value(skill.name) - skill.value)
	return result

/proc/do_skilled(mob/user, atom/target,  delay, required_skills, multiplier)
	return do_after(user, delay = apply_skill_bonus(user, delay, required_skills, multiplier), target = target)

/proc/handle_fumbling(mob/user, atom/target, delay, required_skills, message_self = "", text_target = null, check_busy = TRUE)
	if(is_skill_competent(user, required_skills))
		return TRUE
	if(check_busy && user.is_busy())
		return FALSE
	var/display_message_self = message_self
	var/used_item = target
	if(text_target)
		used_item = text_target
	if(!message_self)
		display_message_self = "<span class='notice'>You fumble around figuring out how to use the [used_item].</span>"
	to_chat(user, display_message_self)

	var/required_time = apply_skill_bonus(user, delay, required_skills, -1) //increase time for each missing level
	return do_after(user, required_time, target = target)

/proc/get_skill_rank_name(skill_type, value)
	for(var/s in subtypesof(skill_type))
		var/datum/skill/skill = all_skills[s]
		if(skill.value == value)
			return skill.rank_name

/proc/get_skill_rank_list(skill_type)
	var/result = list()
	for(var/s in subtypesof(skill_type))
		var/datum/skill/skill = all_skills[s]
		result += skill.rank_name
	return result

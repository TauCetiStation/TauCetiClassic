/proc/is_skill_competent(mob/user, required_skills)
	for(var/datum/skill/skill as anything in required_skills)
		if(user.mind.skills.get_value(initial(skill.name)) < initial(skill.value))
			return FALSE
	return TRUE

/proc/apply_skill_bonus(mob/user, value, required_skills, penalty = 0.5, bonus = 0.4)
	var/result = value
	for(var/datum/skill/skill as anything in required_skills)
		var/skill_name = initial(skill.name)
		var/skill_value = initial(skill.value)
		if(user.mind.skills.get_value(skill_name) < skill_value)
			result += value * penalty * (skill_value - user.mind.skills.get_value(skill_name))
		if(user.mind.skills.get_value(skill_name) > skill_value)
			result -= value * bonus * (user.mind.skills.get_value(skill_name) -skill_value)
	return result

/proc/do_skilled(mob/user, atom/target,  delay, required_skills, penalty = 0.5, bonus = 0.4)
	return do_after(user, delay = apply_skill_bonus(user, delay, required_skills, penalty, bonus), target = target)

/proc/handle_fumbling(mob/user, atom/target, delay, required_skills, time_bonus = SKILL_TASK_TRIVIAL, message_self = "", text_target = null)
	if(is_skill_competent(user, required_skills))
		return TRUE
	var/display_message_self = message_self
	var/used_item = target
	if(text_target)
		used_item = text_target
	if(!message_self)
		display_message_self = "<span class='notice'>You fumble around figuring out how to use the [used_item].</span>"
	to_chat(user, display_message_self)

	var/required_time = apply_skill_bonus(user, time_bonus, required_skills, 1, 0)
	return do_after(user, required_time, target = target)

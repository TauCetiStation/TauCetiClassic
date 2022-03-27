/proc/is_skill_competent(mob/user, required_skills)
	for(var/datum/skill/required_skill as anything in required_skills)
		var/datum/skill/skill = all_skills[required_skill]
		if(user.mind.skills.get_value(skill.name) < skill.value)
			return FALSE
	return TRUE

/proc/apply_skill_bonus(mob/user, value, required_skills, penalty = 0.5, bonus = 0.4)
	var/result = value
	for(var/datum/skill/required_skill as anything in required_skills)
		var/datum/skill/skill = all_skills[required_skill]
		if(user.mind.skills.get_value(skill.name) < skill.value)
			result += value * penalty * (skill.value - user.mind.skills.get_value(skill.name))
		if(user.mind.skills.get_value(skill.name) > skill.value)
			result -= value * bonus * (user.mind.skills.get_value(skill.name) - skill.value)
	return result

/proc/do_skilled(mob/user, atom/target,  delay, required_skills, penalty = 0.5, bonus = 0.4)
	if(user.is_busy())
		return FALSE
	return do_after(user, delay = apply_skill_bonus(user, delay, required_skills, penalty, bonus), target = target)

/proc/handle_fumbling(mob/user, atom/target, delay, required_skills, time_bonus = SKILL_TASK_TRIVIAL, message_self = "", text_target = null)
	if(is_skill_competent(user, required_skills))
		return TRUE
	if(user.is_busy())
		return FALSE
	var/display_message_self = message_self
	var/used_item = target
	if(text_target)
		used_item = text_target
	if(!message_self)
		display_message_self = "<span class='notice'>You fumble around figuring out how to use the [used_item].</span>"
	to_chat(user, display_message_self)

	var/required_time = apply_skill_bonus(user, time_bonus, required_skills, 1, 0)
	return do_after(user, required_time, target = target)

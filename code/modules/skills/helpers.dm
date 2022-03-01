/proc/get_skill_absolute_minimum(skill)
	if(isnull(SKILL_BOUNDS[skill]))
		return 0
	return SKILL_BOUNDS[skill][1]

/proc/get_skill_absolute_maximum(skill)
	if(isnull(SKILL_BOUNDS[skill]))
		return 0
	return SKILL_BOUNDS[skill][2]

/proc/is_skill_competent(mob/user, required_skills)
	for(var/skill in required_skills)
		if(user.mind.skills.get_value(skill) < required_skills[skill])
			return FALSE
	return TRUE

/proc/apply_skill_bonus(mob/user, value, required_skills, penalty = 0.5, bonus = 0.4)
	var/result = value
	for(var/skill in required_skills)
		if(user.mind.skills.get_value(skill) < required_skills[skill])
			result += value * penalty * (required_skills[skill] - user.mind.skills.get_value(skill))
		if(user.mind.skills.get_value(skill) > required_skills[skill])
			result -= value * bonus * (user.mind.skills.get_value(skill) - required_skills[skill])
	return result

/proc/do_skilled(mob/user, atom/target,  delay, required_skills, penalty = 0.5, bonus = 0.4)
	return do_after(user, delay = apply_skill_bonus(user, delay, required_skills, penalty, bonus), target = target)

/proc/handle_fumbling(mob/user, atom/target, delay, required_skill, required_proficiency, time_bonus = SKILL_TASK_TRIVIAL, message_self = "", message_others = "", text_target = null)
	if(is_skill_competent(user, required_skill, required_proficiency))
		return TRUE
	var/display_message_self = message_self
	var/used_item = target
	if(text_target)
		used_item = text_target
	if(!message_self)
		display_message_self = "<span class='notice'>You fumble around figuring out how to use the [used_item].</span>"
	to_chat(user, display_message_self)

	var/required_time = max(time_bonus, delay - time_bonus * user.mind.skills.get_value(required_skill))
	return do_after(user, required_time, target = target)

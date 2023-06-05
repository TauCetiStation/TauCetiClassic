/proc/is_skill_competent(mob/user, required_skills)
	if(isobserver(user))
		return TRUE

	for(var/datum/skill/required_skill as anything in required_skills)
		var/value_with_helpers = get_skill_with_assistance(user, required_skill)
		if(value_with_helpers < required_skills[required_skill])
			return FALSE

	return TRUE

/proc/apply_skill_bonus(mob/user, value, required_skills, multiplier)
	var/result = value
	for(var/datum/skill/required_skill as anything in required_skills)
		var/value_with_helpers = get_skill_with_assistance(user, required_skill)
		result += value * multiplier * (value_with_helpers - required_skills[required_skill])

	return result

/proc/do_skilled(mob/user, atom/target,  delay, required_skills, multiplier, datum/callback/extra_checks=null)
	return do_after(user, delay = apply_skill_bonus(user, delay, required_skills, multiplier), target = target, extra_checks = extra_checks)

/proc/handle_fumbling(mob/user, atom/target, delay, required_skills, message_self = "", text_target = null, check_busy = TRUE, can_move = FALSE)
	if(is_skill_competent(user, required_skills))
		return TRUE
	if(check_busy && user.is_busy())
		return FALSE

	var/display_message_self = message_self
	var/used_item = target
	if(text_target)
		used_item = text_target

	var/required_time = apply_skill_bonus(user, delay, required_skills, -1) //increase time for each missing level
	if(!message_self)
		display_message_self = "<span class='notice'>You fumble around figuring out how to use the [used_item].</span>"
	if(required_time > 0)
		to_chat(user, display_message_self)

	if(prob(80))
		user.emote("hmm")
	return do_after(user, required_time, target = target, can_move = can_move)

/proc/get_skill_with_assistance(mob/living/user, datum/skill/skill)
	var/datum/skills/S = user.get_skills()
	if(!S)
		return 0

	var/own_skill_value = S.get_value(skill)
	if(!user.helpers_skillsets || user.helpers_skillsets.len == 0)
		return own_skill_value

	var/help = 0
	var/command = 0
	for(var/datum/skillset/skillset in user.helpers_skillsets)
		command = max(command, skillset.get_command_modifier())
		help += skillset.get_help_additive(skill)

	return min(own_skill_value * command + help, SKILL_LEVEL_MAX)

/mob/living/proc/get_skills()
	if(!mind)
		return null
	return mind.skills

/datum/skillset
	var/name
	var/list/skills
	var/list/initial_skills

/datum/skillset/New()
	for(var/datum/skill/s as anything in initial_skills)
		var/datum/skill/original = all_skills[s]
		LAZYSET(skills, original.name, all_skills[s])
	for(var/datum/skill/skill as anything in default_skills_list)
		var/datum/skill/default = all_skills[skill]
		if(!(default.name in skills))
			LAZYSET(skills, default.name, default)

/datum/skillset/proc/merge(datum/skillset/other_skillset)
	for(var/skill in skills)
		var/new_value = max(other_skillset.get_value(skill), get_value(skill))
		set_value(skill, new_value)

/datum/skillset/proc/get_value(skill)
	var/datum/skill/s = get_skill(skill)
	return s.value

/datum/skillset/proc/set_value(skill, value)
	var/datum/skill/s = get_skill(skill)
	s.value = value

/datum/skillset/proc/get_skill(skill)
	return skills[skill]

/datum/skillset/proc/copy_skills()
	var/result = list()
	for(var/skill_name in skills)
		var/datum/skill/original = get_skill(skill_name)
		var/datum/skill/skill_copy = new original.type
		result[skill_name] = skill_copy
	return result

/datum/skillset/proc/get_command_modifier()
	var/datum/skill/command = get_skill(SKILL_COMMAND)
	return 1 + command.value/command.max_value

/datum/skillset/proc/get_help_additive(skill_name)
	var/datum/skill/skill = get_skill(skill_name)
	if (skill.value == skill.min_value)
		return skill.value + 0.5
	if (skill.value == skill.max_value)
		return skill.value - 1
	return skill.value

/mob/living/var/list/helpers_skillsets = list()
/mob/living/var/last_help_request = 0

/mob/living/proc/request_help()
	if(!mind)
		return
	last_help_request = world.time

/mob/living/proc/help_other(mob/living/target)
	if(!mind)
		return
	if(!target.last_help_request || (world.time - target.last_help_request > 5 SECONDS))
		return

	var/t_him = "it"
	if (target.gender == MALE)
		t_him = "him"
	else if (target.gender == FEMALE)
		t_him = "her"

	if(target.a_intent == INTENT_HARM)
		visible_message("<span class='notice'>[target] pranks \the [src].</span>", "<span class='notice'>You tried to help \the [target], but he rejects your help and pranks you instead!</span>")
		to_chat(target, "<span class='notice'>You prank \the [src]!</span>")
		apply_effects(1,1)
		return

	visible_message("<span class='notice'>[src] puts his hand on \the [target]'s' shoulder, assisting [t_him].</span>", "<span class='notice'>You put your hand on \the [target]'s' shoulder, assisting [t_him]. You need to stand still while doing this.</span>")
	while(do_mob(src, target, SKILL_TASK_FORMIDABLE))
		if(!(mind.skills.active in target.helpers_skillsets))
			target.helpers_skillsets += mind.skills.active

	target.helpers_skillsets -= mind.skills.active
	visible_message("<span class='notice'>[src] removes his hand from \the [target] shoulder.</span>", "<span class='notice'>You remove your hand from \the [target] shoulder.</span>")

/mob/living/proc/add_command_buff(mob/commander, time)
	helpers_skillsets += commander.mind.skills.active
	addtimer(CALLBACK(src, .proc/remove_command_buff, commander), time)

/mob/living/proc/remove_command_buff(mob/commander)
	helpers_skillsets -= commander.mind.skills.active

/datum/skills
	var/datum/skillset/active = new
	var/datum/skillset/available = new

	var/list/available_skillsets


/datum/skills/proc/get_value(skill)
	return active.get_value(skill)

/datum/skills/proc/get_max(skill)
	return available.get_value(skill)

/datum/skills/proc/update_available()
	var/datum/skillset/temporary = new
	if(length(available_skillsets) == 1)
		temporary = LAZYACCESS(available_skillsets, 1)
	for(var/datum/skillset/sk_set as anything in available_skillsets)
		temporary.merge(sk_set)
	available = temporary
	for(var/skill in available.skills)
		active.set_value(skill, min(active.get_value(skill), available.get_value(skill)))

/datum/skills/proc/maximize_active_skills()
	for(var/skill in available.skills)
		active.set_value(skill, get_max(skill))

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
	LAZYADD(available_skillsets, target.skills.available_skillsets)
	update_available()

/datum/skills/proc/choose_value(skill_type, value)
	if (value > SKILL_LEVEL_MAX || value < SKILL_LEVEL_MIN)
		return
	if (value > available.get_value(skill_type))
		return
	if (value == get_value(skill_type))
		return
	var/datum/skill/skill = all_skills[skill_type]
	var/prev_rank = skill.custom_ranks[active.get_value(skill_type) + 1]
	var/new_rank = skill.custom_ranks[value + 1]
	to_chat(usr, "<span class='notice'>You changed your skill proficiency in [skill] from [prev_rank] to [new_rank].</span>")
	active.set_value(skill_type, value)

/mob/living
	var/list/helpers_skillsets


/mob/living/carbon/human/verb/ask_for_help()
	set category = "IC"
	set name = "Ask for help"
	emote("help")

/mob/living/proc/help_other(mob/living/target)
	if(!mind)
		return
	if(target == src)
		return
	if(incapacitated() || crawling || is_busy() || get_active_hand() || !Adjacent(target))
		return

	if(target.a_intent == INTENT_HARM)
		visible_message("<span class='notice'>[target] pranks \the [src].</span>", "<span class='notice'>You tried to help \the [target], but [P_THEY(target.gender)] rejects your help and pranks you instead!</span>")
		to_chat(target, "<span class='notice'>You prank \the [src]!</span>")
		apply_effects(stun = 1, weaken = 1)
		return

	visible_message("<span class='notice'>[src] puts [P_THEIR(gender)] hand on \the [target]'s shoulder, assisting [P_THEM(target.gender)].</span>", "<span class='notice'>You put your hand on \the [target]'s shoulder, assisting [P_THEM(target.gender)]. You need to stand still while doing this.</span>")
	LAZYDISTINCTADD(target.helpers_skillsets,mind.skills.active)
	while(do_mob(src, target, HELP_OTHER_TIME))
		continue
	LAZYREMOVE(target.helpers_skillsets, mind.skills.active)
	visible_message("<span class='notice'>[src] removes [P_THEIR(gender)] hand from \the [target]'s shoulder.</span>", "<span class='notice'>You remove your hand from \the [target]'s shoulder.</span>")

/mob/living/proc/add_skills_buff(datum/skillset/skillset, time = -1)
	LAZYDISTINCTADD(helpers_skillsets, skillset)
	if(time != -1)
		addtimer(CALLBACK(src, .proc/remove_skills_buff, skillset), time)

/mob/living/proc/remove_skills_buff(datum/skillset/skillset)
	LAZYREMOVE(helpers_skillsets, skillset)

/mob/living/proc/add_command_buff(mob/commander, time)
	add_skills_buff(commander.mind.skills.active, time)

/datum/skills
	var/datum/skillset/active = new
	var/datum/skillset/available = new

	var/list/available_skillsets

/datum/skills/New()
	active.skills = active.copy_skills() // new instance of skills because we will change the skills in active skillset

/datum/skills/proc/get_value(skill)
	return active.get_value(skill)

/datum/skills/proc/get_max(skill)
	return available.get_value(skill)

/datum/skills/proc/update_available()
	var/datum/skillset/temporary = new
	temporary.skills = temporary.copy_skills() //we want different instance beceause of merging proc
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

/mob/living/proc/add_command_buff(mob/commander, time)
	LAZYDISTINCTADD(helpers_skillsets, commander.mind.skills.active)
	addtimer(CALLBACK(src, .proc/remove_command_buff, commander), time)

/mob/living/proc/remove_command_buff(mob/commander)
	LAZYREMOVE(helpers_skillsets, commander.mind.skills.active)

/mob
	var/list/mob/remote_hearers
	var/list/mob/remote_hearing

	var/next_telepathy_clue = 0

/mob/Destroy()
	for(var/mob/M as anything in remote_hearers)
		remove_remote_hearer(M)

	for(var/mob/M as anything in remote_hearing)
		M.remove_remote_hearer(src)

	return ..()

/mob/proc/telepathy_targetable()
	if(stat == DEAD)
		return FALSE

	var/datum/species/S = all_species[get_species()]
	if(S && S.flags[IS_SYNTHETIC])
		return FALSE

	return TRUE

/mob/living/silicon/telepathy_targetable()
	return FALSE

// todo: rewrite telepathy as native hear_say with HEAR_PASS flag and add remote_hearers to get_listening_objs()
// this code is just a mistake
// or burn all current say code and write it again
/mob/proc/telepathy_eavesdrop(atom/source, message, verb, datum/language/language = null, runechat_message)
	for(var/mob/M as anything in remote_hearers)
		M.telepathy_hear_eavesdrop(source, src, message, verb, language, runechat_message)

/mob/proc/telepathy_hear_eavesdrop(atom/source, atom/hearer, message, verb, datum/language/language = null, runechat_message)
	var/dist = get_dist(src, hearer)
	if(z != hearer.z)
		dist += 25

	if(source)
		dist += get_dist(source, hearer)

/* we should not apply stars() at this stage, because some messages are already formatted html

	var/star_chance = 0
	if(dist > CLEAR_TELEPATHY_RANGE)
		star_chance += dist

	if(remote_hearing.len > CLEAR_TELEPATHY_TARGETS)
		star_chance += remote_hearing.len * 5

	if(star_chance)
		message = stars(message, star_chance)
*/

	var/mob/M = hearer
	if(ismob(hearer))
		if(M.next_telepathy_clue < world.time && prob(CLEAR_TELEPATHY_RANGE - dist))
			to_chat(M, "<span class='warning'>You feel as if somebody is eavesdropping on you.</span>")
			M.next_telepathy_clue = world.time + 30 SECONDS


	for(var/mob/hearers in M.remote_hearers)
		to_chat(hearers, "<span class='notice'><span class='bold'>[hearer]</span> [verb]:</span> [message]")

	M.show_runechat_message(source, language, capitalize(runechat_message), null, SHOWMSG_AUDIO)

/mob/proc/add_remote_hearer(mob/hearer)
	LAZYADD(remote_hearers, hearer)
	LAZYADD(hearer.remote_hearing, src)

/mob/proc/remove_remote_hearer(mob/hearer)
	LAZYREMOVE(remote_hearers, hearer)
	LAZYREMOVE(hearer.remote_hearing, src)

/mob/proc/toggle_telepathy_hear()
	set name = "Toggle Telepathic Eavesdropping"
	set desc = "Hear anything that mob hears."
	set category = "Superpower"

	var/list/mob/targets = list()
	for(var/mob/M in hearers(7, src))
		if(!M.telepathy_targetable())
			continue
		if(M == src)
			continue
		if(M in remote_hearing)
			continue
		targets += M

	if(length(remote_hearing))
		for(var/mob/M in remote_hearing)
			targets += M

	var/mob/target = tgui_input_list(usr, "Who do you want to telepathically link up with?", "Choose wisely", targets)

	if(isnull(target))
		return

	if(incapacitated())
		return

	if(!target?.telepathy_targetable())
		to_chat(src, "<span class='notice'>They don't have a mind to eavesdrop on.</span>")
		return

	if(src in target?.remote_hearers)
		target.remove_remote_hearer(src)
		to_chat(src, "<span class='notice'>You stop telepathically eavesdropping on [target].</span>")

	else if(length(remote_hearing) < CLEAR_TELEPATHY_TARGETS)
		target.add_remote_hearer(src)
		to_chat(src, "<span class='notice'>You start telepathically eavesdropping on [target].</span>")

	return target

/mob/proc/telepathy_say()
	set name = "Project Mind"
	set desc = "Make them hear what you desire."
	set category = "Superpower"

	if(typing)
		return

	if(incapacitated())
		return

	if(!remote_hearing)
		nearby_telepathy_say()
	else
		multi_telepathy_say()

/mob/proc/telepathy_hear(atom/source, msg)
	var/dist = get_dist(src, source)
	if(z != source.z)
		dist += 25

	var/star_chance = 0
	if(dist > CLEAR_TELEPATHY_RANGE)
		star_chance += dist

	if(star_chance)
		msg = stars(msg, star_chance)

	var/mob/M = source
	if(ismob(M) && (REMOTE_TALK in M.mutations))
		to_chat(src, "<span class='notice'>You hear <b>[M.real_name]'s voice</b>:</span> [msg]")
	else
		to_chat(src, "<span class='notice'>You hear a voice that seems to echo around the room:</span> [msg]")

	telepathy_eavesdrop(source, msg, "has heard a voice speak", null, msg)

/mob/proc/multi_telepathy_say()
	var/list/mob/targets = list()
	var/list/client/bubble_recipients = list(src.client)
	for(var/mob/M in remote_hearing)
		if(!M.telepathy_targetable())
			continue
		targets += M
		if(M.client)
			bubble_recipients += M.client

	var/msg = input("What do you wish to say?", "Telepathic Message") as text|null
	if(!msg)
		return
	msg = add_period(capitalize(sanitize(trim(msg))))

	for(var/mob/M as anything in targets)
		if(QDELETED(M))
			continue
		M.telepathy_hear(src, msg)
	show_runechat_message(src, null, capitalize(msg), null, SHOWMSG_AUDIO)
	typing_buble_prepare(bubble_recipients)

/mob/proc/nearby_telepathy_say()
	var/list/client/bubble_recipients = list(src.client)
	var/mob/target = toggle_telepathy_hear()
	if(isnull(target))
		return
	if(target.client)
		bubble_recipients += target
	var/msg = input("What do you wish to say?", "Telepathic Message") as text|null
	if(!msg)
		return
	msg = add_period(capitalize(sanitize(trim(msg))))

	show_runechat_message(src, null, capitalize(msg), null, SHOWMSG_AUDIO)
	typing_buble_prepare(bubble_recipients)
	target.telepathy_hear(src, msg)

/mob/proc/typing_buble_prepare(list/bubble_recipients)
	var/image/typing_bubble = image('icons/mob/talk.dmi', src, "robot0", MOB_LAYER + 1)
	typing_bubble.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	typing_bubble.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay), typing_bubble, bubble_recipients, 3 SECONDS)

/datum/action/telepathy/project_mind
	name = "Project Mind"
	action_type = AB_GENERIC
	button_icon_state = "genetic_project"

/datum/action/telepathy/project_mind/Trigger()
	var/mob/living/carbon/C = owner
	C.telepathy_say()

/datum/action/telepathy/toggle_telepathy_hear
	name = "Toggle Telepathy Hear"
	action_type = AB_GENERIC
	button_icon_state = "genetic_empath"

/datum/action/telepathy/toggle_telepathy_hear/Trigger()
	var/mob/living/carbon/C = owner
	C.toggle_telepathy_hear()

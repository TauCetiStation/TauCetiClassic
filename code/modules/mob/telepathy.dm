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

/mob/proc/telepathy_eavesdrop(atom/source, message, verb, datum/language/language = null)
	for(var/mob/M as anything in remote_hearers)
		M.telepathy_hear_eavesdrop(source, src, message, verb, language)

/mob/proc/telepathy_hear_eavesdrop(atom/source, atom/hearer, message, verb, datum/language/language)
	var/dist = get_dist(src, hearer)
	if(z != hearer.z)
		dist += 25

	if(source)
		dist += get_dist(source, hearer)

	var/star_chance = 0
	if(dist > CLEAR_TELEPATHY_RANGE)
		star_chance += dist

	if(remote_hearing.len > CLEAR_TELEPATHY_TARGETS)
		star_chance += remote_hearing.len * 5

	if(star_chance)
		message = stars(message, star_chance)

	var/mob/M = hearer
	if(ismob(hearer))
		if(M.remote_hearers.len > CLEAR_TELEPATHY_LISTENERS)
			star_chance += M.remote_hearers.len * 10

		if(M.next_telepathy_clue < world.time && prob(CLEAR_TELEPATHY_RANGE - dist))
			to_chat(M, "<span class='warning'>You feel as if somebody is eavesdropping on you.</span>")
			M.next_telepathy_clue = world.time + 30 SECONDS

	to_chat(src, "<span class='notice'><span class='bold'>[hearer]</span> [verb]:</span> [message]")

	telepathy_eavesdrop(source, message, verb, language)

/mob/proc/add_remote_hearer(mob/hearer)
	LAZYADD(remote_hearers, hearer)
	LAZYADD(hearer.remote_hearing, src)

/mob/proc/remove_remote_hearer(mob/hearer)
	LAZYREMOVE(remote_hearers, hearer)
	LAZYREMOVE(hearer.remote_hearing, src)

/mob/proc/toggle_telepathy_hear(mob/M)
	set name = "Toggle Telepathic Eavesdropping"
	set desc = "Hear anything that mob hears."
	set category = "Telepathy"

	if(incapacitated())
		return

	if(M == src)
		to_chat(src, "<span class='notice'>No, that would be extremely stupid.</span>")
		return

	if(!M.telepathy_targetable())
		to_chat(src, "<span class='notice'>They don't have a mind to eavesdrop on.</span>")
		return

	if(src in M.remote_hearers)
		M.remove_remote_hearer(src)
		to_chat(src, "<span class='notice'>You stop telepathically eavesdropping on [M].</span>")

	else if(length(remote_hearing) < CLEAR_TELEPATHY_TARGETS)
		M.add_remote_hearer(src)
		to_chat(src, "<span class='notice'>You start telepathically eavesdropping on [M].</span>")

/mob/proc/telepathy_say()
	set name = "Project Mind"
	set desc = "Make them hear what you desire."
	set category = "Telepathy"

	if(typing)
		return

	if(incapacitated())
		return

	var/list/mob/targets = list()
	var/list/client/bubble_recipients = list()
	for(var/mob/M in remote_hearing)
		if(!M.telepathy_targetable())
			continue
		if(!M.client)
			continue
		targets += M
		bubble_recipients += M.client

	var/image/typing_bubble = image('icons/mob/talk.dmi', src, "tele_typing", MOB_LAYER + 1)
	typing_bubble.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	for(var/client/C as anything in bubble_recipients)
		C.images += typing_bubble

	var/msg = input("What do you wish to say?", "Telepathic Message") as text|null

	for(var/client/C as anything in bubble_recipients)
		if(QDELETED(C))
			continue
		C.images -= typing_bubble

	if(!msg)
		return

	msg = add_period(capitalize(sanitize(trim(msg))))

	for(var/mob/M as anything in targets)
		if(QDELETED(M))
			continue
		M.telepathy_hear(src, msg)

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

	if(ismob(source))
		to_chat(M, "<span class='notice'>You project your mind into <b>[src]</b>:</span> [msg]")

	telepathy_eavesdrop(source, msg, "has heard a voice speak")

SUBSYSTEM_DEF(qualities)
	name = "Qualities"
	init_order = SS_INIT_QUALITIES
	flags = SS_NO_FIRE

	// name = instance
	var/list/datum/quality/qualities_by_name = list()
	// type = instance
	var/list/datum/quality/qualities_by_type = list()
	// category == list of types
	var/list/datum/quality/qualities_by_pool = list()

	// Shitspawn-oriented design. Gives the ability to force the same quality on everyone.
	var/forced_quality_type

	// The chances of pools of qualities to be given to the player.
	// Basically, every third round is a challenge.
	// Balance between NEGATIVEISH and QUIRKEISH should be around 1 to 1, but since (so 40-30-30 overall)
	// there's not many QUIRKEISH qualities at all, they are given lower priority.
	var/list/pool_distribution = list(
		QUALITY_POOL_POSITIVEISH = 50,
		QUALITY_POOL_QUIRKIEISH = 20,
		QUALITY_POOL_NEGATIVEISH = 30,
	)

	// ckey = quality_type
	var/list/datum/quality/registered_clients = list()

/datum/controller/subsystem/qualities/Initialize(start_timeofday)
	populate_lists()
	return ..()

/datum/controller/subsystem/qualities/proc/populate_lists()
	for(var/quality_type in subtypesof(/datum/quality))
		var/datum/quality/Q = new quality_type
		if(!Q.name)
			qdel(Q)
			continue

		qualities_by_name[Q.name] = Q
		qualities_by_type[Q.type] = Q

		for(var/pool in Q.pools)
			LAZYADD(qualities_by_pool[pool], Q)

/datum/controller/subsystem/qualities/proc/announce_quality(client/C, datum/quality/quality)
	var/hide = prob(quality.hidden_chance)
	var/q_desc = hide ? "▉▉▉▉▉▉▉▉" : quality.desc
	var/q_requirement = hide ? "▉▉▉▉▉▉▉▉" : quality.requirement

	var/quality_description = \
	   "<font color='green'><b>Вы особенный.</b></font><br>\
		<font color='green'><b>Ваша особенность:</b> [q_desc]</font><br>\
		<font color='green'><b>Требования:</b> [q_requirement]</font>"

	to_chat(C.mob, quality_description)

/datum/controller/subsystem/qualities/proc/roll_pool(client/C)
	return pickweight(pool_distribution)

/datum/controller/subsystem/qualities/proc/roll_quality(client/C)
	var/quality_pool = roll_pool(C)

	var/datum/quality/selected_quality
	var/list/pool_qualities = qualities_by_pool[quality_pool]
	var/list/possible_qualities = pool_qualities.Copy()

	while(possible_qualities.len)
		var/datum/quality/Q = pick(possible_qualities)

		possible_qualities -= Q

		if(Q.max_amount >= 0 && Q.amount >= Q.max_amount)
			continue
		if(!Q.satisfies_availability(C))
			continue

		selected_quality = Q
		break

	if(!selected_quality)
		if(C.mob)
			to_chat(C.mob, "<span class='warning'>В бухгалтерии всё перепутали, и мы, к сожалению не смогли найти твою особенность. В награду за терпение, за то что ты такой крутой, держи очки.</span>")
		selected_quality = qualities_by_type[/datum/quality/positiveish/sunglasses]

	return selected_quality

/datum/controller/subsystem/qualities/proc/set_quality(client/C, datum/quality/Q)
	Q.amount += 1
	registered_clients[C.ckey] = Q.type
	announce_quality(C, Q)
	C.prefs.selected_quality_name = Q.name
	C << output(TRUE, "lobbybrowser:set_quality")

/datum/controller/subsystem/qualities/proc/force_register_client(client/C, datum/quality/Q)
	if(!initialized)
		return

	if(!C.prefs)
		return

	if(C.mob)
		to_chat(C.mob, "<span class='warning'>Похоже кто-то сделал этот выбор за тебя!</span>")

	set_quality(C, Q)

/datum/controller/subsystem/qualities/proc/register_client(client/C)
	if(!initialized)
		if(C.mob)
			to_chat(C.mob, "<span class='warning'>Пожалуйста, подождите загрузки всех систем.</span>")
		return

	if(!SSjob)
		if(C.mob)
			to_chat(C.mob, "<span class='warning'>Пожалуйста, подождите загрузки всех систем.</span>")
		return

	if(!C.prefs)
		if(C.mob)
			to_chat(C.mob, "<span class='warning'>Пожалуйста, подождите загрузки всех систем.</span>")
		return

	var/datum/quality/Q
	if(forced_quality_type)
		Q = qualities_by_type[forced_quality_type]
	else
		Q = roll_quality(C)

	// Only "legitimately" possible if `forced_quality_type` is invalid.
	if(!Q)
		CRASH("BADMIN ALERT! QUALITY REGISTERED IS NULL. HAS SOMEONE PLAYED WITH SSqualities.forced_quality_type?")

	set_quality(C, Q)

/datum/controller/subsystem/qualities/proc/give_all_qualities()
	for(var/mob/living/carbon/human/player in player_list)
		SSqualities.give_quality(player, FALSE)

/datum/controller/subsystem/qualities/proc/give_quality(mob/living/carbon/human/H, latespawn)
	if(!H.client.prefs.selected_quality_name)
		return

	var/datum/quality/quality = qualities_by_type[registered_clients[H.client.ckey]]
	if(quality.satisfies_requirements(H, latespawn))
		quality.add_effect(H, latespawn)

/datum/controller/subsystem/qualities/proc/force_give_quality(mob/living/carbon/human/H, datum/quality/Q, mob/admin)
	if(Q.satisfies_requirements(H, FALSE))
		announce_quality(H.client, Q)
		Q.add_effect(H, FALSE)
	else
		to_chat(admin, "<span class='warning'>[H] не соответствует требованиям особенности.</span>")

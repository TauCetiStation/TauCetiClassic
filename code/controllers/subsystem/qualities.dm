SUBSYSTEM_DEF(qualities)
	name = "Qualities"
	init_order = SS_INIT_QUALITIES
	flags = SS_NO_FIRE

	// name = instance
	var/list/datum/quality/by_name = list()
	// type = instance
	var/list/datum/quality/by_type = list()
	// category == list of types
	var/list/datum/quality/by_pool = list()

	// Shitspawn-oriented design. Gives the ability to force the same quality on everyone.
	var/forced_quality_type

	// The chances of pools of qualities to be given to the player.
	// Basically, every third round is a challenge.
	// Balance between NEGATIVEISH and QUIRKEISH should be around 1 to 1, but since (so 40-30-30 overall)
	// there's not many QUIRKEISH qualities at all, they are given lower priority.
	var/list/pool_distribution = list(
		QUALITY_POOL_POSITIVEISH = 50,
		QUALITY_POOL_QUIRKEISH = 20,
		QUALITY_POOL_NEGATIVEISH = 30,
	)

	// ckey = quality_type
	var/list/datum/quality/registered_clients = list()

/datum/controller/subsystem/qualities/Initialize(start_timeofday)
	populate_lists()
	return ..()

/datum/controller/subsystem/qualities/proc/populate_lists()
	for(var/quality_type in subtypesof(/datum/quality))
		var/datum/quality/quality = new quality_type
		by_name[name] = quality
		by_type[quality_type] = quality

		for(var/pool in quality.pools)
			LAZYADD(by_pool[pool], quality)

/datum/controller/subsystem/qualities/proc/roll_pool(client/C)
	return pickweight(pool_distribution)

/datum/controller/subsystem/qualities/proc/roll_quality(client/C)
	var/quality_pool = roll_pool(C)

	var/datum/quality/selected_quality
	var/list/possible_qualities = by_pool[quality_pool].Copy()

	while(possible_qualities.len)
		var/datum/quality/Q = pick(possible_qualities)

		possible_qualities -= Q

		if(!Q.satisfies_availability(C))
			continue

		selected_quality = Q
		break

	if(!selected_quality)
		if(C.mob)
			to_chat(C.mob, "<span class='warning'>В бухгалтерии всё перепутали, и мы, к сожалению не смогли найти твою особенность. В награду за терпение, за то что ты такой крутой, держи очки.</span>")
		selected_quality = by_type[/datum/quality/positiveish/sunglasses]

	return selected_quality


	if(C.mob && selected_quality)
		var/mob/M = C.mob
		var/hide = prob(selected_quality.hidden_chance)
		var/q_desc = hide ? "▉▉▉▉▉▉▉▉" : selected_quality.desc
		var/q_requirement = hide ? "▉▉▉▉▉▉▉▉" : selected_quality.requirement

		to_chat(M, "<font color='green'><b>Вы особенный.</b></font>")
		to_chat(M, "<font color='green'><b>Ваша особенность:</b> [q_desc]</font>")
		to_chat(M, "<font color='green'><b>Требования:</b> [q_requirement]</font>")

		C.prefs.have_quality = TRUE
		C << output(TRUE, "lobbybrowser:set_quality")

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

	var/datum/quality/Q = roll_quality(C)
	registered_clients[C.ckey] = Q.type


/datum/controller/subsystem/qualities/proc/give_all_qualities()
	for(var/mob/living/carbon/human/player in player_list)
		SSqualities.give_quality(player, FALSE)

/datum/controller/subsystem/qualities/proc/give_quality(mob/living/carbon/human/H, latespawn)
	if(!H.client.prefs.have_quality)
		return

	var/datum/quality/quality = by_type[registered_clients[H.client.ckey]]
	if(quality.satisfies_requirements(H, latespawn))
		quality.add_effect(H, latespawn)

/datum/controller/subsystem/qualities/proc/force_give_quality(mob/living/carbon/human/H, quality_type, mob/admin)
	var/datum/quality/quality = by_type[quality_type]
	if(quality.satisfies_requirements(H, FALSE))
		quality.add_effect(H, FALSE)
	else
		to_chat(admin, "<span class='warning'>[H] не соответствует требованиям особенности.</span>")

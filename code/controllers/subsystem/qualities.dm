SUBSYSTEM_DEF(qualities)
	name = "Qualities"
	init_order = SS_INIT_QUALITIES
	flags = SS_NO_FIRE

	// type = instance
	var/list/datum/quality/qualities_pool = list()
	// ckey = quality_type
	var/list/datum/quality/registered_clients = list()

/datum/controller/subsystem/qualities/Initialize(start_timeofday)
	create_pool()
	return ..()

/datum/controller/subsystem/qualities/proc/create_pool()
	for(var/quality_type in subtypesof(/datum/quality))
		var/datum/quality/quality = new quality_type
		qualities_pool[quality_type] = quality

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

	var/list/possible_qualities = qualities_pool.Copy()
	var/datum/quality/selected_quality

	while(possible_qualities.len)
		var/quality_type = pick(qualities_pool)
		var/datum/quality/quality = qualities_pool[quality_type]

		possible_qualities -= quality_type

		if(!quality.satisfies_availability(C))
			continue

		selected_quality = quality
		break

	if(!selected_quality)
		return

	registered_clients[C.ckey] = selected_quality.type

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

/datum/controller/subsystem/qualities/proc/give_all_qualities()
	for(var/mob/living/carbon/human/player in player_list)
		SSqualities.give_quality(player, FALSE)

/datum/controller/subsystem/qualities/proc/give_quality(mob/living/carbon/human/H, latespawn)
	if(!H.client.prefs.have_quality)
		return

	var/datum/quality/quality = qualities_pool[registered_clients[H.client.ckey]]
	if(quality.satisfies_requirements(H, latespawn))
		quality.add_effect(H, latespawn)

/datum/controller/subsystem/qualities/proc/force_give_quality(mob/living/carbon/human/H, quality_type, mob/admin)
	var/datum/quality/quality = qualities_pool[quality_type]
	if(quality.satisfies_requirements(H, FALSE))
		quality.add_effect(H, FALSE)
	else
		to_chat(admin, "<span class='warning'>[H] не соответствует требованиям особенности.</span>")

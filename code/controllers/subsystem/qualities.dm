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

/datum/controller/subsystem/qualities/proc/registration_client(client/C)
	if(!initialized)
		if(C.mob)
			to_chat(C.mob, "<span class='warning'>Пожалуйста, подождите загрузки всех систем.</span>")
		return

	var/datum/quality/quality
	if(registered_clients[C.ckey])
		quality = qualities_pool[registered_clients[C.ckey]]
	else
		var/quality_type = pick(qualities_pool)
		registered_clients[C.ckey] = quality_type
		quality = qualities_pool[quality_type]

	if(C.mob && quality)
		var/mob/M = C.mob
		to_chat(M, "<font color='green'><b>Вы особенный.</b></font>")
		to_chat(M, "<font color='green'><b>Ваша особенность:</b> [quality.desc]</font>")
		to_chat(M, "<font color='green'><b>Ограничение:</b> [quality.restriction]</font>")

/datum/controller/subsystem/qualities/proc/give_quality(mob/living/carbon/human/H)
	if(!H.client.prefs.have_quality)
		return

	var/datum/quality/quality = qualities_pool[registered_clients[H.client.ckey]]
	if(quality.restriction_check(H))
		quality.add_effect(H)

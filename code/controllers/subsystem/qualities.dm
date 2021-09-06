SUBSYSTEM_DEF(qualities)
	name = "Qualities"
	init_order = SS_INIT_QUALITIES
	flags = SS_NO_FIRE

	// type = instance
	var/list/datum/quality/qualities_pool

/datum/controller/subsystem/qualities/Initialize(start_timeofday)
	create_pool()
	return ..()

/datum/controller/subsystem/qualities/proc/create_pool()
	qualities_pool = list()
	for(var/quality_type in subtypesof(/datum/quality))
		var/datum/quality/quality = new quality_type
		qualities_pool[quality_type] = quality

/datum/controller/subsystem/qualities/proc/give_quality(mob/living/carbon/human/H)
	if(!H.client.prefs.have_quality)
		return

	var/datum/quality/quality = qualities_pool[pick(qualities_pool)]
	if(quality.restriction_check(H))
		quality.add_effect(H)

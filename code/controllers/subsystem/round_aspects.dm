#define CHANCE_OF_NO_ASPECT 80
SUBSYSTEM_DEF(round_aspects)
	name = "Round Aspects"
	init_order = SS_INIT_ASPECTS
	flags = SS_NO_FIRE

	var/datum/round_aspect/aspect

	var/aspect_name

	var/list/datum/round_aspect/possible_aspect = list()


/datum/controller/subsystem/round_aspects/Initialize(start_timeofday)
	populate_lists_and_pick_aspect()
	if(aspect_name)
		announce_aspect()
		aspect.on_start()
	return ..()

/datum/controller/subsystem/round_aspects/proc/populate_lists_and_pick_aspect()
	if(prob(CHANCE_OF_NO_ASPECT))
		return
	for(var/aspect_type in subtypesof(/datum/round_aspect))
		var/datum/round_aspect/RS = new aspect_type
		if(!RS.name)
			qdel(RS)
			continue
		LAZYADD(possible_aspect, RS)
	aspect = pick(possible_aspect)
	aspect_name = aspect.name

/datum/controller/subsystem/round_aspects/proc/announce_aspect()
	message_admins("Round Aspect: [aspect_name]. [aspect.desc]")
	if(aspect.OOC_init_announcement)
		global_ooc_info("[SSround_aspects.aspect.OOC_init_announcement]")


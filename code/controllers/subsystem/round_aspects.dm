#define CHANCE_OF_NO_ASPECT 70
SUBSYSTEM_DEF(round_aspects)
	name = "Round Aspects"
	init_order = SS_INIT_ASPECTS
	flags = SS_NO_FIRE

	var/datum/round_aspect/aspect

	var/aspect_name

	var/list/datum/round_aspect/possible_aspect = list()


/datum/controller/subsystem/round_aspects/Initialize(timeofday)
	populate_lists_and_pick_aspect()
	if(aspect_name)
		aspect.after_init()
		global_announce_aspect()
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
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(after_start))

/datum/controller/subsystem/round_aspects/proc/global_announce_aspect()
	message_admins("Round Aspect: [aspect_name]. [aspect.desc]")
	if(aspect.OOC_lobby_announcement)
		global_ooc_info("[SSround_aspects.aspect.OOC_lobby_announcement]")

/datum/controller/subsystem/round_aspects/proc/local_announce_aspect(client)
	if(aspect_name && aspect.OOC_lobby_announcement)
		to_chat(client,"[SSround_aspects.aspect.OOC_lobby_announcement]")

/datum/controller/subsystem/round_aspects/proc/after_start()
	SIGNAL_HANDLER
	aspect.after_start()
	UnregisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING)

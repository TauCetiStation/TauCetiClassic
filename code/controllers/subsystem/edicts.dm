// Drives the edicts framework (see code/modules/edicts/_edicts.dm). Discovers every /datum/edict
// subtype once, then forwards the ticker's round-start / round-end signals to each of them, so the
// per-edict lifecycle code can live entirely inside its own module instead of being wired into the
// ticker by hand.
SUBSYSTEM_DEF(edicts)
	name = "Edicts"
	flags = SS_NO_FIRE

	// EDICT_* key -> /datum/edict instance.
	var/list/edicts = list()

/datum/controller/subsystem/edicts/Initialize(timeofday)
	for(var/etype in subtypesof(/datum/edict))
		var/datum/edict/E = new etype
		if(!E.name)
			qdel(E)
			continue
		edicts[E.name] = E
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_round_start))
	RegisterSignal(SSticker, COMSIG_TICKER_DECLARE_COMPLETION, PROC_REF(on_round_end))
	return ..()

/datum/controller/subsystem/edicts/proc/on_round_start()
	SIGNAL_HANDLER
	for(var/key in edicts)
		var/datum/edict/E = edicts[key]
		if(E.blocked_on_map())
			continue
		E.on_round_start()

/datum/controller/subsystem/edicts/proc/on_round_end()
	SIGNAL_HANDLER
	for(var/key in edicts)
		var/datum/edict/E = edicts[key]
		if(E.blocked_on_map())
			continue
		E.on_round_end()

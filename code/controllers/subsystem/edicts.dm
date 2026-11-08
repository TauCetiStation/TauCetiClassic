// Drives the edicts framework (see code/modules/edicts/_edicts.dm). Discovers every /datum/edict
// subtype once, then forwards the ticker's round-start / round-end signals to each of them, so the
// per-edict lifecycle code can live entirely inside its own module instead of being wired into the
// ticker by hand.
SUBSYSTEM_DEF(edicts)
	name = "Edicts"
	flags = SS_NO_FIRE

	// EDICT_* key -> /datum/edict instance.
	var/list/edicts = list()
	var/round_end_in_progress = FALSE
	var/round_end_failed = FALSE

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
	INVOKE_ASYNC(src, PROC_REF(process_round_start))

/datum/controller/subsystem/edicts/proc/process_round_start()
	for(var/key in edicts)
		var/datum/edict/E = edicts[key]
		if(E.blocked_on_map())
			continue
		E.on_round_start()

/datum/controller/subsystem/edicts/proc/on_round_end()
	SIGNAL_HANDLER
	round_end_in_progress = TRUE
	round_end_failed = FALSE
	INVOKE_ASYNC(src, PROC_REF(persist_round_end))

/datum/controller/subsystem/edicts/proc/persist_round_end()
	for(var/key in edicts)
		var/datum/edict/E = edicts[key]
		if(E.blocked_on_map())
			continue
		if(E.on_round_end() == FALSE)
			round_end_failed = TRUE
	if(round_end_failed)
		warning("One or more edicts failed round-end persistence.")
	round_end_in_progress = FALSE

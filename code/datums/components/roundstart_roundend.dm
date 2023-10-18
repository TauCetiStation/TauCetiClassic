// A component you put on things you want to have roundstart/roundend procs calls.
/datum/component/roundstart_roundend
	var/datum/callback/roundstart_callback
	var/datum/callback/roundend_callback
	var/datum/callback/destroyed_callback

/datum/component/roundstart_roundend/Initialize(datum/callback/roundstart_callback, datum/callback/roundend_callback, datum/callback/destroyed_callback)
	src.roundstart_callback = roundstart_callback
	src.roundend_callback = roundend_callback
	src.destroyed_callback = destroyed_callback

	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_destroyed))

	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_roundstart))
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_ENDING, PROC_REF(on_roundend))

/datum/component/roundstart_roundend/proc/on_roundstart()
	if(roundstart_callback)
		roundstart_callback.Invoke(parent)
	UnregisterSignal(parent, COMSIG_TICKER_ROUND_STARTING)

/datum/component/roundstart_roundend/proc/on_roundend()
	if(roundend_callback)
		roundend_callback.Invoke(parent)
	UnregisterSignal(parent, COMSIG_TICKER_ROUND_ENDING)

/datum/component/roundstart_roundend/proc/on_destroyed()
	if(destroyed_callback)
		destroyed_callback.Invoke(parent)
	qdel(src)

/datum/component/roundstart_roundend/Destroy()
	UnregisterSignal(parent, list(COMSIG_TICKER_ROUND_ENDING, COMSIG_TICKER_ROUND_STARTING, COMSIG_PARENT_QDELETING))

	QDEL_NULL(roundstart_callback)
	QDEL_NULL(roundend_callback)
	QDEL_NULL(destroyed_callback)

	return ..()

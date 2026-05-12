/datum/component/continuity_object
	var/save_path = ""

	var/datum/callback/saveproc
	var/datum/callback/loadproc

/datum/component/continuity_object/Initialize(datum/callback/_saveproc = null, datum/callback/_loadproc = null, special_id = "no_id")
	if(!_saveproc || !_loadproc)
		qdel(src)
		return

	if(isatom(parent))
		var/atom/A = parent
		if(A.flags_2 & NO_CONTINUITY)
			qdel(src)
			return

	saveproc = _saveproc
	loadproc = _loadproc

	save_path = replacetext("[parent.type]", "/", "_")
	save_path += "/[special_id]"

	SScontinuity.add_object(src, save_path)

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(on_destroyed))

/datum/component/continuity_object/proc/save()
	return saveproc.Invoke()

/datum/component/continuity_object/proc/load(data)
	loadproc.Invoke(data)

/datum/component/continuity_object/proc/on_destroyed()
	SScontinuity.remove_object(src, save_path)
	UnregisterSignal(parent, list(COMSIG_PARENT_QDELETING))
	QDEL_NULL(saveproc)
	QDEL_NULL(loadproc)
	qdel(src)

/datum/component/continuity_object/proc/preemptive_save(...)
	SScontinuity.add_object(saveproc.Invoke(arglist(args)), save_path)
	on_destroyed()

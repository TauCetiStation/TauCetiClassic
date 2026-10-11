/datum/component/continuity_object
	var/save_path = ""

	var/datum/callback/saveproc
	var/datum/callback/loadproc

	var/alist/fields

/datum/component/continuity_object/Initialize(datum/callback/_saveproc = null, datum/callback/_loadproc = null, file_path = null, _fields = null)
	if(SSticker && SSticker.current_state >= GAME_STATE_PLAYING)
		qdel(src)
		return

	if(!_saveproc || !_loadproc || !_fields || !file_path)
		qdel(src)
		return

	saveproc = _saveproc
	loadproc = _loadproc

	fields = _fields

	save_path = "[file_path]"

	SScontinuity.add_object(src, save_path)

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(on_destroyed))

/datum/component/continuity_object/proc/save()
	var/list/data_to_save = saveproc.Invoke()

	try
		data_to_save = sanitize_data(data_to_save)
		return data_to_save
	catch(var/exception/e)
		stack_trace("Tried saving [parent]. [e] on [e.file]:[e.line]")

/datum/component/continuity_object/proc/load(data)
	var/list/data_to_load
	if(!islist(data))
		data_to_load = list(data)
	else
		data_to_load = data

	try
		data_to_load = sanitize_data(data_to_load)
		loadproc.Invoke(data_to_load)
	catch(var/exception/e)
		stack_trace("Tried loading [parent]. [e] on [e.file]:[e.line]")

/datum/component/continuity_object/proc/on_destroyed()
	for(var/datum/primitive_field/field in fields)
		QDEL_NULL(field)

	SScontinuity.remove_object(src, save_path)
	UnregisterSignal(parent, list(COMSIG_PARENT_QDELETING, COMSIG_CONTINUITY_SAVE))
	QDEL_NULL(saveproc)
	QDEL_NULL(loadproc)
	qdel(src)

/datum/component/continuity_object/proc/sanitize_data(list/data)
	for(var/field_name in src.fields)
		if(!(field_name in data))
			throw EXCEPTION("Missing field [field_name]")

	for(var/field_name in data)
		if(!(field_name in src.fields))
			throw EXCEPTION("Invalid [field_name]")

		if(length(field_name) > 100)
			throw EXCEPTION("Field name is too long")

		var/field_data = data[field_name]

		var/datum/primitive_field/object_field = src.fields[field_name]
		if(!object_field)
			throw EXCEPTION("Missing primitive_field of: [field_name]")

		var/newdata = object_field.sanitize_field(field_data)
		data[field_name] = newdata

	return data

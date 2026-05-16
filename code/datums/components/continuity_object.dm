/datum/component/continuity_object
	var/save_path = ""

	var/datum/callback/saveproc
	var/datum/callback/loadproc

	var/alist/fields

/datum/component/continuity_object/Initialize(datum/callback/_saveproc = null, datum/callback/_loadproc = null, file_path = null, _fields = null, special_id = "no_id")
	if(!_saveproc || !_loadproc || !_fields)
		qdel(src)
		return

	if(isatom(parent))
		var/atom/A = parent
		if(A.flags_2 & NO_CONTINUITY)
			qdel(src)
			return

	saveproc = _saveproc
	loadproc = _loadproc

	fields = _fields

	if(file_path)
		save_path = "[file_path]"
	else
		save_path = replacetext("[parent.type]", "/", "_")

	save_path += "/[special_id]"

	SScontinuity.add_object(src, save_path)

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(on_destroyed))
	RegisterSignal(parent, list(COMSIG_CONTINUITY_SAVE), PROC_REF(preemptive_save))

/datum/component/continuity_object/proc/save()
	var/list/data_to_save = saveproc.Invoke()
	data_to_save = sanitize_data(data_to_save)
	return data_to_save

/datum/component/continuity_object/proc/load(data)
	var/list/data_to_load
	if(!islist(data))
		data_to_load = list(data)
	else
		data_to_load = data

	data_to_load = sanitize_data(data_to_load)
	if(isnull(data_to_load))
		stack_trace("Tried loading [parent]. JSON is invalid.")
		return

	loadproc.Invoke(data_to_load)

/datum/component/continuity_object/proc/on_destroyed()
	SScontinuity.remove_object(src, save_path)
	UnregisterSignal(parent, list(COMSIG_PARENT_QDELETING, COMSIG_CONTINUITY_SAVE))
	QDEL_NULL(saveproc)
	QDEL_NULL(loadproc)
	qdel(src)

/datum/component/continuity_object/proc/preemptive_save(...)
	SScontinuity.add_object(saveproc.Invoke(arglist(args)), save_path)
	on_destroyed()

/* --------continuity field types--------

fields = alist(...)

//string
"varname" = list("field_type" = "string", "max_length" = 999, "can_be_null" = TRUE, "in_list" = list(), "allowed_characters" = list())

//int
"varname" = list("field_type" = "int", "max_num" = 999, "min_num" = -999, "can_be_null" = TRUE)

*/

/datum/component/continuity_object/proc/sanitize_string(list/field_data, list/params)
	var/list/newdata = list()
	for(var/field in field_data)
		if(isnull(field) || length(field) == 0)
			if("can_be_null" in params)
				continue

			stack_trace("Tried saving [field] for [parent]. Is null")
			return null

		if(!istext(field))
			stack_trace("Tried saving [field] for [parent]. Not a text")
			return null

		if(!("max_length" in params))
			stack_trace("Tried saving [field] for [parent]. No max_length param")
			return null

		if((length(field) > params["max_length"]))
			stack_trace("Tried saving [field] for [parent]. Text is longer than it should be")
			return null

		if(("allowed_characters" in params))
			var/char = ""
			for(var/i = 1, i <= length(field), i += length(char))
				char = field[i]

				if(!(char in params["allowed_characters"]))
					stack_trace("Tried saving [field] for [parent]. Text contains bad characters")
					return null

		if(("in_list" in params) && !(field in params["in_list"]))
			stack_trace("Tried saving [field] for [parent]. Not an allowed string")
			return null

		newdata += sanitize(field)

	return newdata

/datum/component/continuity_object/proc/sanitize_int(list/field_data, list/params)
	for(var/field in field_data)
		if(!("can_be_null" in params) && isnull(field))
			if("can_be_null" in params)
				return field_data

			stack_trace("Tried saving [field] for [parent]. Is null")
			return null

		if(!isnum(field))
			stack_trace("Tried saving [field] for [parent]. Not a number")
			return null

		if(("max_num" in params) && (field > params["max_num"]))
			stack_trace("Tried saving [field] for [parent]. Number is bigger than it should be")
			return null

		if(("min_num" in params) && (field < params["min_num"]))
			stack_trace("Tried saving [field] for [parent]. Number is smaller than it should be")
			return null

	return field_data

/datum/component/continuity_object/proc/sanitize_data(list/data)
	for(var/field_name in data)
		if(!(field_name in src.fields))
			stack_trace("Tried saving invalid [field_name] for [parent]")
			return null

		var/field_data = data[field_name]
		if(!islist(field_data))
			field_data = list(field_data)

		switch(src.fields[field_name]["field_type"])
			if("string")
				var/newdata = sanitize_string(field_data, src.fields[field_name])
				if(isnull(newdata))
					return null

				data[field_name] = newdata

			if("int")
				var/newdata = sanitize_int(field_data, src.fields[field_name])
				if(isnull(newdata))
					return null

				data[field_name] = newdata

	return data

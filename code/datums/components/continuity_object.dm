#define RUNTIME_SENTINEL "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT"

#define RUNTIMED(proc_output) proc_output == RUNTIME_SENTINEL


/datum/component/continuity_object
	var/save_path = ""

	var/datum/callback/saveproc
	var/datum/callback/loadproc
	var/datum/callback/preemptiveproc

	var/alist/fields

/datum/component/continuity_object/Initialize(datum/callback/_saveproc = null, datum/callback/_loadproc = null, file_path = null, _fields = null, list/signals_list = null, _preemptiveproc = null)
	if(!_saveproc || !_loadproc || !_fields || !file_path)
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

	save_path = "[file_path]"

	SScontinuity.add_object(src, save_path)

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(on_destroyed))
	if(signals_list && signals_list.len)
		if(_preemptiveproc)
			preemptiveproc = _preemptiveproc
		else
			preemptiveproc = _saveproc

		RegisterSignal(parent, signals_list, PROC_REF(preemptive_save))

/datum/component/continuity_object/proc/save()
	var/list/data_to_save = saveproc.Invoke()
	data_to_save = sanitize_data(data_to_save)
	if(RUNTIMED(data_to_save))
		return

	return data_to_save

/datum/component/continuity_object/proc/load(data)
	var/list/data_to_load
	if(!islist(data))
		data_to_load = list(data)
	else
		data_to_load = data

	data_to_load = sanitize_data(data_to_load)
	if(RUNTIMED(data_to_load))
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
	var/list/arguments = args.Copy(2)
	SScontinuity.add_object(preemptiveproc.Invoke(arglist(arguments)), save_path)
	on_destroyed()

/* --------continuity field types--------

fields = alist(...)

//list
"varname" = list("field_type" = "list", "can_be_null" = TRUE, "entry_type" = "string/int", "entry_config" = list(...))

//alist
"varname" = list("field_type" = "alist", "can_be_null" = TRUE, "key_config" = list(...), "entry_type" = "string/int", "entry_config" = list(...))

//string
"varname" = list("field_type" = "string", "max_length" = 999, "can_be_null" = TRUE, "in_list" = list(), "allowed_characters" = list())

//int
"varname" = list("field_type" = "int", "max_num" = 999, "min_num" = -999, "can_be_null" = TRUE)

*/

/datum/component/continuity_object/proc/sanitize_alist(list/field, list/params)
	if(!params["entry_type"])
		stack_trace("Tried saving [field] for [parent]. No entry type.")
		return RUNTIME_SENTINEL

	if(!params["entry_config"])
		stack_trace("Tried saving [field] for [parent]. No entry config.")
		return RUNTIME_SENTINEL

	if(!params["key_config"])
		stack_trace("Tried saving [field] for [parent]. No key config.")
		return RUNTIME_SENTINEL

	if(isnull(field) || !field.len)
		if("can_be_null" in params)
			return field

		stack_trace("Tried saving [field] for [parent]. Is null")
		return RUNTIME_SENTINEL

	var/list/sanitized_list = list()
	for(var/entry_name in field)
		var/valid_name = sanitize_string(entry_name, params["key_config"])
		if(RUNTIMED(valid_name))
			return RUNTIME_SENTINEL

		var/entry = field[entry_name]
		switch(params["entry_type"])
			if("list")
				var/newdata = sanitize_list(entry, params["entry_config"])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				sanitized_list[entry_name] = newdata

			if("alist")
				var/newdata = sanitize_alist(entry, params["entry_config"])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				sanitized_list[entry_name] = newdata

			if("string")
				var/newdata = sanitize_string(entry, params["entry_config"])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				sanitized_list[entry_name] = newdata

			if("int")
				var/newdata = sanitize_int(entry, params["entry_config"])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				sanitized_list[entry_name] = newdata

	return sanitized_list

/datum/component/continuity_object/proc/sanitize_list(list/field, list/params)
	if(!params["entry_type"])
		stack_trace("Tried saving [field] for [parent]. No entry type.")
		return RUNTIME_SENTINEL

	if(!params["entry_config"])
		stack_trace("Tried saving [field] for [parent]. No entry config.")
		return RUNTIME_SENTINEL

	if(isnull(field) || !field.len)
		if("can_be_null" in params)
			return field

		stack_trace("Tried saving [field] for [parent]. Is null")
		return RUNTIME_SENTINEL

	var/list/sanitized_list = list()
	for(var/entry in field)
		switch(params["entry_type"])
			if("list")
				var/newdata = sanitize_list(entry, params["entry_config"])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				sanitized_list += list(newdata)

			if("alist")
				var/newdata = sanitize_alist(entry, params["entry_config"])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				sanitized_list += list(newdata)

			if("string")
				var/newdata = sanitize_string(entry, params["entry_config"])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				sanitized_list += list(newdata)

			if("int")
				var/newdata = sanitize_int(entry, params["entry_config"])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				sanitized_list += list(newdata)

	return sanitized_list

/datum/component/continuity_object/proc/sanitize_string(field, list/params)
	if(isnull(field) || length(field) == 0)
		if("can_be_null" in params)
			return field

		stack_trace("Tried saving [field] for [parent]. Is null")
		return RUNTIME_SENTINEL

	if(!istext(field))
		stack_trace("Tried saving [field] for [parent]. Not a text")
		return RUNTIME_SENTINEL

	if(("in_list" in params))
		if(field in params["in_list"])
			return field

		stack_trace("Tried saving [field] for [parent]. Not an allowed string")
		return RUNTIME_SENTINEL

	if(!("max_length" in params))
		stack_trace("Tried saving [field] for [parent]. No max_length param specified, but is required.")
		return RUNTIME_SENTINEL

	if((length(field) > params["max_length"]))
		stack_trace("Tried saving [field] for [parent]. Text is longer than it should be")
		return RUNTIME_SENTINEL

	if(("allowed_characters" in params))
		var/char = ""
		for(var/i = 1, i <= length(field), i += length(char))
			char = field[i]

			if(!(char in params["allowed_characters"]))
				stack_trace("Tried saving [field] for [parent]. Text contains bad characters")
				return RUNTIME_SENTINEL

	return field

/datum/component/continuity_object/proc/sanitize_int(field, list/params)
	if(isnull(field))
		if("can_be_null" in params)
			return field

		stack_trace("Tried saving [field] for [parent]. Is null")
		return RUNTIME_SENTINEL

	if(!isnum(field))
		stack_trace("Tried saving [field] for [parent]. Not a number")
		return RUNTIME_SENTINEL

	if(("max_num" in params) && (field > params["max_num"]))
		stack_trace("Tried saving [field] for [parent]. Number is bigger than it should be")
		return RUNTIME_SENTINEL

	if(("min_num" in params) && (field < params["min_num"]))
		stack_trace("Tried saving [field] for [parent]. Number is smaller than it should be")
		return RUNTIME_SENTINEL

	return field

/datum/component/continuity_object/proc/sanitize_data(list/data)
	for(var/field_name in data)
		if(!(field_name in src.fields))
			stack_trace("Tried saving invalid [field_name] for [parent]")
			return RUNTIME_SENTINEL

		if(RUNTIMED(sanitize_string(field_name, list("field_type" = "string", "max_length" = 100))))
			return RUNTIME_SENTINEL

		var/field_data = data[field_name]

		switch(src.fields[field_name]["field_type"])
			if("list")
				var/newdata = sanitize_list(field_data, src.fields[field_name])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				data[field_name] = newdata

			if("alist")
				var/newdata = sanitize_alist(field_data, src.fields[field_name])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				data[field_name] = newdata

			if("string")
				var/newdata = sanitize_string(field_data, src.fields[field_name])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				data[field_name] = newdata

			if("int")
				var/newdata = sanitize_int(field_data, src.fields[field_name])
				if(RUNTIMED(newdata))
					return RUNTIME_SENTINEL

				data[field_name] = newdata

			else
				return RUNTIME_SENTINEL

	return data

#undef RUNTIMED
#undef RUNTIME_SENTINEL

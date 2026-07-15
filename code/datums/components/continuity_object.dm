#define RUNTIME_SENTINEL "THE PROC HAS RUNTIMED WHAT ARE YOU GOING ON ABOUT"

#define RUNTIMED(proc_output) proc_output == RUNTIME_SENTINEL


/datum/component/continuity_object
	var/save_path = ""

	var/datum/callback/saveproc
	var/datum/callback/loadproc

	var/alist/fields

/datum/component/continuity_object/Initialize(datum/callback/_saveproc = null, datum/callback/_loadproc = null, file_path = null, _fields = null)
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
	for(var/datum/continuity_field/field in fields)
		QDEL_NULL(field)

	SScontinuity.remove_object(src, save_path)
	UnregisterSignal(parent, list(COMSIG_PARENT_QDELETING, COMSIG_CONTINUITY_SAVE))
	QDEL_NULL(saveproc)
	QDEL_NULL(loadproc)
	qdel(src)

/* --------continuity field types--------

fields = alist(...)

//list
"varname" = list("field_type" = "list", "can_be_null" = TRUE, "entry_config" = list(...))

//alist
"varname" = list("field_type" = "alist", "can_be_null" = TRUE, "key_config" = list(...), "entry_config" = list(...))

//string
"varname" = list("field_type" = "string", "max_length" = 999, "can_be_null" = TRUE, "in_list" = list(), "allowed_characters" = list(), "regex" = @"text")

//int
"varname" = list("field_type" = "int", "max_num" = 999, "min_num" = -999, "can_be_null" = TRUE)

//type
"varname" = list("field_type" = "type", "in_list" = list(), "can_be_null" = TRUE)

*/

/datum/continuity_field
	var/name = "blank field"

/datum/continuity_field/proc/sanitize_field()
	stack_trace("Tried creating basic continuity field")
	return RUNTIME_SENTINEL

/datum/continuity_field/listfield
	name = "list"
	var/can_be_null = FALSE
	var/datum/continuity_field/entry_config

/datum/continuity_field/listfield/New(entry_config = null, can_be_null = FALSE)
	if(!entry_config)
		stack_trace("Tried creating continuity field. No entry config")
		return

	src.entry_config = entry_config

	src.can_be_null = can_be_null

/datum/continuity_field/listfield/Destroy()
	QDEL_NULL(entry_config)

	..()

/datum/continuity_field/listfield/sanitize_field(list/field)
	if(isnull(field))
		if(can_be_null)
			return field

		stack_trace("Tried saving [field]. Is null")
		return RUNTIME_SENTINEL

	var/list/sanitized_list = list()
	for(var/entry in field)
		var/newdata = entry_config.sanitize_field(entry)
		if(RUNTIMED(newdata))
			return RUNTIME_SENTINEL

		sanitized_list += list(newdata)

	return sanitized_list


/datum/continuity_field/alistfield
	name = "alist"
	var/can_be_null = FALSE
	var/datum/continuity_field/key_config
	var/datum/continuity_field/entry_config

	var/list/key_types = list("string", "int", "type")

/datum/continuity_field/alistfield/New(key_config = null, entry_config = null, can_be_null = FALSE)
	if(!key_config)
		stack_trace("Tried creating continuity field. No key config")

	src.key_config = key_config

	if(!(src.key_config.name in key_types))
		stack_trace("Tried creating continuity field. Invalid key type")
		return RUNTIME_SENTINEL

	if(!entry_config)
		stack_trace("Tried creating continuity field. No entry config")

	src.entry_config = entry_config

	src.can_be_null = can_be_null

/datum/continuity_field/alistfield/Destroy()
	QDEL_NULL(key_config)
	QDEL_NULL(entry_config)

	..()

/datum/continuity_field/alistfield/sanitize_field(list/field)
	if(isnull(field))
		if(can_be_null)
			return field

		stack_trace("Tried saving [field]. Is null")
		return RUNTIME_SENTINEL

	var/list/sanitized_list = list()
	for(var/entry_name in field)
		var/valid_name = key_config.sanitize_field(entry_name)
		if(RUNTIMED(valid_name))
			return RUNTIME_SENTINEL

		var/entry = field[entry_name]
		var/newdata = entry_config.sanitize_field(entry)
		if(RUNTIMED(newdata))
			return RUNTIME_SENTINEL

		sanitized_list[valid_name] = newdata

	return sanitized_list


/datum/continuity_field/string
	name = "string"

	var/regex/reg
	var/list/in_list
	var/can_be_null = FALSE
	var/max_length
	var/list/allowed_characters

/datum/continuity_field/string/New(regex = null, in_list = null, can_be_null = FALSE, max_length = null, allowed_characters = null)
	if(!max_length && !(regex || in_list))
		stack_trace("Tried creating continuity field. No max_length specified, but is required")

	if(regex)
		src.reg = regex(regex)
	src.in_list = in_list

	src.can_be_null = can_be_null

	src.max_length = max_length
	src.allowed_characters = allowed_characters

/datum/continuity_field/string/sanitize_field(field)
	if(reg)
		if(reg.Find(field))
			return field

		stack_trace("Tried saving [field]. Regex failed")
		return RUNTIME_SENTINEL

	if(in_list)
		if(field in in_list)
			return field

		stack_trace("Tried saving [field]. Not an allowed string")
		return RUNTIME_SENTINEL

	if(isnull(field))
		if(can_be_null)
			return field

		stack_trace("Tried saving [field]. Is null")
		return RUNTIME_SENTINEL

	if(!istext(field))
		stack_trace("Tried saving [field]. Not a text")
		return RUNTIME_SENTINEL

	if(length(field) > max_length)
		stack_trace("Tried saving [field]. Text is longer than it should be")
		return RUNTIME_SENTINEL

	if(allowed_characters)
		var/char = ""
		for(var/i = 1, i <= length(field), i += length(char))
			char = field[i]

			if(!(char in allowed_characters))
				stack_trace("Tried saving [field]. Text contains bad characters")
				return RUNTIME_SENTINEL

	return field


/datum/continuity_field/int
	name = "int"

	var/can_be_null = FALSE
	var/max_num
	var/min_num

/datum/continuity_field/int/New(can_be_null = FALSE, max_num = null, min_num = null)
	src.max_num = max_num
	src.min_num = min_num

	src.can_be_null = can_be_null

/datum/continuity_field/int/sanitize_field(field)
	if(isnull(field))
		if(can_be_null)
			return field

		stack_trace("Tried saving [field]. Is null")
		return RUNTIME_SENTINEL

	if(!isnum(field))
		stack_trace("Tried saving [field]. Not a number")
		return RUNTIME_SENTINEL

	if(max_num && (field > max_num))
		stack_trace("Tried saving [field]. Number is bigger than it should be")
		return RUNTIME_SENTINEL

	if(min_num && (field < min_num))
		stack_trace("Tried saving [field]. Number is smaller than it should be")
		return RUNTIME_SENTINEL

	return field


/datum/continuity_field/type
	name = "type"

	var/list/in_list
	var/can_be_null = FALSE

/datum/continuity_field/type/New(in_list = null, can_be_null = FALSE)
	src.in_list = in_list

	src.can_be_null = can_be_null

/datum/continuity_field/type/sanitize_field(field)
	if(istext(field)) //JSON saves paths as strings, sadly.
		field = text2path(field)

	if(in_list)
		if(field in in_list)
			return field

		stack_trace("Tried saving [field]. Not an allowed type")
		return RUNTIME_SENTINEL

	if(isnull(field))
		if(can_be_null)
			return field

		stack_trace("Tried saving [field]. Is null")
		return RUNTIME_SENTINEL

	if(!ispath(field))
		stack_trace("Tried saving [field]. Not a text")
		return RUNTIME_SENTINEL

	return field

/datum/component/continuity_object/proc/sanitize_data(list/data)
	for(var/field_name in src.fields)
		if(!(field_name in data))
			stack_trace("Tried saving [parent]. Missing field [field_name]")
			return RUNTIME_SENTINEL

	for(var/field_name in data)
		if(!(field_name in src.fields))
			stack_trace("Tried saving invalid [field_name]")
			return RUNTIME_SENTINEL

		if(length(field_name) > 100)
			return RUNTIME_SENTINEL

		var/field_data = data[field_name]

		var/datum/continuity_field/object_field = src.fields[field_name]
		if(!object_field)
			return RUNTIME_SENTINEL

		var/newdata = object_field.sanitize_field(field_data)
		if(RUNTIMED(newdata))
			return RUNTIME_SENTINEL

		data[field_name] = newdata

	return data

#undef RUNTIMED
#undef RUNTIME_SENTINEL

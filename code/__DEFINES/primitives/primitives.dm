/* --------primitive field types--------

fields = alist(...)

//list
"varname" = list("field_type" = "list", "can_be_null" = TRUE, "entry_config" = list(...))

//alist
"varname" = list("field_type" = "alist", "can_be_null" = TRUE, "key_config" = list(...), "entry_config" = list(...))

//text
"varname" = list("field_type" = "text", "max_length" = 999, "can_be_null" = TRUE, "in_list" = list(), "regex" = @"text")

//num
"varname" = list("field_type" = "num", "max_num" = 999, "min_num" = -999, "can_be_null" = TRUE)

//type
"varname" = list("field_type" = "type", "in_list" = list(), "can_be_null" = TRUE)

*/

/datum/primitive_field
	var/name = "blank field"

/datum/primitive_field/proc/sanitize_field()
	throw EXCEPTION("Tried sanitizing blank continuity field")

/datum/primitive_field/listfield
	name = "list"
	var/can_be_null = FALSE
	var/datum/primitive_field/entry_config

/datum/primitive_field/listfield/New(entry_config = null, can_be_null = FALSE)
	if(!entry_config)
		stack_trace("Tried creating continuity field. No entry config")
		return

	src.entry_config = entry_config

	if(!istype(entry_config, /datum/primitive_field))
		stack_trace("Tried creating continuity field. Invalid entry config type")
		return

	src.can_be_null = can_be_null

/datum/primitive_field/listfield/Destroy()
	QDEL_NULL(entry_config)

	..()

/datum/primitive_field/listfield/sanitize_field(list/field)
	if(isnull(field))
		if(can_be_null)
			return field
		throw EXCEPTION("Is null")

	var/list/sanitized_list = list()
	for(var/entry in field)
		var/newdata = entry_config.sanitize_field(entry)
		sanitized_list += list(newdata)

	return sanitized_list


/datum/primitive_field/alistfield
	name = "alist"
	var/can_be_null = FALSE
	var/datum/primitive_field/key_config
	var/datum/primitive_field/entry_config

	var/static/list/key_types = list(/datum/primitive_field/text, /datum/primitive_field/num, /datum/primitive_field/type)

/datum/primitive_field/alistfield/New(key_config = null, entry_config = null, can_be_null = FALSE)
	if(!key_config)
		stack_trace("Tried creating continuity field. No key config")
		return

	src.key_config = key_config

	if(!(src.key_config.type in key_types))
		stack_trace("Tried creating continuity field. Invalid key type")
		return

	if(!entry_config)
		stack_trace("Tried creating continuity field. No entry config")
		return

	src.entry_config = entry_config

	if(!istype(entry_config, /datum/primitive_field))
		stack_trace("Tried creating continuity field. Invalid entry config type")
		return

	src.can_be_null = can_be_null

/datum/primitive_field/alistfield/Destroy()
	QDEL_NULL(key_config)
	QDEL_NULL(entry_config)

	..()

/datum/primitive_field/alistfield/sanitize_field(list/field)
	if(isnull(field))
		if(can_be_null)
			return field

		throw EXCEPTION("Is null")

	var/list/sanitized_list = list()
	for(var/entry_name in field)
		var/valid_name = key_config.sanitize_field(entry_name)
		var/newdata = entry_config.sanitize_field(field[entry_name])

		sanitized_list[valid_name] = newdata

	return sanitized_list


/datum/primitive_field/text
	name = "text"

	var/regex/reg
	var/list/in_list
	var/can_be_null = FALSE
	var/max_length

/datum/primitive_field/text/New(regex = null, in_list = null, can_be_null = FALSE, max_length = null)
	if(!max_length && !(regex || in_list))
		stack_trace("Tried creating continuity field. No max_length specified, but is required")
		return

	if(regex)
		try
			src.reg = regex(regex)
		catch(var/exception/e)
			stack_trace("Tried creating continuity field. [e.name]")
			return

	if(islist(in_list))
		var/list/L = in_list
		for(var/entry in L)
			if(!istext(entry))
				stack_trace("Tried creating continuity field. Text list contains not a text entry")
				return

	src.in_list = in_list

	src.can_be_null = can_be_null

	src.max_length = max_length

/datum/primitive_field/text/sanitize_field(field)
	if(in_list)
		if(field in in_list)
			return field

		throw EXCEPTION("Not an allowed text")

	if(isnull(field))
		if(can_be_null)
			return field

		throw EXCEPTION("Is null")

	if(!istext(field))
		throw EXCEPTION("Not a text")

	if(max_length && (length(field) > max_length))
		throw EXCEPTION("Text is longer than it should be")

	if(reg)
		if(reg.Find(field))
			return field

		throw EXCEPTION("Regex failed")

	return field


/datum/primitive_field/num
	name = "num"

	var/can_be_null = FALSE
	var/max_num
	var/min_num

/datum/primitive_field/num/New(can_be_null = FALSE, max_num = null, min_num = null)
	if(!(isnull(min_num) || isnull(max_num)) && (min_num > max_num))
		stack_trace("Tried creating continuity field. Min_num greater than max_num")
		return

	src.max_num = max_num
	src.min_num = min_num

	src.can_be_null = can_be_null

/datum/primitive_field/num/sanitize_field(field)
	if(isnull(field))
		if(can_be_null)
			return field

		throw EXCEPTION("Is null")

	if(!isnum(field))
		throw EXCEPTION("Not a number")

	if(max_num && (field > max_num))
		throw EXCEPTION("Number is bigger than it should be")

	if(min_num && (field < min_num))
		throw EXCEPTION("Number is smaller than it should be")

	return field


/datum/primitive_field/type
	name = "type"

	var/list/in_list
	var/can_be_null = FALSE

/datum/primitive_field/type/New(in_list = null, can_be_null = FALSE)
	if(islist(in_list))
		var/list/L = in_list
		for(var/entry in L)
			if(!ispath(entry))
				stack_trace("Tried creating continuity field. Type list contains not a path entry")
				return

	src.in_list = in_list

	src.can_be_null = can_be_null

/datum/primitive_field/type/sanitize_field(field)
	if(isnull(field))
		if(can_be_null)
			return field

		throw EXCEPTION("Is null")

	if(istext(field)) //JSON saves paths as strings, sadly.
		field = text2path(field)

		if(isnull(field)) //If text2path returns null, that means that it was not a path
			throw EXCEPTION("Not a path")

	if(in_list)
		if(field in in_list)
			return field

		throw EXCEPTION("Not an allowed type")

	return field

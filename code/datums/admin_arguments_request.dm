/datum/admin_arguments_request
	var/arg_name
	var/arg_desc
	var/arg_def_val
	var/arg_named
	var/value_required

/datum/admin_arguments_request/New(argument_name, named_arg, desc="", arg_def_val=null, val_req = FALSE)
	arg_name = argument_name
	arg_desc = desc
	arg_def_val = null
	arg_named = named_arg
	value_required = val_req

/datum/admin_arguments_request/proc/get_value(client/admin)
	return null



/datum/admin_arguments_request/bool

/datum/admin_arguments_request/bool/get_value(client/admin)
	var/ret
	if(value_required)
		while(!ret)
			to_chat(admin, "<span class='warning'>You MUST enter a value for <b>" + arg_name + "</b>.</span>")
			ret = input(admin, arg_desc ? arg_desc : "Please enter a boolean value for " + arg_name + ".", "Boolean field.") as text
	else
		ret = input(admin, arg_desc ? arg_desc : "Please enter a boolean value for " + arg_name + ".", "Boolean field.") as null|text
	if(ret)
		ret = lowertext(ret)
		if(ret == "true")
			return TRUE
		else if(ret == "false")
			return FALSE
		ret = text2num(ret)
		if(ret)
			return TRUE
		return FALSE
	return arg_def_val



/datum/admin_arguments_request/integer

/datum/admin_arguments_request/integer/get_value(client/admin)
	var/ret
	if(value_required)
		while(!ret)
			to_chat(admin, "<span class='warning'>You MUST enter a value for <b>" + arg_name + "</b>.</span>")
			ret = input(admin, arg_desc ? arg_desc : "Please enter an integer for " + arg_name + ".", "Integer field.") as num
	else
		ret = input(admin, arg_desc ? arg_desc : "Please enter an integer for " + arg_name + ".", "Integer field.") as null|num
	if(ret)
		return ret
	return arg_def_val



/datum/admin_arguments_request/text

/datum/admin_arguments_request/text/get_value(client/admin)
	var/ret
	if(value_required)
		while(!ret)
			to_chat(admin, "<span class='warning'>You MUST enter a value for <b>" + arg_name + "</b>.</span>")
			ret = input(admin, arg_desc ? arg_desc : "Please enter an integer for " + arg_name + ".", "Text field.") as text
	else
		ret = input(admin, arg_desc ? arg_desc : "Please enter an integer for " + arg_name + ".", "Text field.") as null|text
	if(ret)
		return ret
	return arg_def_val

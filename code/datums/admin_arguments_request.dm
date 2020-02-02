/datum/admin_arguments_request
	var/arg_name
	var/arg_desc
	var/arg_def_val
	var/arg_named
	var/value_required

/datum/admin_arguments_request/New(argument_name, named_arg, desc="", def_arg_val=null, val_req = FALSE)
	arg_name = argument_name
	arg_desc = desc
	arg_def_val = def_arg_val
	arg_named = named_arg
	value_required = val_req

/datum/admin_arguments_request/proc/get_value(client/admin)
	return null



/datum/admin_arguments_request/integer

/datum/admin_arguments_request/integer/get_value(client/admin)
	var/ret
	if(value_required)
		while(!ret)
			to_chat(admin, "<span class='warning'>You MUST enter a value for <b>" + arg_name + "</b>.</span>")
			ret = input(admin, arg_desc ? arg_desc : "Please enter an integer for " + arg_name + ".", "Integer field.") as num
	else
		ret = input(admin, arg_desc ? arg_desc : "Please enter an integer for " + arg_name + ".", "Integer field.") as null|num
	if(!isnull(ret))
		return ret
	return arg_def_val

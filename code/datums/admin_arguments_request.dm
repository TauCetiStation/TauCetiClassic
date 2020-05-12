/*
	A little something to handle getting values
	into a list.
*/
// This function converts a list of requests to a list of arguments through means
// of asking the admin to enter them in. (Still needs to be converted to byond
// arglist when passing to function).

// An example would be: foo(arglist(get_arglist_from_requests(admin,  requests)))
/proc/get_arglist_from_requests(client/admin, list/datum/admin_arguments_request/requests)
	var/list/retVal = list()
	for(var/argument_name in requests)
		var/datum/admin_arguments_request/AAR = requests[argument_name]
		if(AAR.arg_named)
			retVal[argument_name] = AAR.get_value(admin)
		else
			retVal += AAR.get_value(admin)
	return retVal


/datum/admin_arguments_request
	// The name of the argument that will be used in the input field(unless you override it).
	var/arg_name
	// The text in input field that will override the default "Please enter %type_name%"
	var/arg_desc
	// The value of an argument, if an admin presses "Cancel". Is not compatible with value_required = TRUE.
	var/arg_def_val
	// Whether this argument is a named one, or a positional one. Please supply named arguments in proper order.
	// (Meaning, after the positional ones).
	var/arg_named
	// Whether the request should go on until a meaningful value is given. Is not compatible with arg_def_val.
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

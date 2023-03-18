/proc/_ckey(t)
	return ckey(t)

/proc/_optional(param_type, default, value)
	if(value == null)
		return default

	return param_type.Invoke(value)

/proc/_sanitize_integer(min, max, default, value)
	return sanitize_integer(value, min, max, default)

/proc/_route(proc_to_call, params, packed_data)
	var/list/proc_params = list()

	for(var/param in params)
		var/value = packed_data[param]
		var/param_type = params[param]

		var/sanitized_value = param_type.Invoke(value)

		// Error: Required Param Missing.
		if(sanitized_value == null)
			return

		proc_params[param] = sanitized_value

	proc_to_call.Invoke(arglist(proc_params))

#define INTEGER_PARAM(min, max, default) CALLBACK(GLOBAL_PROC, ._sanitize_integer, min, max, default)
#define STRING_PARAM CALLBACK(GLOBAL_PROC, .sanitize_text)
#define CKEY_PARAM CALLBACK(GLOBAL_PROC, ._ckey)

#define OPTIONAL_PARAM(param_type) CALLBACK(GLOBAL_PROC, ._optional, param_type, default)

#define ROUTE(proc_to_call, params) CALLBACK(GLOBAL_PROC, ._route, CALLBACK(GLOBAL_PROC, .##proc_to_call, params))

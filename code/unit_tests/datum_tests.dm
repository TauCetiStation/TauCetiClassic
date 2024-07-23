/datum/unit_test/pref_default_value
	name = "PREFS: all prefs should have valid default value."

/datum/unit_test/pref_default_value/start_test()
	var/failed = ""
	for(var/type in subtypesof(/datum/pref))
		var/datum/pref/P = new type()
		if(P.value && P.value != P.sanitize_value(P.value))
			failed += "\n[type] has bad default value!"
	if(failed)
		fail(failed)
	else
		pass("No invalid prefs found.")

	return TRUE

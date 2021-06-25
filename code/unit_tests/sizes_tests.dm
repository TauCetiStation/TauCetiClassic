/datum/unit_test/sizes
	name = "SIZES: objects should have w_class or ABSTRACT flag, mobs shold have w_class."

/datum/unit_test/sizes/start_test()
	var/failed = ""
	
	for(var/T in subtypesof(/obj)) 
		var/atom/movable/A = T
		if(initial(A.w_class) == 0 && !(initial(A.flags) & ABSTRACT))
			failed += "\nNo w_class or ABSTRACT flag in [T]"

	for(var/T in subtypesof(/mob))
		var/atom/movable/A = T
		if(initial(A.w_class) == 0)
			failed += "\nNo w_class in [T]"

	if(failed)
		fail(failed)
	else
		pass("All size classes is ok.")

	return TRUE

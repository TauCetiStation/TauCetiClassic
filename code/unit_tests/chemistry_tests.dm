/datum/unit_test/reactions_reagent_id_typos
	name = "CHEMISTRY: all chemical reaction ids must be valid."

/datum/unit_test/reactions_reagent_id_typos/start_test()
	var/failed = ""
	for(var/I in global.chemical_reactions_list)
		for(var/V in global.chemical_reactions_list[I])
			var/datum/chemical_reaction/R = V
			for(var/id in (R.required_reagents + R.required_catalysts))
				if(!global.chemical_reagents_list[id])
					failed += "\nUnknown chemical id \"[id]\" in recipe [R.type]"
	if(failed)
		fail(failed)
	else
		pass("No invalid chemical ids found.")

	return TRUE

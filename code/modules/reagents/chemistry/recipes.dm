/datum/chemical_reaction
		var/name = null
		var/id = null
		var/result = null
		var/list/required_reagents = new/list()
		var/list/required_catalysts = new/list()

		// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
		var/atom/required_container = null // the container required for the reaction to happen
		var/required_other = 0 // an integer required for the reaction to happen

		var/result_amount = 0
		var/secondary = 0 // set to nonzero if secondary reaction
		var/list/secondary_results = list()		//additional reagents produced by the reaction
		var/requires_heating = 0

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return
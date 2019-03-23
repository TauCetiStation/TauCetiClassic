/datum
	var/list/status_traits
	var/list/datum_components //for /datum/components
	var/list/comp_lookup //it used to be for looking up components which had registered a signal but now anything can register
	var/list/signal_procs
	var/signal_enabled = FALSE

/datum/bodypart_controller/robot/unbranded_monitor
	company = "Unbranded Monitor"
	desc = "A generic unbranded interpretation of a popular prosthetic head model. It looks rudimentary and cheaply constructed."
	iconbase = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_monitor.dmi'
	low_quality = TRUE
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)
	ipc_parts = list(BP_HEAD)

	carry_weight = 10 * ITEM_SIZE_NORMAL
	mental_load = 15
	processing_language = "Trinary"

/datum/bodypart_controller/robot/unbranded_mechanized
	company = "Unbranded Mechanized"
	desc = "A generic unbranded mechanized version of an internal organ. It looks rudimentary and cheaply constructed."
	low_quality = TRUE
	parts = list(O_EYES, O_HEART)
	restrict_species = list("exclude", IPC)
	allowed_states = list("Mechanical")

/datum/bodypart_controller/robot/unbranded_assisted
	company = "Unbranded Assisted"
	desc = "A generic unbranded mechanized version of an internal organ. It looks rudimentary and cheaply constructed."
	low_quality = TRUE
	parts = list(O_EYES, O_HEART)
	restrict_species = list("exclude", IPC)
	allowed_states = list("Assisted")

/datum/bodypart_controller/robot/grayson_ipc
	company = "Grayson"
	desc = "This limb has a sturdy and heavy build to it."
	iconbase = 'icons/mob/human_races/cyberlimbs/grayson/grayson_ipc.dmi'
	restrict_species = list(IPC)
	parts = BP_ALL

	carry_weight = 10 * ITEM_SIZE_NORMAL
	mental_load = 15
	processing_language = "Trinary"

/datum/bodypart_controller/robot/grayson_monitor
	company = "Grayson Monitor"
	desc = "This limb has a sturdy and heavy build to it, and uses plastics in the place of glass for the monitor."
	iconbase = 'icons/mob/human_races/cyberlimbs/grayson/grayson_monitor.dmi'
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)

	carry_weight = 10 * ITEM_SIZE_NORMAL
	mental_load = 15
	processing_language = "Trinary"

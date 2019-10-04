/datum/bodypart_controller/robot/cybersolutions
	company = "Cyber Solutions"
	desc = "This limb is grey and rough, with little in the way of aesthetic."
	iconbase = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_main.dmi'

	processing_language = "Tradeband"

/datum/bodypart_controller/robot/cybersolutions_ipc
	company = "Cyber Solutions - Wight"
	desc = "This limb has cheap plastic panels mounted on grey metal."
	iconbase = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_ipc.dmi'
	restrict_species = list(IPC)
	parts = BP_ALL

	carry_weight = 10 * ITEM_SIZE_NORMAL
	mental_load = 15
	processing_language = "Trinary"

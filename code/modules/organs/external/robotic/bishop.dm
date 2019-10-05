/datum/bodypart_controller/robot/bishop
	company = "Bishop"
	desc = "This limb has a white polymer casing with blue holo-displays."
	iconbase = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'

	processing_language = "Tradeband"

/datum/bodypart_controller/robot/bishop_ipc
	company = "Bishop - Glyph"
	desc = "This limb has a white polymer casing with blue holo-displays."
	iconbase = 'icons/mob/human_races/cyberlimbs/bishop/bishop_ipc.dmi'
	restrict_species = list(IPC)
	parts = BP_ALL

	carry_weight = 10 * ITEM_SIZE_NORMAL
	mental_load = 15
	processing_language = "Trinary"

/datum/bodypart_controller/robot/bishop_monitor
	company = "Bishop Monitor"
	desc = "Bishop Cybernetics' unique spin on a popular prosthetic head model. The themes conflict in an intriguing way."
	iconbase = 'icons/mob/human_races/cyberlimbs/bishop/bishop_monitor.dmi'
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)
	ipc_parts = list(BP_HEAD)

	carry_weight = 10 * ITEM_SIZE_NORMAL
	mental_load = 15
	processing_language = "Trinary"

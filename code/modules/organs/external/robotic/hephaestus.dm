/datum/bodypart_controller/robot/hephaestus
	company = "Hephaestus"
	desc = "This limb has a militaristic black and green casing with gold stripes."
	iconbase = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_main.dmi'
	brute_mod = 0.9
	burn_mod = 0.9
	speed_mod = 0.35 // Two hands would slow you down to Unathi levels.
	tech_tier = HIGH_TECH_PROSTHETIC

	size = 2 * ITEM_SIZE_NORMAL
	mental_load = 20
	processing_language = "Gutter"

	rejection_time = 3 MINUTES
	arr_consume_amount = 0.1

/datum/bodypart_controller/robot/hephaestus_ipc
	company = "Hephaestus - Athena"
	desc = "This rather thick limb has a militaristic green plating."
	iconbase = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_ipc.dmi'
	restrict_species = list(IPC)
	parts = BP_ALL
	brute_mod = 0.9
	burn_mod = 0.9
	speed_mod = 0.35
	tech_tier = HIGH_TECH_PROSTHETIC

	size = 2 * ITEM_SIZE_NORMAL
	carry_weight = 18 * ITEM_SIZE_NORMAL
	mental_load = 30
	processing_language = "Trinary"

	rejection_time = 3 MINUTES
	arr_consume_amount = 0.1

/datum/bodypart_controller/robot/hephaestus_monitor
	company = "Hephaestus Monitor"
	desc = "Hephaestus' unique spin on a popular prosthetic head model. It looks rugged and sturdy."
	iconbase = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_monitor.dmi'
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)
	brute_mod = 0.9
	burn_mod = 0.9
	speed_mod = 0.35
	tech_tier = HIGH_TECH_PROSTHETIC

	size = 2 * ITEM_SIZE_NORMAL
	carry_weight = 18 * ITEM_SIZE_NORMAL
	mental_load = 30
	processing_language = "Trinary"

	rejection_time = 3 MINUTES
	arr_consume_amount = 0.1

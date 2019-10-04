/datum/bodypart_controller/robot/wardtakahashi
	company = "Ward-Takahashi"
	desc = "This limb features sleek black and white polymers."
	iconbase = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
	tech_tier = HIGH_TECH_PROSTHETIC

	carry_speed_mod = -0.5

	size = 2 * ITEM_SIZE_NORMAL
	carry_weight = 18 * ITEM_SIZE_NORMAL
	mental_load = 20
	processing_language = "Tradeband"

/datum/bodypart_controller/robot/wardtakahashi_ipc
	company = "Ward-Takahashi - Spirit"
	desc = "This limb has white and purple features, with a heavier casing."
	iconbase = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_ipc.dmi'
	restrict_species = list(IPC)
	tech_tier = HIGH_TECH_PROSTHETIC
	parts = BP_ALL

	carry_speed_mod = -0.5

	size = 2 * ITEM_SIZE_NORMAL
	carry_weight = 18 * ITEM_SIZE_NORMAL
	mental_load = 30
	processing_language = "Trinary"

/datum/bodypart_controller/robot/wardtakahashi_monitor
	company = "Ward-Takahashi Monitor"
	desc = "Ward-Takahashi's unique spin on a popular prosthetic head model. It looks sleek and modern."
	iconbase = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_monitor.dmi'
	tech_tier = HIGH_TECH_PROSTHETIC
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)

	carry_speed_mod = -0.5

	size = 2 * ITEM_SIZE_NORMAL
	carry_weight = 18 * ITEM_SIZE_NORMAL
	mental_load = 30
	processing_language = "Trinary"

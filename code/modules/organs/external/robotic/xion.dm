/datum/bodypart_controller/robot/xion
	company = "Xion"
	desc = "This limb has a minimalist black and red casing."
	iconbase = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
	tech_tier = MEDIUM_TECH_PROSTHETIC
	low_quality = TRUE

	mental_load = 15
	processing_language = "Gutter"

	built_in_tools = list("hand" = null,
	                      "wrench" = /obj/item/weapon/wrench,
	                      "screwdriver" = /obj/item/weapon/screwdriver,
	                      "wirecutters" = /obj/item/weapon/wirecutters,
	                      "welding tool" = /obj/item/weapon/weldingtool,
	                      "crowbar" = /obj/item/weapon/crowbar)
	default_selected_tool = "hand"

	default_cell_type = /obj/item/weapon/stock_parts/cell/high
	passive_cell_use = 1
	action_cell_use = 1

/datum/bodypart_controller/robot/xion_ipc
	company = "Xion - Breach"
	desc = "This limb has a minimalist black and red casing. Looks a bit menacing."
	iconbase = 'icons/mob/human_races/cyberlimbs/xion/xion_ipc.dmi'
	tech_tier = MEDIUM_TECH_PROSTHETIC
	low_quality = TRUE
	restrict_species = list(IPC)
	parts = BP_ALL

	carry_weight = 10 * ITEM_SIZE_NORMAL
	mental_load = 22
	processing_language = "Trinary"

	built_in_tools = list("hand" = null,
	                      "wrench" = /obj/item/weapon/wrench,
	                      "screwdriver" = /obj/item/weapon/screwdriver,
	                      "wirecutters" = /obj/item/weapon/wirecutters,
	                      "welding tool" = /obj/item/weapon/weldingtool,
	                      "crowbar" = /obj/item/weapon/crowbar)
	default_selected_tool = "hand"

	default_cell_type = /obj/item/weapon/stock_parts/cell/high
	passive_cell_use = 1
	action_cell_use = 1

/datum/bodypart_controller/robot/xion_monitor
	company = "Xion Monitor"
	desc = "Xion Mfg.'s unique spin on a popular prosthetic head model. It looks and minimalist and utilitarian."
	iconbase = 'icons/mob/human_races/cyberlimbs/xion/xion_monitor.dmi'
	tech_tier = MEDIUM_TECH_PROSTHETIC
	low_quality = TRUE
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)
	ipc_parts = list(BP_HEAD)

	carry_weight = 10 * ITEM_SIZE_NORMAL
	mental_load = 22
	processing_language = "Trinary"

	built_in_tools = list("hand" = null,
	                      "wrench" = /obj/item/weapon/wrench,
	                      "screwdriver" = /obj/item/weapon/screwdriver,
	                      "wirecutters" = /obj/item/weapon/wirecutters,
	                      "welding tool" = /obj/item/weapon/weldingtool,
	                      "crowbar" = /obj/item/weapon/crowbar)
	default_selected_tool = "hand"

	default_cell_type = /obj/item/weapon/stock_parts/cell/high
	passive_cell_use = 1
	action_cell_use = 1

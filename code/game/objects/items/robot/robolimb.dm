var/global/list/all_robolimbs = list()
var/global/list/all_robolimbs_try = list()
var/global/list/monitor_robolimbs = list()

var/datum/robolimb/unbranded

/datum/robolimb
	var/company = "Unbranded"                            // Shown when selecting the limb.
	var/desc = "A generic unbranded robotic prosthesis." // Seen when examining a limb.
	var/iconbase = 'icons/mob/human_races/robotic.dmi'   // Icon base to draw from.
	var/protected = 0                                    // How protected from EMP the limb is.
	var/low_quality = FALSE                              // If TRUE, limb may spawn in being sabotaged.
	var/list/restrict_species = list("exclude")          // Species that CAN wear the limb.
	var/list/possible_tools = list()                     // If limb can simulate a tool, it will be in this list.
	var/monitor = FALSE			 		 			 // Whether the limb can display IPC screens.
	var/parts = list(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)						 	 // Defines what parts said brand can replace on a body.

/datum/robolimb/unbranded_monitor
	company = "Unbranded Monitor"
	desc = "A generic unbranded interpretation of a popular prosthetic head model. It looks rudimentary and cheaply constructed."
	iconbase = 'icons/mob/human_races/cyberlimbs/unbranded/unbranded_monitor.dmi'
	low_quality = TRUE
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)

/datum/robolimb/nanotrasen
	company = "NanoTrasen"
	desc = "A simple but efficient robotic limb, created by NanoTrasen."
	iconbase = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_main.dmi'
	parts = list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM)

/datum/robolimb/bishop
	company = "Bishop"
	desc = "This limb has a white polymer casing with blue holo-displays."
	iconbase = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'
	parts = list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM)

/datum/robolimb/bishop_ipc
	company = "Bishop - Glyph"
	desc = "This limb has a white polymer casing with blue holo-displays."
	iconbase = 'icons/mob/human_races/cyberlimbs/bishop/bishop_ipc.dmi'
	restrict_species = list(IPC)
	parts = BP_ALL

/datum/robolimb/bishop_monitor
	company = "Bishop Monitor"
	desc = "Bishop Cybernetics' unique spin on a popular prosthetic head model. The themes conflict in an intriguing way."
	iconbase = 'icons/mob/human_races/cyberlimbs/bishop/bishop_monitor.dmi'
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)

/datum/robolimb/cybersolutions
	company = "Cyber Solutions"
	desc = "This limb is grey and rough, with little in the way of aesthetic."
	iconbase = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_main.dmi'
	parts = list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM)

/datum/robolimb/cybersolutions_ipc
	company = "Cyber Solutions - Wight"
	desc = "This limb has cheap plastic panels mounted on grey metal."
	iconbase = 'icons/mob/human_races/cyberlimbs/cybersolutions/cybersolutions_ipc.dmi'
	restrict_species = list(IPC)
	parts = BP_ALL

/datum/robolimb/grayson_ipc
	company = "Grayson"
	desc = "This limb has a sturdy and heavy build to it."
	iconbase = 'icons/mob/human_races/cyberlimbs/grayson/grayson_ipc.dmi'
	restrict_species = list(IPC)
	parts = BP_ALL

/datum/robolimb/grayson_monitor
	company = "Grayson Monitor"
	desc = "This limb has a sturdy and heavy build to it, and uses plastics in the place of glass for the monitor."
	iconbase = 'icons/mob/human_races/cyberlimbs/grayson/grayson_monitor.dmi'
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)

/datum/robolimb/hephaestus
	company = "Hephaestus"
	desc = "This limb has a militaristic black and green casing with gold stripes."
	iconbase = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_main.dmi'
	parts = list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM)

/datum/robolimb/hephaestus_ipc
	company = "Hephaestus - Athena"
	desc = "This rather thick limb has a militaristic green plating."
	iconbase = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_ipc.dmi'
	restrict_species = list(IPC)
	parts = BP_ALL

/datum/robolimb/hephaestus_monitor
	company = "Hephaestus Monitor"
	desc = "Hephaestus' unique spin on a popular prosthetic head model. It looks rugged and sturdy."
	iconbase = 'icons/mob/human_races/cyberlimbs/hephaestus/hephaestus_monitor.dmi'
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)

/datum/robolimb/morpheus
	company = "Morpheus"
	desc = "This limb is simple and functional; no effort has been made to make it look human."
	iconbase = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_ipc.dmi'
	restrict_species = list(IPC)
	parts = BP_ALL

/datum/robolimb/wardtakahashi
	company = "Ward-Takahashi"
	desc = "This limb features sleek black and white polymers."
	iconbase = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
	parts = list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM)

/datum/robolimb/wardtakahashi_ipc
	company = "Ward-Takahashi - Spirit"
	desc = "This limb has white and purple features, with a heavier casing."
	iconbase = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_ipc.dmi'
	restrict_species = list(IPC)
	parts = BP_ALL

/datum/robolimb/wardtakahashi_monitor
	company = "Ward-Takahashi Monitor"
	desc = "Ward-Takahashi's unique spin on a popular prosthetic head model. It looks sleek and modern."
	iconbase = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_monitor.dmi'
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)

/datum/robolimb/xion
	company = "Xion"
	desc = "This limb has a minimalist black and red casing."
	iconbase = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
	low_quality = TRUE
	possible_tools = list("hand" = null, "screwdriver" = /obj/item/weapon/screwdriver, "wrench" = /obj/item/weapon/wrench)
	parts = list(BP_L_LEG, BP_R_LEG, BP_L_ARM, BP_R_ARM)

/datum/robolimb/xion_ipc
	company = "Xion - Breach"
	desc = "This limb has a minimalist black and red casing. Looks a bit menacing."
	iconbase = 'icons/mob/human_races/cyberlimbs/xion/xion_ipc.dmi'
	low_quality = TRUE
	possible_tools = list("hand" = null, "screwdriver" = /obj/item/weapon/screwdriver, "wrench" = /obj/item/weapon/wrench)
	restrict_species = list(IPC)
	parts = BP_ALL

/datum/robolimb/xion_monitor
	company = "Xion Monitor"
	desc = "Xion Mfg.'s unique spin on a popular prosthetic head model. It looks and minimalist and utilitarian."
	iconbase = 'icons/mob/human_races/cyberlimbs/xion/xion_monitor.dmi'
	low_quality = TRUE
	monitor = TRUE
	restrict_species = list(IPC)
	parts = list(BP_HEAD)

/datum/auto_surgery
	var/name = "surgery"

	var/insurance_needed = INSURANCE_STANDARD
	var/step_cost = 1
	var/list/datum/surgery_step/steps = list()
	var/list/available_target_zones = list()

/datum/auto_surgery/bone
	name = "bone surgery"

	insurance_needed = INSURANCE_STANDARD
	step_cost = 1
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/generic/cauterize
	)
	available_target_zones = list(BP_CHEST, BP_HEAD, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

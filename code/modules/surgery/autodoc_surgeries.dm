/datum/auto_surgery
	var/name = "surgery"

	var/insurance_needed = INSURANCE_STANDARD
	var/step_cost = 1
	var/list/datum/surgery_step/steps = list()
	var/list/available_target_zones = list()

/datum/auto_surgery/bone/skull
	name = "исправить кости черепа"

	insurance_needed = INSURANCE_STANDARD
	step_cost = 3
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/mend_skull,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	available_target_zones = list(BP_HEAD)

/datum/auto_surgery/bone/ribs
	name = "исправить рёбра"

	insurance_needed = INSURANCE_STANDARD
	step_cost = 2
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/ribcage/mend_ribcage,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	available_target_zones = list(BP_CHEST)

/datum/auto_surgery/bone
	name = "исправить кости"

	insurance_needed = INSURANCE_STANDARD
	step_cost = 1
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	available_target_zones = list(BP_GROIN, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/auto_surgery/arthery
	name = "зашить артерии"

	insurance_needed = INSURANCE_STANDARD
	step_cost = 5
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/fix_vein,
		/datum/surgery_step/generic/cauterize
	)
	available_target_zones = list(BP_GROIN, BP_CHEST, BP_HEAD, BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)

/datum/auto_surgery/organ
	name = "исправить внутренние органы"

	insurance_needed = INSURANCE_PREMIUM
	step_cost = 10
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/ribcage/saw_ribcage,
		/datum/surgery_step/ribcage/retract_ribcage,
		/datum/surgery_step/ribcage/fix_chest_internal,
		/datum/surgery_step/ribcage/close_ribcage,
		/datum/surgery_step/ribcage/mend_ribcage,
		/datum/surgery_step/generic/cauterize
	)
	available_target_zones = list(BP_CHEST)

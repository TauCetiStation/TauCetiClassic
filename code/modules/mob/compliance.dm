/mob/verb/comply()
	set name = "Подчиниться"
	set desc = "Активно подчиняться действиям совершаемым с вами."
	set category = "IC"

	if(!in_use_action || incapacitated())
		actively_complying = FALSE
		return

	actively_complying = TRUE

/mob/proc/getComplianceLevel()
	// if we are incapacitated (handcuffed, sleeping, dead) we cannot really resist much
	// but also cannot comply actively, so by default we return COMPLIANCE_LEVEL_WEAK
	if(incapacitated())
		return COMPLIANCE_LEVEL_WEAK

	// actively complying return COMPLIANCE_LEVEL_STRONG
	// because it implies actually helping the abuser with their goals
	if(actively_complying)
		actively_complying = FALSE
		return COMPLIANCE_LEVEL_STRONG

	// if we are under effects of substances we also comply
	if(reagents.has_reagent_type(/datum/reagent/drug))
		return COMPLIANCE_LEVEL_WEAK

	return COMPLIANCE_LEVEL_NONE

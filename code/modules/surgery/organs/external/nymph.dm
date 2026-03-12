// Humans do not have Dionaea gestalt consciousness to use nymphs as their appendages.
/datum/bodypart_controller/nymph/check_rejection()
	if(BP.owner.species.name == BP.species.name)
		BP.is_rejecting = FALSE

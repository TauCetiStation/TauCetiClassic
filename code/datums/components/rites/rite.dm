/*
 This component is necessary to give the other components the same features.
*/
/datum/component/rite
	var/tip_text = ""

/datum/component/rite/Initialize()
	var/datum/religion_rites/rite = parent
	rite.update_tip(tip_text)

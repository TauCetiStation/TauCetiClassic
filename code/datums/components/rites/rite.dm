/*
 This component is necessary to give the other components the same features.
*/
/datum/component/rite
	var/tip_text = ""

/datum/component/rite/Initialize()
	var/datum/religion_rites/rite = parent
	if(tip_text && tip_text != "")
		rite.add_tips(tip_text)
	rite.update_tip()

/*
 This component is necessary to give the other components the same features.
*/
/datum/component/rite
	//Unique tip on rite
	var/tip_text = ""

/datum/component/rite/Initialize()
	var/datum/religion_rites/rite = parent
	if(tip_text && tip_text != "")
		rite.add_tips(tip_text)

/datum/component/rite/Destroy()
	var/datum/religion_rites/rite = parent
	for(var/tip in rite.tips)
		rite.remove_tip(rite.tips[tip])
	return ..()

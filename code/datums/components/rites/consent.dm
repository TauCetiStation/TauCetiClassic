/*
 This component is used in chaplain's rites to ask for consent to executing the rite.
*/
/datum/component/rite/consent
	var/consent_msg
	var/consent
	var/def_consent = FALSE

	tip_text = "This ritual is performed only if the victim consents."

/datum/component/rite/consent/Initialize(msg, tip_text)
	if(tip_text)
		src.tip_text = tip_text
	..()
	consent_msg = msg
	consent = def_consent

	RegisterSignal(parent, list(COMSIG_RITE_ON_CHOSEN), .proc/victim_ask)
	RegisterSignal(parent, list(COMSIG_RITE_REQUIRED_CHECK), .proc/check_victim)

// Send ask to victim
/datum/component/rite/consent/proc/victim_ask(datum/source, mob/user, obj/structure/altar_of_gods/AOG)
	// revert consent to it's default
	consent = def_consent

	var/mob/victim = AOG.buckled_mob
	if(!victim)
		return

	if(!victim.IsAdvancedToolUser())
		consent = TRUE
	else 
		if(alert(victim, consent_msg, "Rite", "Yes", "No") == "Yes")
			consent = TRUE
			to_chat(victim, "<span class='notice'>You agreed to the rite.</span>")

// Checks for a victim
/datum/component/rite/consent/proc/check_victim(datum/source, mob/user, obj/structure/altar_of_gods/AOG)
	if(!AOG)
		to_chat(user, "<span class='warning'>This rite requires an altar to be performed.</span>")
		return COMPONENT_CHECK_FAILED
	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return COMPONENT_CHECK_FAILED
	if(!consent)
		var/mob/victim = AOG.buckled_mob
		to_chat(user, "<span class='warning'>[victim] does not want to give themselves into this ritual!.</span>")
		return COMPONENT_CHECK_FAILED
	return NONE

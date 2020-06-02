/*
 This component used in chaplain rite for ask question at victim on altar.
*/
/datum/component/rite_consent
	var/consent_msg
	var/consent
	var/def_consent = FALSE

/datum/component/rite_consent/Initialize(msg)
	consent_msg = msg
	consent = def_consent
	RegisterSignal(parent, list(COMSIG_RITE_ON_CHOSEN), .proc/victim_ask)
	RegisterSignal(parent, list(COMSIG_RITE_REQUIRED_CHECK), .proc/check_victim)

// Send ask to victim
/datum/component/rite_consent/proc/victim_ask(datum/source, mob/user, atom/movable/AOG)
	var/mob/victim = AOG.buckled_mob
	if(!victim.IsAdvancedToolUser())
		consent = TRUE
	else 
		if(alert(victim, consent_msg, "Rite", "Yes", "No") == "Yes")
			consent = TRUE

// Checks for a victim
/datum/component/rite_consent/proc/check_victim(datum/source, mob/user, atom/movable/AOG)
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
	// revert consent to it's default
	consent = def_consent
	return NONE

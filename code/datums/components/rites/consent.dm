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

	RegisterSignal(parent, list(COMSIG_RITE_ON_CHOSEN), PROC_REF(victim_ask))
	RegisterSignal(parent, list(COMSIG_RITE_CAN_START), PROC_REF(check_victim))

// Send ask to victim
/datum/component/rite/consent/proc/victim_ask(datum/source, mob/user, obj/AOG)
	// revert consent to it's default
	consent = def_consent

	var/mob/victim = AOG.buckled_mob
	if(!victim)
		return

	if(tgui_alert(victim, consent_msg, "Rite", list("Yes", "No")) == "Yes")
		consent = TRUE
		to_chat(victim, "<span class='notice'>Вы согласились на ритуал.</span>")

// Checks for a victim
/datum/component/rite/consent/proc/check_victim(datum/source, mob/user, obj/AOG)
	if(!AOG)
		to_chat(user, "<span class='warning'>Требуется алтарь для проведения ритуала.</span>")
		return COMPONENT_CHECK_FAILED
	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>Требуется прикрепить жертву к алтарю.</span>")
		return COMPONENT_CHECK_FAILED
	if(!AOG.buckled_mob.mind)
		return NONE
	if(!AOG.buckled_mob.client)
		to_chat(user, "<span class='warning'>Требуется сознательная жертва на алтаре.</span>")
		return COMPONENT_CHECK_FAILED
	if(!consent)
		to_chat(user, "<span class='warning'>Жертва решила не давать согласие на проведение ритуала!</span>")
		return COMPONENT_CHECK_FAILED
	return NONE

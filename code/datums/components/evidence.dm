/datum/component/evidence
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/text_info = ""

/datum/component/evidence/Initialize(text_evidence = "")
	text_info = text_evidence
	RegisterSignal(parent, list(COMSIG_PARENT_POST_EXAMINE), .proc/show_evidence_info)

/datum/component/evidence/proc/show_evidence_info(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!detective_check_passed(user))
		return
	to_chat(user, "<span class='info'>[text_info]</span>")

/datum/component/evidence/proc/detective_check_passed(mob/user)
	var/datum/atom_hud/evidence/evid_hud = global.huds[DATA_HUD_EVIDENCE]
	if(user in evid_hud.hudusers)
		return TRUE
	return FALSE

/datum/component/evidence/InheritComponent(datum/component/C, i_am_original, new_text)
	text_info = new_text

/datum/component/evidence/Destroy()
	//UnregisterSignal(parent, COMSIG_MOUSEDROPPED_ONTO)
	return ..()

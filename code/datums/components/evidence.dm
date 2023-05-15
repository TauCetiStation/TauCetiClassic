/datum/component/evidence
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/text_info = ""

/datum/component/evidence/Initialize(text_evidence = "", give_huds = TRUE)
	text_info = text_evidence
	if(give_huds)
		if(!isatom(parent))
			return COMPONENT_INCOMPATIBLE
		var/atom/A = parent
		A.prepare_huds()
		var/datum/atom_hud/evidence/evid_hud = global.huds[DATA_HUD_EVIDENCE]
		evid_hud.add_to_hud(A)
		A.set_evidence_hud()
	RegisterSignal(parent, list(COMSIG_PARENT_POST_EXAMINE), .proc/show_evidence_info)
	RegisterSignal(parent, list(COMSIG_ITEM_PICKUP), .proc/delete_component)

/datum/component/evidence/proc/detective_check_passed(mob/user)
	var/datum/atom_hud/evidence/evid_hud = global.huds[DATA_HUD_EVIDENCE]
	if(user in evid_hud.hudusers)
		return TRUE
	return FALSE

/datum/component/evidence/proc/show_evidence_info(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!detective_check_passed(user))
		return
	to_chat(user, "<span class='info'>[text_info]</span>")

/datum/component/evidence/proc/delete_component(datum/source)
	SIGNAL_HANDLER
	var/datum/atom_hud/evidence/evid_hud = global.huds[DATA_HUD_EVIDENCE]
	evid_hud.remove_from_hud(parent)
	//set_evidence_hud()
	qdel(src)

/datum/component/evidence/InheritComponent(datum/component/C, i_am_original, new_text)
	text_info = new_text

/datum/component/evidence/Destroy()
	UnregisterSignal(parent, COMSIG_PARENT_POST_EXAMINE)
	UnregisterSignal(parent, COMSIG_ITEM_PICKUP)
	return ..()

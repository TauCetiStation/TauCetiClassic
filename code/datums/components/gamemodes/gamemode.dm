// TODO: It's not be a /datum/component
/datum/component/gamemode

/datum/component/gamemode/Initialize(...)
	RegisterSignal(parent, list(COMSIG_ROLE_GETSCOREBOARD), .proc/GetScoreboard)
	RegisterSignal(parent, list(COMSIG_ROLE_PANELBUTTONS), .proc/extraPanelButtons)
	RegisterSignal(parent, list(COMSIG_ROLE_ROLETOPIC), .proc/RoleTopic)
	RegisterSignal(parent, list(COMSIG_ROLE_POSTSETUP), .proc/OnPostSetup)

/datum/component/gamemode/proc/GetScoreboard(datum/source)
	return

/datum/component/gamemode/proc/extraPanelButtons(datum/source)
	return

/datum/component/gamemode/proc/RoleTopic(datum/source, href, href_list, datum/mind/M, admin_auth)
	return

/datum/component/gamemode/proc/OnPostSetup(datum/source, laterole)
	return

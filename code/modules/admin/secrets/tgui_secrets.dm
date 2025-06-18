// Basic datum for admin secrets on tgui
// Implements basic tgui interface for further use e.g. in holder
// Check modules/admin/secrets/secrets_menu/custom_announcement.dm for example

/datum/tgui_secrets
	var/title = "Admins Secrets"
	var/name = "KitchenSink"

/datum/tgui_secrets/tgui_status()
	return UI_INTERACTIVE

/datum/tgui_secrets/tgui_state()
	return global.admin_state

/datum/tgui_secrets/proc/interact(mob/user)
	tgui_interact(user)

/datum/tgui_secrets/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, name, title)
		ui.open()

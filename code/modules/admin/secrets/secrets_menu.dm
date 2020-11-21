/* Datum for admin secrets */

/datum/secrets_menu
	var/datum/tgui_window/tgui_window
	var/mob/admin
	var/datum/admins/holder
	var/title = "Admin Secrets"
	var/name = "KitchenSink"

/datum/secrets_menu/New(mob/user)
	admin = user
	holder = admin.client.holder

/datum/secrets_menu/Destroy()
	admin = null
	holder = null
	tgui_window = null
	name = null
	return ..()

/datum/secrets_menu/tgui_status()
	return UI_INTERACTIVE

/datum/secrets_menu/proc/interact()
	tgui_interact(admin)

/datum/secrets_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, name, title)
		ui.open()
		tgui_window = ui.window

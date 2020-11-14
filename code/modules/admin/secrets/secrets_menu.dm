/* Datum for admin secrets */

/datum/secrets_menu
    var/datum/tgui/tgui_ui
    var/mob/admin
    var/title = "Admin Secrets"
    var/name = "KitchenSink"

/datum/secrets_menu/New(mob/user)
    admin = user

/datum/secrets_menu/Destroy()
	admin = null
	tgui_ui = null
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
        tgui_ui = ui
        ui.open()

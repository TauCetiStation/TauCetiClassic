/obj/machinery/computer/smartlight
	name = "Central Lighting Control Console"
	desc = "Controls all station smart light lamps. Allows to set the mood for crew."

	icon_state = "computer_generic"

	req_access = list(access_heads)
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)
	fumbling_time = SKILL_TASK_VERY_EASY

	COOLDOWN_DECLARE(heavy_operation_cd)

/obj/machinery/computer/smartlight/ui_interact(mob/user)

	var/html = ""

	var/datum/smartlight_preset/SLP = SSsmartlight.smartlight_preset

	html += "<div class='Section__title'>Settings</div><div class='Section'>"

	var/default_name = SLP.default_mode ? light_modes_by_type[SLP.default_mode].name : "Not Set"
	var/nightshift_name = SLP.nightshift_mode ? light_modes_by_type[SLP.nightshift_mode].name : "Not Set"

	html += "Default mode: <a href='?src=\ref[src];change_default=1'>[default_name]</a><br>"
	html += "Night Shift mode: <a href='?src=\ref[src];change_nightshift=1'>[nightshift_name]</a><br>"

	html += "<br>Night Shift mode currently globally [SSsmartlight.nightshift_active ? "enabled" : "disabled"]."

	html += "</div>"

	html += "<div class='Section__title'>List of available modes</div><div class='Section'>"

	for(var/path in SLP.available_modes)

		if(path in SLP.disabled_modes)
			html += "<a class='bad' href='?src=\ref[src];enable_mode=[path]'>Disabled</a>"
		else
			html += "<a class='good' href='?src=\ref[src];disable_mode=[path]'>Enabled</a>"

		html += " <b>[light_modes_by_type[path].name]</b>"

		html += "<br>"

	html += "</div>"

	html += "<div class='Section'>"
	html += "<a href='?src=\ref[src];sync_apc=1'>Sync all APC Settings</a>"
	html += " <a href='?src=\ref[src];toggle_nightshift=1'>Toggle Night Shift</a>"
	html += "</div>"

	var/datum/browser/popup = new(user, "smartlight_console", name, 400, 500)
	popup.set_content(html)
	popup.open()

/obj/machinery/computer/smartlight/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	var/datum/smartlight_preset/SLP = SSsmartlight.smartlight_preset

	if(href_list["change_default"])
		var/list/datum/light_mode/available_modes = SLP.get_user_available_modes()
		var/mode_name = input(usr, "Please choose new default lighting mode.") as null|anything in available_modes
		if(!can_still_interact_with(usr))
			return
		if(mode_name && available_modes[mode_name])
			SLP.default_mode = available_modes[mode_name].type
			updateUsrDialog()

	else if(href_list["change_nightshift"])
		var/list/datum/light_mode/available_modes = SLP.get_user_available_modes()
		var/mode_name = input(usr, "Please choose new night shift lighting mode.") as null|anything in available_modes
		if(!can_still_interact_with(usr))
			return
		if(mode_name && available_modes[mode_name])
			SLP.nightshift_mode = available_modes[mode_name].type
			updateUsrDialog()

	else if(href_list["enable_mode"])
		var/path = text2path(href_list["enable_mode"])
		if(path in SLP.available_modes)
			SLP.enable_mode(path)
			updateUsrDialog()

	else if(href_list["disable_mode"])
		var/path = text2path(href_list["disable_mode"])
		if(path in SLP.available_modes)
			if(SLP.default_mode == path || SLP.nightshift_mode == path)
				tgui_alert(usr, "Impossible to disable default or night shift mode.")
				return
			SLP.disable_mode(path)
			updateUsrDialog()

	else if(href_list["sync_apc"])
		if(SSsmartlight.forced_admin_mode)
			tgui_alert(usr, "Error: global operations are blocked by CentComm.")
			return
		if(!COOLDOWN_FINISHED(src, heavy_operation_cd))
			tgui_alert(usr, "You must wait at least one minute between each global operation.")
			return
		COOLDOWN_START(src, heavy_operation_cd, 1 MINUTE)
		SSsmartlight.sync_apc()
		updateUsrDialog()

	else if(href_list["toggle_nightshift"])
		if(SSsmartlight.forced_admin_mode)
			tgui_alert(usr, "Error: global operations are blocked by CentComm.")
			return
		if(!COOLDOWN_FINISHED(src, heavy_operation_cd))
			tgui_alert(usr, "You must wait at least one minute between each global operation.")
			return
		COOLDOWN_START(src, heavy_operation_cd, 1 MINUTE)
		SSsmartlight.toggle_nightshift(!SSsmartlight.nightshift_active)
		updateUsrDialog()

/obj/machinery/computer/smartlight/emag_act(mob/user)
	if(emagged)
		return FALSE
	emagged = TRUE

	SSsmartlight.smartlight_preset = new /datum/smartlight_preset/horror_station
	to_chat(user, "<span class='notice'>You did a factory reset!</span>")
	SSsmartlight.sync_apc()
	updateUsrDialog()

/obj/machinery/computer/smartlight/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/disk/smartlight_programm))
		var/obj/item/weapon/disk/smartlight_programm/D = I
		var/type = D.light_mode
		var/datum/smartlight_preset/SLP = SSsmartlight.smartlight_preset
		if(type in SLP.available_modes)
			to_chat(usr, "<span class='warning'>This programm is already installed.</span>")
			return

		if(!global.light_modes_by_type[type])
			stack_trace("Impossible programm: [type]")
			return

		if(!handle_fumbling(user, src, SKILL_TASK_EASY, list(/datum/skill/engineering = SKILL_LEVEL_TRAINED), message_self = "<span class='notice'>You fumble around, figuring out how to install new programm.</span>"))
			return

		to_chat(usr, "<span class='notice'>You have successfully installed new programm.</span>")
		SLP.add_mode(type, disabled = TRUE)
		qdel(D)
	else
		return ..()

/* Programms */

/obj/item/weapon/disk/smartlight_programm
	name = "Smartlight upgrade programm"
	desc = "Programm for expanding capabilities of Central Lighting Control Console"

	icon = 'icons/obj/cloning.dmi' // wtf, why all disk icons in cloning.dmi?
	icon_state = "datadisk0"
	item_state = "card-id"
	w_class = SIZE_TINY

	var/light_mode = /datum/light_mode/default

/obj/item/weapon/disk/smartlight_programm/atom_init()
	var/datum/light_mode/LM = light_mode
	desc += "\nIt contains next programm: \"[initial(LM.name)] lighting mode\""
	return ..()

/obj/item/weapon/disk/smartlight_programm/soft
	light_mode = /datum/light_mode/soft

/obj/item/weapon/disk/smartlight_programm/hard
	light_mode = /datum/light_mode/hard

/obj/item/weapon/disk/smartlight_programm/k3000
	light_mode = /datum/light_mode/k3000

/obj/item/weapon/disk/smartlight_programm/k4000
	light_mode = /datum/light_mode/k4000

/obj/item/weapon/disk/smartlight_programm/k5000
	light_mode = /datum/light_mode/k5000

/obj/item/weapon/disk/smartlight_programm/k6000
	light_mode = /datum/light_mode/k6000

/obj/item/weapon/disk/smartlight_programm/shadows_soft
	light_mode = /datum/light_mode/shadows_soft

/obj/item/weapon/disk/smartlight_programm/shadows_hard
	light_mode = /datum/light_mode/shadows_hard

/obj/item/weapon/disk/smartlight_programm/code_red
	light_mode = /datum/light_mode/code_red

/obj/item/weapon/disk/smartlight_programm/blue_night
	light_mode = /datum/light_mode/blue_night

/obj/item/weapon/disk/smartlight_programm/soft_blue
	light_mode = /datum/light_mode/soft_blue

/obj/item/weapon/disk/smartlight_programm/neon
	light_mode = /datum/light_mode/neon

/obj/item/weapon/disk/smartlight_programm/neon_dark
	light_mode = /datum/light_mode/neon_dark

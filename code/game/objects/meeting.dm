ADD_TO_GLOBAL_LIST(/obj/meeting_button, meeting_buttons)
/obj/meeting_button
	name = "Meeting Red Button"
	desc = "When the impostor is sus."
	icon = 'icons/obj/toy.dmi'
	icon_state = "sound_button_on"
	anchored = TRUE
	w_class = SIZE_SMALL
	var/meeting_id = 0
	var/list/synced_buttons = list()
	var/list/display_names = list()

/obj/meeting_button/atom_init()
	. = ..()
	var/obj/structure/table/table = locate(/obj/structure/table, get_turf(src))
	if(!table)
		return
	RegisterSignal(table, list(COMSIG_PARENT_QDELETING), PROC_REF(deconstruct))

/obj/meeting_button/Destroy()
	for(var/obj/vote_button/V as anything in synced_buttons)
		V.general_button = null
	synced_buttons.Cut()
	return ..()

/obj/meeting_button/proc/add_person_name(name)
	var/list/stored_count = display_names[name]
	if(!length(stored_count))
		display_names[name] = list()
	display_names[name] += "1"

/obj/meeting_button/proc/release_button()
	flick("sound_button_up", src)
	icon_state = "sound_button_on"
	playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER, 50, FALSE, null, -4)

/obj/meeting_button/Click(location, control, params)
	if(display_names.len < 1)
		return ..()
	var/msg = "==============<br>"
	for(var/i in display_names)
		var/list/count = display_names[i]
		if(!length(count))
			continue
		msg += "<span class='notice'>[i] -</span> <span class='userdanger'>[count.len]</span><br>"
	msg += "=============="
	visible_message(message = msg, blind_message = msg, viewing_distance = 3, runechat_msg = "Voting Completed!")
	display_names.Cut()
	for(var/obj/vote_button/V as anything in synced_buttons)
		if(V.avaible_to_choose)
			continue
		V.release_button()
	release_button()

/obj/vote_button
	name = "Vote Button"
	desc = "When the impostor is sus."
	icon = 'icons/obj/toy.dmi'
	icon_state = "sound_button_on"
	anchored = TRUE
	w_class = SIZE_SMALL
	var/avaible_to_choose = TRUE
	var/obj/meeting_button/general_button
	var/meeting_id = 0

/obj/vote_button/atom_init()
	. = ..()
	var/obj/structure/table/table = locate(/obj/structure/table, get_turf(src))
	if(!table)
		return
	RegisterSignal(table, list(COMSIG_PARENT_QDELETING), PROC_REF(deconstruct))

/obj/vote_button/Destroy()
	if(general_button)
		general_button.synced_buttons -= src
		general_button = null
	return ..()

/obj/vote_button/proc/sync_red_buttons()
	for(var/obj/meeting_button/M as anything in global.meeting_buttons)
		if(M.meeting_id == meeting_id)
			general_button = M
			general_button.synced_buttons |= src

/obj/vote_button/Click(location, control, params)
	if(!avaible_to_choose)
		return ..()
	if(!general_button)
		sync_red_buttons()
		if(!general_button)
			return ..()
	var/list/heads_manifest = list()
	for(var/datum/data/record/t in data_core.general)
		if(t.fields["real_rank"] in global.command_positions)
			heads_manifest[sanitize(t.fields["name"])] =  t.fields["photo_f"]
	var/headname = show_radial_menu(usr, src, heads_manifest, require_near = TRUE, tooltips = TRUE)
	if(!headname)
		return
	general_button.add_person_name(headname)
	flick("sound_button_down", src)
	icon_state = "sound_button_off"
	avaible_to_choose = FALSE

/obj/vote_button/proc/release_button()
	flick("sound_button_up", src)
	icon_state = "sound_button_on"
	avaible_to_choose = TRUE
	playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER, 50, FALSE, null, -4)

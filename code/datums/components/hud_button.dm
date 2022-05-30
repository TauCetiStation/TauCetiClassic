
/datum/component/hud_button
	var/time_to_screen_del = null
	var/screen_type = ""

/datum/component/hud_button/Initialize(_time_to_screen_del, _screen_type)
	if(!ishuman(parent) || _time_to_screen_del == null || _screen_type == "")
		return COMPONENT_INCOMPATIBLE

	time_to_screen_del = _time_to_screen_del
	screen_type = _screen_type

	RegisterSignal(parent, list(COMSIG_ADD_HUD_BUTTON), .proc/add_screen)

	addtimer(CALLBACK(parent, .proc/del_screen, screen_type), time_to_screen_del)

/datum/component/hud_button/proc/add_screen(screen_type)
	SIGNAL_HANDLER
	if(screen_type == "Join to Revolution")
		add_revolution_screen()


/datum/component/hud_button/proc/add_revolution_screen(parent)
	var/datum/hud/hud = parent.hud
	var/datum/hud/button = hud.human_hud()
	var/atom/movable/screen/join_to_revolution = null
	join_to_revolution = new /atom/movable/screen()
	join_to_revolution.name = "Join To Revolution"
	join_to_revolution.icon = 'icons/mob/screen1.dmi'
	join_to_revolution.icon_state = "revolution"
	join_to_revolution.screen_loc = ui_lingstingdisplay
	join_to_revolution.plane = ABOVE_HUD_PLANE
	join_to_revolution.invisibility = INVISIBILITY_NONE
	button.adding += join_to_revolution


/datum/component/hud_button/proc/del_screen(parent, screen_type)
	var/mob/living/carbon/human/H = parent
	if(H.client)
		for(var/atom/movable/screen/screen in H.client.screen)
			if(screen.name == screen_type)
				H.client.screen -= screen
				qdel(screen)
				break
	qdel(src)

/datum/component/hud_button/Destroy()
	UnregisterSignal(parent, list(COMSIG_ADD_HUD_BUTTON))
	return ..()

/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/atom/movable/screen
	name = ""
	icon = 'icons/hud/screen1.dmi'
	plane = HUD_PLANE
	flags = ABSTRACT
	vis_flags = VIS_INHERIT_PLANE
	appearance_flags = APPEARANCE_UI
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/internal_switch = 0 // Cooldown for internal switching
	var/assigned_map
	var/del_on_map_removal = TRUE

	var/hud_slot = HUD_SLOT_ADDING
	var/copy_flags = ALL

/atom/movable/screen/Destroy()
	master = null
	return ..()

/atom/movable/screen/proc/add_to_hud(datum/hud/hud)
	switch(hud_slot)
		if(HUD_SLOT_ADDING)
			hud.adding += src
		if(HUD_SLOT_HOTKEYS)
			hud.hotkeybuttons += src
		if(HUD_SLOT_MAIN)
			hud.main += src

	if(hud.hud_shown)
		hud.mymob.client.screen += src
	update_by_hud(hud)
	
/atom/movable/screen/proc/update_by_hud(datum/hud/hud)
	if((copy_flags & HUD_COPY_ICON) && hud.ui_style)
		icon = hud.ui_style
	if((copy_flags & HUD_COPY_ALPHA) && hud.ui_alpha)
		alpha = hud.ui_alpha
	if((copy_flags & HUD_COPY_COLOR) && hud.ui_color)
		color = hud.ui_color
	
/atom/movable/screen/proc/remove_from_hud(datum/hud/hud)
	switch(hud_slot)
		if(HUD_SLOT_ADDING)
			hud.adding -= src
		if(HUD_SLOT_HOTKEYS)
			hud.hotkeybuttons -= src
		if(HUD_SLOT_MAIN)
			hud.main -= src

	hud.mymob.client?.screen -= src

/atom/movable/screen/proc/action(location, control, params)
	return

/atom/movable/screen/Click(location, control, params)
	if(!usr)
		return

	SEND_SIGNAL(src, COMSIG_CLICK, location, control, params, usr)

	action(location, control, params)

/atom/movable/screen/proc/set_screen_loc(new_loc)
	screen_loc = new_loc

/atom/movable/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/atom/movable/screen/grab
	name = "grab"

/atom/movable/screen/grab/action()
	if(master)
		var/obj/item/weapon/grab/G = master
		G.s_click(src)

/atom/movable/screen/grab/attack_hand()
	return

/atom/movable/screen/grab/attackby()
	return FALSE

/atom/movable/screen/nuke
	icon = 'icons/effects/station_explosion.dmi'
	icon_state = "station_intact"
	screen_loc = "1,0"
	plane = SPLASHSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/temp
	plane = SPLASHSCREEN_PLANE
	var/mob/user
	var/delay = 0

/atom/movable/screen/temp/atom_init(mapload, mob/M)
	. = ..()
	user = M
	if(user.client)
		user.client.screen += src
	QDEL_IN(src, delay)

/atom/movable/screen/temp/Destroy()
	if(user.client)
		user.client.screen -= src
	user = null
	return ..()

/atom/movable/screen/temp/cult_teleportation
	name = "cult teleportation"
	icon = 'icons/effects/bloodTP.dmi'
	icon_state = "cult_tp"
	screen_loc = "1,1"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	delay = 8.5

/atom/movable/screen/cooldown_overlay
	name = ""
	icon_state = "cooldown"
	pixel_y = 4
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = RESET_COLOR | PIXEL_SCALE | RESET_TRANSFORM | KEEP_TOGETHER | RESET_ALPHA
	vis_flags = VIS_INHERIT_ID
	var/cooldown_time = 0
	var/atom/movable/screen/parent_button
	var/datum/callback/callback
	var/timer

/atom/movable/screen/cooldown_overlay/atom_init(mapload, button)
	. = ..()
	parent_button = button

/atom/movable/screen/cooldown_overlay/Destroy()
	stop_cooldown()
	deltimer(timer)
	return ..()

/atom/movable/screen/cooldown_overlay/proc/start_cooldown(delay, need_timer = TRUE)
	parent_button.color = "#8000007c"
	parent_button.vis_contents += src
	cooldown_time = delay
	set_maptext(cooldown_time)
	if(need_timer)
		timer = addtimer(CALLBACK(src, PROC_REF(tick)), 1 SECOND, TIMER_STOPPABLE)

/atom/movable/screen/cooldown_overlay/proc/tick()
	if(cooldown_time == 1)
		stop_cooldown()
		return
	cooldown_time--
	set_maptext(cooldown_time)
	if(timer)
		timer = addtimer(CALLBACK(src, PROC_REF(tick)), 1 SECOND, TIMER_STOPPABLE)

/atom/movable/screen/cooldown_overlay/proc/stop_cooldown()
	if(cooldown_time == 0)
		return
	cooldown_time = 0
	parent_button.color = "#ffffffff"
	parent_button.vis_contents -= src
	if(callback)
		callback.Invoke()

/atom/movable/screen/cooldown_overlay/proc/set_maptext(time)
	maptext = "<div style=\"font-size:6pt;font:'Arial Black';text-align:center;\">[time]</div>"

/proc/start_cooldown(atom/movable/screen/button, time, datum/callback/callback)
	if(!time)
		return
	var/atom/movable/screen/cooldown_overlay/cooldown = new(button, button)
	if(callback)
		cooldown.callback = callback
		cooldown.start_cooldown(time)
	else
		cooldown.start_cooldown(time, FALSE)
	return cooldown

/atom/movable/screen/mood
	name = "mood"
	icon_state = "mood5"
	screen_loc = ui_mood

	copy_flags = NONE

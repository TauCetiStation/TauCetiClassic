#define DAMAGE_LAYER FULLSCREEN_LAYER + 0.1
#define BLIND_LAYER DAMAGE_LAYER + 0.1
#define CRIT_LAYER BLIND_LAYER + 0.1

/mob
	var/list/screens = list()

/mob/proc/overlay_fullscreen(category, type, severity)
	var/obj/screen/fullscreen/screen
	if(screens[category])
		screen = screens[category]
		if(screen.type != type)
			clear_fullscreen(category, FALSE)
			return .()
		else if(!severity || severity == screen.severity)
			return null
	else
		screen = new type()

	screen.icon_state = "[initial(screen.icon_state)][severity]"
	screen.severity = severity
	screen.invisibility = initial(screen.invisibility)

	screens[category] = screen
	if(client)
		client.screen += screen
		screen.add_screen_part(client)
	return screen

/mob/proc/clear_fullscreen(category, animate = 10)
	set waitfor = 0
	var/obj/screen/fullscreen/screen = screens[category]
	if(!screen)
		return

	if(animate)
		animate(screen, alpha = 0, time = animate)
		sleep(animate)

	screens -= category
	if(client)
		client.screen -= screen
		screen.remove_screen_part(client)
	qdel(screen)

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category)

/datum/hud/proc/reload_fullscreen()
	var/list/screens = mymob.screens
	for(var/category in screens)
		var/obj/screen/fullscreen/screen = screens[category]
		mymob.client.screen |= screen
		screen.add_screen_part(mymob.client, TRUE)


/obj/screen/fullscreen
	icon = 'icons/mob/screen1_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = 0
	var/severity = 0
	var/obj/screen/fullscreen/screen_part

/obj/screen/fullscreen/Destroy()
	QDEL_NULL(screen_part)
	severity = 0
	return ..()

/obj/screen/fullscreen/proc/add_screen_part(client/C, reload)
	return

/obj/screen/fullscreen/proc/remove_screen_part(client/C)
	return

/obj/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/fullscreen/crit
	icon_state = "passage"
	layer = CRIT_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = BLIND_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = MOUSE_OPACITY_ICON

/obj/screen/fullscreen/blind/add_screen_part(client/C, reload)
	if(!screen_part)
		screen_part = new /obj/screen/fullscreen/blind/ring
	if(!reload)
		C.screen += screen_part
	else
		C.screen |= screen_part

/obj/screen/fullscreen/blind/remove_screen_part(client/C)
	C.screen -= screen_part

/obj/screen/fullscreen/blind/ring
	icon_state = "blackimageoverlay_ring"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/fullscreen/blind/Click(location, control, params)
	if(usr.client.void)
		usr.client.void.Click(location, control, params)

/obj/screen/fullscreen/impaired
	icon_state = "impairedoverlay"

/obj/screen/fullscreen/blurry
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blurry"

/obj/screen/fullscreen/flash
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "flash"

/obj/screen/fullscreen/flash/noise
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "noise"

/obj/screen/fullscreen/high
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"

#undef FULLSCREEN_LAYER
#undef BLIND_LAYER
#undef DAMAGE_LAYER
#undef CRIT_LAYER

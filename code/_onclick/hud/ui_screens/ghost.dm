/atom/movable/screen/ghost
	icon = 'icons/hud/screen_ghost.dmi'

/atom/movable/screen/ghost/MouseEntered()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/jumptomob
	name = "Jump to mob"
	icon_state = "jumptomob"
	screen_loc = ui_ghost_jumptomob

/atom/movable/screen/ghost/jumptomob/Click()
	var/mob/dead/observer/G = usr
	G.jumptomob()

/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"
	screen_loc = ui_ghost_orbit

/atom/movable/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()

/atom/movable/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"
	screen_loc = ui_ghost_reenter_corpse

/atom/movable/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"
	screen_loc = ui_ghost_teleport

/atom/movable/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/atom/movable/screen/ghost/mafia
	name = "Mafia Signup"
	icon_state = "mafia"
	screen_loc = ui_ghost_mafia

/atom/movable/screen/ghost/mafia/Click()
	var/mob/dead/observer/G = usr
	G.mafia_signup()

/atom/movable/screen/ghost/spawners_menu
	name = "Spawners menu"
	icon_state = "spawners"
	screen_loc = ui_ghost_spawners_menu

/atom/movable/screen/ghost/spawners_menu/Click()
	var/mob/dead/observer/observer = usr
	observer.open_spawners_menu()

/atom/movable/screen/ghost/toggle_darkness
	name = "Toggle Darkness"
	icon_state = "toggle_darkness"
	screen_loc = ui_ghost_toggle_darkness

/atom/movable/screen/ghost/toggle_darkness/Click()
	var/mob/dead/observer/G = usr
	G.toggle_darkness()

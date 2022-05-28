/area/lepr
	name = "Логово Жадности"
	icon_state = "green"
	ambience = list(
		'sound/ambience/lepr1.ogg',
		'sound/ambience/lepr2.ogg',)
	is_force_ambience = TRUE

/obj/effect/portal/lepr
	name = "На повехность"
	var/area/A =/area/custom/lepr_exit
	var/list/turf/possible_tile
	icon = 'icons/obj/objects.dmi'
	icon_state = "bluespace_wormhole_enter"
	failchance = 0

/obj/effect/portal/lepr/atom_init()
	possible_tile = get_area_turfs(get_area_by_type(A))
	target = pick(possible_tile)
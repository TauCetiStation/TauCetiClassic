/datum/hud/proc/ian_hud()
	if(!(is_alien_whitelisted(mymob, "ian") || (mymob.client.supporter && !is_alien_whitelisted_banned(mymob, "ian"))))
		return

	ui_style = 'icons/mob/screen_corgi.dmi'

	add_intents()

	var/list/types = list(
		/atom/movable/screen/resist/ian,
		/atom/movable/screen/corgi/sit_lie,
		/atom/movable/screen/drop,
	)
	init_screens(types)

	add_move_intent()

	add_stamina_display()

	get_screen(/atom/movable/screen/inventory/head/ian)

	get_screen(/atom/movable/screen/corgi/ability)

	add_hands(r_type = /atom/movable/screen/inventory/corgi_mouth, l_type = FALSE)

	types = list(
		/atom/movable/screen/inventory/corgi_neck,
		/atom/movable/screen/inventory/back/ian
	)
	init_screens(types)

	add_healths()
	add_pullin()
	add_zone_sel()

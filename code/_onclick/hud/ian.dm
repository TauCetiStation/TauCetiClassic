/datum/hud/proc/ian_hud()
	if(!(is_alien_whitelisted(mymob, "ian") || (mymob.client.supporter && !is_alien_whitelisted_banned(mymob, "ian"))))
		return

	ui_style = 'icons/mob/screen_corgi.dmi'

	default_hud()

	var/list/types = list(
		/atom/movable/screen/resist/ian, // hotkeys
		/atom/movable/screen/drop,
		/atom/movable/screen/corgi/sit_lie, // ian abilities
		/atom/movable/screen/corgi/ability,
		/atom/movable/screen/inventory/corgi_neck, // inventory
		/atom/movable/screen/inventory/head/ian,
		/atom/movable/screen/inventory/back/ian,
	)
	init_screens(types)

	add_stamina_display()

	add_hands(r_type = /atom/movable/screen/inventory/corgi_mouth, l_type = FALSE)

	add_healths(/atom/movable/screen/health/ian)

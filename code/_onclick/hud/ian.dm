/mob/living/carbon/ian/add_to_hud(datum/hud/hud)
	if(!(is_alien_whitelisted(src, "ian") || (src.client.supporter && !is_alien_whitelisted_banned(src, "ian"))))
		return

	hud.ui_style = 'icons/hud/screen_corgi.dmi'

	..(hud, FALSE)

	hud.init_screens(list(
		/atom/movable/screen/resist/ian,
		/atom/movable/screen/drop,
		/atom/movable/screen/corgi/sit_lie,
		/atom/movable/screen/corgi/ability,
		/atom/movable/screen/inventory/corgi_neck,
		/atom/movable/screen/inventory/head/ian,
		/atom/movable/screen/inventory/back/ian,
		/atom/movable/screen/corgi/stamina_bar,
		/atom/movable/screen/inventory/hand/r/corgi,
		/atom/movable/screen/health/ian,
	))

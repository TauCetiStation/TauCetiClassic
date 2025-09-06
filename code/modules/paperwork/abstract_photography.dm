/obj/item/device/camera/abstract
	flash_enabled = FALSE

/obj/item/device/camera/abstract/captureimage(atom/target, atom/from)
	var/mobs = ""
	var/list/mob_names = list()

	var/list/seen

	if(from)
		seen = hear(world.view, from)
	else
		seen = hear(world.view, target)


	var/list/turfs = list()
	for(var/turf/T in range(round(photo_size * 0.5), target))
		if(T in seen)
			var/detail_list = camera_get_mobs(T)
			turfs += T
			mobs += detail_list["mob_detail"]
			mob_names += detail_list["names_detail"]

	var/icon/temp = get_base_photo_icon()
	temp.Blend("#000", ICON_OVERLAY)
	temp.Blend(camera_get_icon(turfs, target), ICON_OVERLAY)

	//Photo Effects
	if(lens)
		if(lens.effect)
			//First Flter
			if(lens.effect["effect1"])
				temp.MapColors(arglist(lens.effect["effect1"]))

			//Additions
			if(lens.effect["mask"])
				var/icon/vign
				switch(photo_size)
					if(1)
						vign = icon('icons/effects/32x32.dmi', lens.effect["mask"])
					if(3)
						vign = icon('icons/effects/96x96.dmi', lens.effect["mask"])
					if(5)
						vign = icon('icons/effects/160x160.dmi', lens.effect["mask"])
				temp.Blend(vign, ICON_OVERLAY, 1, 1)

			//Second Filter
			if(lens.effect["effect2"])
				temp.MapColors(arglist(lens.effect["effect2"]))

	return createpicture(from, temp, mobs, mob_names)


/obj/item/device/camera/abstract/vendomat
	name = "vendomat camera"
	desc = "A built-in vendomat camera module."
	pictures_left = 30
	can_put_lens = FALSE
	base_lens = /obj/item/device/lens/grayscale
	photo_size = 5
	flash_enabled = TRUE

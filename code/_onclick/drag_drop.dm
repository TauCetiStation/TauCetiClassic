/*
	MouseDrop:

	Called on the atom you're dragging.  In a lot of circumstances we want to use the
	recieving object instead, so that's the default action.  This allows you to drag
	almost anything into a trash can.
*/
/atom/proc/CanMouseDrop(atom/over, mob/user = usr)
	if(!user || !over)
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!src.Adjacent(user) || !over.Adjacent(user))
		return FALSE // should stop you from dragging through windows
	return TRUE

/atom/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.gestalt_direct_control)
			var/list/modifiers = params2list(params)
			if(modifiers["alt"] || modifiers["ctrl"])
				var/turf/src_T = get_turf(src)
				var/turf/over_T = get_turf(over)
				if(src_T && over_T)
					var/list/turfs_ = block(src_T, over_T)
					var/x_sc = 0
					var/y_sc = 0
					var/x_off = 0
					var/y_off = 0
					if(over_T.x > src_T.x)
						x_sc = over_T.x - src_T.x
						x_off = x_sc * 16
					else
						x_sc = src_T.x - over_T.x
						x_off = -(x_sc * 16)
					if(over_T.y > src_T.y)
						y_sc = over_T.y - src_T.y
						y_off = y_sc * 16
					else
						y_sc = src_T.y - over_T.y
						y_off = -(y_sc * 16)
					x_sc += 1
					y_sc += 1
					var/language_key = ":q"
					var/turf/H_T = get_turf(H)
					if(istype(H_T, /turf/space))
						language_key = ":f"
					else
						var/datum/gas_mixture/environment = H_T.return_air()
						if(environment)
							var/pressure = environment.return_pressure()
							if(pressure < SOUND_MINIMUM_PRESSURE)
								language_key = ":f"
					for(var/turf/T in turfs_)
						for(var/atom/A in T)
							if(istype(A, /mob/living/carbon/monkey/diona))
								var/mob/living/carbon/monkey/diona/D = A
								if(D.gestalt == H)
									if(modifiers["alt"])
										if(D.selected)
											H.queue_order("[language_key] [D.my_number] select stop.")
									else if(modifiers["ctrl"])
										if(!D.selected)
											H.queue_order("[language_key] [D.my_number] select.")

					var/image/turf_image = image(icon = 'icons/misc/tools.dmi', loc = src_T, icon_state = "tile_selected_full")
					turf_image.layer = LIGHTING_LAYER + 1
					turf_image.plane = LIGHTING_PLANE + 1
					turf_image.color = H.unique_diona_hive_color
					turf_image.transform = matrix(matrix(), x_sc, y_sc, MATRIX_SCALE)
					turf_image.pixel_x = x_off
					turf_image.pixel_y = y_off

					flick_overlay(turf_image, list(H.client), 1 SECOND)
			else
				for(var/mob/living/carbon/monkey/diona/D in H.gestalt_subordinates)
					if(D.stat != CONSCIOUS)
						continue
					if(get_dist(H, D) > 10)
						continue
					if(!Adjacent(D) || !over.Adjacent(D))
						continue
					INVOKE_ASYNC(over, /atom.proc/MouseDrop_T, src, D)
			return
	if(!Adjacent(usr) || !over.Adjacent(usr))
		return // should stop you from dragging through windows

	INVOKE_ASYNC(over, /atom.proc/MouseDrop_T, src, usr)

// recieve a mousedrop
/atom/proc/MouseDrop_T(atom/dropping, mob/user)
	return

/obj/mecha/medical/atom_init()
	. = ..()
	var/turf/T = get_turf(src)
	if(!is_centcom_level(T.z) && !is_junkyard_level(T.z))
		new /obj/item/mecha_parts/mecha_tracking(src)


/obj/mecha/medical/mechturn(direction)
	set_dir(direction)
	playsound(src, 'sound/mecha/mechmove01.ogg', VOL_EFFECTS_MASTER, 40)
	return 1

/obj/mecha/medical/mechstep(direction)
	var/old_loc = loc
	var/result = step(src,direction)
	if(result)
		playsound(src, 'sound/mecha/mechstep.ogg', VOL_EFFECTS_MASTER, 25)
		direction = get_dir(src, old_loc)
		if(ISDIAGONALDIR(direction))
			return 2
	return result

/obj/mecha/medical/mechsteprand()
	var/result = step_rand(src)
	if(result)
		playsound(src, 'sound/mecha/mechstep.ogg', VOL_EFFECTS_MASTER, 25)
	return result

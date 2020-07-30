// RIGHT CLICK TELEPORT
//Right click to teleport somewhere, almost exactly like admin jump to turf.
/obj/item/clothing/suit/space/space_ninja/proc/ninjashift(turf/T in oview())
	set name = "Phase Shift (400E)"
	set desc = "Utilizes the internal VOID-shift device to rapidly transit to a destination in view."
	set category = null//So it does not show up on the panel but can still be right-clicked.
	set src = usr.contents//Fixes verbs not attaching properly for objects. Praise the DM reference guide!

	var/C = 40
	if(!ninjacost(C,1))
		var/mob/living/carbon/human/U = affecting
		var/turf/mobloc = get_turf(U.loc)//To make sure that certain things work properly below.
		if((!T.density)&&istype(mobloc, /turf))
			spawn(0)
				playsound(U, 'sound/effects/sparks4.ogg', VOL_EFFECTS_MASTER)
				anim(mobloc,src,'icons/mob/mob.dmi',,"phaseout",,U.dir)

			cell.use(C*10)
			handle_teleport_grab(T, U)
			U.forceMove(T)

			spawn(0)
				spark_system.start()
				playsound(U, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER, 25)
				playsound(U, 'sound/effects/sparks2.ogg', VOL_EFFECTS_MASTER)
				anim(U.loc,U,'icons/mob/mob.dmi',,"phasein",,U.dir)
		else
			to_chat(U, "<span class='warning'>You cannot teleport into solid walls or from solid matter.</span>")
	return


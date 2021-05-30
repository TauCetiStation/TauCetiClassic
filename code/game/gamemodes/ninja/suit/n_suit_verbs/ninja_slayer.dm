//=======//5 TILE TELEPORT/GIB//=======//
//Allows to gib up to five squares in a straight line. Seriously.
/obj/item/clothing/suit/space/space_ninja/proc/ninjaslayer()
	set name = "Phase Slayer"
	set desc = "Utilizes the internal VOID-shift device to mutilate creatures in a straight line."
	set category = "Ninja Ability"
	set popup_menu = 0

	if(!ninjacost())
		var/mob/living/carbon/human/U = affecting
		var/turf/destination = get_teleport_loc(U.loc,U,5)
		var/turf/mobloc = get_turf(U.loc)//To make sure that certain things work properly below.
		if(destination&&istype(mobloc, /turf))
			U.say("Ai Satsugai!")
			spawn(0)
				playsound(U, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
				anim(mobloc,U,'icons/mob/mob.dmi',,"phaseout",,U.dir)

			spawn(0)
				for(var/turf/T in getline(mobloc, destination))
					spawn(0)
						T.kill_creatures(U)
					if(T==mobloc||T==destination)	continue
					spawn(0)
						anim(T,U,'icons/mob/mob.dmi',,"phasein",,U.dir)

			handle_teleport_grab(destination, U)
			U.loc = destination

			spawn(0)
				spark_system.start()
				playsound(U, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER, 25)
				playsound(U, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
				anim(U.loc,U,'icons/mob/mob.dmi',,"phasein",,U.dir)
			s_coold = 1
		else
			to_chat(U, "<span class='warning'>The VOID-shift device is malfunctioning, <B>teleportation failed</B>.</span>")
	return

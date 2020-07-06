/*
  * KAMIKAZE MODE
  * Or otherwise known as anime mode. Which also happens to be ridiculously powerful.
*/

// NINJA MOVEMENT
//Also makes you move like you're on crack.
/obj/item/clothing/suit/space/space_ninja/proc/ninjawalk()
	set name = "Shadow Walk"
	set desc = "Combines the VOID-shift and CLOAK-tech devices to freely move between solid matter. Toggle on or off."
	set category = "Ninja Ability"
	set popup_menu = 0

	var/mob/living/carbon/human/U = affecting
	if(!U.incorporeal_move)
		U.incorporeal_move = 2
		to_chat(U, "<span class='notice'>You will now phase through solid matter.</span>")
	else
		U.incorporeal_move = 0
		to_chat(U, "<span class='notice'>You will no-longer phase through solid matter.</span>")
	return

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

// TELEPORT BEHIND MOB
/*Appear behind a randomly chosen mob while a few decoy teleports appear.
This is so anime it hurts. But that's the point.*/
/obj/item/clothing/suit/space/space_ninja/proc/ninjamirage()
	set name = "Spider Mirage"
	set desc = "Utilizes the internal VOID-shift device to create decoys and teleport behind a random target."
	set category = "Ninja Ability"
	set popup_menu = 0

	if(!ninjacost())//Simply checks for stat.
		var/mob/living/carbon/human/U = affecting
		var/targets[]
		targets = new()
		for(var/mob/living/M in oview(6))
			if(M.incapacitated())
				continue
			targets.Add(M)
		if(targets.len)
			var/mob/living/target=pick(targets)
			var/locx
			var/locy
			var/turf/mobloc = get_turf(target.loc)
			var/safety = 0
			switch(target.dir)
				if(NORTH)
					locx = mobloc.x
					locy = (mobloc.y-1)
					if(locy<1)
						safety = 1
				if(SOUTH)
					locx = mobloc.x
					locy = (mobloc.y+1)
					if(locy>world.maxy)
						safety = 1
				if(EAST)
					locy = mobloc.y
					locx = (mobloc.x-1)
					if(locx<1)
						safety = 1
				if(WEST)
					locy = mobloc.y
					locx = (mobloc.x+1)
					if(locx>world.maxx)
						safety = 1
				else	safety=1
			if(!safety&&istype(mobloc, /turf))
				U.say("Kumo no Shinkiro!")
				var/turf/picked = locate(locx,locy,mobloc.z)
				spawn(0)
					playsound(U, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
					anim(mobloc,U,'icons/mob/mob.dmi',,"phaseout",,U.dir)

				spawn(0)
					var/limit = 4
					for(var/turf/T in oview(5))
						if(prob(20))
							spawn(0)
								anim(T,U,'icons/mob/mob.dmi',,"phasein",,U.dir)
							limit--
						if(limit<=0)	break

				handle_teleport_grab(picked, U)
				U.loc = picked
				U.dir = target.dir

				spawn(0)
					spark_system.start()
					playsound(U, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER, 25)
					playsound(U, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
					anim(U.loc,U,'icons/mob/mob.dmi',,"phasein",,U.dir)
				s_coold = 1
			else
				to_chat(U, "<span class='warning'>The VOID-shift device is malfunctioning, <B>teleportation failed</B>.</span>")
		else
			to_chat(U, "<span class='warning'>There are no targets in view.</span>")
	return

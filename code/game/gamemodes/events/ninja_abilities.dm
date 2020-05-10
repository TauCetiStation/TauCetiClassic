/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+++++++++++++++++++++++++++++++++//                    //++++++++++++++++++++++++++++++++++
==================================SPACE NINJA ABILITIES====================================
___________________________________________________________________________________________
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//=======//SAFETY CHECK//=======//
/*
X is optional, tells the proc to check for specific stuff. C is also optional.
All the procs here assume that the character is wearing the ninja suit if they are using the procs.
They should, as I have made every effort for that to be the case.
In the case that they are not, I imagine the game will run-time error like crazy.
s_cooldown ticks off each second based on the suit recharge proc, in seconds. Default of 1 seconds. Some abilities have no cool down.
*/
/obj/item/clothing/suit/space/space_ninja/proc/ninjacost(C = 0,X = 0)
	var/mob/living/carbon/human/U = affecting
	if( (U.stat||U.incorporeal_move)&&X!=3 )//Will not return if user is using an adrenaline booster since you can use them when stat==1.
		to_chat(U, "<span class='warning'>You must be conscious and solid to do this.</span>")//It's not a problem of stat==2 since the ninja will explode anyway if they die.
		return 1
	else if(C&&cell.charge<C*10)
		to_chat(U, "<span class='warning'>Not enough energy.</span>")
		return 1
	switch(X)
		if(1)
			cancel_stealth()//Get rid of it.
		if(2)
			if(s_bombs<=0)
				to_chat(U, "<span class='warning'>There are no more smoke bombs remaining.</span>")
				return 1
		if(3)
			if(a_boost<=0)
				to_chat(U, "<span class='warning'>You do not have any more adrenaline boosters.</span>")
				return 1
	return (s_coold)//Returns the value of the variable which counts down to zero.

//=======//SMOKE//=======//
/*Summons smoke in radius of user.
Not sure why this would be useful (it's not) but whatever. Ninjas need their smoke bombs.*/
/obj/item/clothing/suit/space/space_ninja/proc/ninjasmoke()
	set name = "Smoke Bomb"
	set desc = "Blind your enemies momentarily with a well-placed smoke bomb."
	set category = "Ninja Ability"
	set popup_menu = 0//Will not see it when right clicking.

	if(!ninjacost(,2))
		var/mob/living/carbon/human/U = affecting
		var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
		smoke.set_up(10, 0, U.loc)
		smoke.start()
		playsound(U, 'sound/effects/bamf.ogg', VOL_EFFECTS_MASTER)
		s_bombs--
		s_coold = 1
		to_chat(U, "<span class='info'>There are <B>[s_bombs]</B> smoke bombs remaining.</span>")
	return


//=======//RIGHT CLICK TELEPORT//=======//
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

//=======//EM PULSE//=======//
//Disables nearby tech equipment.
/obj/item/clothing/suit/space/space_ninja/proc/ninjapulse()
	set name = "EM Burst (2,000E)"
	set desc = "Disable any nearby technology with a electro-magnetic pulse."
	set category = "Ninja Ability"
	set popup_menu = 0

	var/C = 200
	if(!ninjacost(C,0)) // EMP's now cost 1,000Energy about 30%
		var/mob/living/carbon/human/U = affecting
		playsound(U, 'sound/effects/EMPulse.ogg', VOL_EFFECTS_MASTER)
		empulse(U, 2, 3) //Procs sure are nice. Slightly weaker than wizard's disable tch.
		s_coold = 2
		cell.use(C*10)
	return

//=======//ENERGY BLADE//=======//
//Summons a blade of energy in active hand.
/obj/item/clothing/suit/space/space_ninja/proc/ninjablade()
	set name = "Energy Blade (500E)"
	set desc = "Create a focused beam of energy in your active hand."
	set category = "Ninja Ability"
	set popup_menu = 0

	var/C = 50
	if(!ninjacost(C,0)) //Same spawn cost but higher upkeep cost
		var/mob/living/carbon/human/U = affecting
		if(!kamikaze)
			cancel_stealth()
			if(!U.get_active_hand()&&!istype(U.get_inactive_hand(), /obj/item/weapon/melee/energy/blade))
				var/obj/item/weapon/melee/energy/blade/W = new()
				spark_system.start()
				playsound(U, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
				U.put_in_hands(W)
				cell.use(C*10)
			else
				to_chat(U, "<span class='warning'>You can only summon one blade. Try dropping an item first.</span>")
		else//Else you can run around with TWO energy blades. I don't know why you'd want to but cool factor remains.
			if(!U.get_active_hand())
				var/obj/item/weapon/melee/energy/blade/W = new()
				U.put_in_hands(W)
			if(!U.get_inactive_hand())
				var/obj/item/weapon/melee/energy/blade/W = new()
				U.put_in_inactive_hand(W)
			spark_system.start()
			playsound(U, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			s_coold = 1
	return

//=======//NINJA STARS//=======//
/*Shoots ninja stars at random people.
This could be a lot better but I'm too tired atm.*/
/obj/item/clothing/suit/space/space_ninja/proc/ninjastar()
	set name = "Energy Star (800E)"
	set desc = "Launches an energy star at a random living target."
	set category = "Ninja Ability"
	set popup_menu = 0

	var/C = 80
	if(!ninjacost(C,1))
		var/mob/living/carbon/human/U = affecting
		var/targets[] = list()//So yo can shoot while yo throw dawg
		for(var/mob/living/M in oview(loc))
			if(M.incapacitated())
				continue
			targets.Add(M)
		if(targets.len)
			var/mob/living/target=pick(targets)//The point here is to pick a random, living mob in oview to shoot stuff at.

			var/turf/curloc = U.loc
			var/atom/targloc = get_turf(target)
			if (!targloc || !istype(targloc, /turf) || !curloc)
				return
			if (targloc == curloc)
				return
			var/obj/item/projectile/energy/dart/A = new(curloc)
			A.starting = get_turf(affecting)
			A.current = curloc
			A.original = targloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			cell.use(C*10)
			A.process()
		else
			to_chat(U, "<span class='warning'>There are no targets in view.</span>")
	return

//=======//ENERGY NET//=======//
/*Allows the ninja to capture people, I guess.
Must right click on a mob to activate.*/
/obj/item/clothing/suit/space/space_ninja/proc/ninjanet(mob/living/carbon/M in oview())//Only living carbon mobs.
	set name = "Energy Net (500E)"
	set desc = "Captures a opponent in a net of energy."
	set category = null
	set src = usr.contents

	//var/C = 700
	var/C = 50
	if(!ninjacost(C,0)&&iscarbon(M))
		var/mob/living/carbon/human/U = affecting
		if(M.client)//Monkeys without a client can still step_to() and bypass the net. Also, netting inactive people is lame.
		//if(M)//DEBUG
			if(!locate(/obj/effect/energy_net) in M.loc)//Check if they are already being affected by an energy net.
				for(var/turf/T in getline(U.loc, M.loc))
					if(T.density)//Don't want them shooting nets through walls. It's kind of cheesy.
						to_chat(U, "You may not use an energy net through solid obstacles!")
						return
				spawn(0)
					U.Beam(M,"n_beam",,15)
				M.captured = 1
				U.say("Get over here!")
				var/obj/effect/energy_net/E = new /obj/effect/energy_net(M.loc)
				E.layer = M.layer+1//To have it appear one layer above the mob.
				U.visible_message("<span class='warning'>[U] caught [M] with an energy net!</span>")
				E.affecting = M
				E.master = U
				spawn(0)//Parallel processing.
					E.process(M)
				cell.use(C*10) // Nets now cost what should be most of a standard battery, since your taking someone out of the round
			else
				to_chat(U, "They are already trapped inside an energy net.")
		else
			to_chat(U, "They will bring no honor to your Clan!")
	return

//=======//ADRENALINE BOOST//=======//
/*Wakes the user so they are able to do their thing. Also injects a decent dose of radium.
Movement impairing would indicate drugs and the like.*/
/obj/item/clothing/suit/space/space_ninja/proc/ninjaboost()
	set name = "Adrenaline Boost"
	set desc = "Inject a secret chemical that will counteract all movement-impairing effect."
	set category = "Ninja Ability"
	set popup_menu = 0

	if(!ninjacost(,3))//Have to make sure stat is not counted for this ability.
		var/mob/living/carbon/human/U = affecting
		//Wouldn't need to track adrenaline boosters if there was a miracle injection to get rid of paralysis and the like instantly.
		//For now, adrenaline boosters ARE the miracle injection. Well, radium, really.
		U.SetParalysis(0)
		U.SetWeakened(0)
	/*
	Due to lag, it was possible to adrenaline boost but remain helpless while life.dm resets player stat.
	This lead to me and others spamming adrenaline boosters because they failed to kick in on time.
	It's technically possible to come back from crit with this but it is very temporary.
	Life.dm will kick the player back into unconsciosness the next process loop.
	*/
		U.stat = CONSCIOUS//At least now you should be able to teleport away or shoot ninja stars.
		spawn(30)//Slight delay so the enemy does not immedietly know the ability was used. Due to lag, this often came before waking up.
			U.say(pick("A CORNERED FOX IS MORE DANGEROUS THAN A JACKAL!","HURT ME MOOORRREEE!","IMPRESSIVE!"))
		spawn(70)
			reagents.reaction(U, 2)
			reagents.trans_id_to(U, "radium", a_transfer)
			to_chat(U, "<span class='warning'>You are beginning to feel the after-effect of the injection.</span>")
		a_boost--
		s_coold = 3
	return

/*
===================================================================================
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<KAMIKAZE MODE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
===================================================================================
Or otherwise known as anime mode. Which also happens to be ridiculously powerful.
*/

//=======//NINJA MOVEMENT//=======//
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

//=======//TELEPORT BEHIND MOB//=======//
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

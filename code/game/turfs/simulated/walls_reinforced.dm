/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "r_wall"
	opacity = 1
	density = 1

	damage_cap = 200
	max_temperature = 20000

	walltype = "rwall"
	sheet_type = /obj/item/stack/sheet/plasteel

	var/d_state = 0

/turf/simulated/wall/r_wall/attack_hand(mob/user)
	if(HULK in user.mutations) //#Z2
		if(user.a_intent == "hurt")
			to_chat(user, text("\blue You punch the wall."))
			take_damage(rand(5, 25))
			if(prob(25))
				user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			if(prob(5))
				playsound(user.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
				var/organ_name = pick("l_arm","r_arm")
				if(user.hand)
					organ_name = "l_arm"
				else
					organ_name = "r_arm"
				var/mob/living/carbon/human/H = user
				var/datum/organ/external/E = H.get_organ(organ_name)
				E.take_damage(rand(5, 15), 0, 0, 0, "Reinforced wall")
				to_chat(user, text("\red Ouch!!"))
			else
				playsound(user.loc, 'sound/effects/grillehit.ogg', 50, 1)
			return //##Z2

	if(rotting)
		to_chat(user, "\blue This wall feels rather unstable.")
		return

	/*user << "\blue You push the wall but nothing happens!"
	playsound(src, 'sound/weapons/Genhit.ogg', 25, 1)
	src.add_fingerprint(user)*/ //this code is in standard wall attack_hand proc
	..()
	return


/turf/simulated/wall/r_wall/attackby(obj/item/W, mob/user)

	if (!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	//get the user's location
	if(!istype(user.loc, /turf))
		return	//can't do this stuff whilst inside objects and such

	if(rotting)
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0,user))
				to_chat(user, "<span class='notice'>You burn away the fungi with \the [WT].</span>")
				playsound(src, 'sound/items/Welder.ogg', 10, 1)
				for(var/obj/effect/E in src) if(E.name == "Wallrot")
					qdel(E)
				rotting = 0
				return
		else if(!is_sharp(W) && W.force >= 10 || W.force >= 20)
			to_chat(user, "<span class='notice'>\The [src] crumbles away under the force of your [W.name].</span>")
			src.dismantle_wall()
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0,user))
				thermitemelt(user)
				return

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			thermitemelt(user)
			return

		else if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			to_chat(user, "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>")
			playsound(src, "sparks", 50, 1)
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)

			thermitemelt(user)
			return

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		to_chat(user, "<span class='notice'>This wall is too thick to slice through. You will need to find a different path.</span>")
		return

	if(damage && istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>You start repairing the damage to [src].</span>")
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			if(do_after(user, max(5, damage / 5), target = src) && WT && WT.isOn())
				to_chat(user, "<span class='notice'>You finish repairing the damage to [src].</span>")
				take_damage(-damage)
			return
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return

	var/turf/T = user.loc	//get user's location for delay checks

	//DECONSTRUCTION
	switch(d_state)
		if(0)
			if (istype(W, /obj/item/weapon/wirecutters))
				playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
				src.d_state = 1
				src.icon_state = "r_wall-1"
				new /obj/item/stack/rods(src)
				to_chat(user, "<span class='notice'>You cut the outer grille.</span>")
				return

		if(1)
			if (istype(W, /obj/item/weapon/screwdriver))
				to_chat(user, "<span class='notice'>You begin removing the support lines.</span>")
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)

				if(do_after(user,40,target = src))
					if(!istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T)
						return

					if(d_state == 1 && user.loc == T && user.get_active_hand() == W)
						src.d_state = 2
						src.icon_state = "r_wall-2"
						to_chat(user, "<span class='notice'>You remove the support lines.</span>")
				return

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/O = W
				src.d_state = 0
				src.icon_state = "r_wall"
				relativewall_neighbours()	//call smoothwall stuff
				to_chat(user, "<span class='notice'>You replace the outer grille.</span>")
				if (O.amount > 1)
					O.amount--
				else
					qdel(O)
				return

		if(2)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))

					to_chat(user, "<span class='notice'>You begin slicing through the metal cover.</span>")
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user,60,target = src))
						if(!istype(src, /turf/simulated/wall/r_wall) || !user || !WT || !WT.isOn() || !T)
							return

						if(d_state == 2 && user.loc == T && user.get_active_hand() == WT)
							src.d_state = 3
							src.icon_state = "r_wall-3"
							to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return

			if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))

				to_chat(user, "<span class='notice'>You begin slicing through the metal cover.</span>")
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user,60,target = src))
					if(!istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T)
						return

					if(d_state == 2 && user.loc == T && user.get_active_hand() == W)
						src.d_state = 3
						src.icon_state = "r_wall-3"
						to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				return

		if(3)
			if (istype(W, /obj/item/weapon/crowbar))

				to_chat(user, "<span class='notice'>You struggle to pry off the cover.</span>")
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user,100,target = src))
					if(!istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T)
						return

					if(d_state == 3 && user.loc == T && user.get_active_hand() == W)
						src.d_state = 4
						src.icon_state = "r_wall-4"
						to_chat(user, "<span class='notice'>You pry off the cover.</span>")
				return

		if(4)
			if (istype(W, /obj/item/weapon/wrench))

				to_chat(user, "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame.</span>")
				playsound(src, 'sound/items/Ratchet.ogg', 100, 1)

				if(do_after(user,40,target = src))
					if(!istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T)
						return

					if(d_state == 4 && user.loc == T && user.get_active_hand() == W)
						src.d_state = 5
						src.icon_state = "r_wall-5"
						to_chat(user, "<span class='notice'>You remove the bolts anchoring the support rods.</span>")
				return

		if(5)
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))

					to_chat(user, "<span class='notice'>You begin slicing through the support rods.</span>")
					playsound(src, 'sound/items/Welder.ogg', 100, 1)

					if(do_after(user,100,target = src))
						if(!istype(src, /turf/simulated/wall/r_wall) || !user || !WT || !WT.isOn() || !T)
							return

						if(d_state == 5 && user.loc == T && user.get_active_hand() == WT)
							src.d_state = 6
							src.icon_state = "r_wall-6"
							new /obj/item/stack/rods(src)
							to_chat(user, "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>")
				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return

			if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))

				to_chat(user, "<span class='notice'>You begin slicing through the support rods.</span>")
				playsound(src, 'sound/items/Welder.ogg', 100, 1)

				if(do_after(user,70,target = src))
					if(!istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T)
						return

					if(d_state == 5 && user.loc == T && user.get_active_hand() == W)
						src.d_state = 6
						src.icon_state = "r_wall-6"
						new /obj/item/stack/rods(src)
						to_chat(user, "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>")
				return

		if(6)
			if(istype(W, /obj/item/weapon/crowbar))

				to_chat(user, "<span class='notice'>You struggle to pry off the outer sheath.</span>")
				playsound(src, 'sound/items/Crowbar.ogg', 100, 1)

				if(do_after(user,100,target = src))
					if(!istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T)
						return

					if(user.loc == T && user.get_active_hand() == W)
						to_chat(user, "<span class='notice'>You pry off the outer sheath.</span>")
						dismantle_wall()
				return

//vv OK, we weren't performing a valid deconstruction step or igniting thermite,let's check the other possibilities vv

	//DRILLING
	if(istype(W,/obj/item/weapon/changeling_hammer) && !rotting)
		var/obj/item/weapon/changeling_hammer/C = W
		user.do_attack_animation(src)
		visible_message("\red <B>[user]</B> has punched \the <B>[src]!</B>")
		if(C.use_charge(src,user, 4))
			playsound(user.loc, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), 50, 1)
			take_damage(pick(10, 20, 30))
		return
	else if (istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))

		to_chat(user, "<span class='notice'>You begin to drill though the wall.</span>")

		if(do_after(user,200,target = src))
			if(!istype(src, /turf/simulated/wall/r_wall) || !user || !W || !T)
				return

			if(user.loc == T && user.get_active_hand() == W)
				to_chat(user, "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>")
				dismantle_wall()

	//REPAIRING
	else if(istype(W, /obj/item/stack/sheet/metal) && d_state)
		var/obj/item/stack/sheet/metal/MS = W

		to_chat(user, "<span class='notice'>You begin patching-up the wall with \a [MS].</span>")

		if(do_after(user,(max(20*d_state,100)),target = src))	//time taken to repair is proportional to the damage! (max 10 seconds)
			if(!istype(src, /turf/simulated/wall/r_wall) || !user || !MS || !T)
				return

			if(user.loc == T && user.get_active_hand() == MS && d_state)
				src.d_state = 0
				src.icon_state = "r_wall"
				relativewall_neighbours()	//call smoothwall stuff
				to_chat(user, "<span class='notice'>You repair the last of the damage.</span>")
				if (MS.amount > 1)
					MS.amount--
				else
					qdel(MS)

	//APC
	else if(istype(W,/obj/item/apc_frame))
		var/obj/item/apc_frame/AH = W
		AH.try_build(src)

	else if(istype(W,/obj/item/newscaster_frame))     //Be damned the man who thought only mobs need attack() and walls dont need inheritance, hitler incarnate
		var/obj/item/newscaster_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/alarm_frame))
		var/obj/item/alarm_frame/AH = W
		AH.try_build(src)

	else if(istype(W,/obj/item/firealarm_frame))
		var/obj/item/firealarm_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame))
		var/obj/item/light_fixture_frame/AH = W
		AH.try_build(src)
		return

	else if(istype(W,/obj/item/light_fixture_frame/small))
		var/obj/item/light_fixture_frame/small/AH = W
		AH.try_build(src)
		return

	//Poster stuff
	else if(istype(W,/obj/item/weapon/poster))
		place_poster(W,user)
		return

	//Finally, CHECKING FOR FALSE WALLS if it isn't damaged
	else if(!d_state)
		return attack_hand(user)
	return

/turf/simulated/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

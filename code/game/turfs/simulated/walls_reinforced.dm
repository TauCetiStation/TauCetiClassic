/turf/simulated/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon = 'icons/turf/walls/has_false_walls/reinforced_wall.dmi'
	opacity = 1
	density = 1

	damage_cap = 200
	max_temperature = 20000

	sheet_type = /obj/item/stack/sheet/plasteel

	seconds_to_melt = 60

	var/d_state = INTACT

/turf/simulated/wall/r_wall/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_MELEE)
	if(HULK in user.mutations) //#Z2
		if(user.a_intent == INTENT_HARM)
			to_chat(user, text("<span class='notice'>You punch the wall.</span>"))
			take_damage(rand(5, 25))
			if(prob(25))
				user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			if(prob(5))
				playsound(user, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/BP = H.bodyparts_by_name[user.hand ? BP_L_ARM : BP_R_ARM]
				BP.take_damage(rand(5, 15), used_weapon = "Reinforced wall")
				to_chat(user, text("<span class='warning'>Ouch!!</span>"))
			else
				playsound(user, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
			return //##Z2

	if(rotting)
		to_chat(user, "<span class='notice'>This wall feels rather unstable.</span>")
		return

	/*user << "<span class='notice'>You push the wall but nothing happens!</span>"
	playsound(src, 'sound/weapons/Genhit.ogg', VOL_EFFECTS_MASTER, 25)
	src.add_fingerprint(user)*/ //this code is in standard wall attack_hand proc
	..()
	return


/turf/simulated/wall/r_wall/attackby(obj/item/W, mob/user)

	if (!(ishuman(user) || SSticker) && SSticker.mode.name != "monkey")
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	//get the user's location
	if(!isturf(user.loc))
		return	//can't do this stuff whilst inside objects and such
	user.SetNextMove(CLICK_CD_MELEE)
	if(user.is_busy()) return

	if(rotting)
		if(iswelder(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.use(0,user))
				to_chat(user, "<span class='notice'>You burn away the fungi with \the [WT].</span>")
				playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER, 10)
				for(var/obj/effect/E in src) if(E.name == "Wallrot")
					qdel(E)
				rotting = 0
				return
		else if(!W.is_sharp() && W.force >= 10 || W.force >= 20)
			to_chat(user, "<span class='notice'>\The [src] crumbles away under the force of your [W.name].</span>")
			src.dismantle_wall()
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(iswelder(W))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.use(0,user))
				thermitemelt(user, seconds_to_melt)
				return

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			thermitemelt(user, seconds_to_melt)
			return

		else if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/obj/item/weapon/melee/energy/blade/EB = W

			EB.spark_system.start()
			to_chat(user, "<span class='notice'>You slash \the [src] with \the [EB]; the thermite ignites!</span>")
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)

			thermitemelt(user, seconds_to_melt)
			return

	else if(istype(W, /obj/item/weapon/melee/energy/blade))
		to_chat(user, "<span class='notice'>This wall is too thick to slice through. You will need to find a different path.</span>")
		return

	if(damage && iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.use(0,user))
			to_chat(user, "<span class='notice'>You start repairing the damage to [src].</span>")
			if(W.use_tool(src, user, max(5, damage / 5), volume = 100))
				to_chat(user, "<span class='notice'>You finish repairing the damage to [src].</span>")
				take_damage(-damage)
			return
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return

	var/turf/T = user.loc	//get user's location for delay checks

	//DECONSTRUCTION
	switch(d_state)
		if(INTACT)
			if (iswirecutter(W))
				playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
				d_state = SUPPORT_LINES
				update_icon()
				new /obj/item/stack/rods(src)
				to_chat(user, "<span class='notice'>You cut the outer grille.</span>")
				return

		if(SUPPORT_LINES)
			if (isscrewdriver(W))
				to_chat(user, "<span class='notice'>You begin removing the support lines.</span>")
				playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)

				if(W.use_tool(src, user, 40, volume = 100))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == SUPPORT_LINES && user.loc == T && user.get_active_hand() == W)
						d_state = COVER
						update_icon()
						to_chat(user, "<span class='notice'>You remove the support lines.</span>")
				return

			//REPAIRING (replacing the outer grille for cosmetic damage)
			else if(istype(W, /obj/item/stack/rods))
				var/obj/item/stack/O = W
				if(!O.use(1))
					return
				d_state = INTACT
				update_icon()
				to_chat(user, "<span class='notice'>You replace the outer grille.</span>")
				return

		if(COVER)
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.use(0,user))

					to_chat(user, "<span class='notice'>You begin slicing through the metal cover.</span>")
					if(WT.use_tool(src, user, 60, volume = 100))
						if(!istype(src, /turf/simulated/wall/r_wall) || !T)
							return

						if(d_state == COVER && user.loc == T && user.get_active_hand() == WT)
							d_state = CUT_COVER
							update_icon()
							to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return

			if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
				to_chat(user, "<span class='notice'>You begin slicing through the metal cover.</span>")
				if(W.use_tool(src, user, 60, volume = 100))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == COVER && user.loc == T && user.get_active_hand() == W)
						d_state = CUT_COVER
						update_icon()
						to_chat(user, "<span class='notice'>You press firmly on the cover, dislodging it.</span>")
				return

		if(CUT_COVER)
			if (iscrowbar(W))
				to_chat(user, "<span class='notice'>You struggle to pry off the cover.</span>")
				if(W.use_tool(src, user, 100, volume = 100))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == CUT_COVER && user.loc == T && user.get_active_hand() == W)
						d_state = ANCHOR_BOLTS
						update_icon()
						to_chat(user, "<span class='notice'>You pry off the cover.</span>")
				return

		if(ANCHOR_BOLTS)
			if (iswrench(W))

				to_chat(user, "<span class='notice'>You start loosening the anchoring bolts which secure the support rods to their frame.</span>")
				if(W.use_tool(src, user, 40, volume = 100))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == ANCHOR_BOLTS && user.loc == T && user.get_active_hand() == W)
						d_state = SUPPORT_RODS
						update_icon()
						to_chat(user, "<span class='notice'>You remove the bolts anchoring the support rods.</span>")
				return

		if(SUPPORT_RODS)
			if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.use(0,user))

					to_chat(user, "<span class='notice'>You begin slicing through the support rods.</span>")
					if(W.use_tool(src, user, 100, volume = 100))
						if(!istype(src, /turf/simulated/wall/r_wall) || !T)
							return

						if(d_state == SUPPORT_RODS && user.loc == T && user.get_active_hand() == WT)
							d_state = SHEATH
							update_icon()
							new /obj/item/stack/rods(src)
							to_chat(user, "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>")
				else
					to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return

			if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))

				to_chat(user, "<span class='notice'>You begin slicing through the support rods.</span>")
				if(W.use_tool(src, user, 70, volume = 100))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == SUPPORT_RODS && user.loc == T && user.get_active_hand() == W)
						d_state = SHEATH
						update_icon()
						new /obj/item/stack/rods(src)
						to_chat(user, "<span class='notice'>The support rods drop out as you cut them loose from the frame.</span>")
				return

		if(SHEATH)
			if(iscrowbar(W))

				to_chat(user, "<span class='notice'>You struggle to pry off the outer sheath.</span>")
				if(W.use_tool(src, user, 100, volume  = 100))
					if(!istype(src, /turf/simulated/wall/r_wall) || !T)
						return

					if(d_state == SHEATH && user.loc == T && user.get_active_hand() == W)
						to_chat(user, "<span class='notice'>You pry off the outer sheath.</span>")
						dismantle_wall()
				return

//vv OK, we weren't performing a valid deconstruction step or igniting thermite,let's check the other possibilities vv

	//DRILLING
	if(istype(W,/obj/item/weapon/changeling_hammer) && !rotting)
		var/obj/item/weapon/changeling_hammer/C = W
		user.do_attack_animation(src)
		visible_message("<span class='warning'><B>[user]</B> has punched \the <B>[src]!</B></span>")
		if(C.use_charge(user, 4))
			playsound(user, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), VOL_EFFECTS_MASTER)
			take_damage(pick(10, 20, 30))
		return
	else if (istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))

		to_chat(user, "<span class='notice'>You begin to drill though the wall.</span>")

		if(W.use_tool(src, user, 200, volume = 50))
			if(!istype(src, /turf/simulated/wall/r_wall) || !T)
				return

			if(user.loc == T && user.get_active_hand() == W)
				to_chat(user, "<span class='notice'>Your drill tears though the last of the reinforced plating.</span>")
				dismantle_wall()

	//REPAIRING
	else if(istype(W, /obj/item/stack/sheet/metal) && d_state)
		var/obj/item/stack/sheet/metal/MS = W

		to_chat(user, "<span class='notice'>You begin patching-up the wall with \a [MS].</span>")

		if(W.use_tool(src, user, (max(20*d_state,100)), volume = 100))	//time taken to repair is proportional to the damage! (max 10 seconds)
			if(!istype(src, /turf/simulated/wall/r_wall) || !T)
				return

			if(user.loc == T && user.get_active_hand() == MS && d_state)
				if(!MS.use(1))
					return
				d_state = INTACT
				update_icon()
				queue_smooth(src)	//call smoothwall stuff
				to_chat(user, "<span class='notice'>You repair the last of the damage.</span>")

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

	else if(istype(W,/obj/item/door_control_frame))
		var/obj/item/door_control_frame/AH = W
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

/turf/simulated/wall/r_wall/update_icon()
	if(d_state != INTACT)
		smooth = SMOOTH_FALSE
		icon_state = "r_wall-[d_state]"
	else
		smooth = SMOOTH_TRUE
		queue_smooth_neighbors(src)
		queue_smooth(src)

/turf/simulated/wall/r_wall/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

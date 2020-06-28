/**
#Z2 miscellaneous stuff
**/

//New Hulk stuff...
/mob
	var/hulk_cd = 0

/mob/living/carbon/human/proc/hulk_jump()
	set name = "Leap Forward(Hulk)"
	set category = "Superpower"

	if(!(HULK in src.mutations))
		src.verbs -= /mob/living/carbon/human/proc/hulk_jump
		return

	var/failure = 0
	if (istype(usr.loc,/mob) || usr.incapacitated() || !usr.canmove)
		to_chat(usr, "<span class='warning'>You can't jump right now!</span>")
		return

	if(usr.hulk_cd)
		to_chat(usr, "<span class='warning'>You need a bit of time, before you can use any ability!</span>")
		return

	usr.hulk_cd = 1
	spawn(150)
		usr.hulk_cd = 0

	if (istype(usr.loc,/turf) && !(istype(usr.loc,/turf/space)))

		if(usr.restrained())
			for(var/mob/M in range(usr, 1))
				if(M.pulling == usr)
					M.stop_pulling()

		if(usr.pinned.len)
			failure = 1

		usr.visible_message("<span class='warning'><b>[usr.name]</b> takes a huge leap!</span>")
		playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
		if(failure)
			usr.Weaken(5)
			usr.Stun(5)
			usr.visible_message("<span class='warning'> \the [usr] attempts to leap away but is slammed back down to the ground!</span>",
								"<span class='warning'>You attempt to leap away but are suddenly slammed back down to the ground!</span>",
								"<span class='notice'>You hear the flexing of powerful muscles and suddenly a crash as a body hits the floor.</span>")
			return 0

		usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		var/prevLayer = usr.layer
		usr.layer = 9
		var/cur_dir = usr.dir
		var/turf/simulated/floor/tile = usr.loc
		if(tile)
			tile.break_tile()
		var/o=3
		for(var/i=0, i<14, i++)
			usr.density = 0
			usr.canmove = 0
			o++
			if(o == 4)
				o = 0
				step(usr, cur_dir)
			if(i < 7) usr.pixel_y += 8
			else usr.pixel_y -= 8
			sleep(1)
		playsound(src, 'sound/effects/explosionfar.ogg', VOL_EFFECTS_MASTER)
		for(tile in range(1, usr))
			if(prob(50))
				tile.break_tile()
		for(var/mob/living/M in usr.loc.contents)
			if(M != usr)
				M.log_combat(usr, "hulk_jumped")
				var/mob/living/carbon/human/H = M
				if(istype(H,/mob/living/carbon/human))
					playsound(H, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
					var/obj/item/organ/external/BP = H.bodyparts_by_name[pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG , BP_HEAD , BP_GROIN)]
					BP.take_damage(20, null, null, "Hulk Foot")
					BP.fracture()
					H.Stun(5)
					H.Weaken(5)
				else
					playsound(M, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
					M.Stun(5)
					M.Weaken(5)
					M.take_overall_damage(35, used_weapon = "Hulk Foot")
		var/snd = 1
		for(var/direction in alldirs)
			var/turf/T = get_step(src,direction)
			for(var/mob/living/M in T.contents)
				if( (M != usr) && !(M.stat))
					if(snd)
						snd = 0
						playsound(M, 'sound/misc/slip.ogg', VOL_EFFECTS_MASTER)
					M.Weaken(2)
					for(var/i=0, i<6, i++)
						spawn(i)
							if(i < 3) M.pixel_y += 8
							else M.pixel_y -= 8

		if (HAS_TRAIT(usr, TRAIT_FAT) && prob(66))
			usr.visible_message("<span class='warning'><b>[usr.name]</b> crashes due to their heavy weight!</span>")
			playsound(src, 'sound/misc/slip.ogg', VOL_EFFECTS_MASTER)
			usr.weakened += 10
			usr.stunned += 5

		usr.density = 1
		usr.canmove = 1
		usr.layer = prevLayer
	else
		to_chat(usr, "<span class='warning'>You need a ground to do this!</span>")
		return

	if (istype(usr.loc,/obj))
		var/obj/container = usr.loc
		to_chat(usr, "<span class='warning'>You leap and slam your head against the inside of [container]! Ouch!</span>")
		usr.paralysis += 3
		usr.weakened += 5
		container.visible_message("<span class='warning'><b>[usr.loc]</b> emits a loud thump and rattles a bit.</span>")
		playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0

	return

/mob/living/carbon/human/proc/hulk_dash()
	set name = "Dash Forward(Hulk)"
	set category = "Superpower"

	if(!(HULK in src.mutations))
		src.verbs -= /mob/living/carbon/human/proc/hulk_dash
		return

	var/turf/T = get_turf(get_step(usr,usr.dir))
	for(var/mob/living/M in T.contents)
		to_chat(usr, "<span class='warning'>Something right in front of you!</span>")
		return
	T = get_turf(get_step(T,usr.dir))
	for(var/mob/living/M in T.contents)
		to_chat(usr, "<span class='warning'>Something right in front of you!</span>")
		return

	var/failure = 0
	if (istype(usr.loc,/mob) || usr.incapacitated() || !usr.canmove)
		to_chat(usr, "<span class='warning'>You can't dash right now!</span>")
		return

	if(usr.hulk_cd)
		to_chat(usr, "<span class='warning'>You need a bit of time, before you can use any ability!</span>")
		return

	usr.hulk_cd = 1
	spawn(150)
		usr.hulk_cd = 0

	if (istype(usr.loc,/turf) && !(istype(usr.loc,/turf/space)))
		if(usr.restrained())
			for(var/mob/M in range(usr, 1))
				if(M.pulling == usr)
					M.stop_pulling()

		if(usr.pinned.len)
			failure = 1

		usr.visible_message("<span class='warning'><b>[usr.name]</b> dashes forward!</span>")
		playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
		if(failure)
			usr.Weaken(5)
			usr.Stun(5)
			usr.visible_message("<span class='warning'> \the [usr] attempts to dash away but was interrupted!</span>",
								"<span class='warning'>You attempt to dash but suddenly interrupted!</span>",
								"<span class='notice'>You hear the flexing of powerful muscles and suddenly a crash as a body hits the floor.</span>")
			return 0

		usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		var/prevLayer = usr.layer
		usr.layer = 9
		var/cur_dir = usr.dir
		var/turf/simulated/floor/tile = usr.loc
		if(tile)
			tile.break_tile()
		var/speed = 3
		for(var/i=0, i<30, i++)
			var/hit = 0
			T = get_turf(get_step(usr,usr.dir))
			if(i < 7)
				if(istype(T,/turf/simulated/wall))
					hit = 1
				else if(istype(T,/turf/simulated/floor))
					for(var/obj/structure/S in T.contents)
						if(istype(S,/obj/structure/window))
							hit = 1
						if(istype(S,/obj/structure/grille))
							hit = 1
			else if(i > 6)
				if(istype(T,/turf/simulated/floor))
					for(var/obj/structure/S in T.contents)
						if(istype(S,/obj/structure/window))
							S.ex_act(2)
						if(istype(S,/obj/structure/grille))
							qdel(S)
				if(istype(T,/turf/simulated/wall))
					var/turf/simulated/wall/W = T
					var/mob/living/carbon/human/H = usr
					if(istype(T,/turf/simulated/wall/r_wall))
						playsound(H, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
						hit = 1
						H.Weaken(10)
						H.take_overall_damage(25, used_weapon = "reinforced wall")
					else
						playsound(H, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
						if(i > 20)
							if(prob(65))
								hit = 1
								W.dismantle_wall(1)
							else
								hit = 1
								W.take_damage(50)
								H.Weaken(5)
						else
							hit = 1
							W.take_damage(25)
							H.Weaken(5)
			if(i > 20)
				usr.canmove = 0
				usr.density = 0
				for(var/mob/living/M in T.contents)
					if(!M.lying)
						M.log_combat(usr, "hulk_dashed")
						var/turf/target = get_turf(get_step(usr,cur_dir))
						hit = 1
						playsound(M, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
						for(var/o=0, o<10, o++)
							target = get_turf(get_step(target,cur_dir))
						var/mob/living/carbon/human/H = M
						if(istype(H,/mob/living/carbon/human))
							var/obj/item/organ/external/BP = H.bodyparts_by_name[pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG , BP_HEAD , BP_GROIN)]
							BP.take_damage(20, null, null, "Hulk Shoulder")
							BP.fracture()
							M.Weaken(5)
							M.Stun(5)
						else
							M.Weaken(5)
							M.Stun(5)
							M.take_overall_damage(40, used_weapon = "Hulk Foot")
						M.throw_at(target, 200, 100)
						break
			else if(i > 6)
				for(var/mob/living/M in T.contents)
					playsound(M, 'sound/misc/slip.ogg', VOL_EFFECTS_MASTER)
					M.Weaken(5)
			if(usr.lying)
				break
			if(hit)
				break
			if(i < 7)
				speed++
				if(speed > 3)
					speed = 0
					step(usr, cur_dir)
			else if(i < 14)
				speed++
				if(speed > 2)
					speed = 0
					step(usr, cur_dir)
			else if(i < 21)
				speed++
				if(speed > 1)
					speed = 0
					step(usr, cur_dir)
			else if(i < 30)
				step(usr, cur_dir)
			sleep(1)

		if (HAS_TRAIT(usr, TRAIT_FAT) && prob(66))
			usr.visible_message("<span class='warning'><b>[usr.name]</b> crashes due to their heavy weight!</span>")
			playsound(src, 'sound/misc/slip.ogg', VOL_EFFECTS_MASTER)
			usr.weakened += 10
			usr.stunned += 5

		usr.density = 1
		usr.canmove = 1
		usr.layer = prevLayer
	else
		to_chat(usr, "<span class='warning'>You need a ground to do this!</span>")
		return

	if (istype(usr.loc,/obj))
		var/obj/container = usr.loc
		to_chat(usr, "<span class='warning'>You dash and slam your head against the inside of [container]! Ouch!</span>")
		usr.paralysis += 3
		usr.weakened += 5
		container.visible_message("<span class='warning'><b>[usr.loc]</b> emits a loud thump and rattles a bit.</span>")
		playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0

	return

/mob/living/carbon/human/proc/hulk_smash()
	set name = "Smash Ground(Hulk)"
	set category = "Superpower"

	if(!(HULK in src.mutations))
		src.verbs -= /mob/living/carbon/human/proc/hulk_smash
		return

	if (usr.incapacitated() || !usr.canmove)
		to_chat(usr, "<span class='warning'>You can't smash right now!</span>")
		return

	if(usr.hulk_cd)
		to_chat(usr, "<span class='warning'>You need a bit of time, before you can use any ability!</span>")
		return

	usr.hulk_cd = 1
	spawn(150)
		usr.hulk_cd = 0

	if (istype(usr.loc,/turf))
		usr.visible_message("<font size='4' color='red'><b>[usr.name] prepares a heavy attack!</b></font>")
		for(var/i=0, i<30, i++)
			usr.canmove = 0
			usr.anchored = 1
			sleep(1)
		usr.anchored = 0
		usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		usr.visible_message("<span class='warning'><b>[usr.name] slams the ground with \his arms!</b></span>")
		playsound(src, 'sound/effects/explosionfar.ogg', VOL_EFFECTS_MASTER)
		var/cur_dir = usr.dir
		var/turf/T = get_turf(get_step(usr,cur_dir))
		var/turf/simulated/floor/tile = T
		var/turf/simulated/wall/W = T
		if(istype(tile))
			tile.break_tile()
		if(istype(W,/turf/simulated/wall/r_wall))
			to_chat(usr, "<span class='warning'><B>Ouch!</B> This wall is too strong.</span>")
			var/mob/living/carbon/human/H = usr
			H.take_overall_damage(25, used_weapon = "reinforced wall")
		else if(istype(W,/turf/simulated/wall))
			W.take_damage(50)
		for(var/mob/living/M in T.contents)
			if(M != usr)
				M.log_combat(usr, "hulk_smashed")
				var/mob/living/carbon/human/H = M
				if(istype(H,/mob/living/carbon/human))
					playsound(H, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
					var/obj/item/organ/external/BP = H.bodyparts_by_name[pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG , BP_HEAD , BP_GROIN)]
					if(HAS_TRAIT(usr, TRAIT_FAT))
						BP.take_damage(100, null, null, "Hulk Fat Arm")
						H.Stun(10)
						H.Weaken(10)
					else
						BP.take_damage(50, null, null, "Hulk Arm")
						H.Stun(5)
						H.Weaken(5)
					BP.fracture()
				else
					playsound(M, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
					if(HAS_TRAIT(usr, TRAIT_FAT))
						M.Stun(10)
						M.Weaken(10)
						M.take_overall_damage(130, used_weapon = "Hulk Fat Arm")
					else
						M.Stun(5)
						M.Weaken(5)
						M.take_overall_damage(65, used_weapon = "Hulk Arm")
		sleep(2)
		for(tile in range(1, T))
			if(prob(75))
				tile.break_tile()
		for(var/mob/living/M in range(1, T))
			if( (M != usr) && !M.lying)
				playsound(M, 'sound/misc/slip.ogg', VOL_EFFECTS_MASTER)
				M.Weaken(5)
		for(var/obj/structure/S in range(1, T))
			if(istype(S,/obj/structure/window))
				S.ex_act(2)
			if(istype(S,/obj/structure/grille))
				qdel(S)
		sleep(3)
		for(tile in range(2, T))
			if(prob(40))
				tile.break_tile()
		for(var/mob/living/M in range(2, T))
			if( (M != usr) && !M.lying)
				playsound(M, 'sound/misc/slip.ogg', VOL_EFFECTS_MASTER)
				M.Weaken(2)
		for(var/obj/structure/S in range(2, T))
			if(prob(40))
				if(istype(S,/obj/structure/window))
					S.ex_act(2)
				if(istype(S,/obj/structure/grille))
					qdel(S)
		usr.canmove = 1

	if (istype(usr.loc,/obj))
		var/obj/container = usr.loc
		to_chat(usr, "<span class='warning'>You smash [container]!</span>")
		container.visible_message("<span class='warning'><b>[usr.loc]</b> emits a loud thump and rattles a bit.</span>")
		playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0
		visible_message("<span class='warning'>[usr] destroys the [container]. </span>")
		for(var/atom/movable/A as mob|obj in container)
			A.loc = container.loc
			var/mob/M = A
			if( (istype(M, /mob)) && M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		qdel(container)

	return

//Girders!!!!!
/obj/structure/girder/attack_paw(mob/user)
	return src.attack_hand(user) //#Z2

/obj/structure/girder/attack_hand(mob/user)
	if (HULK in user.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		if(user.a_intent == INTENT_HARM)
			playsound(src, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
			if (prob(75))
				to_chat(user, text("<span class='notice'>You destroy that girder!</span>"))
				user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
				new /obj/item/stack/sheet/metal(loc)
				qdel(src)
			else
				to_chat(user, text("<span class='notice'>You punch the girder.</span>"))
		else
			to_chat(user, "<span class='notice'>You push the girder but nothing happens!</span>")
		return

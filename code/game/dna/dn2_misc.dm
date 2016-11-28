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
	if (istype(usr.loc,/mob/) || usr.lying || usr.stunned || usr.buckled || usr.stat)
		to_chat(usr, "\red You can't jump right now!")
		return

	if(usr.hulk_cd)
		to_chat(usr, "\red You need a bit of time, before you can use any ability!")
		return

	usr.hulk_cd = 1
	spawn(150)
		usr.hulk_cd = 0

	if (istype(usr.loc,/turf/) && !(istype(usr.loc,/turf/space)))

		if(usr.restrained())
			for(var/mob/M in range(usr, 1))
				if(M.pulling == usr)
					M.stop_pulling()

		if(usr.pinned.len)
			failure = 1

		usr.visible_message("\red <b>[usr.name]</b> takes a huge leap!")
		playsound(usr.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
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
		playsound(usr.loc, 'sound/effects/explosionfar.ogg', 50, 1)
		for(tile in range(1, usr))
			if(prob(50))
				tile.break_tile()
		for(var/mob/living/M in usr.loc.contents)
			if(M != usr)
				usr.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with hulk_jump</font>"
				M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [usr.name] ([usr.ckey]) with hulk_jump</font>"
				msg_admin_attack("[key_name(usr)] attacked [key_name(M)] with hulk_jump")
				var/mob/living/carbon/human/H = M
				if(istype(H,/mob/living/carbon/human/))
					playsound(H.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
					var/organ_name = pick("chest","l_arm","r_arm","r_leg","l_leg","head","groin")
					var/datum/organ/external/E = H.get_organ(organ_name)
					E.take_damage(20, 0, 0, 0, "Hulk Foot")
					E.fracture()
					H.Stun(5)
					H.Weaken(5)
				else
					playsound(M.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
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
						playsound(M.loc, 'sound/misc/slip.ogg', 50, 1)
					M.Weaken(2)
					for(var/i=0, i<6, i++)
						spawn(i)
							if(i < 3) M.pixel_y += 8
							else M.pixel_y -= 8

		if ((FAT in usr.mutations) && prob(66))
			usr.visible_message("\red <b>[usr.name]</b> crashes due to their heavy weight!")
			playsound(usr.loc, 'sound/misc/slip.ogg', 50, 1)
			usr.weakened += 10
			usr.stunned += 5

		usr.density = 1
		usr.canmove = 1
		usr.layer = prevLayer
	else
		to_chat(usr, "\red You need a ground to do this!")
		return

	if (istype(usr.loc,/obj/))
		var/obj/container = usr.loc
		to_chat(usr, "\red You leap and slam your head against the inside of [container]! Ouch!")
		usr.paralysis += 3
		usr.weakened += 5
		container.visible_message("\red <b>[usr.loc]</b> emits a loud thump and rattles a bit.")
		playsound(usr.loc, 'sound/effects/bang.ogg', 50, 1)
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
		to_chat(usr, "\red Something right in front of you!")
		return
	T = get_turf(get_step(T,usr.dir))
	for(var/mob/living/M in T.contents)
		to_chat(usr, "\red Something right in front of you!")
		return

	var/failure = 0
	if (istype(usr.loc,/mob/) || usr.lying || usr.stunned || usr.buckled || usr.stat)
		to_chat(usr, "\red You can't dash right now!")
		return

	if(usr.hulk_cd)
		to_chat(usr, "\red You need a bit of time, before you can use any ability!")
		return

	usr.hulk_cd = 1
	spawn(150)
		usr.hulk_cd = 0

	if (istype(usr.loc,/turf/) && !(istype(usr.loc,/turf/space)))
		if(usr.restrained())
			for(var/mob/M in range(usr, 1))
				if(M.pulling == usr)
					M.stop_pulling()

		if(usr.pinned.len)
			failure = 1

		usr.visible_message("\red <b>[usr.name]</b> dashes forward!")
		playsound(usr.loc, 'sound/weapons/thudswoosh.ogg', 50, 1)
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
				if(istype(T,/turf/simulated/wall/))
					hit = 1
				else if(istype(T,/turf/simulated/floor/))
					for(var/obj/structure/S in T.contents)
						if(istype(S,/obj/structure/window/))
							hit = 1
						if(istype(S,/obj/structure/grille/))
							hit = 1
			else if(i > 6)
				if(istype(T,/turf/simulated/floor/))
					for(var/obj/structure/S in T.contents)
						if(istype(S,/obj/structure/window/))
							S.ex_act(2)
						if(istype(S,/obj/structure/grille/))
							qdel(S)
				if(istype(T,/turf/simulated/wall/))
					var/turf/simulated/wall/W = T
					var/mob/living/carbon/human/H = usr
					if(istype(T,/turf/simulated/wall/r_wall))
						playsound(H.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
						hit = 1
						H.Weaken(10)
						H.take_overall_damage(25, used_weapon = "reinforced wall")
					else
						playsound(H.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
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
						usr.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with hulk_dash</font>"
						M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [usr.name] ([usr.ckey]) with hulk_dash</font>"
						msg_admin_attack("[key_name(usr)] attacked [key_name(M)] with hulk_dash")
						var/turf/target = get_turf(get_step(usr,cur_dir))
						hit = 1
						playsound(M.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
						for(var/o=0, o<10, o++)
							target = get_turf(get_step(target,cur_dir))
						var/mob/living/carbon/human/H = M
						if(istype(H,/mob/living/carbon/human/))
							var/organ_name = pick("chest","l_arm","r_arm","r_leg","l_leg","head","groin")
							var/datum/organ/external/E = H.get_organ(organ_name)
							E.take_damage(20, 0, 0, 0, "Hulk Shoulder")
							E.fracture()
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
					playsound(M.loc, 'sound/misc/slip.ogg', 50, 1)
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

		if ((FAT in usr.mutations) && prob(66))
			usr.visible_message("\red <b>[usr.name]</b> crashes due to their heavy weight!")
			playsound(usr.loc, 'sound/misc/slip.ogg', 50, 1)
			usr.weakened += 10
			usr.stunned += 5

		usr.density = 1
		usr.canmove = 1
		usr.layer = prevLayer
	else
		to_chat(usr, "\red You need a ground to do this!")
		return

	if (istype(usr.loc,/obj/))
		var/obj/container = usr.loc
		to_chat(usr, "\red You dash and slam your head against the inside of [container]! Ouch!")
		usr.paralysis += 3
		usr.weakened += 5
		container.visible_message("\red <b>[usr.loc]</b> emits a loud thump and rattles a bit.")
		playsound(usr.loc, 'sound/effects/bang.ogg', 50, 1)
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

	if (usr.lying || usr.stunned || usr.stat)
		to_chat(usr, "\red You can't smash right now!")
		return

	if(usr.hulk_cd)
		to_chat(usr, "\red You need a bit of time, before you can use any ability!")
		return

	usr.hulk_cd = 1
	spawn(150)
		usr.hulk_cd = 0

	if (istype(usr.loc,/turf/))
		usr.visible_message("<font size='4' color='red'><b>[usr.name] prepares a heavy attack!</b>")
		for(var/i=0, i<30, i++)
			usr.canmove = 0
			usr.anchored = 1
			sleep(1)
		usr.anchored = 0
		usr.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		usr.visible_message("\red <b>[usr.name] slams the ground with \his arms!</b>")
		playsound(usr.loc, 'sound/effects/explosionfar.ogg', 50, 1)
		var/cur_dir = usr.dir
		var/turf/T = get_turf(get_step(usr,cur_dir))
		var/turf/simulated/floor/tile = T
		var/turf/simulated/wall/W = T
		if(istype(tile))
			tile.break_tile()
		if(istype(W,/turf/simulated/wall/r_wall))
			to_chat(usr, "\red <B>Ouch!</B> This wall is too strong.")
			var/mob/living/carbon/human/H = usr
			H.take_overall_damage(25, used_weapon = "reinforced wall")
		else if(istype(W,/turf/simulated/wall))
			W.take_damage(50)
		for(var/mob/living/M in T.contents)
			if(M != usr)
				usr.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with hulk_smash</font>"
				M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [usr.name] ([usr.ckey]) with hulk_smash</font>"
				msg_admin_attack("[key_name(usr)] attacked [key_name(M)] with hulk_smash")
				var/mob/living/carbon/human/H = M
				if(istype(H,/mob/living/carbon/human/))
					playsound(H.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
					var/organ_name = pick("chest","l_arm","r_arm","r_leg","l_leg","head","groin")
					var/datum/organ/external/E = H.get_organ(organ_name)
					if(FAT in usr.mutations)
						E.take_damage(100, 0, 0, 0, "Hulk Fat Arm")
						H.Stun(10)
						H.Weaken(10)
					else
						E.take_damage(50, 0, 0, 0, "Hulk Arm")
						H.Stun(5)
						H.Weaken(5)
					E.fracture()
				else
					playsound(M.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
					if(FAT in usr.mutations)
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
				playsound(M.loc, 'sound/misc/slip.ogg', 50, 1)
				M.Weaken(5)
		for(var/obj/structure/S in range(1, T))
			if(istype(S,/obj/structure/window/))
				S.ex_act(2)
			if(istype(S,/obj/structure/grille/))
				qdel(S)
		sleep(3)
		for(tile in range(2, T))
			if(prob(40))
				tile.break_tile()
		for(var/mob/living/M in range(2, T))
			if( (M != usr) && !M.lying)
				playsound(M.loc, 'sound/misc/slip.ogg', 50, 1)
				M.Weaken(2)
		for(var/obj/structure/S in range(2, T))
			if(prob(40))
				if(istype(S,/obj/structure/window/))
					S.ex_act(2)
				if(istype(S,/obj/structure/grille/))
					qdel(S)
		usr.canmove = 1

	if (istype(usr.loc,/obj/))
		var/obj/container = usr.loc
		to_chat(usr, "\red You smash [container]!")
		container.visible_message("\red <b>[usr.loc]</b> emits a loud thump and rattles a bit.")
		playsound(usr.loc, 'sound/effects/bang.ogg', 50, 1)
		var/wiggle = 6
		while(wiggle > 0)
			wiggle--
			container.pixel_x = rand(-3,3)
			container.pixel_y = rand(-3,3)
			sleep(1)
		container.pixel_x = 0
		container.pixel_y = 0
		visible_message("\red [usr] destroys the [container]. ")
		for(var/atom/movable/A as mob|obj in container)
			A.loc = container.loc
			var/mob/M = A
			if( (istype(M, /mob/)) && M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		qdel(container)

	return

//Girders!!!!!
/obj/structure/girder/attack_paw(mob/user)
	return src.attack_hand(user) //#Z2

/obj/structure/girder/attack_hand(mob/user)
	if (HULK in user.mutations)
		if(user.a_intent == "hurt")
			playsound(user.loc, 'sound/effects/grillehit.ogg', 50, 1)
			if (prob(75))
				to_chat(user, text("\blue You destroy that girder!"))
				user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
				new /obj/item/stack/sheet/metal(get_turf(src))
				qdel(src)
			else
				to_chat(user, text("\blue You punch the girder."))
		else
			to_chat(user, "\blue You push the girder but nothing happens!")
		return

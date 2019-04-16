/obj/effect/proc_holder/spell/aoe_turf/hulk_jump
	name = "Leap"
	desc = ""
	panel = "Hulk"
	charge_max = 130
	clothes_req = 0
	range = 5

/obj/effect/proc_holder/spell/aoe_turf/hulk_jump/cast(list/targets)
	//for(var/turf/T in targets)
	var/failure = 0
	if (istype(usr.loc,/mob) || usr.lying || usr.stunned || usr.buckled || usr.stat)
		to_chat(usr, "\red You can't jump right now!")
		return

	if (istype(usr.loc,/turf) && !(istype(usr.loc,/turf/space)))

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

		usr.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
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
				if(istype(H,/mob/living/carbon/human))
					playsound(H.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
					var/bodypart_name = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG , BP_HEAD , BP_GROIN)
					var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart_name]
					BP.take_damage(20, used_weapon = "Hulk Foot")
					BP.fracture()
					H.Stun(5)
					H.Weaken(5)
				else
					playsound(M.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
					M.Stun(5)
					M.Weaken(5)
					M.take_overall_damage(35, used_weapon = "Hulk Foot")
		var/snd = 1
		for(var/direction in alldirs)
			var/turf/T = get_step(usr,direction)
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

	if (istype(usr.loc,/obj))
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

/obj/effect/proc_holder/spell/aoe_turf/hulk_dash
	name = "Dash"
	desc = ""
	panel = "Hulk"
	charge_max = 130
	clothes_req = 0
	range = 5

/obj/effect/proc_holder/spell/aoe_turf/hulk_dash/cast(list/targets)
	var/turf/T = get_turf(get_step(usr,usr.dir))
	for(var/mob/living/M in T.contents)
		to_chat(usr, "\red Something right in front of you!")
		return
	T = get_turf(get_step(T,usr.dir))
	for(var/mob/living/M in T.contents)
		to_chat(usr, "\red Something right in front of you!")
		return

	var/failure = 0
	if (istype(usr.loc,/mob) || usr.lying || usr.stunned || usr.buckled || usr.stat)
		to_chat(usr, "\red You can't dash right now!")
		return

	if (istype(usr.loc,/turf) && !(istype(usr.loc,/turf/space)))
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

		usr.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
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
						if(istype(H,/mob/living/carbon/human))
							var/bodypart_name = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG , BP_HEAD , BP_GROIN)
							var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart_name]
							BP.take_damage(20, used_weapon = "Hulk Shoulder")
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

	if (istype(usr.loc,/obj))
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

/obj/effect/proc_holder/spell/aoe_turf/hulk_smash
	name = "Smash"
	desc = ""
	panel = "Hulk"
	charge_max = 130
	clothes_req = 0
	range = 5

/obj/effect/proc_holder/spell/aoe_turf/hulk_smash/cast(list/targets)
	if (usr.lying || usr.stunned || usr.stat)
		to_chat(usr, "\red You can't smash right now!")
		return

	if (istype(usr.loc,/turf))
		usr.visible_message("<font size='4' color='red'><b>[usr.name] prepares a heavy attack!</b></font>")
		//for(var/i=0, i<30, i++)
		//	usr.canmove = 0
		//	usr.anchored = 1
		//	sleep(1)
		//usr.anchored = 0
		sleep(30)
		usr.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
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
				if(istype(H,/mob/living/carbon/human))
					playsound(H.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
					var/bodypart_name = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG , BP_HEAD , BP_GROIN)
					var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart_name]
					if(FAT in usr.mutations)
						BP.take_damage(100, used_weapon = "Hulk Fat Arm")
						H.Stun(10)
						H.Weaken(10)
					else
						BP.take_damage(50, used_weapon = "Hulk Arm")
						H.Stun(5)
						H.Weaken(5)
					BP.fracture()
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
				playsound(M.loc, 'sound/misc/slip.ogg', 50, 1)
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
			if( (istype(M, /mob)) && M.client)
				M.client.eye = M.client.mob
				M.client.perspective = MOB_PERSPECTIVE
		qdel(container)

	return

/obj/structure/girder/attack_animal(mob/user)
	..()
	if(istype(user, /mob/living/simple_animal/hulk))
		playsound(user.loc, 'sound/effects/grillehit.ogg', 50, 1)
		if (prob(75))
			to_chat(user, text("\blue You destroy that girder!"))
			user.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
			new /obj/item/stack/sheet/metal(get_turf(src))
			qdel(src)
		else
			to_chat(user, text("\blue You punch the girder."))
	return

///////////////////////////////////////////////////////
////////////////// Z  I  L  L  A /////////////////////
/////////////////////////////////////////////////////
/obj/effect/proc_holder/spell/aoe_turf/hulk_mill
	name = "Windmill"
	desc = ""
	panel = "Hulk"
	charge_max = 200
	clothes_req = 0
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/hulk_mill/cast(list/targets)
	if (usr.lying || usr.stunned || usr.stat)
		to_chat(usr, "\red You can't right now!")
		return

	usr.attack_log += "\[[time_stamp()]\]<font color='red'> Uses hulk_mill</font>"
	msg_admin_attack("[key_name(usr)] uses hulk_mill")

	for(var/i in 1 to 45)
		if(usr.dir == 1)
			usr.dir = 2
		else if(usr.dir == 2)
			usr.dir = 4
		else if(usr.dir == 4)
			usr.dir = 8
		else if(usr.dir == 8)
			usr.dir = 1

		for(var/mob/living/M in view(2, usr) - usr - usr.contents)
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				var/bodypart_name = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_R_LEG , BP_L_LEG , BP_HEAD , BP_GROIN)
				var/obj/item/organ/external/BP = H.bodyparts_by_name[bodypart_name]
				BP.take_damage(1.5, used_weapon = "Tail")
			else
				M.take_overall_damage(1.5, used_weapon = "Tail")
			playsound(M.loc, 'sound/weapons/tablehit1.ogg', 50, 1)
			if(prob(3))
				M.Weaken(2)
		sleep(1)

/obj/effect/proc_holder/spell/aoe_turf/hulk_gas
	name = "Gas"
	desc = ""
	panel = "Hulk"
	charge_max = 400
	clothes_req = 0
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/hulk_gas/cast(list/targets)
	if (usr.lying || usr.stunned || usr.stat)
		to_chat(usr, "\red You can't right now!")
		return

	//Some weird magic
	var/obj/item/weapon/grenade/TG = new /obj/item/weapon/grenade/chem_grenade/teargas(get_turf(usr))
	TG.prime()

	usr.attack_log += "\[[time_stamp()]\]<font color='red'> Uses hulk_gas</font>"
	msg_admin_attack("[key_name(usr)] uses hulk_gas")

/obj/item/projectile/energy/hulkspit
	name = "spit"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX

/obj/item/projectile/energy/hulkspit/on_hit(atom/target, blocked = 0)
	if(istype(target, /mob/living/carbon))
		var/mob/living/carbon/M = target
		M.Weaken(2)
		M.adjust_fire_stacks(20)
		M.IgniteMob()

/obj/effect/proc_holder/spell/aoe_turf/hulk_spit
	name = "Fire Spit"
	desc = ""
	panel = "Hulk"
	charge_max = 80
	clothes_req = 0
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/hulk_spit/cast(list/targets)
	if (usr.lying || usr.stunned || usr.stat)
		to_chat(usr, "\red You can't right now!")
		return

	var/turf/T = usr.loc
	var/turf/U = get_step(usr, usr.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return

	var/obj/item/projectile/energy/hulkspit/A = new /obj/item/projectile/energy/hulkspit(usr.loc)
	A.original = U
	A.current = U
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn( 0 )
		A.process()

	usr.attack_log += "\[[time_stamp()]\]<font color='red'> Uses hulk_spit</font>"
	msg_admin_attack("[key_name(usr)] uses hulk_spit")

/obj/effect/proc_holder/spell/aoe_turf/hulk_eat
	name = "Tear or Swallow"
	desc = ""
	panel = "Hulk"
	charge_max = 100
	clothes_req = 0
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/hulk_eat/cast_check()
	to_chat(usr, "\blue Target someone, then alt+click.")
	return 0

/mob/living/simple_animal/hulk/unathi/AltClickOn(atom/A)
	if(!stat && mind && health > 0 && isliving(A) && A != src && Adjacent(A))
		try_to_eat(A)
		next_click = world.time + 5
	else
		..()

/mob/living/simple_animal/hulk/unathi/proc/try_to_eat(mob/living/target)
	var/obj/effect/proc_holder/spell/aoe_turf/hulk_eat/HE = locate(/obj/effect/proc_holder/spell/aoe_turf/hulk_eat) in spell_list
	if(istype(HE))
		if(HE.charge_counter >= HE.charge_max)
			HE.charge_counter = 0
		else
			to_chat(usr, "Tear or Swallow is still recharging.")
			return
	else
		return

	var/mob/living/simple_animal/SA = usr
	if(target.stat == DEAD)
		usr.visible_message("\red <b>[usr.name]</b> is trying to swallow <b>[target.name]</b>!")
		if(do_after(usr,50,target = target))
			usr.attack_log += "\[[time_stamp()]\]<font color='red'> Eats [target.name] ([target.ckey]) with hulk_eat</font>"
			msg_admin_attack("[key_name(usr)] eats [key_name(target)] body with hulk_eat")
			if(isrobot(target))
				usr.visible_message("\red <b>[usr.name]</b> swallows <b>[target.name]</b> and vomits some parts of it!\black Looks like robots are not so tasty.")
				SA.health -= 150
			else
				usr.visible_message("\red <b>[usr.name]</b> swallows <b>[target.name]</b>!")
				SA.health += 30
				if(isanimal(target))
					HE.charge_counter += 90
				else if(ismonkey(target))
					HE.charge_counter += 60
			playsound(usr.loc, 'sound/weapons/zilla_eat.ogg', 50, 2)
			target.gib()
	else
		usr.visible_message("\red <b>[usr.name]</b> is trying to rend <b>[target.name]</b> into shreds!")
		if(do_after(usr,20,target = target))
			usr.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [target.name] ([target.ckey]) with hulk_eat</font>"
			target.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [usr.name] ([usr.ckey]) with hulk_eat</font>"
			msg_admin_attack("[key_name(usr)] attacked [key_name(target)] with hulk_eat")
			if(isrobot(target))
				usr.visible_message("\red <b>[usr.name]</b> rends apart and vomit some parts of <b>[target.name]</b>!\black Looks like robots are not so tasty.")
				SA.health -= 45
				HE.charge_counter += 30
				target.take_overall_damage(rand(75,140), used_weapon = "teeth marks")
			else
				usr.visible_message("\red <b>[usr.name]</b> rends <b>[target.name]</b> apart!")
				SA.health += 15
				HE.charge_counter += 60
				if(isanimal(target))
					target.take_overall_damage(rand(90,130), used_weapon = "teeth marks")
				else
					target.take_overall_damage(rand(35,60), used_weapon = "teeth marks")
			playsound(usr.loc, 'sound/weapons/zilla_eat.ogg', 50, 2)
		else
			HE.charge_counter += 90
	HE.start_recharge()

/obj/effect/proc_holder/spell/aoe_turf/hulk_lazor
	name = "LazorZ"
	desc = ""
	panel = "Hulk"
	charge_max = 250
	clothes_req = 0
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/hulk_lazor/cast(list/targets)
	if (usr.lying || usr.stunned || usr.stat)
		to_chat(usr, "\red You can't right now!")
		return

	var/turf/T = usr.loc
	var/turf/U = get_step(usr, usr.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return

	var/obj/item/projectile/beam/A = new /obj/item/projectile/beam(usr.loc)
	playsound(usr.loc, 'sound/weapons/taser2.ogg', 75, 1)
	A.original = U
	A.current = U
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn( 0 )
		A.process()

	usr.attack_log += "\[[time_stamp()]\]<font color='red'> Uses hulk_lazor</font>"
	msg_admin_attack("[key_name(usr)] uses hulk_lazor")

/obj/effect/proc_holder/spell/aoe_turf/HulkHONK
	name = "HulkHONK"
	desc = ""
	panel = "Hulk"
	charge_max = 250
	clothes_req = 0
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/HulkHONK/cast(list/target)
	if (usr.lying || usr.stunned || usr.stat)
		to_chat(usr, "<span class='red'>You can't right now!</span>")
		return
	playsound(usr, 'sound/items/AirHorn.ogg',100, 1)
	usr.attack_log += "\[[time_stamp()]\]<font color='red'> Uses HulkHONK</font>"
	msg_admin_attack("[key_name(usr)] uses HulkHONK")
	for(var/mob/living/carbon/M in ohearers(2))
		if(CLUMSY in M.mutations)
			M.heal_bodypart_damage(10, 10)
			M.adjustToxLoss(-10)
			M.adjustOxyLoss(-10)
			M.AdjustWeakened(-1)
			M.AdjustStunned(-1)
		else
			var/mob/living/carbon/human/H = M
			if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
				continue
			M.stuttering += 2
			M.ear_deaf += 2
			M.Weaken(2)
			M.make_jittery(500)


/obj/item/weapon/organ/attack_animal(mob/user)
	..()
	if(istype(user, /mob/living/simple_animal/hulk))
		if(istype(src, /obj/item/weapon/organ/head))
			to_chat(usr, "\blue Head? Ewww..")
			return
		var/mob/living/simple_animal/hulk/Hulk = user
		playsound(user.loc, 'sound/weapons/zilla_eat.ogg', 50, 2)
		Hulk.health += 10
		usr.visible_message("\red <b>[usr.name]</b> eats [src.name]!")
		qdel(src)

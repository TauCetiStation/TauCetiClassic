/obj/item/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = 1
	flag = "magic"

	var/power_of_spell = 1

/obj/item/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	light_special_on = TRUE
	light_color = "#00bfff"
	light_power = 2
	light_range = 2
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "magic"

/obj/item/projectile/magic/atom_init(mapload, power_of_spell = 1)
	src.power_of_spell = power_of_spell
	. = ..()

/obj/item/projectile/magic/change/on_hit(atom/change)
	wabbajack(change)

/obj/item/projectile/magic/change/proc/wabbajack (mob/M in living_mob_list)
	if(istype(M, /mob/living) && M.stat != DEAD)
		if(M.monkeyizing)	return
		M.monkeyizing = 1
		M.canmove = 0
		M.icon = null
		M.overlays.Cut()
		M.invisibility = 101

		if(istype(M, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/Robot = M
			if(Robot.mmi)	qdel(Robot.mmi)
		else
			for(var/obj/item/W in M)
				if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
					qdel(W)
					continue
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)
				W.loc = M.loc
				W.dropped(M)

		var/mob/living/new_mob

		//var/randomize = pick("monkey","robot","slime","xeno","human") No xeno for now.
		var/randomize = pick("monkey","robot","slime","human")
		switch(randomize)
			if("monkey")
				new_mob = new /mob/living/carbon/monkey(M.loc)
				new_mob.universal_speak = 1
			if("robot")
				new_mob = new /mob/living/silicon/robot(M.loc)
				new_mob.gender = M.gender
				new_mob.invisibility = 0
				new_mob.job = "Cyborg"
				var/mob/living/silicon/robot/Robot = new_mob
				Robot.mmi = new /obj/item/device/mmi(new_mob)
				Robot.mmi.transfer_identity(M)	//Does not transfer key/client.
			if("slime")
				if(prob(50))		new_mob = new /mob/living/carbon/slime/adult(M.loc)
				else				new_mob = new /mob/living/carbon/slime(M.loc)
				new_mob.universal_speak = 1
			//if("xeno")
			//	var/alien_caste = pick("Hunter","Sentinel","Drone","Larva")
			//	switch(alien_caste)
			//		if("Hunter")	new_mob = new /mob/living/carbon/alien/humanoid/hunter(M.loc)
			//		if("Sentinel")	new_mob = new /mob/living/carbon/alien/humanoid/sentinel(M.loc)
			//		if("Drone")		new_mob = new /mob/living/carbon/alien/humanoid/drone(M.loc)
			//		else			new_mob = new /mob/living/carbon/alien/larva(M.loc)
			//	new_mob.universal_speak = 1
			if("human")
				new_mob = new /mob/living/carbon/human(M.loc, pick(all_species))
				if(M.gender == MALE)
					new_mob.gender = MALE
					new_mob.name = pick(first_names_male)
				else
					new_mob.gender = FEMALE
					new_mob.name = pick(first_names_female)
				new_mob.name += " [pick(last_names)]"
				new_mob.real_name = new_mob.name

				var/datum/preferences/A = new()	//Randomize appearance for the human
				A.randomize_appearance_for(new_mob)
	/*		if("animal")
				if(prob(50))
					var/beast = pick("carp","bear","tomato","goat")
					switch(beast)
						if("carp")		new_mob = new /mob/living/simple_animal/hostile/carp(M.loc)
						if("bear")		new_mob = new /mob/living/simple_animal/hostile/bear(M.loc)
						if("tomato")	new_mob = new /mob/living/simple_animal/hostile/tomato(M.loc)
						if("goat")		new_mob = new /mob/living/simple_animal/hostile/retaliate/goat(M.loc)
				else
					var/animal = pick("parrot","corgi","crab","cat","mouse","chicken","cow","lizard","chick")
					switch(animal)
						if("parrot")	new_mob = new /mob/living/simple_animal/parrot(M.loc)
						if("corgi")		new_mob = new /mob/living/simple_animal/corgi(M.loc)
						if("crab")		new_mob = new /mob/living/simple_animal/crab(M.loc)
						if("cat")		new_mob = new /mob/living/simple_animal/cat(M.loc)
						if("mouse")		new_mob = new /mob/living/simple_animal/mouse(M.loc)
						if("chicken")	new_mob = new /mob/living/simple_animal/chicken(M.loc)
						if("cow")		new_mob = new /mob/living/simple_animal/cow(M.loc)
						if("lizard")	new_mob = new /mob/living/simple_animal/lizard(M.loc)
						else			new_mob = new /mob/living/simple_animal/chick(M.loc)
				new_mob.universal_speak = 1	*/
			else
				return

		for (var/obj/effect/proc_holder/spell/S in M.spell_list)
			new_mob.spell_list += new S.type

		new_mob.attack_log = M.attack_log
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>[M.real_name] ([M.ckey]) became [new_mob.real_name].</font>")

		new_mob.a_intent = "hurt"
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.key = M.key

		to_chat(new_mob, "<B>Your form morphs into that of a [randomize].</B>")

		qdel(M)
		return new_mob

/obj/item/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	light_special_on = TRUE
	light_color = "#ff0000"
	light_power = 2
	light_range = 2
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "magic"

/obj/item/projectile/magic/animate/Bump(atom/change)
	. = ..()
	if(istype(change, /obj/item) || istype(change, /obj/structure) && !is_type_in_list(change, protected_objects))
		var/obj/O = change
		new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer)
	else if(istype(change, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = change
		C.ChangeOwner(firer)


/*
/obj/item/projectile/magic/death
	name = "bolt of death"
	icon_state = "pulse1_bl"
	damage = 9001
	damage_type = OXY
	nodamage = 0
	flag = "magic"*/

/obj/item/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"
	damage = 0
	damage_type = OXY
	nodamage = 1
	flag = "magic"

/obj/item/projectile/magic/resurrection/on_hit(mob/living/carbon/target)
	if(!istype(target))
		return
	var/old_stat = target.stat
	target.revive()
	if(!target.ckey || !target.mind)
		for(var/mob/dead/observer/ghost in dead_mob_list)
			if(target.mind == ghost.mind)
				ghost.reenter_corpse()
				break
	if(old_stat != DEAD)
		to_chat(target, "<span class='notice'>You feel great!</span>")
	else
		to_chat(target, "<span class='notice'>You rise with a start, you're alive!!!</span>")

/obj/item/projectile/magic/door
	name = "bolt of door creation"
	icon_state = "energy"
	damage = 0
	damage_type = OXY
	nodamage = 1
	flag = "magic"
	var/list/doors = list(/obj/structure/mineral_door/metal, /obj/structure/mineral_door/silver,/obj/structure/mineral_door/gold, /obj/structure/mineral_door/uranium,
					/obj/structure/mineral_door/sandstone, /obj/structure/mineral_door/transparent/diamond, /obj/structure/mineral_door/wood)

/obj/item/projectile/magic/door/on_hit(atom/target)
	if(!(getOPressureDifferential(target) >= FIREDOOR_MAX_PRESSURE_DIFF))
		if(istype(target, /turf/simulated/wall))
			var/turf/place = target
			place.ChangeTurf(/turf/simulated/floor/plating)
			var/pickedtype = pick(doors)
			new pickedtype(place)
		else if(istype(target, /obj/machinery/door))
			var/obj/machinery/door/D = target
			D.open()
		else if(istype(target, /obj/structure/mineral_door))
			var/obj/structure/mineral_door/D = target
			D.Open()
	qdel(src)

/*/obj/item/projectile/magic/teleport
	name = "bolt of teleportation"
	icon_state = "bluespace"
	damage = 0
	damage_type = OXY
	nodamage = 1
	flag = "magic"
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

/obj/item/projectile/magic/teleport/on_hit(mob/target)
	var/teleammount = 0
	var/teleloc = target
	if(!isturf(target))
		teleloc = target.loc
	for(var/atom/movable/stuff in teleloc)
		if(!stuff.anchored && stuff.loc)
			teleammount++
			do_teleport(stuff, stuff, 10)
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
			smoke.set_up(max(round(10 - teleammount),1), 0, stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
			smoke.start()*/

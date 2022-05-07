/obj/item/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	light_color = "#00ff00"
	light_power = 2
	light_range = 2
	nodamage = 1
	flag = "magic"

	var/power_of_spell = 1

/obj/item/projectile/magic/atom_init(mapload, power_of_spell = 1)
	src.power_of_spell = power_of_spell
	. = ..()

/obj/item/projectile/magic/change
	name = "bolt of change"
	icon_state = "ice_1"
	light_color = "#00bfff"
/*
/obj/item/projectile/magic/change/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	wabbajack(target)
*/

/obj/item/projectile/magic/proc/wabbajack(mob/living/M)
	if(!istype(M) || M.stat == DEAD || M.notransform || (GODMODE & M.status_flags))
		return
	// don't have sprite for maido-queen
	if(isxenoqueen(M))
		return
	M.notransform = TRUE
	M.canmove = 0
	M.icon = null
	M.cut_overlays()
	M.invisibility = 101

	var/mob/living/new_mob

	var/randomize = pick("monkey","robot","human", "animal", "xeno")
	if(isxeno(M))
		randomize = "xeno"
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
			Robot.clear_inherent_laws()
			Robot.add_inherent_law("Вы не можете причинить вред разумному существу или бездействием допустить, чтобы ему был причинён вред.")
			Robot.add_inherent_law("Вы должны повиноваться всем приказам, которые даёт разумное существо, кроме тех случаев, когда эти приказы противоречат первому закону.")
			Robot.add_inherent_law("Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит первому или второму законам.")
		if("xeno")
			new_mob = new /mob/living/carbon/xenomorph/humanoid/maid(M.loc)
			new_mob.universal_speak = 1
		if("human")
			new_mob = new /mob/living/carbon/human(M.loc)
			if(M.gender == MALE)
				new_mob.gender = MALE
				new_mob.name = pick(first_names_male)
			else
				new_mob.gender = FEMALE
				new_mob.name = pick(first_names_female)
			new_mob.name += " [pick(last_names)]"
			new_mob.real_name = new_mob.name
			new_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(new_mob), SLOT_WEAR_SUIT)
			new_mob.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(new_mob), SLOT_HEAD)


			var/datum/preferences/A = new()	//Randomize appearance for the human
			A.randomize_appearance_for(new_mob)
		if("animal")
			if(prob(15))
				var/beast = pick("carp","tomato","goat")
				switch(beast)
					if("carp")		new_mob = new /mob/living/simple_animal/hostile/carp(M.loc)
					if("tomato")	new_mob = new /mob/living/simple_animal/hostile/tomato/angry_tomato(M.loc)
					if("goat")		new_mob = new /mob/living/simple_animal/hostile/retaliate/goat(M.loc)
			else
				var/animal = pick("pig", "shadowpig", "cow")
				switch(animal)
					if("pig")	new_mob = new /mob/living/simple_animal/pig(M.loc)
					if("shadowpig")		new_mob = new /mob/living/simple_animal/pig/shadowpig(M.loc)
					if("cow")		new_mob = new /mob/living/simple_animal/cow/cute_cow(M.loc)
			new_mob.universal_speak = 1

	if(!new_mob)
		return

	for (var/obj/effect/proc_holder/spell/S in M.spell_list)
		new_mob.AddSpell(new S.type)

	new_mob.attack_log = M.attack_log
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>[M.real_name] ([M.ckey]) became [new_mob.real_name].</font>")

	new_mob.set_a_intent(INTENT_HARM)
	if(M.mind)
		M.mind.transfer_to(new_mob)
	else
		new_mob.key = M.key
		create_spawner(/datum/spawner/living/spirit_incarnate, new_mob)

	to_chat(new_mob, "<B>Your form morphs into that of a [randomize].</B>")

	qdel(M)
	return new_mob

/obj/item/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	light_color = "#ff0000"

/obj/item/projectile/magic/animate/Bump(atom/change)
	. = ..()
	if(isitem(change) || istype(change, /obj/structure) && !is_type_in_list(change, protected_objects))
		var/obj/O = change
		new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer)
	else if(istype(change, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = change
		C.ChangeOwner(firer)
		create_spawner(/datum/spawner/living/mimic, C)
	else if(istype(change, /mob/living/simple_animal/shade) || isxeno(change))
		wabbajack(change)

/obj/item/projectile/magic/resurrection
	name = "bolt of resurrection"
	icon_state = "ion"
	light_color = "#a9e2f3"

/obj/item/projectile/magic/resurrection/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/old_stat = C.stat
	C.revive()
	if(!C.ckey || !C.mind)
		for(var/mob/dead/observer/ghost as anything in observer_list)
			if(C.mind == ghost.mind)
				ghost.reenter_corpse()
				break
	if(old_stat != DEAD)
		to_chat(target, "<span class='notice'>You feel great!</span>")
	else
		to_chat(target, "<span class='notice'>You rise with a start, you're alive!!!</span>")

/obj/item/projectile/magic/door
	name = "bolt of door creation"
	var/list/doors = list(/obj/structure/mineral_door/metal, /obj/structure/mineral_door/silver,/obj/structure/mineral_door/gold, /obj/structure/mineral_door/uranium,
					/obj/structure/mineral_door/sandstone, /obj/structure/mineral_door/transparent/diamond, /obj/structure/mineral_door/wood)

/obj/item/projectile/magic/door/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
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

/obj/item/projectile/magic/forcebolt
	name = "force bolt"
	icon_state = "ice_1"
	light_color = "#00bfff"
	damage = 20
	nodamage = 0

/obj/item/projectile/magic/forcebolt/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)

	var/obj/T = target
	var/throwdir = get_dir(firer,target)
	T.throw_at(get_edge_target_turf(target, throwdir),10,10)
	return 1

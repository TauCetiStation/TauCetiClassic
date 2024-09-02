/obj/item/projectile/magic
	name = "bolt of nothing"
	icon_state = "energy"
	light_color = "#ffffff"
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

/obj/item/projectile/magic/change/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	wabbajack(target)

/obj/item/projectile/magic/proc/wabbajack(mob/living/M)
	if(!istype(M) || isAI(M) || isdrone(M) || isconstruct(M) || M.stat == DEAD || M.notransform || (GODMODE & M.status_flags) || isxenoqueen(M))
		return

	if(!issilicon(M))
		for(var/obj/item/W in M)
			M.drop_from_inventory(W)

	var/mob/living/new_mob

	var/randomizer = pick("animal", "cyborg", "carbon")
	switch(randomizer)
		if("animal")
			var/beast = pick(
				/mob/living/simple_animal/mouse,
				/mob/living/simple_animal/cow,
				/mob/living/simple_animal/chicken,
				/mob/living/simple_animal/chick,
				/mob/living/simple_animal/cat,
				/mob/living/simple_animal/corgi,
				/mob/living/simple_animal/corgi/Lisa,
				/mob/living/simple_animal/corgi/borgi,
				/mob/living/simple_animal/corgi/puppy,
				/mob/living/simple_animal/parrot,
				/mob/living/simple_animal/crab,
				/mob/living/simple_animal/hostile/retaliate/goat,
				/mob/living/simple_animal/pig/shadowpig,
				/mob/living/simple_animal/pig,
				/mob/living/simple_animal/turkey,
				/mob/living/simple_animal/goose,
				/mob/living/simple_animal/seal,
				/mob/living/simple_animal/walrus,
				/mob/living/simple_animal/fox,
				/mob/living/simple_animal/lizard,
				/mob/living/simple_animal/pug,
				/mob/living/simple_animal/shiba,
				/mob/living/simple_animal/mushroom,
				/mob/living/simple_animal/yithian,
				/mob/living/simple_animal/spiderbot)
			new_mob = new beast(M.loc)
			new_mob.universal_speak = TRUE
		if("cyborg")
			new_mob = new /mob/living/silicon/robot(M.loc, "Default", /datum/ai_laws/asimov_xenophile, FALSE, global.chaplain_religion)
			new_mob.gender = M.gender
			new_mob.invisibility = 0
			new_mob.job = "Cyborg"
		if("carbon")
			var/carbon = pick(
				/mob/living/carbon/human,
				/mob/living/carbon/monkey,
				/mob/living/carbon/monkey/tajara,
				/mob/living/carbon/monkey/skrell,
				/mob/living/carbon/monkey/unathi,
				/mob/living/carbon/monkey/diona/podman,
				/mob/living/carbon/human/tajaran,
				/mob/living/carbon/human/skrell,
				/mob/living/carbon/human/unathi,
				/mob/living/carbon/human/podman,
				/mob/living/carbon/human/abductor,
				/mob/living/carbon/human/golem,
				/mob/living/carbon/human/vox)
			new_mob = new carbon(M.loc)
			new_mob.gender = M.gender
			new_mob.languages = M.languages
	if(!new_mob)
		return

	new_mob.attack_log = M.attack_log
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>[M.real_name] ([M.ckey]) became [new_mob.real_name].</font>")

	if(M.mind)
		M.mind.transfer_to(new_mob)
	else
		new_mob.key = M.key

	if(!M.original_body)
		new_mob.original_body = M
		M.original_body = M

	M.forceMove(new_mob)
	new_mob.original_body = M.original_body

	for(var/mob/living/H in M.contents)
		H.forceMove(new_mob)
		qdel(M)

	new_mob.wabbajacked = 1

	to_chat(new_mob, "<B>Your body forms to something else!</B>")

/mob/living/proc/unwabbajack(mob/living/M)
	if(!issilicon(M))
		for(var/obj/item/W in M)
			M.drop_from_inventory(W)

	var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
	smoke.set_up(10, 0, src.loc)
	smoke.start()
	playsound(src, 'sound/effects/bamf.ogg', VOL_EFFECTS_MASTER)

	var/obj/effect/decal/remains/human/RH = new /obj/effect/decal/remains/human(src.loc)
	var/matrix/Mx = matrix()
	RH.transform = Mx

	for(M in contents)
		M.loc = src.loc
		if(isliving(M))
			var/mob/living/L = M
			L.Paralyse(15)
			L.update_canmove()
			if(mind && original_body)
				mind.transfer_to(original_body)

	qdel(src)

/obj/item/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	light_color = "#ff0000"

/obj/item/projectile/magic/animate/on_hit(atom/change)
	. = ..()
	if(isitem(change) || istype(change, /obj/structure) && !is_type_in_list(change, protected_objects))
		var/obj/O = change
		new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer)
	else if(istype(change, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = change
		C.ChangeOwner(firer)
		create_spawner(/datum/spawner/living/mimic, C)
	else if(isshade(change) || isxeno(change))
		var/mob/living/M = animate_atom_living(change)
		if(!M)
			return
		if(firer && iswizard(firer))
			var/datum/role/wizard/mage = firer.mind.GetRole(WIZARD)
			var/datum/faction/wizards/federation = mage.GetFaction()
			if(federation && M.mind)
				var/datum/role/wizard_apprentice/recruit = add_faction_member(federation, M)
				var/datum/objective/target/protect/new_objective = recruit.AppendObjective(/datum/objective/target/protect)
				new_objective.explanation_text = "Help [firer.real_name], the Demiurgos of your new life."
				new_objective.target = firer.mind
				var/datum/role/R = M.mind.GetRole(EVIL_SHADE)
				if(R)
					R.Deconvert()

/obj/item/projectile/magic/animate/proc/animate_atom_living(mob/living/M)
	if(!istype(M) || M.stat == DEAD || M.notransform || (GODMODE & M.status_flags) || !M.client || isxenoqueen(M))
		return

	M.notransform = TRUE
	M.canmove = 0
	M.icon = null
	M.cut_overlays()
	M.invisibility = 101

	var/mob/living/new_mob

	var/randomizer = pick("animal", "cyborg", "xeno")
	if(isxeno(M))
		randomizer = "xeno"
	switch(randomizer)
		if("animal")
			var/beast = pick(/mob/living/simple_animal/hostile/carp, /mob/living/simple_animal/hostile/tomato/angry_tomato, /mob/living/simple_animal/hostile/retaliate/goat, /mob/living/simple_animal/pig/shadowpig)
			new_mob = new beast(M.loc)
			new_mob.universal_speak = TRUE
		if("cyborg")
			new_mob = new /mob/living/silicon/robot(M.loc, "Default", /datum/ai_laws/asimov_xenophile, FALSE, global.chaplain_religion)
			new_mob.gender = M.gender
			new_mob.invisibility = 0
			new_mob.job = "Cyborg"
		if("xeno")
			new_mob = new /mob/living/carbon/xenomorph/humanoid/maid(M.loc)
			new_mob.universal_speak = TRUE
	if(!new_mob)
		return

	new_mob.attack_log = M.attack_log
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>[M.real_name] ([M.ckey]) became [new_mob.real_name].</font>")

	new_mob.set_a_intent(INTENT_HARM)
	if(M.mind)
		M.mind.transfer_to(new_mob)
	else
		new_mob.key = M.key

	to_chat(new_mob, "<B>Your body forms to something else!</B>")

	qdel(M)
	return new_mob

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
		if(iswallturf(target))
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

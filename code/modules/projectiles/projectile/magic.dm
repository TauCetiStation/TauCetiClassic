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

/obj/item/projectile/magic/change/on_hit(atom/target, def_zone = BP_CHEST, blocked = 0)
	if(isliving(target))
		var/mob/living/L = target
		L.wabbajack()

/mob/living/proc/wabbajack(new_body, permanent = FALSE)
	if(!istype(src)|| notransform || isxenoqueen(src))
		return
	if(!isliving(new_body))
		for(var/mob/living/L in src.contents)
			if(L || (GODMODE & status_flags))
				return
			if(!L && stat == DEAD)
				return

	var/mob/living/new_mob

	if(isliving(new_body)) //Returny case
		var/mob/L = new_body
		L.forceMove(get_turf(src))
		L.notransform = FALSE
		new_mob = L

	if(!new_body)
		new_body = pick("monkey", "animal", "hostile", "hostile", "cyborg", "xeno", "humanoid")
	switch(new_body)
		if("monkey")
			new_mob = new /mob/living/carbon/monkey(get_turf(loc))
		if("animal")
			var/beast = pick(
			/mob/living/simple_animal/hostile/retaliate/goat,
			/mob/living/simple_animal/pig/shadowpig,
			/mob/living/simple_animal/parrot,
			/mob/living/simple_animal/mouse,
			/mob/living/simple_animal/corgi,
			/mob/living/simple_animal/crab,
			/mob/living/simple_animal/pug,
			/mob/living/simple_animal/cat,
			/mob/living/simple_animal/cow,
			/mob/living/simple_animal/fox,
			/mob/living/simple_animal/chick,
			/mob/living/simple_animal/lizard,
			/mob/living/simple_animal/chicken,
			/mob/living/simple_animal/mushroom,
			/mob/living/simple_animal/cat/Syndi,
			)
			new_mob = new beast(get_turf(loc))
			new_mob.universal_speak = TRUE
			new_mob.add_status_flags(GODMODE)
			new_mob.maxHealth = 10000
			new_mob.health = 10000
		if("hostile")
			var/beast = pick(
			/mob/living/simple_animal/hostile/carp,
			/mob/living/simple_animal/hostile/tree,
			/mob/living/simple_animal/hostile/tomato,
			/mob/living/simple_animal/hostile/giant_spider,
			/mob/living/simple_animal/hostile/giant_spider/hunter,
			/mob/living/simple_animal/hostile/blob/blobbernaut/independent,
			/mob/living/simple_animal/hostile/asteroid/basilisk,
			/mob/living/simple_animal/hostile/asteroid/goliath,
			/mob/living/simple_animal/construct/proteon,
			/mob/living/simple_animal/construct/behemoth,
			/mob/living/simple_animal/construct/wraith,
			/mob/living/carbon/xenomorph/humanoid/maid,
			)
			new_mob = new beast(get_turf(loc))
			new_mob.universal_speak = TRUE
		if("cyborg")
			new_mob = new /mob/living/silicon/robot(get_turf(loc), "Default", /datum/ai_laws/asimov_xenophile, FALSE, global.chaplain_religion)
			new_mob.gender = gender
			new_mob.invisibility = 0
			new_mob.job = "Cyborg"
		if("xeno")
			var/xeno_type = pick(
				/mob/living/carbon/xenomorph/humanoid/hunter,
				/mob/living/carbon/xenomorph/humanoid/sentinel,
			)
			new_mob = new xeno_type(get_turf(loc))
			new_mob.universal_speak = TRUE
		if("humanoid")
			var/mob/living/carbon/human/new_human = new (get_turf(loc))
			if(prob(80))
				var/list/possibilites = all_species.Copy()
				possibilites -= list(ZOMBIE, ZOMBIE_TAJARAN, ZOMBIE_SKRELL, ZOMBIE_UNATHI)
				new_human.set_species(pick(possibilites))

			// Randomize everything but the species, which was already handled above.
			new_human.update_body()
			new_human.update_hair()
			new_human.dna.ResetUI()
			new_human.dna.ResetSE()
			new_mob = new_human
	if(!new_mob)
		return

	new_mob.attack_log = attack_log
	attack_log += text("\[[time_stamp()]\] <font color='orange'>[real_name] ([ckey]) became [new_mob.real_name].</font>")

	if(mind)
		mind.transfer_to(new_mob)
	else
		new_mob.key = key

	if(isliving(new_body)) //Returny case
		var/mob/dead/observer/ghost = new_mob.get_ghost()
		if(ghost)
			ghost.reenter_corpse()
		new_mob.burn_skin((maxHealth - health) / maxHealth * new_mob.maxHealth) //You can bring them to the doorstep of death
		qdel(src)
	else
		to_chat(new_mob,"<font color='red'>============Полиморфизм - краткий курс============</font><BR>\
		- Хоть ваше тело и изменилось (быть может, до неузнаваемости) - это не значит, что ваш разум также прерпет изменение!<BR>\
		- Ваш разум - всё тот же, как и раньше. Вы были членом экипажа? Им вы и остались!<BR>\
		- На вас действуют те же правила и ограничения, что и до превращения.<BR>\
		<font color='red'>============Прочие детали============</font><<BR>\
		- В таком обличии вам предстоит провести некоторое время: иногда это может занять минуту, а иногда это до конца (может быть и вашего).<BR>\
		- В случае временного превращения полученный вами урон перейдёт на старое тело. Если раньше вы были человеком, то смерть в новом теле вас не убьёт моментально, однако может сильно ранить, в ином случае всё может быть печальнее.<BR>\
		- Если раньше вы были человеком, то смерть в новом теле вас не убьёт моментально, однако может сильно ранить, в ином случае всё может быть печальнее.")

		new_mob.set_a_intent(INTENT_HARM)
		if(!permanent)
			forceMove(new_mob)
			addtimer(CALLBACK(new_mob, .proc/wabbajack, src), 40 SECONDS)
			notransform = TRUE
		else
			qdel(src)

	return new_mob

/obj/item/projectile/magic/animate
	name = "bolt of animation"
	icon_state = "red_1"
	light_color = "#ff0000"

/obj/item/projectile/magic/animate/on_impact(atom/change)
	. = ..()
	if(isitem(change) || istype(change, /obj/structure) && !is_type_in_list(change, protected_objects))
		var/obj/O = change
		new /mob/living/simple_animal/hostile/mimic/copy(O.loc, O, firer)
	else if(istype(change, /mob/living/simple_animal/hostile/mimic/copy))
		// Change our allegiance!
		var/mob/living/simple_animal/hostile/mimic/copy/C = change
		C.ChangeOwner(firer)
		create_spawner(/datum/spawner/living/mimic, C)
	else if(istype(change, /mob/living/simple_animal/shade))
		var/mob/living/M = change
		M = M.wabbajack("animal", TRUE)
		if(firer && iswizard(firer))
			var/datum/role/wizard/mage = firer.mind.GetRole(WIZARD)
			var/datum/faction/wizards/federation = mage.GetFaction()
			if(federation)
				var/datum/role/wizard_apprentice/recruit = add_faction_member(federation, M)
				var/datum/objective/target/protect/new_objective = recruit.AppendObjective(/datum/objective/target/protect)
				new_objective.explanation_text = "Help [firer.real_name], the Demiurgos of your new life."
				new_objective.target = firer.mind

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

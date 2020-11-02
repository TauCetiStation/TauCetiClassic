/obj/effect/proc_holder/spell/targeted/spawn_bible
	name = "Create bible"
	desc = "Bible"

	charge_max = 2 MINUTES
	favor_cost = 100
	divine_power = 1 //count
	needed_aspect = list(ASPECT_RESOURCES = 1, ASPECT_RESCUE = 1)

	range = 0
	invocation = "none"
	clothes_req = 0

	action_icon_state = "spawn_bible"
	sound = 'sound/effects/phasein.ogg'

/obj/effect/proc_holder/spell/targeted/spawn_bible/cast()
	for(var/mob/living/carbon/human/M in viewers(usr.loc, null))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	for(var/i in 1 to divine_power)
		global.chaplain_religion.spawn_bible(usr.loc)

/obj/effect/proc_holder/spell/targeted/heal
	name = "Heal"

	favor_cost = 300
	charge_max = 1.5 MINUTES
	divine_power = -5 //power
	needed_aspect = list(ASPECT_RESCUE = 1, ASPECT_CHAOS = 1)

	clothes_req = 0
	invocation = "none"
	range = 6
	selection_type = "range"

	action_icon_state = "heal"
	sound = 'sound/magic/heal.ogg'


/obj/effect/proc_holder/spell/targeted/heal/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		revert_cast()
		return

	var/mob/living/carbon/target = locate() in targets

	var/mob/living/carbon/human/H = target
	if(!(H in oview(range))) // If they are not in overview after selection.
		to_chat(user, "<span class='warning'>They are too far away!</span>")
		revert_cast()
		return

	H.apply_damages(divine_power * rand(-2, 10) * 0.1, divine_power * rand(-2, 10) * 0.1, divine_power * rand(-2, 10) * 0.1)

/obj/effect/proc_holder/spell/targeted/heal/damage
	name = "Punishment"

	favor_cost = 300
	charge_max = 1.5 MINUTES
	divine_power = 5 //power
	needed_aspect = list(ASPECT_OBSCURE = 1, ASPECT_CHAOS = 1)

	action_icon_state = "god_default"
	sound = 'sound/magic/Repulse.ogg'

/obj/effect/proc_holder/spell/dumbfire/blessing
	name = "Blessing"

	favor_cost = 200
	charge_max = 1 MINUTES
	divine_power = 5 //power
	needed_aspect = list(ASPECT_WEAPON = 1, ASPECT_MYSTIC = 1)

	range = 0
	invocation = "none"
	clothes_req = 0

	action_icon_state = "blessing"
	sound = 'sound/magic/heal.ogg'

/obj/effect/proc_holder/spell/dumbfire/blessing/cast()
	var/list/possible_targets = list()
	var/obj/item/weapon/target

	for(var/obj/item/W in orange(3))
		if(!W.blessed)
			possible_targets += W

	if(possible_targets.len == 0)
		revert_cast()
		return

	target = input("Choose the target for the spell.", "Targeting") in possible_targets

	target.visible_message("<span class='notice'>[target] has been blessed by [usr]!</span>")
	target.name = "blessed [target.name]"
	target.force += divine_power
	var/holy_outline = filter(type = "outline", size = 1, color = "#fffb00a1")
	target.filters += holy_outline

	target.blessed = TRUE

/obj/effect/proc_holder/spell/targeted/charge/religion
	name = "Electric Charge Pulse"

	favor_cost = 400
	charge_max = 4 MINUTES
	divine_power = 1 //range
	needed_aspect = list(ASPECT_RESCUE = 1, ASPECT_TECH = 1)

	range = 0
	invocation = "none"
	invocation_type = "none"
	clothes_req = 0

	action_icon_state = "charge"

/obj/effect/proc_holder/spell/targeted/charge/religion/proc/flick_sparks(atom/movable/AM)
	var/obj/effect/effect/sparks/blue/B = new /obj/effect/effect/sparks/blue(AM.loc)
	QDEL_IN(B, 6)

/obj/effect/proc_holder/spell/targeted/charge/religion/cast(mob/user = usr)
	var/charged = FALSE

	for(var/I in range(divine_power))
		if(isrobot(I))
			var/mob/living/silicon/robot/R = I
			flick_sparks(R)
			if(R.cell)
				cell_charge(R.cell)
				charged = TRUE

		else if(istype(I, /obj/item/weapon/stock_parts/cell))
			flick_sparks(I)
			cell_charge(I)
			charged = TRUE

		else if(istype(I, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = I
			flick_sparks(B)
			B.charges = initial(B.charges)
			B.status = 1
			B.update_icon()
			charged = TRUE

		else if(istype(I, /obj/machinery/power/smes))
			flick_sparks(I)
			charged = TRUE
			for(var/obj/item/weapon/stock_parts/cell/Cell in I)
				cell_charge(Cell)

		else if(istype(I, /obj/mecha))
			var/obj/mecha/M = I
			flick_sparks(M)
			cell_charge(M.cell)
			charged = TRUE

		else if(istype(I, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/A = I
			flick_sparks(A)
			cell_charge(A.cell)
			charged = TRUE

	if(charged)
		playsound(user, 'sound/magic/Charge.ogg', VOL_EFFECTS_MASTER)
	else
		to_chat(user, "<span class='notice'>There is nothing to charge in the radius!</span>")
		revert_cast()
		return

/obj/effect/proc_holder/spell/targeted/food
	name = "Spawn food"

	favor_cost = 250
	charge_max = 3 MINUTES
	divine_power = 2 //count
	needed_aspect = list(ASPECT_SPAWN = 1 , ASPECT_FOOD = 1)

	range = 0
	invocation = "none"
	clothes_req = 0

	action_icon_state = "spawn_food"
	sound = 'sound/effects/phasein.ogg'

/obj/effect/proc_holder/spell/targeted/food/cast()
	for(var/mob/living/carbon/human/M in viewers(usr.loc))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	spawn_food(usr.loc, 4 + rand(1, divine_power))

/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal
	name = "Create random friendly animal"

	favor_cost = 250
	charge_max = 2 MINUTES
	divine_power = 1 //count
	needed_aspect = list(ASPECT_SPAWN = 1)
	summon_amt = 0

	invocation = "none"
	clothes_req = 0

	action_icon_state = "spawn_animal"
	sound = 'sound/effects/phasein.ogg'

	summon_type = list(/mob/living/simple_animal/corgi/puppy, /mob/living/simple_animal/hostile/retaliate/goat, /mob/living/simple_animal/corgi, /mob/living/simple_animal/cat, /mob/living/simple_animal/parrot, /mob/living/simple_animal/crab, /mob/living/simple_animal/cow, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken, /mob/living/simple_animal/pig, /mob/living/simple_animal/turkey, /mob/living/simple_animal/goose, /mob/living/simple_animal/seal, /mob/living/simple_animal/walrus, /mob/living/simple_animal/fox, /mob/living/simple_animal/lizard, /mob/living/simple_animal/mouse, /mob/living/simple_animal/mushroom, /mob/living/simple_animal/pug, /mob/living/simple_animal/shiba, /mob/living/simple_animal/yithian, /mob/living/simple_animal/tindalos, /mob/living/carbon/monkey, /mob/living/carbon/monkey/skrell, /mob/living/carbon/monkey/tajara, /mob/living/carbon/monkey/unathi, /mob/living/simple_animal/slime)

/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal/cast()
	// if you write 0, then the variable will not change, because '*=' used to increase the divine_power
	if(divine_power != 1)
		summon_amt += divine_power
	for(var/mob/living/carbon/human/M in viewers(usr.loc, null))
		if(M.mind && !M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()
	..()

/obj/effect/proc_holder/spell/targeted/grease
	name = "Spill grease"

	favor_cost = 500
	charge_max = 5 MINUTES
	divine_power = 1 //range
	needed_aspect = list(ASPECT_WACKY = 3)

	invocation = "none"
	range = 0
	clothes_req = 0

	action_icon_state = "grease"
	sound = 'sound/magic/ForceWall.ogg'

/obj/effect/proc_holder/spell/targeted/grease/cast()
	for(var/turf/simulated/floor/F in RANGE_TURFS(divine_power, usr))
		F.make_wet_floor(LUBE_FLOOR)

/obj/effect/proc_holder/spell/dumbfire/infection
	name = "Spread a good infection"
	desc = "Good infection with viruses weight even and mind restoration"

	favor_cost = 300
	charge_max = 3 MINUTES
	divine_power = 1 //range
	needed_aspect = list(ASPECT_RESCUE = 1, ASPECT_OBSCURE = 1)

	range = 0
	invocation = "none"
	clothes_req = 0

	action_icon_state = "infection_good"
	sound = 'sound/magic/Smoke.ogg'

	var/list/infected = list()
	var/obj/effect/proc_holder/spell/dumbfire/infection/obcurse/evil_spell

/obj/effect/proc_holder/spell/dumbfire/infection/cast()
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	create_reagents(10)
	reagents.add_reagent("tricordrazine", 10)
	S.attach(usr.loc)
	S.set_up(reagents, 5, 0, usr.loc)
	S.start()

	var/datum/disease2/effectholder/hungry_holder = new
	hungry_holder.effect = new /datum/disease2/effect/weight_even()
	hungry_holder.chance = rand(hungry_holder.effect.chance_minm, hungry_holder.effect.chance_maxm)
	var/datum/disease2/disease/hungry = new
	hungry.addeffect(hungry_holder)

	var/datum/disease2/effectholder/mind_holder = new
	mind_holder.effect = new /datum/disease2/effect/mind_restoration()
	mind_holder.chance = rand(mind_holder.effect.chance_minm, mind_holder.effect.chance_maxm)
	var/datum/disease2/disease/mind = new
	mind.addeffect(mind_holder)

	// That would not infect infected.
	if(!evil_spell)
		for(var/obj/effect/proc_holder/spell/dumbfire/infection/obcurse/O in usr.spell_list)
			evil_spell = O

	for(var/mob/living/carbon/human/H in range(divine_power))
		if(evil_spell)
			if(H in evil_spell.infected)
				continue
			infected += H

		infect_virus2(H, mind)
		infect_virus2(H, hungry)

/obj/effect/proc_holder/spell/dumbfire/infection/obcurse
	name = "Spread a evil infection"
	desc = "Evil infection with viruses cough and headache"

	needed_aspect = list(ASPECT_DEATH = 1, ASPECT_OBSCURE = 1)

	action_icon_state = "infection_evil"

	var/obj/effect/proc_holder/spell/dumbfire/infection/good_spell

/obj/effect/proc_holder/spell/dumbfire/infection/obcurse/cast()
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	create_reagents(1)
	reagents.add_reagent("harvester", 1)
	S.attach(usr.loc)
	S.set_up(reagents, 5, 0, usr.loc)
	S.color = "#421c52" //dark purple
	S.start()

	var/datum/disease2/effectholder/cough_holder = new
	cough_holder.effect = new /datum/disease2/effect/cough()
	cough_holder.chance = rand(cough_holder.effect.chance_minm, cough_holder.effect.chance_maxm)
	var/datum/disease2/disease/cough = new
	cough.addeffect(cough_holder)

	var/datum/disease2/effectholder/headache_holder = new
	headache_holder.effect = new /datum/disease2/effect/headache()
	headache_holder.chance = rand(headache_holder.effect.chance_minm, headache_holder.effect.chance_maxm)
	var/datum/disease2/disease/headache = new
	headache.addeffect(headache_holder)

	// That would not infect infected.
	if(!good_spell)
		for(var/obj/effect/proc_holder/spell/dumbfire/infection/O in usr.spell_list)
			if(istype(O, /obj/effect/proc_holder/spell/dumbfire/infection))
				good_spell = O

	for(var/mob/living/carbon/human/H in range(divine_power))
		if(H.mind && H.mind.holy_role >= HOLY_ROLE_PRIEST)
			continue
		if(good_spell)
			if(H in good_spell.infected)
				continue
			infected += H

		infect_virus2(H, cough)
		infect_virus2(H, headache)

/obj/effect/proc_holder/spell/dumbfire/rot
	name = "The smell of rot"
	desc = "Spread smoke with Thermopsis"

	favor_cost = 150
	charge_max = 3 MINUTES
	divine_power = 1 //count gibs
	needed_aspect = list(ASPECT_FOOD = 1, ASPECT_OBSCURE = 2)

	range = 0
	invocation = "none"
	clothes_req = 0

	action_icon_state = "rot"
	sound = 'sound/magic/Smoke.ogg'

/obj/effect/proc_holder/spell/dumbfire/rot/cast()
	var/datum/effect/effect/system/smoke_spread/chem/S = new
	create_reagents(30)
	reagents.add_reagent("thermopsis", 30)
	S.attach(usr.loc)
	S.set_up(reagents, 2, 0, usr.loc)
	S.color = "#3d0606" //dark red
	S.start()

	if(divine_power >= 1)
		gibs(usr.loc)
		if(divine_power >= 2)
			hgibs(usr.loc)

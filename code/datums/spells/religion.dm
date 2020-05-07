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
		if(!M.mind.holy_role && M.eyecheck() <= 0)
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

/obj/effect/proc_holder/spell/targeted/blessing
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

	var/list/blessed = list()

/obj/effect/proc_holder/spell/targeted/blessing/cast()
	var/list/possible_targets = list()
	var/obj/item/weapon/target

	for(var/obj/item/W in orange(3))
		if(!(W in blessed))
			possible_targets += W

	if(possible_targets.len == 0)
		revert_cast()
		return

	target = input("Choose the target for the spell.", "Targeting") in possible_targets

	target.visible_message("<span class='notice'>[target] has been blessed by [src]!</span>")
	target.name = "blessed [target.name]"
	target.force += divine_power

	blessed += target

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
		if(!M.mind.holy_role && M.eyecheck() <= 0)
			M.flash_eyes()

	spawn_food(usr.loc, 4 + rand(1, divine_power))

/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal
	name = "Create random friendly animal"

	favor_cost = 250
	charge_max = 2 MINUTES
	divine_power = 1 //count
	needed_aspect = list(ASPECT_SPAWN = 1, ASPECT_DEATH = 1,)
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
		if(!M.mind.holy_role && M.eyecheck() <= 0)
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

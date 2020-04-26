/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_bible
	name = "Create bible"
	desc = "Bible"

	school = "conjuration"
	charge_max = 120 //BALANCE
	favor_cost = 10 //BALANCE
	clothes_req = 0
	invocation = "none"
	range = 0
	summon_amt = 0

	action_icon_state = "spawn_bible"

	summon_type = list(/obj/item/weapon/storage/bible)

/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_bible/cast()
	for(var/mob/living/carbon/human/M in viewers(get_turf_loc(usr), null))
		if(M.eyecheck() <= 0)
			M.flash_eyes()
	..()

/obj/effect/proc_holder/spell/targeted/heal
	name = "Heal"

	favor_cost = 10 //BALANCE
	charge_max = 120 //BALANCE
	clothes_req = 0
	invocation = "none"
	range = 6
	sound = 'sound/magic/heal.ogg'
	selection_type = "range"

	action_icon_state = "heal"

	divine_power = -10 //power

/obj/effect/proc_holder/spell/targeted/heal/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/carbon/target
	while(targets.len)
		target = targets[targets.len]
		targets -= target
		if(istype(target))
			break

	if(!ishuman(target))
		to_chat(user, "<span class='notice'>It'd be stupid to give [target] such a life improvement!</span>")
		return

	var/mob/living/carbon/human/H = target
	if(!(H in oview(range))) // If they are not in overview after selection.
		to_chat(user, "<span class='warning'>They are too far away!</span>")
		return

	H.apply_damages(divine_power, divine_power, divine_power)
	cast_with_favor()

/obj/effect/proc_holder/spell/targeted/heal/damage
	name = "Damage"
	sound = 'sound/magic/Repulse.ogg'

	action_icon_state = "god_default"
	divine_power = 5 //power

/obj/effect/proc_holder/spell/targeted/blessing
	name = "Blessing"

	favor_cost = 10  //BALANCE
	charge_max = 120 //BALANCE
	divine_power = 5  //power
	range = 0
	invocation = "none"
	clothes_req = 0
	action_icon_state = "blessing"

	var/list/blessed = list()

/obj/effect/proc_holder/spell/targeted/blessing/cast()
	var/list/possible_targets = list()
	var/obj/item/weapon/target

	for(var/obj/item/weapon/W in range(3))
		if(!(W in blessed))
			possible_targets += W

	if(possible_targets.len == 0)
		revert_cast()
		return

	cast_with_favor()

	target = input("Choose the target for the spell.", "Targeting") in possible_targets

	to_chat(usr, "[usr] blessed [target.name]")
	target.name = "blessed [target.name]"
	target.force += divine_power

	blessed += target

/obj/effect/proc_holder/spell/targeted/charge/religion
	name = "Charge electricity"

	favor_cost = 10  //BALANCE
	charge_max = 120 //BALANCE
	divine_power = 1 //range
	range = 0
	invocation = "none"
	invocation_type = "none"
	clothes_req = 0
	action_icon_state = "charge"

/obj/effect/proc_holder/spell/targeted/charge/religion/cast()
	var/charged = FALSE

	for(var/I in range(divine_power))
		if(isrobot(I))
			var/mob/living/silicon/robot/R = I
			if(R.cell)
				cell_charge(R.cell)
				charged = TRUE

		if(istype(I, /obj/item/weapon/stock_parts/cell))
			cell_charge(I)
			charged = TRUE

		if(istype(I, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = I
			B.charges = initial(B.charges)
			B.status = 1
			B.update_icon()
			charged = TRUE

		if(istype(I, /obj/machinery/power/smes))
			charged = TRUE
			for(var/obj/item/weapon/stock_parts/cell/Cell in I)
				cell_charge(Cell)

	if(charged)
		playsound(usr, 'sound/magic/Charge.ogg', VOL_EFFECTS_MASTER)
		to_chat(usr, "<span class='notice'>You have charged cell in a radiuse!</span>")
		cast_with_favor()
	else
		revert_cast()
		return

/obj/effect/proc_holder/spell/targeted/food
	name = "Spawn food"

	favor_cost = 10  //BALANCE
	charge_max = 120 //BALANCE
	divine_power = 2 //count
	range = 0
	invocation = "none"
	clothes_req = 0
	action_icon_state = "spawn_food"

/obj/effect/proc_holder/spell/targeted/food/cast()
	var/list/borks = subtypesof(/obj/item/weapon/reagent_containers/food/snacks)
	cast_with_favor()

	playsound(usr, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)

	for(var/mob/living/carbon/human/M in viewers(get_turf_loc(usr), null))
		if(M.eyecheck() <= 0)
			M.flash_eyes()

	for(var/i in 1 to 4 + rand(1, divine_power))
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf_loc(usr)
			if(prob(50))
				for(var/j in 1 to rand(1, 3))
					step(B, pick(NORTH,SOUTH,EAST,WEST))

/obj/effect/proc_holder/spell/targeted/forcewall/religion
	name = "Create energy wall"

	favor_cost = 10  //BALANCE
	charge_max = 120 //BALANCE
	divine_power = 1 //CD
	invocation = "none"
	invocation_type = "none"
	clothes_req = 0

	summon_path = /obj/effect/forcefield/magic/religion

/obj/effect/forcefield/magic/religion
	name = "magic wall"
	desc = "Strange energy field."
	var/mob/chaplain

/obj/effect/forcefield/magic/religion/CanPass(atom/movable/mover, turf/target, height=0)
	if(mover == chaplain)
		return 1
	return 0

/obj/effect/proc_holder/spell/targeted/forcewall/religion/cast()
	cast_with_favor()
	charge_max = charge_max / divine_power

	var/obj/effect/forcefield/magic/religion/wall = new summon_path(get_turf(usr), usr)
	for(var/mob/living/carbon/human/H in range(6))
		if(H.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
			wall.chaplain = H

/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal
	name = "Create random friendly animal"

	favor_cost = 10  //BALANCE
	charge_max = 120 //BALANCE
	divine_power = 0 //count
	summon_amt = 0
	invocation = "none"
	clothes_req = 0
	action_icon_state = "spawn_animal"
	summon_type = list(/mob/living/simple_animal/corgi/puppy, /mob/living/simple_animal/hostile/retaliate/goat, /mob/living/simple_animal/corgi, /mob/living/simple_animal/cat, /mob/living/simple_animal/parrot, /mob/living/simple_animal/crab, /mob/living/simple_animal/cow, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken, /mob/living/simple_animal/pig, /mob/living/simple_animal/turkey, /mob/living/simple_animal/goose, /mob/living/simple_animal/seal, /mob/living/simple_animal/walrus, /mob/living/simple_animal/fox, /mob/living/simple_animal/lizard, /mob/living/simple_animal/mouse, /mob/living/simple_animal/mushroom, /mob/living/simple_animal/pug, /mob/living/simple_animal/shiba, /mob/living/simple_animal/slime, /mob/living/simple_animal/yithian, /mob/living/simple_animal/tindalos)

/obj/effect/proc_holder/spell/aoe_turf/conjure/spawn_animal/cast()
	summon_amt += divine_power
	for(var/mob/living/carbon/human/M in viewers(get_turf_loc(usr), null))
		if(M.eyecheck() <= 0)
			M.flash_eyes()
	..()

/datum/combat_combo/uppercut
	name = COMBO_UPPERCUT
	desc = "A move where you lunge your fist from below into opponent's chin, knocking their helmet off."
	combo_icon_state = "uppercut"
	fullness_lose_on_execute = 60
	combo_elements = list(INTENT_HARM, INTENT_HARM, INTENT_HARM, INTENT_HARM)

	ignore_size = TRUE

	scale_damage_coeff = 1.0

	// Unathi cut people's heads off.
	// apply_dam_flags = TRUE

	allowed_target_zones = list(BP_HEAD)

	require_head = TRUE
	require_arm_to_perform = TRUE

	heavy_animation = TRUE

/datum/combat_combo/uppercut/animate_combo(mob/living/victim, mob/living/attacker)
	var/saved_targetzone = attacker.get_targetzone()
	var/list/attack_obj = attacker.get_unarmed_attack()

	attacker.set_dir(pick(NORTH, SOUTH)) // So they will appear sideways, as if they are actually knocking with their fist.

	var/DTM = get_dir(attacker, victim)
	var/shift_x = 0
	var/shift_y = 0

	var/matrix/M = matrix()
	var/matrix/victim_M = matrix()
	var/matrix/prev_attacker_M = attacker.transform
	var/matrix/prev_victim_M = victim.transform

	if(DTM & NORTH)
		shift_y = 16
		attacker.set_dir(pick(WEST, EAST))
	else if(DTM & SOUTH)
		shift_y = -16
		attacker.set_dir(pick(WEST, EAST))

	if(DTM & EAST)
		shift_x = 16
		attacker.set_dir(pick(NORTH, SOUTH))
		M.Turn(-10)
		victim_M.Turn(90)
	else if(DTM & WEST)
		shift_x = -16
		attacker.set_dir(pick(NORTH, SOUTH))
		M.Turn(10)
		victim_M.Turn(-90)

	var/prev_pix_x = attacker.pixel_x
	var/prev_pix_y = attacker.pixel_y

	var/prev_victim_layer = victim.layer

	victim.layer = attacker.layer - 0.1

	animate(attacker, pixel_x = attacker.pixel_x + shift_x, pixel_y = attacker.pixel_y + shift_y, time = 2)
	if(!do_after(attacker, 2, target = victim, progress = FALSE))
		return

	var/prev_victim_pix_y = victim.pixel_y

	animate(attacker, transform = M, pixel_y = attacker.pixel_y + 8, time = 2)
	if(!do_combo(victim, attacker, 2))
		return
	animate(attacker, transform = prev_attacker_M, pixel_y = attacker.pixel_y + 8, time = 2)
	animate(victim, transform = victim_M, pixel_y = victim.pixel_y + 16, time = 2)
	if(!do_combo(victim, attacker, 2))
		return

	var/atom/move_attacker_to = victim.loc
	var/atom/move_victim_dir = get_dir(victim, get_step_away(victim, attacker))
	step(victim, move_victim_dir)

	attacker.pixel_x = prev_pix_x
	attacker.pixel_y = prev_pix_y + 16
	attacker.forceMove(move_attacker_to)

	animate(attacker, pixel_y = attacker.pixel_y - 16, time = 2)
	animate(victim, pixel_y = prev_victim_pix_y, time = 2)
	if(!do_combo(victim, attacker, 2))
		return

	attacker.transform = prev_attacker_M
	victim.transform = prev_victim_M
	victim.layer = prev_victim_layer

	victim.visible_message("<span class='danger'>[attacker] has performed an uppercut on [victim]!</span>")

	apply_effect(1, WEAKEN,  victim, attacker, zone=saved_targetzone, attack_obj=attack_obj, min_value=1)
	apply_damage(18, victim, attacker, zone=BP_HEAD, attack_obj=attack_obj)

	if(iscarbon(victim))
		var/mob/living/carbon/C = victim
		if(C.head && !(C.head.flags & (ABSTRACT|NODROP)) && C.head.canremove)
			var/obj/item/clothing/VH = C.head
			victim.drop_from_inventory(VH, victim.loc)
			attacker.newtonian_move(get_dir(victim, attacker))

			var/turf/target = get_step(victim, attacker.dir)

			VH.throw_at(target, VH.throw_range, VH.throw_speed, attacker)

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/uppercut/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/suplex
	name = COMBO_SUPLEX
	desc = "A move that lifts your opponent up, only to then throw them to the ground, harshly."
	combo_icon_state = "suplex"
	fullness_lose_on_execute = 75
	combo_elements = list(INTENT_HARM, INTENT_HARM, INTENT_HARM, INTENT_GRAB)

	check_bodyarmor = TRUE

	scale_size_exponent = 1.0

	allowed_target_zones = list(BP_GROIN)

	heavy_animation = TRUE

	force_dam_type = BRUTE

/datum/combat_combo/suplex/animate_combo(mob/living/victim, mob/living/attacker)
	var/saved_targetzone = attacker.get_targetzone()
	var/list/attack_obj = attacker.get_unarmed_attack()

	var/DTM = get_dir(attacker, victim)
	var/victim_dir = get_dir(victim, attacker)
	var/shift_x = 0
	var/shift_y = 0

	if(DTM & NORTH)
		shift_y = 32
	else if(DTM & SOUTH)
		shift_y = -32

	if(DTM & EAST)
		shift_x = 32
	else if(DTM & WEST)
		shift_x = -32

	var/prev_pix_x = attacker.pixel_x
	var/prev_pix_y = attacker.pixel_y

	animate(attacker, pixel_x = attacker.pixel_x + shift_x, pixel_y = attacker.pixel_y + shift_y, time = 5)
	if(!do_after(attacker, 5, target = victim, progress = FALSE))
		return

	attacker.forceMove(victim.loc)
	attacker.pixel_x = prev_pix_x
	attacker.pixel_y = prev_pix_y

	var/matrix/M = matrix()
	M.Turn(pick(90, -90))

	prev_pix_x = victim.pixel_x
	prev_pix_y = victim.pixel_y

	animate(victim, transform = M, time = 2)
	if(!do_after(attacker, 2, target = victim, progress = FALSE))
		return

	animate(victim, pixel_y = victim.pixel_y + 20, time = 6)
	if(!do_after(attacker, 6, target = victim, progress = FALSE))
		return

	victim.Stun(1)
	attacker.Stun(1) // So he doesn't do something funny during the trick.

	var/prev_victim_anchored = victim.anchored
	var/prev_attacker_anchored = attacker.anchored
	victim.anchored = TRUE
	attacker.anchored = TRUE
	animate(victim, pixel_x = victim.pixel_x - shift_x, pixel_y = victim.pixel_y - 20 - shift_y, time = 2)
	if(!do_combo(victim, attacker, 2))
		return

	victim.forceMove(get_step(victim, victim_dir))
	victim.anchored = prev_victim_anchored
	attacker.anchored = prev_attacker_anchored

	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	victim.visible_message("<span class='danger'>[attacker] has thrown [victim] over their shoulder!</span>")

	apply_effect(4, WEAKEN, victim, attacker, zone=saved_targetzone, attack_obj=attack_obj, min_value=1)
	apply_damage(23, victim, attacker, attack_obj=attack_obj)

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/suplex/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/diving_elbow_drop
	name = COMBO_DIVING_ELBOW_DROP
	desc = "A move in which you jump up high, and then fall onto your opponent, hitting them with your elbow."
	combo_icon_state = "diving_elbow_drop"
	fullness_lose_on_execute = 50
	combo_elements = list(COMBO_SUPLEX, INTENT_HARM, INTENT_PUSH, INTENT_HARM)

	// A body dropped on us! Armor ain't helping.
	armor_pierce = TRUE

	scale_size_exponent = 1.5

	allowed_target_zones = list(BP_CHEST)

	require_arm_to_perform = TRUE

	heavy_animation = TRUE

	force_dam_type = BRUTE

/datum/combat_combo/diving_elbow_drop/animate_combo(mob/living/victim, mob/living/attacker)
	var/list/attack_obj = attacker.get_unarmed_attack()

	var/DTM = get_dir(attacker, victim)
	var/shift_x = 0
	var/shift_y = 0

	if(DTM & NORTH)
		shift_y = 32
	else if(DTM & SOUTH)
		shift_y = -32

	if(DTM & EAST)
		shift_x = 32
	else if(DTM & WEST)
		shift_x = -32

	var/prev_pix_x = attacker.pixel_x
	var/prev_pix_y = attacker.pixel_y

	animate(attacker, pixel_y = attacker.pixel_y - 4, time = 5)
	if(!do_combo(victim, attacker, 5))
		return

	var/prev_anchored = attacker.anchored
	var/prev_canmove = attacker.canmove
	var/prev_density = attacker.density
	attacker.anchored = TRUE
	attacker.canmove = FALSE
	attacker.density = FALSE // We are in the air
	attacker.Stun(2) // So they don't do anything stupid during the trick.

	var/matrix/M = matrix()
	M.Turn(pick(-100, 100))

	animate(attacker, transform = M, pixel_x = attacker.pixel_x + shift_x, pixel_y = attacker.pixel_y + shift_y + 36, time = 4)
	if(!do_combo(victim, attacker, 4))
		return

	// Hover ominously.
	if(!do_combo(victim, attacker, 3))
		return

	attacker.pixel_x = prev_pix_x
	attacker.pixel_y = prev_pix_y + 32
	attacker.forceMove(victim.loc)

	animate(attacker, pixel_y = prev_pix_y, time = 2)
	if(!do_combo(victim, attacker, 2))
		return

	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	attacker.visible_message("<span class='danger'>[attacker] falls elbow first onto [attacker.loc] with a loud thud!</span>")

	for(var/mob/living/L in victim.loc)
		if(L == attacker)
			continue
		if(L.lying || L.resting || L.crawling)
			apply_damage(28, L, attacker, attack_obj=attack_obj)
		apply_effect(6, WEAKEN, L, attacker, attack_obj=attack_obj, min_value = 1)

		event_log(L, attacker, "Diving Elbow Drop bypasser.")

	attacker.anchored = prev_anchored
	attacker.canmove = prev_canmove
	attacker.density = prev_density

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/diving_elbow_drop/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/charge
	name = COMBO_CHARGE
	desc = "A move that grabs your opponent by the neck, and drives you into the closest obstacle, hitting them on it."
	combo_icon_state = "charge"
	fullness_lose_on_execute = 75
	combo_elements = list(INTENT_GRAB, INTENT_HARM, INTENT_HARM, INTENT_GRAB)

	check_bodyarmor = TRUE

	allowed_target_zones = list(BP_CHEST)

	heavy_animation = TRUE

	force_dam_type = BRUTE

/datum/combat_combo/charge/animate_combo(mob/living/victim, mob/living/attacker)
	var/list/attack_obj = attacker.get_unarmed_attack()

	var/obj/item/weapon/grab/victim_G = prepare_grab(victim, attacker, GRAB_NECK)
	if(!istype(victim_G))
		return

	var/try_steps = 6
	var/charge_dir = attacker.dir

	try_steps_loop:
		for(var/try_to_step in 1 to try_steps)
			if(QDELETED(victim_G)) // Somebody disarmed us, stop this.
				break

			var/turf/T = get_step(attacker, charge_dir)
			if(attacker.client)
				attacker.client.Move(T, charge_dir, forced=TRUE)
			else
				attacker.Move(T, charge_dir)

			attacker.set_dir(charge_dir)
			victim_G.adjust_position(adjust_time = 0, force_loc = TRUE, force_dir = charge_dir)

			if(T != attacker.loc) // We bumped into something, so we bumped our victim into it...
				var/list/to_check = T.contents + attacker.loc.contents - list(attacker)
				for(var/mob/living/L in to_check)
					if(L.is_bigger_than(victim))
						continue

					var/obj/structure/table/facetable = locate() in T
					if(facetable && facetable.Adjacent(attacker))
						facetable.attackby(victim_G, attacker)
						playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
						victim.visible_message("<span class='danger'>[attacker] slams [victim] into an obstacle!</span>")
					else
						playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
						victim.visible_message("<span class='danger'>[attacker] slams [victim] into an obstacle!</span>")

					apply_effect(6, WEAKEN, L, attacker, attack_obj=attack_obj, min_value=1)
					apply_damage(33, L, attacker, attack_obj=attack_obj)
				break try_steps_loop

			if(!do_after(attacker, attacker.movement_delay() * 0.5, can_move = TRUE, target = victim, progress = FALSE))
				break try_steps_loop

	destroy_grabs(victim, attacker)

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/charge/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/spin_throw
	name = COMBO_SPIN_THROW
	desc = "A move in which you start to spin yourself up, and at a point you throw your opponent with immense force."
	combo_icon_state = "spin_throw"
	fullness_lose_on_execute = 50
	combo_elements = list(INTENT_GRAB, INTENT_GRAB, INTENT_GRAB, INTENT_HARM)

	// We threw a guy over 6 tiles distance. Armor probably ain't helping.
	armor_pierce = TRUE

	scale_size_exponent = 1.0

	allowed_target_zones = list(BP_CHEST)

	heavy_animation = TRUE

	force_dam_type = BRUTE

/datum/combat_combo/spin_throw/animate_combo(mob/living/victim, mob/living/attacker)
	var/list/attack_obj = attacker.get_unarmed_attack()

	var/obj/item/weapon/grab/victim_G = prepare_grab(victim, attacker, GRAB_AGGRESSIVE)
	if(!istype(victim_G))
		return

	victim.forceMove(attacker.loc)
	var/cur_spin_time = 3
	grab_stages_loop:
		for(var/grab_stages in list(GRAB_AGGRESSIVE, GRAB_NECK, GRAB_NECK, GRAB_KILL))
			for(var/i in 1 to 4)
				attacker.set_dir(turn(attacker.dir, 90))

				if(QDELETED(victim_G))
					break grab_stages_loop

				victim_G.adjust_position(adjust_time=0, force_loc = TRUE, force_dir = attacker.dir)
				victim.Stun(max(0, 2 - victim.stunned))

				if(!do_after(attacker, cur_spin_time, target = victim, progress = FALSE))
					break grab_stages_loop

			if(grab_stages != victim_G.state)
				victim_G.set_state(grab_stages, adjust_time=0, force_loc = TRUE, force_dir = attacker.dir)
				cur_spin_time -= 1

			if(grab_stages == GRAB_KILL)
				var/turf/target = get_turf(attacker)

				var/turf/start_T = target
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [COORD(start_T)] in area [get_area(start_T)]</font>"

				target_search:
					for(var/i in 1 to 7)
						target = get_step(target, attacker.dir)
						if(istype(target, /turf/simulated/wall))
							break target_search

				if(!target || !victim_G)
					break grab_stages_loop

				var/mob/living/M = victim_G.throw_held()
				qdel(victim_G)
				if(!istype(M))
					break grab_stages_loop

				M.visible_message("<span class='rose'>[attacker] has thrown [M] with immense force!</span>")

				attacker.newtonian_move(get_dir(target, attacker))

				var/turf/end_T = target
				var/end_T_descriptor = "<font color='#6b4400'>tile at [COORD(end_T)] in area [get_area(end_T)]</font>"

				M.log_combat(attacker, "throwm from [start_T_descriptor] with the target [end_T_descriptor]")

				M.throw_at(target, 6, 8, attacker)
				apply_effect(7, WEAKEN, M, attacker, attack_obj=attack_obj, min_value=1)

				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
						var/obj/item/clothing/suit/V = H.wear_suit
						V.attack_reaction(H, REACTION_THROWITEM)
				return

	destroy_grabs(victim, attacker)

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/spin_throw/execute(mob/living/victim, mob/living/attacker)
	return

/datum/combat_combo/wake_up
	name = COMBO_WAKE_UP
	desc = "A move in which you pull your opponent up, shaking off all his pain and stuns."
	combo_icon_state = "spin_throw"
	cost = 20
	combo_elements = list(INTENT_HELP, INTENT_HELP, INTENT_HELP, INTENT_GRAB)

	allowed_target_zones = list(BP_CHEST)

	heavy_animation = TRUE

	// How much time does each shake take.
	var/shake_delay = 1
	var/delay_offset = 1
	// How many shakes should be performed.
	var/total_shakes = 16

	// How much "stuns" should go away per tick spent shaking.
	var/effectiveness = 1.5

/datum/combat_combo/wake_up/animate_combo(mob/living/victim, mob/living/attacker)
	var/list/attack_obj = attacker.get_unarmed_attack()

	var/obj/item/weapon/grab/victim_G = prepare_grab(victim, attacker, GRAB_PASSIVE)
	if(!istype(victim_G))
		return

	var/started_shaking = world.time

	victim.forceMove(attacker.loc)

	attacker.visible_message("<span class='notice'>[attacker] is shaking [victim] with visible force!</span>")

	if(victim.lying)
		var/matrix/M = matrix(victim.transform)
		M.Turn(-victim.lying_current)
		victim.transform = M

	attacker.set_dir(pick(list(WEST, EAST)))
	victim.set_dir(turn(attacker.dir, 180))
	for(var/shake_num in 1 to total_shakes)
		if(QDELETED(victim_G))
			return

		var/delay = shake_delay + rand(-delay_offset, delay_offset)
		// replace 1 with delay when Stun( will be reworked. ~Luduk
		attacker.Stun(1)
		victim.Stun(1)

		victim_G.adjust_position(adjust_time = 0, force_loc = TRUE, force_dir = turn(attacker.dir, 180))
		victim.pixel_y = 4
		victim.layer = attacker.layer - 0.01

		var/shake_degree = min(scale_value(15, scale_damage_coeff, victim, attacker, attack_obj), 30)
		var/max_shake_height = min(scale_value(4, scale_damage_coeff, victim, attacker, attack_obj), 8)

		var/matrix/prev_transform = matrix(victim.transform)
		var/prev_pixel_y = victim.pixel_y

		var/matrix/M = matrix(victim.transform)
		M.Turn(pick(-shake_degree, shake_degree))

		var/shake_height = rand(0, max_shake_height)

		var/shift_dir = attacker.dir == EAST ? 1 : -1

		animate(victim, transform = M, pixel_x = shift_dir * 2, pixel_y = victim.pixel_y + shake_height, time = delay)
		if(!do_combo(victim, attacker, shake_delay))
			return

		animate(victim, transform = prev_transform, pixel_y = prev_pixel_y, time = 1)
		if(!do_combo(victim, attacker, 1))
			return

	var/shake_time = world.time - started_shaking

	var/wake_up_amount = -shake_time * effectiveness

	victim.adjustHalLoss(wake_up_amount)
	victim.AdjustStunned(wake_up_amount)
	victim.AdjustWeakened(wake_up_amount)

	step_away(victim, attacker)

	destroy_grabs(victim, attacker)

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/wake_up/execute(mob/living/victim, mob/living/attacker)
	return

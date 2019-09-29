/mob/living/simple_animal/hostile/retaliate/clown/robust
	speak_chance = 50
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("HONK", "Honk!", "HONKA!", "Honka!", "Boop!")
	emote_see = list("honks")
	a_intent = I_HURT
	maxHealth = 200
	health = 200
	speed = -1
	harm_intent_damage = 10
	melee_damage = 3
	attacktext = "robust"
	attack_sound = list('sound/items/bikehorn.ogg')

	var/list/intent_rotation = list()
	var/list/desired_intent_rotation = list()
	var/desired_targetzones = list(BP_CHEST)
	var/datum/combat_combo/desired_combo = null

/mob/living/simple_animal/hostile/retaliate/clown/robust/proc/get_desired_combo(datum/combo_saved/CS)
	if(!desired_combo)
		var/list/combos_to_check = list() + global.combat_combos_by_name

		for(var/i in 1 to 100)
			if(length(combos_to_check) == 0)
				break

			var/combo_key = pick(combos_to_check)
			var/datum/combat_combo/pos_desired_combo = global.combat_combos_by_name[combo_key]

			combos_to_check -= combo_key

			var/default_desired_tz = list(BP_CHEST)
			desired_targetzones = pos_desired_combo.allowed_target_zones

			var/can_achieve = TRUE
			c_el_check_loop:
				for(var/c_el in pos_desired_combo.combo_elements)
					if(!(c_el in list(I_DISARM, I_GRAB, I_HURT)))
						can_achieve = FALSE
						break c_el_check_loop

			if(can_achieve && pos_desired_combo.can_execute(CS))
				desired_combo = pos_desired_combo
				desired_intent_rotation = desired_combo.combo_elements
			else
				desired_targetzones = default_desired_tz

	else if(!desired_combo.can_execute(CS))
		desired_intent_rotation = list() // We handle this in AttackingTarget, restoring our desires to default.

/mob/living/simple_animal/hostile/retaliate/clown/robust/AttackingTarget()
	var/datum/combo_saved/target_CS
	for(var/datum/combo_saved/CS in combos_performed)
		if(CS.victim == target)
			target_CS = CS
			break

	if(target_CS)
		get_desired_combo(target_CS)

	a_intent = I_HURT

	if(length(desired_intent_rotation))
		a_intent = desired_intent_rotation[1]
		desired_intent_rotation.Cut(1, 2)
	else
		desired_intent_rotation = list(I_HURT)
		desired_targetzones = list(BP_CHEST)
		desired_combo = null

	target.attack_animal(src)

/mob/living/simple_animal/hostile/retaliate/clown/robust/get_targetzone()
	return pick(desired_targetzones)

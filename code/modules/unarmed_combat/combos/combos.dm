/datum/combat_combo/disarm
	name = "Weapon Disarm"
	desc = "A move that knocks anything out of your opponent's hands."
	combo_icon_state = "weapon_disarm"
	fullness_lose_on_execute = 10
	combo_elements = list(INTENT_PUSH, INTENT_PUSH, INTENT_PUSH)

	ignore_size = TRUE

	allowed_target_zones = TARGET_ZONE_ALL

/datum/combat_combo/disarm/execute(mob/living/victim, mob/living/attacker)
	var/list/to_drop = list(victim.get_active_hand(), victim.get_inactive_hand())

	for(var/obj/item/weapon/gun/G in to_drop)
		victim.visible_message("<span class='danger'>[victim]'s [G] goes off during struggle!</span>")
		var/list/dir_to_shoot = pick(alldirs)
		G.afterattack(get_step(attacker, dir_to_shoot), victim, FALSE) // So we shoot in their general direction.

	victim.add_my_combo_value(-20)
	for(var/obj/item/I in to_drop)
		victim.drop_from_inventory(I)
	victim.visible_message("<span class='warning'><B>[attacker] has disarmed [victim]!</B></span>")

	// Clowns disarming put the last thing from their backpack into their opponent's hands
	// And then either force the opponent to attack themselves with that item(if intent is hurt)
	// Or force the opponent to activate the item(if intent is not hurt)
	if(CLUMSY in attacker.mutations)
		if(iscarbon(attacker))
			var/mob/living/carbon/C = attacker
			var/obj/item/to_give = attacker.get_active_hand() || attacker.get_inactive_hand()
			if(to_give)
				if(to_give.flags & (ABSTRACT | DROPDEL))
					to_give = null
				else if(to_give.w_class < ITEM_SIZE_LARGE && (HULK in victim.mutations))
					to_give = null

			if(!to_give && istype(C.back, /obj/item/weapon/storage) && C.back.contents.len > 0)
				var/obj/item/weapon/storage/S = C.back
				var/obj/item/I = S.contents[S.contents.len]

				if(I.flags & (ABSTRACT | DROPDEL))
					return
				if(I.w_class < ITEM_SIZE_LARGE && (HULK in victim.mutations))
					return

				if(!S.remove_from_storage(I, C))
					return
				attacker.put_in_hands(I)
				to_give = I

			if(to_give)
				attacker.drop_from_inventory(to_give)
				if(victim.put_in_hands(to_give))
					victim.visible_message("<span class='notice'>[attacker] handed \the [to_give] to [victim]!</span>")
					to_give.add_fingerprint(victim)
					// Extra ! ! ! F U N ! ! !
					if(attacker.a_intent != INTENT_HARM)
						event_log(victim, attacker, "Forced in-hand use of [to_give]")
						to_give.attack_self(victim)
					else
						event_log(victim, attacker, "Forced self-attack by [to_give]")
						var/resolved = victim.attackby(to_give, victim)
						if(!resolved && victim && to_give)
							to_give.afterattack(victim, victim, TRUE)

/datum/combat_combo/push
	name = "Push"
	desc = "A move that simply pushes your opponent to the ground."
	combo_icon_state = "push"
	fullness_lose_on_execute = 40
	combo_elements = list("Weapon Disarm", INTENT_PUSH, INTENT_PUSH, INTENT_PUSH)

	check_bodyarmor = TRUE

	allowed_target_zones = list(BP_CHEST)

/datum/combat_combo/push/execute(mob/living/victim, mob/living/attacker)
	var/list/attack_obj = attacker.get_unarmed_attack()
	apply_effect(3, WEAKEN, victim, attacker, attack_obj=attack_obj, min_value=1)
	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	victim.visible_message("<span class='danger'>[attacker] has pushed [victim] to the ground!</span>")



/datum/combat_combo/slide_kick
	name = "Slide Kick"
	desc = "A move that makes you slide, kicking down people on your way."
	combo_icon_state = "slide_kick"
	fullness_lose_on_execute = 40
	combo_elements = list("Weapon Disarm", INTENT_PUSH, INTENT_PUSH, INTENT_PUSH)

	ignore_size = TRUE

	allowed_target_zones = list(BP_L_LEG, BP_R_LEG)

	require_leg = TRUE
	require_leg_to_perform = TRUE

	heavy_animation = TRUE

/datum/combat_combo/slide_kick/animate_combo(mob/living/victim, mob/living/attacker)
	if(!do_combo(victim, attacker, 3))
		return

	var/saved_targetzone = attacker.get_targetzone()
	var/list/attack_obj = attacker.get_unarmed_attack()

	var/slide_dir = get_dir(attacker, victim)

	// AFTER ALEXOFP'S PR USE WHATEVER HE DID FOR CRAWLING AND UNCRAWLING, BUT DON'T ACTUALLY UNCRAWL AFTER THIS MOVE

	var/prev_crawling = attacker.crawling
	var/prev_lying = attacker.lying
	var/prev_pass_flags = attacker.pass_flags

	attacker.crawling = TRUE
	attacker.lying = TRUE
	attacker.pass_flags |= PASSCRAWL

	attacker.update_canmove()

	var/slide_steps = 3
	for(var/i in 1 to slide_steps)
		var/turf/T = get_step(attacker, slide_dir)
		if(attacker.client)
			attacker.client.Move(T, slide_dir, forced=TRUE)
		else
			attacker.Move(T, slide_dir)

		if(T != attacker.loc)
			break

		slide_kick_loop:
			for(var/mob/living/L in T)
				if(L == attacker)
					continue slide_kick_loop

				if(L.is_bigger_than(attacker))
					continue slide_kick_loop

				if(!apply_effect(2, WEAKEN, L, attacker, zone=saved_targetzone, attack_obj=attack_obj, min_value=1))
					continue slide_kick_loop

				var/end_string = "to the ground!"
				// Clowns take off the uniform while slidekicking.
				// A little funny.
				if(CLUMSY in attacker.mutations)
					if(ishuman(L))
						var/mob/living/carbon/human/H = L
						var/obj/item/clothing/PANTS = H.w_uniform
						var/obj/item/clothing/BELT = H.belt

						var/first = TRUE
						pants_takeoff_loop:
							for(var/obj/item/I in list(BELT, PANTS))
								if(!I)
									continue pants_takeoff_loop
								if(I.loc != L) // Perhaps they fell off during this or something.
									continue pants_takeoff_loop
								if(I.flags & (ABSTRACT|NODROP) && I.canremove)
									continue pants_takeoff_loop
								if(first)
									end_string = ", taking off their [I]"
								else
									end_string += ", [I]"
								end_string += "!"
								event_log(L, attacker, "Taking off [I]")
								L.drop_from_inventory(I, L.loc)
								// attacker is crawling, so they can't anyway.
								// attacker.put_in_hands(I)

						if(!first)
							end_string += "!"
				L.visible_message("<span class='danger'>[attacker] slide-kicks [L][end_string]</span>")

		if(!do_after(attacker, attacker.movement_delay() * 0.4, can_move = TRUE, target = victim, progress = FALSE))
			break

	attacker.crawling = prev_crawling
	attacker.lying = prev_lying
	attacker.pass_flags = prev_pass_flags

	attacker.update_canmove()

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/slide_kick/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/capture
	name = "Capture"
	desc = "A move that allows you to quickly grab your opponent into a jointlock, and press them against the ground."
	combo_icon_state = "capture"
	fullness_lose_on_execute = 75
	combo_elements = list(INTENT_PUSH, INTENT_PUSH, INTENT_PUSH, INTENT_GRAB)

	scale_size_exponent = 0.0

	allowed_target_zones = list(BP_L_ARM, BP_R_ARM)

	require_arm = TRUE

/datum/combat_combo/capture/execute(mob/living/victim, mob/living/attacker)
	var/saved_targetzone = attacker.get_targetzone()
	var/list/attack_obj = attacker.get_unarmed_attack()

	victim.Stun(2)

	if(victim.buckled)
		victim.buckled.unbuckle_mob()
	if(attacker.buckled)
		attacker.buckled.unbuckle_mob()

	var/obj/item/weapon/grab/victim_G = prepare_grab(victim, attacker, GRAB_AGGRESSIVE)
	if(!istype(victim_G))
		return

	var/target_zone = attacker.get_targetzone()
	var/armor_check = victim.run_armor_check(target_zone, "melee")

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/external/BP = H.get_bodypart(target_zone)
		victim.visible_message("<span class='danger'>[attacker] [pick("bent", "twisted")] [victim]'s [BP.name] into a jointlock!</span>")
		if(armor_check < 30)
			to_chat(victim, "<span class='danger'>You feel extreme pain!</span>")
			victim.adjustHalLoss(clamp(0, 40 - victim.halloss, 40)) // up to 40 halloss

	victim_G.force_down = TRUE
	apply_effect(3, WEAKEN, victim, attacker, zone=saved_targetzone, attack_obj=attack_obj, min_value=1)
	victim.visible_message("<span class='danger'>[attacker] presses [victim] to the ground!</span>")

	step_to(attacker, victim)
	attacker.set_dir(EAST) //face the victim
	victim.set_dir(SOUTH) //face up



/datum/combat_combo/uppercut
	name = "Uppercut"
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
	if(!do_combo(victim, attacker, 3))
		return

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
	name = "Suplex"
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
	if(!do_combo(victim, attacker, 3))
		return

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
	name = "Diving Elbow Drop"
	desc = "A move in which you jump up high, and then fall onto your opponent, hitting them with your elbow."
	combo_icon_state = "diving_elbow_drop"
	fullness_lose_on_execute = 50
	combo_elements = list("Suplex", INTENT_HARM, INTENT_PUSH, INTENT_HARM)

	// A body dropped on us! Armor ain't helping.
	armor_pierce = TRUE

	scale_size_exponent = 1.5

	allowed_target_zones = list(BP_CHEST)

	require_arm_to_perform = TRUE

	heavy_animation = TRUE

	force_dam_type = BRUTE

/datum/combat_combo/diving_elbow_drop/animate_combo(mob/living/victim, mob/living/attacker)
	if(!do_combo(victim, attacker, 3))
		return

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



/datum/combat_combo/dropkick
	name = "Dropkick"
	desc = "A move in which you jump with your both legs into opponent's belly, knocking them backwards."
	combo_icon_state = "dropkick"
	fullness_lose_on_execute = 25
	combo_elements = list(INTENT_PUSH, INTENT_HARM, INTENT_PUSH, INTENT_HARM)

	armor_pierce = TRUE

	ignore_size = TRUE

	scale_size_exponent = 1.5

	allowed_target_zones = list(BP_GROIN)

	require_leg_to_perform = TRUE

	heavy_animation = TRUE

/datum/combat_combo/dropkick/animate_combo(mob/living/victim, mob/living/attacker)
	if(!do_combo(victim, attacker, 3))
		return

	var/list/attack_obj = attacker.get_unarmed_attack()

	var/dropkick_dir = get_dir(attacker, victim)
	var/face_dir = get_dir(victim, attacker)
	var/shift_x = 0
	var/shift_y = 0

	var/matrix/M = matrix()

	if(dropkick_dir & NORTH)
		shift_y = 16
		M.Turn(pick(180, -180))
	else if(dropkick_dir & SOUTH)
		shift_y = -16

	if(dropkick_dir & EAST)
		shift_x = 16
		M.Turn(-90)
	else if(dropkick_dir & WEST)
		shift_x = -16
		M.Turn(90)

	var/prev_pix_x = attacker.pixel_x
	var/prev_pix_y = attacker.pixel_y
	var/prev_transform = attacker.transform

	var/prev_anchored = attacker.anchored

	attacker.anchored = TRUE

	attacker.set_dir(NORTH) // Face up.

	animate(attacker, pixel_x = attacker.pixel_x + shift_x, pixel_y = attacker.pixel_y + shift_y, transform  = M, time = 3)
	if(!do_combo(victim, attacker, 3))
		return

	attacker.pixel_x = prev_pix_x
	attacker.pixel_y = prev_pix_y
	attacker.forceMove(victim.loc)

	attacker.anchored = prev_anchored
	attacker.transform = prev_transform
	attacker.apply_effect(3, WEAKEN, blocked = 0)

	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	attacker.visible_message("<span class='danger'>[attacker] dropkicks [victim], pushing them onward!</span>")

	var/try_steps = 5

	if(face_dir & NORTH)
		face_dir = NORTH
	if(face_dir & SOUTH)
		face_dir = SOUTH
	if(face_dir & WEST)
		face_dir = WEST
	if(face_dir & EAST)
		face_dir = EAST

	var/list/collected = list(victim)
	var/list/movers = list("1" = victim)
	var/list/prev_info = list("1" = list("pix_x" = victim.pixel_x, "pix_y" = victim.pixel_y, "pass_flags" = victim.pass_flags))

	var/i = 1
	try_steps_loop:
		for(var/try_step in 1 to try_steps)
			var/cur_movers = list() + collected - list(victim)

			var/atom/old_V_loc = victim.loc
			var/turf/target_turf = get_step(get_turf(victim), dropkick_dir)
			step(victim, dropkick_dir)

			if(old_V_loc == victim.loc)
				var/list/candidates = target_turf.contents - list(victim)
				new_movers:
					for(var/mob/living/new_mover in candidates)
						if(new_mover == attacker)
							continue new_movers
						if(new_mover in collected)
							continue new_movers
						if(new_mover.is_bigger_than(victim))
							break try_steps_loop
						if(!new_mover.anchored)
							collected += new_mover
							new_mover.Stun(1)
							i++
							movers["[i]"] = new_mover
							prev_info["[i]"] = list("pix_x" = new_mover.pixel_x, "pix_y" = new_mover.pixel_y, "pass_flags" = new_mover.pass_flags)
							new_mover.pixel_x += rand(-8, 8)
							new_mover.pixel_y += rand(-8, 8)
							new_mover.pass_flags |= PASSMOB|PASSCRAWL

							event_log(new_mover, attacker, "Forced Dropkick Stun")

			for(var/mob/living/L in cur_movers)
				INVOKE_ASYNC(GLOBAL_PROC, .proc/_step, L, dropkick_dir)

			// Since they were the one to push.
			if(!do_combo(victim, attacker, attacker.movement_delay() * 0.5))
				for(var/j in 1 to i)
					var/mob/living/L = movers["[j]"]
					var/list/prev_info_el = prev_info["[j]"]
					L.pixel_x = prev_info_el["pix_x"]
					L.pixel_y = prev_info_el["pix_y"]
					L.pass_flags = prev_info_el["pass_flags"]
					apply_effect(4, WEAKEN, L, attacker, attack_obj=attack_obj, min_value=1)
				return

	for(var/j in 1 to i)
		var/mob/living/L = movers["[j]"]
		var/list/prev_info_el = prev_info["[j]"]
		L.pixel_x = prev_info_el["pix_x"]
		L.pixel_y = prev_info_el["pix_y"]
		L.pass_flags = prev_info_el["pass_flags"]
		apply_effect(4, WEAKEN, L, attacker, attack_obj=attack_obj, min_value=1)

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/dropkick/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/charge
	name = "Charge"
	desc = "A move that grabs your opponent by the neck, and drives you into the closest obstacle, hitting them on it."
	combo_icon_state = "charge"
	fullness_lose_on_execute = 75
	combo_elements = list(INTENT_GRAB, INTENT_HARM, INTENT_HARM, INTENT_GRAB)

	check_bodyarmor = TRUE

	allowed_target_zones = list(BP_CHEST)

	heavy_animation = TRUE

	force_dam_type = BRUTE

/datum/combat_combo/charge/animate_combo(mob/living/victim, mob/living/attacker)
	if(!do_combo(victim, attacker, 3))
		return

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
	name = "Spin & Throw"
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
	if(!do_combo(victim, attacker, 3))
		return

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
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"

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
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				M.log_combat(attacker, "throwm from [start_T_descriptor] with the target [end_T_descriptor]")

				M.throw_at(target, 6, 8, attacker)
				apply_effect(7, WEAKEN, M, attacker, attack_obj=attack_obj, min_value=1)

				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
						var/obj/item/clothing/suit/V = H.wear_suit
						V.attack_reaction(H, REACTION_THROWITEM)
				return

	destroy_grabs()

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/spin_throw/execute(mob/living/victim, mob/living/attacker)
	return

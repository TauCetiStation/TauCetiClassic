/datum/combat_combo/disarm
	name = "Weapon Disarm"
	desc = "A move that knocks anything out of your opponent's hands."
	combo_icon_state = "weapon_disarm"
	fullness_lose_on_execute = 15
	combo_elements = list(I_DISARM, I_DISARM, I_DISARM, I_DISARM)

	allowed_target_zones = TARGET_ZONE_ALL

/datum/combat_combo/disarm/execute(mob/living/victim, mob/living/attacker)
	for(var/obj/item/weapon/gun/G in list(victim.get_active_hand(), victim.get_inactive_hand()))
		var/chance = 0
		if(victim.get_active_hand() == G)
			chance = 40
		else
			chance = 20

		if(prob(chance))
			victim.visible_message("<span class='danger'>[victim]'s [G] goes off during struggle!</span>")
			var/list/turfs = list()
			for(var/turf/T in view(7, victim))
				turfs += T
			var/turf/target = pick(turfs)
			return G.afterattack(target, victim)

	victim.drop_item()
	victim.visible_message("<span class='warning'><B>[attacker] has disarmed [victim]!</B></span>")



/datum/combat_combo/push
	name = "Push"
	desc = "A move that simply pushes your opponent to the ground."
	combo_icon_state = "push"
	fullness_lose_on_execute = 40
	combo_elements = list("Weapon Disarm", I_DISARM, I_DISARM, I_DISARM)

	allowed_target_zones = list(BP_CHEST)

/datum/combat_combo/push/execute(mob/living/victim, mob/living/attacker)
	var/obj/item/organ/external/BP = attacker.get_targetzone()

	var/armor_check = 0
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		BP = H.get_bodypart(BP)
		armor_check = victim.run_armor_check(BP, "melee")

	victim.apply_effect(3, WEAKEN, BP, blocked = armor_check)
	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	victim.visible_message("<span class='danger'>[attacker] has pushed [victim] to the ground!</span>")



/datum/combat_combo/slide_kick
	name = "Slide Kick"
	desc = "A move that makes you slide, kicking down people on your way."
	combo_icon_state = "slide_kick"
	fullness_lose_on_execute = 40
	combo_elements = list("Weapon Disarm", I_DISARM, I_DISARM, I_DISARM)

	allowed_target_zones = list(BP_L_LEG, BP_R_LEG)

/datum/combat_combo/slide_kick/animate_combo(mob/living/victim, mob/living/attacker)
	attacker.combo_animation = TRUE
	attacker.become_busy(victim, _hand = 0)
	attacker.become_busy(victim, _hand = 1)
	victim.in_use_action = TRUE
	victim.Stun(1)
	sleep(3)

	if(victim.buckled)
		victim.buckled.unbuckle_mob()
	if(attacker.buckled)
		attacker.buckled.unbuckle_mob()

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
			attacker.Move(T, slide_dir, forced=TRUE)

		if(T != attacker.loc)
			break

		for(var/mob/living/L in T)
			if(L == attacker)
				continue

			var/obj/item/organ/external/BP = attacker.get_targetzone()
			var/armor_check = 0
			if(ishuman(L))
				var/mob/living/carbon/human/H = victim
				BP = H.get_bodypart(BP)
				armor_check = H.run_armor_check(BP, "melee")

			L.apply_effect(2, WEAKEN, BP, blocked = armor_check)

			var/end_string = "to the ground!"
			if(CLUMSY in attacker.mutations) // Make a funny
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					var/obj/item/clothing/PANTS = H.w_uniform
					var/obj/item/clothing/BELT = H.belt

					var/first = TRUE
					for(var/obj/item/I in list(PANTS, BELT))
						if(!I)
							continue
						if(first)
							end_string = ", taking off their [I]"
						else
							end_string += ", [I]"
					if(!first)
						end_string += "!"
			L.visible_message("<span class='danger'>[attacker] slide-kicks [L][end_string]</span>")


		if(!do_after(attacker, attacker.movement_delay() * 0.5, can_move = TRUE, target = victim, progress = FALSE))
			break

	attacker.crawling = prev_crawling
	attacker.lying = prev_lying
	attacker.pass_flags = prev_pass_flags

	attacker.update_canmove()

	attacker.become_not_busy(victim, _hand = 0)
	attacker.become_not_busy(victim, _hand = 1)
	attacker.combo_animation = FALSE

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/slide_kick/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/capture
	name = "Capture"
	desc = "A move that allows you to quickly grab your opponent into a jointlock, and press them against the ground."
	combo_icon_state = "capture"
	fullness_lose_on_execute = 75
	combo_elements = list(I_DISARM, I_DISARM, I_DISARM, I_GRAB)

	allowed_target_zones = list(BP_L_ARM, BP_R_ARM)

/datum/combat_combo/capture/execute(mob/living/victim, mob/living/attacker)
	victim.Stun(2)

	if(victim.buckled)
		victim.buckled.unbuckle_mob()
	if(attacker.buckled)
		attacker.buckled.unbuckle_mob()

	attacker.Grab(victim, GRAB_AGGRESSIVE)
	var/obj/item/weapon/grab/victim_G
	for(var/obj/item/weapon/grab/G in attacker.GetGrabs())
		if(G.affecting == victim)
			if(G.state != GRAB_AGGRESSIVE)
				G.set_state(GRAB_AGGRESSIVE)
			victim_G = G
			break

	if(victim_G)
		var/obj/item/organ/external/BP = attacker.get_targetzone()
		var/armor_check = 0
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			BP = H.get_bodypart(BP)
			armor_check = H.run_armor_check(BP, "melee")

			victim.visible_message("<span class='danger'>[attacker] [pick("bent", "twisted")] [victim]'s [BP.name] into a jointlock!</span>")
			if(armor_check < 2)
				to_chat(victim, "<span class='danger'>You feel extreme pain!</span>")
				victim.adjustHalLoss(CLAMP(0, 40 - victim.halloss, 40)) // up to 40 halloss

		victim_G.force_down = TRUE
		victim.apply_effect(3, WEAKEN, BP, blocked = armor_check)
		victim.visible_message("<span class='danger'>[attacker] presses [victim] to the ground!</span>")

		step_to(attacker, victim)
		attacker.set_dir(EAST) //face the victim
		victim.set_dir(SOUTH) //face up



/datum/combat_combo/uppercut
	name = "Uppercut"
	desc = "A move where you lunge your fist from below into opponent's chin, knocking their helmet off."
	combo_icon_state = "uppercut"
	fullness_lose_on_execute = 50
	combo_elements = list(I_HURT, I_HURT, I_HURT, I_HURT)

	allowed_target_zones = list(BP_HEAD)

/datum/combat_combo/uppercut/animate_combo(mob/living/victim, mob/living/attacker)
	victim.Stun(2)
	attacker.become_busy(victim, _hand = 0)
	attacker.become_busy(victim, _hand = 1)
	attacker.combo_animation = TRUE

	var/prev_attacker_M = attacker.transform
	var/prev_victim_M = victim.transform

	sleep(3)

	attacker.set_dir(pick(NORTH, SOUTH)) // So they will appear sideways, as if they are actually knocking with their fist.

	var/DTM = get_dir(attacker, victim)
	var/shift_x = 0
	var/shift_y = 0

	var/matrix/M = matrix()
	var/matrix/victim_M = matrix()

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

	if(victim.buckled)
		victim.buckled.unbuckle_mob()
	if(attacker.buckled)
		attacker.buckled.unbuckle_mob()

	var/prev_victim_layer = victim.layer

	victim.layer = attacker.layer - 0.1

	animate(attacker, pixel_x = attacker.pixel_x + shift_x, pixel_y = attacker.pixel_y + shift_y, time = 2)
	if(!do_after(attacker, 2, target = victim, progress = FALSE))
		attacker.pixel_x = prev_pix_x
		attacker.pixel_y = prev_pix_y

		victim.layer = prev_victim_layer

		attacker.become_not_busy(victim, _hand = 0)
		attacker.become_not_busy(victim, _hand = 1)
		attacker.combo_animation = FALSE
		return

	var/prev_victim_pix_y = victim.pixel_y

	animate(attacker, transform = M, pixel_y = attacker.pixel_y + 8, time = 2)
	sleep(2)
	animate(attacker, transform = prev_attacker_M, pixel_y = attacker.pixel_y + 8, time = 2)
	animate(victim, transform = victim_M, pixel_y = victim.pixel_y + 16, time = 2)
	sleep(2)

	var/atom/move_attacker_to = victim.loc
	var/atom/move_victim_dir = get_dir(victim, get_step_away(victim, attacker))
	step(victim, move_victim_dir)

	attacker.pixel_x = prev_pix_x
	attacker.pixel_y = prev_pix_y + 16
	attacker.forceMove(move_attacker_to)

	animate(attacker, pixel_y = attacker.pixel_y - 16, time = 2)
	animate(victim, pixel_y = prev_victim_pix_y, time = 2)
	sleep(2)

	attacker.transform = prev_attacker_M
	victim.transform = prev_victim_M
	victim.layer = prev_victim_layer

	var/obj/item/organ/external/BP = BP_HEAD
	var/armor_check = 0
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		BP = H.get_bodypart(BP)
		armor_check = H.run_armor_check(BP, "melee")

	victim.apply_effect(2, WEAKEN, BP, blocked = armor_check)
	victim.apply_damage(20, BRUTE, BP, blocked = armor_check)
	victim.visible_message("<span class='danger'>[attacker] has performed an uppercut on [victim]!</span>")

	if(iscarbon(victim))
		var/mob/living/carbon/C = victim
		if(C.head && !(C.head.flags & (ABSTRACT|NODROP)))
			var/obj/item/clothing/VH = C.head
			victim.drop_from_inventory(VH, victim.loc)
			attacker.newtonian_move(get_dir(victim, attacker))

			var/turf/target = get_step(victim, attacker.dir)

			VH.throw_at(target, VH.throw_range, VH.throw_speed, attacker)

	attacker.become_not_busy(victim, _hand = 0)
	attacker.become_not_busy(victim, _hand = 1)
	attacker.combo_animation = FALSE

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/uppercut/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/suplex
	name = "Suplex"
	desc = "A move that lifts your opponent up, only to then throw them to the ground, harshly."
	combo_icon_state = "suplex"
	fullness_lose_on_execute = 75
	combo_elements = list(I_HURT, I_HURT, I_HURT, I_GRAB)

	allowed_target_zones = list(BP_GROIN)

/datum/combat_combo/suplex/animate_combo(mob/living/victim, mob/living/attacker)
	victim.Stun(2)
	attacker.become_busy(victim, _hand = 0)
	attacker.become_busy(victim, _hand = 1)
	attacker.combo_animation = TRUE

	var/matrix/victim_M = victim.transform

	sleep(3)

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

	if(victim.buckled)
		victim.buckled.unbuckle_mob()
	if(attacker.buckled)
		attacker.buckled.unbuckle_mob()

	animate(attacker, pixel_x = attacker.pixel_x + shift_x, pixel_y = attacker.pixel_y + shift_y, time = 5)
	if(!do_after(attacker, 5, target = victim, progress = FALSE))
		attacker.pixel_x = prev_pix_x
		attacker.pixel_y = prev_pix_y

		attacker.become_not_busy(victim, _hand = 0)
		attacker.become_not_busy(victim, _hand = 1)
		attacker.combo_animation = FALSE
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
		victim.transform = victim_M

		attacker.become_not_busy(victim, _hand = 0)
		attacker.become_not_busy(victim, _hand = 1)
		attacker.combo_animation = FALSE
		return

	animate(victim, pixel_y = victim.pixel_y + 20, time = 6)
	if(!do_after(attacker, 6, target = victim, progress = FALSE))
		victim.pixel_x = prev_pix_x
		victim.pixel_y = prev_pix_y
		victim.transform = victim_M

		attacker.combo_animation = FALSE
		return

	victim.Stun(1)
	attacker.Stun(1) // So he doesn't do something funny during the trick.

	var/prev_victim_anchored = victim.anchored
	var/prev_attacker_anchored = attacker.anchored
	victim.anchored = TRUE
	attacker.anchored = TRUE
	animate(victim, pixel_x = victim.pixel_x - shift_x, pixel_y = victim.pixel_y - 20 - shift_y, time = 2)
	sleep(2)

	victim.transform = victim_M
	victim.forceMove(get_step(victim, victim_dir))
	victim.pixel_x = prev_pix_x
	victim.pixel_y = prev_pix_y
	victim.anchored = prev_victim_anchored
	attacker.anchored = prev_attacker_anchored

	var/obj/item/organ/external/BP = BP_GROIN
	var/armor_check = 0
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		BP = H.get_bodypart(BP)
		armor_check = H.run_armor_check(H, "melee")

	victim.apply_effect(5, WEAKEN, blocked = armor_check)
	victim.apply_damage(30, BRUTE, blocked = armor_check)

	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	victim.visible_message("<span class='danger'>[attacker] has thrown [victim] over their shoulder!</span>")

	attacker.become_not_busy(victim, _hand = 0)
	attacker.become_not_busy(victim, _hand = 1)
	attacker.combo_animation = FALSE

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/suplex/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/diving_elbow_drop
	name = "Diving Elbow Drop"
	desc = "A move in which you jump up high, and then fall onto your opponent, hitting them with your elbow."
	combo_icon_state = "diving_elbow_drop"
	fullness_lose_on_execute = 40
	combo_elements = list("Suplex", I_HURT, I_DISARM, I_HURT)

	allowed_target_zones = list(BP_CHEST)

/datum/combat_combo/diving_elbow_drop/animate_combo(mob/living/victim, mob/living/attacker)
	victim.Stun(2)
	attacker.become_busy(victim, _hand = 0)
	attacker.become_busy(victim, _hand = 1)
	attacker.combo_animation = TRUE

	var/prev_transform = attacker.transform

	sleep(3)

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

	if(victim.buckled)
		victim.buckled.unbuckle_mob()
	if(attacker.buckled)
		attacker.buckled.unbuckle_mob()

	animate(attacker, pixel_y = attacker.pixel_y - 4, time = 5)
	if(!do_after(attacker, 5, target = victim, progress = FALSE))
		attacker.pixel_y += 4

		attacker.become_not_busy(victim, _hand = 0)
		attacker.become_not_busy(victim, _hand = 1)
		attacker.combo_animation = FALSE
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
	sleep(4)

	sleep(2) // Hover ominously.

	attacker.pixel_x = prev_pix_x
	attacker.pixel_y = prev_pix_y + 32
	attacker.forceMove(victim.loc)

	animate(attacker, pixel_y = prev_pix_y, time = 2)
	sleep(2)

	for(var/mob/living/L in victim.loc)
		if(L == attacker)
			continue
		if(L.lying || L.resting || L.crawling)
			L.apply_damage(30, BRUTE, blocked =0) // A body dropped on us! Armor ain't helping.
		L.apply_effect(6, WEAKEN, blocked = 0)

	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	attacker.visible_message("<span class='danger'>[attacker] falls elbow first onto [attacker.loc] with a loud thud!</span>")

	attacker.anchored = prev_anchored
	attacker.canmove = prev_canmove
	attacker.density = prev_density
	attacker.transform = prev_transform
	attacker.pixel_x = prev_pix_x
	attacker.pixel_y = prev_pix_y

	attacker.become_not_busy(victim, _hand = 0)
	attacker.become_not_busy(victim, _hand = 1)
	attacker.combo_animation = FALSE

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/diving_elbow_drop/execute(mob/living/victim, mob/living/attacker)
	return


/datum/combat_combo/dropkick
	name = "Dropkick"
	desc = "A move in which you jump with your both legs into opponent's belly, knocking them backwards."
	combo_icon_state = "dropkick"
	fullness_lose_on_execute = 25
	combo_elements = list(I_DISARM, I_HURT, I_DISARM, I_HURT)

	allowed_target_zones = list(BP_GROIN)

/datum/combat_combo/dropkick/animate_combo(mob/living/victim, mob/living/attacker)
	victim.Stun(2)
	attacker.Stun(2)
	attacker.become_busy(victim, _hand = 0)
	attacker.become_busy(victim, _hand = 1)
	attacker.combo_animation = TRUE

	var/prev_transform = attacker.transform

	sleep(3)

	if(victim.buckled)
		victim.buckled.unbuckle_mob()
	if(attacker.buckled)
		attacker.buckled.unbuckle_mob()

	var/DTM = get_dir(attacker, victim)
	var/shift_x = 0
	var/shift_y = 0

	var/matrix/M = matrix()

	if(DTM & NORTH)
		shift_y = 16
		M.Turn(pick(180, -180))
	else if(DTM & SOUTH)
		shift_y = -16

	if(DTM & EAST)
		shift_x = 16
		M.Turn(-90)
	else if(DTM & WEST)
		shift_x = -16
		M.Turn(90)

	var/prev_pix_x = attacker.pixel_x
	var/prev_pix_y = attacker.pixel_y

	var/prev_anchored = attacker.anchored

	attacker.anchored = TRUE

	attacker.set_dir(NORTH) // Face up.

	animate(attacker, pixel_x = attacker.pixel_x + shift_x, pixel_y = attacker.pixel_y + shift_y, transform  = M, time = 3)
	sleep(3)

	var/dropkick_dir = get_dir(attacker, victim)
	var/face_dir = get_dir(victim, attacker)

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
	var/list/prev_pixs = list("1" = list("pix_x" = victim.pixel_x, "pix_y" = victim.pixel_y))

	var/i = 1
	for(var/try_step in 1 to try_steps)
		var/cur_movers = list() + movers

		for(var/mob/living/L in cur_movers)
			var/atom/old_L_loc = L.loc
			step(L, dropkick_dir)

			if(old_L_loc == L.loc)
				new_movers:
					for(var/mob/living/new_mover in L.loc)
						if(new_mover == attacker)
							continue new_movers
						if(new_mover in collected)
							continue new_movers
						if(!new_mover.anchored)
							new_mover.Stun(1)
							i++
							movers["[i]"] = new_mover
							prev_pixs["[i]"] = list("pix_x" = new_mover.pixel_x, "pix_y" = new_mover.pixel_y)
							new_mover.pixel_x += rand(-8, 8)
							new_mover.pixel_y += rand(-8, 8)

		sleep(attacker.movement_delay() * 0.75) // Since they were the one to push.

	for(var/j in 1 to i)
		var/mob/living/L = movers["[j]"]
		var/list/prev_pixs_el = prev_pixs["[j]"]
		L.pixel_x = prev_pixs_el["pix_x"]
		L.pixel_y = prev_pixs_el["pix_y"]
		L.apply_effect(5, WEAKEN, blocked = 0)

	attacker.become_not_busy(victim, _hand = 0)
	attacker.become_not_busy(victim, _hand = 1)
	attacker.combo_animation = FALSE

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/dropkick/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/charge
	name = "Charge"
	desc = "A move that grabs your opponent by the neck, and drives you into the closest obstacle, hitting them on it."
	combo_icon_state = "charge"
	fullness_lose_on_execute = 75
	combo_elements = list(I_GRAB, I_HURT, I_HURT, I_GRAB)

	allowed_target_zones = list(BP_CHEST)

/datum/combat_combo/charge/animate_combo(mob/living/victim, mob/living/attacker)
	victim.Stun(2)
	attacker.become_busy(victim, _hand = 0)
	attacker.become_busy(victim, _hand = 1)
	attacker.combo_animation = TRUE
	sleep(3)

	if(victim.buckled)
		victim.buckled.unbuckle_mob()
	if(attacker.buckled)
		attacker.buckled.unbuckle_mob()

	attacker.Grab(victim, GRAB_NECK)
	var/success = FALSE
	for(var/obj/item/weapon/grab/G in attacker.GetGrabs())
		if(G.affecting == victim)
			if(G.state != GRAB_NECK)
				G.set_state(GRAB_NECK)
			success = TRUE
			break

	if(success)
		var/try_steps = 6
		var/charge_dir = attacker.dir

		for(var/try_to_step in 1 to try_steps)
			var/obj/item/weapon/grab/victim_G
			grab_search:
				for(var/obj/item/weapon/grab/G in attacker.GetGrabs())
					if(G.affecting == victim)
						victim_G = G
						break grab_search

			if(!victim_G) // Somebody disarmed us, stop this.
				break

			var/turf/T = get_step(attacker, charge_dir)
			if(attacker.client)
				attacker.client.Move(T, charge_dir, forced=TRUE)
			else
				attacker.Move(T, charge_dir, forced=TRUE)

			attacker.set_dir(charge_dir)
			victim_G.adjust_position(adjust_time = 0, force_loc = TRUE, force_dir = charge_dir)

			if(T != attacker.loc) // We bumped into something, so we bumped our victim into it...
				var/list/to_check = T.contents + attacker.loc.contents - list(attacker)
				for(var/mob/living/L in to_check)
					var/obj/item/organ/external/BP = BP_CHEST
					var/armor_check = 0
					if(ishuman(L))
						var/mob/living/carbon/human/H = victim
						BP = H.get_bodypart(BP)
						armor_check = H.run_armor_check(H, "melee")

					var/obj/structure/table/facetable = locate() in T
					if(facetable)
						facetable.attackby(victim_G, attacker)
						playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
						victim.visible_message("<span class='danger'>[attacker] slams [victim] into an obstacle!</span>")
					else
						playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
						victim.visible_message("<span class='danger'>[attacker] slams [victim] into an obstacle!</span>")

					L.apply_effect(6, WEAKEN, blocked = armor_check)
					L.apply_damage(40, BRUTE, blocked = armor_check)
					break

			if(!do_after(attacker, attacker.movement_delay() * 0.75, can_move = TRUE, target = victim, progress = FALSE))
				break

	for(var/obj/item/weapon/grab/G in attacker.GetGrabs())
		if(G.affecting == victim)
			attacker.drop_from_inventory(G)
			break

	attacker.become_not_busy(victim, _hand = 0)
	attacker.become_not_busy(victim, _hand = 1)
	attacker.combo_animation = FALSE

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/charge/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/spin_throw
	name = "Spin & Throw"
	desc = "A move in which you start to spin yourself up, and at a point you throw your opponent with immense force."
	combo_icon_state = "spin_throw"
	fullness_lose_on_execute = 50
	combo_elements = list(I_GRAB, I_GRAB, I_GRAB, I_HURT)

	allowed_target_zones = list(BP_CHEST)

/datum/combat_combo/spin_throw/animate_combo(mob/living/victim, mob/living/attacker)
	victim.Stun(2)
	attacker.become_busy(victim, _hand = 0)
	attacker.become_busy(victim, _hand = 1)
	attacker.combo_animation = TRUE
	sleep(3)

	if(victim.buckled)
		victim.buckled.unbuckle_mob()
	if(attacker.buckled)
		attacker.buckled.unbuckle_mob()

	attacker.Grab(victim, GRAB_AGGRESSIVE)
	var/success = FALSE
	for(var/obj/item/weapon/grab/G in attacker.GetGrabs())
		if(G.affecting == victim)
			if(G.state != GRAB_AGGRESSIVE)
				G.set_state(GRAB_AGGRESSIVE)
			success = TRUE
			break

	if(success)
		var/cur_spin_time = 3
		grab_stages_loop:
			for(var/grab_stages in list(GRAB_AGGRESSIVE, GRAB_NECK, GRAB_NECK, GRAB_KILL))
				var/obj/item/weapon/grab/victim_G
				for(var/i in 1 to 4)
					attacker.set_dir(turn(attacker.dir, 90))
					grab_search:
						for(var/obj/item/weapon/grab/G in attacker.GetGrabs())
							if(G.affecting == victim)
								victim_G = G
								break grab_search

					if(!victim_G)
						break grab_stages_loop

					victim_G.adjust_position(adjust_time=0, force_loc = TRUE, force_dir = attacker.dir)

					victim.Stun(min(0, 2 - victim.stunned))

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
					if(!istype(M))
						break grab_stages_loop
					qdel(victim_G)

					M.visible_message("<span class='rose'>[attacker] has thrown [M] with immense force!</span>")

					attacker.newtonian_move(get_dir(target, attacker))

					var/turf/end_T = target
					var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been thrown by [attacker.name] ([attacker.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
					attacker.attack_log += text("\[[time_stamp()]\] <font color='red'>Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
					msg_admin_attack("[attacker.name] ([attacker.ckey]) has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]", attacker)

					M.throw_at(target, 7, 5, attacker)
					victim.apply_damage(30, BRUTE, blocked = 0) // We threw a guy over 7 tiles distance. Armor probably ain't helping.
					M.apply_effect(6, WEAKEN, blocked = 0)

					if(ishuman(src))
						var/mob/living/carbon/human/H = src
						if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit))
							var/obj/item/clothing/suit/V = H.wear_suit
							V.attack_reaction(H, REACTION_THROWITEM)

					attacker.become_not_busy(victim, _hand = 0)
					attacker.become_not_busy(victim, _hand = 1)
					attacker.combo_animation = FALSE
					return

	for(var/obj/item/weapon/grab/G in attacker.GetGrabs())
		if(G.affecting == victim)
			attacker.drop_from_inventory(G)
			break

	attacker.become_not_busy(victim, _hand = 0)
	attacker.become_not_busy(victim, _hand = 1)
	attacker.combo_animation = FALSE

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/spin_throw/execute(mob/living/victim, mob/living/attacker)
	return

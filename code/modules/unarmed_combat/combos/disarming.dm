/datum/combat_combo/disarm
	name = COMBO_DISARM
	desc = "A move that knocks anything out of your opponent's hands."
	combo_icon_state = "weapon_disarm"
	cost = 10
	combo_elements = list(INTENT_PUSH, INTENT_PUSH, INTENT_PUSH)

	ignore_size = TRUE

	allowed_target_zones = TARGET_ZONE_ALL

	pump_bodyparts = list(
		BP_ACTIVE_ARM = 1,
	)

/datum/combat_combo/disarm/proc/item_swaparoo(mob/living/victim, mob/living/attacker)
	if(!iscarbon(attacker))
		return

	var/mob/living/carbon/C = attacker

	if(!victim.can_accept_gives(attacker, show_warnings=FALSE) || !C.can_give(victim, show_warnings=FALSE) || victim.client == null)
		return

	var/obj/item/to_give = attacker.get_active_hand() || attacker.get_inactive_hand()
	if(to_give)
		if(to_give.flags & (ABSTRACT|DROPDEL))
			to_give = null
		else if(!to_give.canremove)
			to_give = null
		else if(to_give.w_class < SIZE_NORMAL && (HULK in victim.mutations))
			to_give = null

	if(!to_give && istype(C.back, /obj/item/weapon/storage) && C.back.contents.len > 0)
		var/obj/item/weapon/storage/S = C.back
		var/obj/item/I = S.contents[S.contents.len]

		if(I.flags & (ABSTRACT | DROPDEL))
			return
		if(!I.canremove)
			return
		if(I.w_class < SIZE_NORMAL && (HULK in victim.mutations))
			return

		if(!S.remove_from_storage(I, C))
			return
		if(!attacker.put_in_hands(I))
			return

		to_give = I

	if(!to_give)
		return

	if(!attacker.drop_from_inventory(to_give, victim))
		return

	if(!victim.put_in_hands(to_give))
		return

	victim.visible_message("<span class='notice'>[attacker] handed \the [to_give] to [victim]!</span>")
	to_give.add_fingerprint(victim)
	// Extra ! ! ! F U N ! ! !
	if(C.a_intent != INTENT_HARM)
		event_log(victim, C, "Forced in-hand use of [to_give]")
		to_give.attack_self(victim)
	else
		event_log(victim, C, "Forced self-attack by [to_give]")
		to_give.melee_attack_chain(victim, victim)

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

	if(!(attacker.IsClumsy()))
		return

	// Clowns disarming put the last thing from their backpack into their opponent's hands
	// And then either force the opponent to attack themselves with that item(if intent is hurt)
	// Or force the opponent to activate the item(if intent is not hurt)

	item_swaparoo(victim, attacker)

/datum/combat_combo/push
	name = COMBO_PUSH
	desc = "A move that simply pushes your opponent to the ground."
	combo_icon_state = "push"
	cost = 40
	combo_elements = list(COMBO_DISARM, INTENT_PUSH, INTENT_PUSH, INTENT_PUSH)

	check_bodyarmor = TRUE

	allowed_target_zones = list(BP_CHEST)

	pump_bodyparts = list(
		BP_ACTIVE_ARM = 4,
		BP_INACTIVE_ARM = 4,
	)

/datum/combat_combo/push/execute(mob/living/victim, mob/living/attacker)
	var/list/attack_obj = attacker.get_unarmed_attack()
	apply_effect(3, STUN, victim, attacker, attack_obj=attack_obj, min_value=1)
	apply_effect(3, WEAKEN, victim, attacker, attack_obj=attack_obj, min_value=1)
	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	victim.visible_message("<span class='danger'>[attacker] has pushed [victim] to the ground!</span>")



/datum/combat_combo/slide_kick
	name = COMBO_SLIDE_KICK
	desc = "A move that makes you slide, kicking down people on your way."
	combo_icon_state = "slide_kick"
	cost = 40
	combo_elements = list(COMBO_DISARM, INTENT_PUSH, INTENT_PUSH, INTENT_PUSH)

	ignore_size = TRUE

	allowed_target_zones = list(BP_L_LEG, BP_R_LEG)

	require_leg = TRUE
	require_leg_to_perform = TRUE

	heavy_animation = TRUE

	pump_bodyparts = list(
		BP_L_LEG = 4,
		BP_R_LEG = 4,
	)

// Returns what to replace the append to the slide kick message with
/datum/combat_combo/slide_kick/proc/take_pants_off(mob/living/L, mob/living/attacker)
	if(!ishuman(L))
		return ""

	var/mob/living/carbon/human/H = L
	var/obj/item/clothing/PANTS = H.w_uniform
	var/obj/item/clothing/BELT = H.belt

	var/first = TRUE
	for(var/obj/item/I in list(BELT, PANTS))
		if(!I)
			continue
		// Perhaps they fell off during the slide-kick or something.
		if(I.loc != L)
			continue
		if((I.flags & (ABSTRACT|NODROP)) || !I.canremove)
			continue
		if(first)
			. = ", taking off their [I]"
		else
			. += ", [I]"
		. += "!"
		event_log(L, attacker, "Taking off [I]")
		L.drop_from_inventory(I, L.loc)

	if(!first)
		. += "!"

/datum/combat_combo/slide_kick/animate_combo(mob/living/victim, mob/living/attacker)
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
				if(attacker.IsClumsy())
					var/temp_end_string = take_pants_off(L, attacker)
					if(temp_end_string != "")
						end_string = temp_end_string

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
	name = COMBO_CAPTURE
	desc = "A move that allows you to quickly grab your opponent into a jointlock, and press them against the ground."
	combo_icon_state = "capture"
	cost = 75
	combo_elements = list(INTENT_PUSH, INTENT_PUSH, INTENT_PUSH, INTENT_GRAB)

	scale_size_exponent = 0.0

	allowed_target_zones = list(BP_L_ARM, BP_R_ARM)

	require_arm = TRUE

	pump_bodyparts = list(
		BP_ACTIVE_ARM = 7,
		BP_INACTIVE_ARM = 7,
		BP_CHEST = 7,
	)

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
	var/armor_check = victim.run_armor_check(target_zone, MELEE)

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/external/BP = H.get_bodypart(target_zone)
		victim.visible_message("<span class='danger'>[attacker] [pick("bent", "twisted")] [victim]'s [BP.name] into a jointlock!</span>")
		if(armor_check < 30)
			to_chat(victim, "<span class='danger'>You feel extreme pain!</span>")
			victim.adjustHalLoss(clamp(0, 40 - victim.halloss, 40)) // up to 40 halloss

	victim_G.force_down = TRUE
	apply_effect(3, WEAKEN, victim, attacker, zone=saved_targetzone, attack_obj=attack_obj, min_value=1)
	apply_effect(3, STUN, victim, attacker, zone=saved_targetzone, attack_obj=attack_obj, min_value=1)
	victim.visible_message("<span class='danger'>[attacker] presses [victim] to the ground!</span>")

	step_to(attacker, victim)
	attacker.set_dir(EAST) //face the victim
	victim.set_dir(SOUTH) //face up



/datum/combat_combo/dropkick
	name = COMBO_DROPKICK
	desc = "A move in which you jump with your both legs into opponent's belly, knocking them backwards."
	combo_icon_state = "dropkick"
	cost = 25
	combo_elements = list(INTENT_PUSH, INTENT_HARM, INTENT_PUSH, INTENT_HARM)

	armor_pierce = TRUE

	ignore_size = TRUE

	scale_size_exponent = 1.5

	allowed_target_zones = list(BP_GROIN)

	require_leg_to_perform = TRUE

	heavy_animation = TRUE

	pump_bodyparts = list(
		BP_L_LEG = 2,
		BP_R_LEG = 2,
		BP_GROIN = 2,
	)

/datum/combat_combo/dropkick/animate_combo(mob/living/victim, mob/living/attacker)
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
	attacker.Weaken(3)
	attacker.Stun(3)

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
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(_step), L, dropkick_dir)

			// Since they were the one to push.
			if(!do_combo(victim, attacker, attacker.movement_delay() * 0.5))
				for(var/j in 1 to i)
					var/mob/living/L = movers["[j]"]
					var/list/prev_info_el = prev_info["[j]"]
					L.pixel_x = prev_info_el["pix_x"]
					L.pixel_y = prev_info_el["pix_y"]
					L.pass_flags = prev_info_el["pass_flags"]
					apply_effect(4, WEAKEN, L, attacker, attack_obj=attack_obj, min_value=1)
					apply_effect(4, STUN, L, attacker, attack_obj=attack_obj, min_value=1)
				return

	for(var/j in 1 to i)
		var/mob/living/L = movers["[j]"]
		var/list/prev_info_el = prev_info["[j]"]
		L.pixel_x = prev_info_el["pix_x"]
		L.pixel_y = prev_info_el["pix_y"]
		L.pass_flags = prev_info_el["pass_flags"]
		apply_effect(4, WEAKEN, L, attacker, attack_obj=attack_obj, min_value=1)
		apply_effect(4, STUN, L, attacker, attack_obj=attack_obj, min_value=1)

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/dropkick/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/capture_cqc
	name = COMBO_CAPTURE_CQC
	desc = "A move that allows you to quickly grab the opponent's hand, quickly turn it around, breaking it, and then take the opponent into a very strong grab."
	combo_icon_state = "capture_cqc"
	cost = 90
	combo_elements = list(INTENT_PUSH, INTENT_PUSH, INTENT_HARM, INTENT_GRAB)

	scale_size_exponent = 0.0

	allowed_target_zones = list(BP_L_ARM, BP_R_ARM)

	require_arm = TRUE

	pump_bodyparts = list(
		BP_ACTIVE_ARM = 7,
		BP_INACTIVE_ARM = 7,
		BP_CHEST = 7,
	)

/datum/combat_combo/capture_cqc/execute(mob/living/victim, mob/living/attacker)
	var/saved_targetzone = attacker.get_targetzone()
	var/list/attack_obj = attacker.get_unarmed_attack()

	victim.Stun(2)

	if(victim.buckled)
		victim.buckled.unbuckle_mob()
	if(attacker.buckled)
		attacker.buckled.unbuckle_mob()

	var/obj/item/weapon/grab/victim_G = prepare_grab(victim, attacker, GRAB_NECK)
	if(!istype(victim_G))
		return

	var/target_zone = attacker.get_targetzone()
	var/armor_check = victim.run_armor_check(target_zone, MELEE)

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/external/BP = H.get_bodypart(target_zone)
		victim.visible_message("<span class='danger'>[attacker] [pick("bent", "twisted")] [victim]'s [BP.name] into a jointlock!</span>")
		to_chat(victim, "<span class='danger'>You feel extreme pain!</span>")
		victim.adjustHalLoss(clamp(0, 40 - victim.halloss, 40)) // up to 40 halloss
		if(armor_check < 30)
			BP.fracture()

	victim_G.force_down = TRUE
	apply_effect(3, WEAKEN, victim, attacker, zone=saved_targetzone, attack_obj=attack_obj, min_value=2)
	apply_effect(3, STUN, victim, attacker, zone=saved_targetzone, attack_obj=attack_obj, min_value=2)
	victim.visible_message("<span class='danger'>[attacker] bends [victim] arm sharply!</span>")

	step_to(attacker, victim)
	attacker.set_dir(EAST) //face the victim
	victim.set_dir(SOUTH) //face up



/datum/combat_combo/neck_blow
	name = COMBO_NECK_CULT
	desc = "A blow to the neck allows you to silence the target, as well as stop their breath."
	combo_icon_state = "neckblow_cult"
	cost = 15
	combo_elements = list(INTENT_PUSH, INTENT_PUSH, INTENT_HARM)
	allowed_target_zones = list(BP_HEAD)
	require_arm_to_perform = TRUE


	pump_bodyparts = list(
		BP_ACTIVE_ARM = 7
	)

/datum/combat_combo/neck_blow/execute(mob/living/victim, mob/living/attacker)
	victim.losebreath += 40
	victim.silent += 15
	victim.visible_message("<span class='danger'>[attacker] punches [victim] in the neck!</span>")
	playsound(victim, 'sound/effects/mob/hits/medium_1.ogg', VOL_EFFECTS_MASTER)



/datum/combat_combo/eyes
	name = COMBO_EYES_CULT
	desc = "You masterfully poke your opponent in the eyes, which allows you to disorient them, as well as damage their eyeballs. Does not work if the target is wearing glasses or a mask."
	combo_icon_state = "eyes_cult"
	cost = 10
	combo_elements = list(INTENT_PUSH, INTENT_PUSH, INTENT_HARM)
	allowed_target_zones = list(O_EYES)
	require_arm_to_perform = TRUE

	pump_bodyparts = list(
		BP_ACTIVE_ARM = 7
	)

/datum/combat_combo/eyes/execute(mob/living/victim, mob/living/attacker)
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		if(((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			// you can't stab someone in the eyes wearing a mask!
			to_chat(attacker, "<span class='warning'>You're going to need to remove the eye covering first.</span>")
			return
	victim.MakeConfused(5)
	victim.adjustBlurriness(5)
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
		IO.damage += 20
	victim.flash_eyes()
	victim.visible_message("<span class='danger'>[attacker] pokes [victim] in the eye!</span>")

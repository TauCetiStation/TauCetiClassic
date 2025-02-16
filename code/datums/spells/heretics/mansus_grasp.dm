/obj/effect/proc_holder/spell/in_hand/mansus_grasp
	name = "Mansus Grasp"
	desc = "A touch spell that lets you channel the power of the Old Gods through your grip."
	action_background_icon_state = "bg_heretic"
	action_icon_state = "mansus_grasp"
	icon = 'icons/hud/actions_ecult.dmi'

	school = "evocation"
	clothes_req = 0
	charge_max = 10 SECONDS
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	invocation = "R'CH T'H TR'TH!"
	invocation_type = INVOCATION_SHOUT

	hand_path = /obj/item/melee/touch_attack/mansus_fist

/obj/effect/proc_holder/spell/in_hand/mansus_grasp/is_valid_target(atom/cast_on)
	return TRUE // This baby can hit anything

/obj/effect/proc_holder/spell/in_hand/mansus_grasp/can_cast_spell(feedback = TRUE)
	return ..() && (!!isheretic(owner) || !!islunatic(owner))

/obj/effect/proc_holder/spell/in_hand/mansus_grasp/on_antimagic_triggered(obj/item/weapon/magic/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("The spell bounces off of [victim]!"),
		span_danger("The spell bounces off of you!"),
	)

/obj/effect/proc_holder/spell/in_hand/mansus_grasp/cast_on_hand_hit(obj/item/weapon/magic/hand, atom/victim, mob/living/carbon/caster)
	if(!isliving(victim))
		return FALSE

	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, victim) & COMPONENT_BLOCK_HAND_USE)
		return FALSE

	var/mob/living/living_hit = victim
	living_hit.adjustBruteLoss(10)
	if(!iscarbon(victim))
		return TRUE

	var/mob/living/carbon/carbon_hit = victim

	// Cultists are momentarily disoriented by the stunning aura. Enough for both parties to go 'oh shit' but only a mild combat ability.
	// Cultists have an identical effect on their stun hand. The heretic's faster spell charge time is made up for by their lack of teammates.
	if(iscultist(carbon_hit))
		carbon_hit.AdjustWeakened(0.5 SECONDS)
		carbon_hit.adjust_confusion_up_to(1.5 SECONDS, 3 SECONDS)
		carbon_hit.adjust_dizzy_up_to(1.5 SECONDS, 3 SECONDS)
		ADD_TRAIT(carbon_hit, TRAIT_NO_SIDE_KICK, REF(src)) // We don't want this to be a good stunning tool, just minor disorientation
		addtimer(TRAIT_CALLBACK_REMOVE(carbon_hit, TRAIT_NO_SIDE_KICK, REF(src)), 1 SECONDS)

		var/old_color = carbon_hit.color
		carbon_hit.color = COLOR_CULT_RED
		animate(carbon_hit, color = old_color, time = 4 SECONDS, easing = EASE_IN)
		carbon_hit.mob_light(range = 1.5, power = 2.5, color = COLOR_CULT_RED, duration = 0.5 SECONDS)
		playsound(carbon_hit, 'sound/effects/curse.ogg', 50, TRUE)

		to_chat(caster, span_warning("An unholy force intervenes as you grasp [carbon_hit], absorbing most of the effects!"))
		to_chat(carbon_hit, span_warning("As [caster] grasps you with eldritch forces, your blood magic absorbs most of the effects!"))
		carbon_hit.balloon_alert_to_viewers("absorbed!")
		return TRUE

	carbon_hit.adjust_timed_status_effect(4 SECONDS, /datum/status_effect/speech/slurring/heretic)
	carbon_hit.AdjustWeakened(5 SECONDS)
	carbon_hit.adjustHalLoss(80)

	return TRUE

/obj/effect/proc_holder/spell/in_hand/mansus_grasp/cast_on_secondary_hand_hit(obj/item/weapon/magic/hand, atom/victim, mob/living/carbon/caster)
	if(isliving(victim)) // if it's a living mob, go with our normal afterattack
		return SECONDARY_ATTACK_CALL_NORMAL

	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, victim) & COMPONENT_USE_HAND)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/weapon/magic/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it. \
		Causes knockdown, minor bruises, and major stamina damage. \
		It gains additional beneficial effects as you expand your knowledge of the Mansus."
	icon = 'icons/obj/hand.dmi'
	lefthand_file = 'icons/mob/inhands/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/touchspell_righthand.dmi'
	icon_state = "mansus"
	s_fire = 'sound/items/Welder.ogg'

/obj/item/weapon/magic/mansus_fist/atom_init()
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You remove %THEEFFECT.", \
		tip_text = "Clear rune", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/heretic_rune), \
		time_to_remove = 0.4 SECONDS)

/*
 * Callback for effect_remover component.
 */
/obj/item/weapon/magic/mansus_fist/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc, target.greyscale_colors)
	var/obj/effect/proc_holder/spell/in_hand/mansus_grasp/grasp = spell_which_made_us?.resolve()
	grasp?.spell_feedback(user)

	remove_hand_with_no_refund(user)

/obj/item/weapon/magic/mansus_fist/ignition_effect(atom/to_light, mob/user)
	. = span_rose("[user] effortlessly snaps [user.p_their()] fingers near [to_light], igniting it with eldritch energies. Fucking badass!")
	remove_hand_with_no_refund(user)

/obj/item/weapon/magic/mansus_fist/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] covers [user.p_their()] face with [user.p_their()] sickly-looking hand! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/mob/living/carbon/carbon_user = user //iscarbon already used in spell's parent
	var/obj/effect/proc_holder/spell/in_hand/mansus_grasp/source = spell_which_made_us?.resolve()
	if(QDELETED(source) || !isheretic(user))
		return SHAME

	if(user.can_block_magic(source.antimagic_flags))
		return SHAME

	var/escape_our_torment = 0
	while(carbon_user.stat == CONSCIOUS)
		if(QDELETED(src) || QDELETED(user))
			return SHAME
		if(escape_our_torment > 20) //Stops us from infinitely stunning ourselves if we're just not taking the damage
			return FIRELOSS

		if(prob(70))
			carbon_user.adjustFireLoss(20)
			playsound(carbon_user, 'sound/effects/wounds/sizzle1.ogg', 70, vary = TRUE)
			if(prob(50))
				carbon_user.emote("scream")
				carbon_user.adjust_stutter(26 SECONDS)

		source.cast_on_hand_hit(src, user, user)

		escape_our_torment++
		stoplag(0.4 SECONDS)
	return FIRELOSS

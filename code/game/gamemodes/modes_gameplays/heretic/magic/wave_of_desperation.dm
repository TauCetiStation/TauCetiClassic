/obj/effect/proc_holder/spell/aoe/wave_of_desperation
	name = "Wave Of Desperation"
	desc = "Removes your restraints, repels and knocks down adjacent people, and applies certain effects of the Mansus Grasp upon everything nearby. \
		Cannot be cast unless you are restrained, and the stress renders you unconscious 12 seconds later!"
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	icon = 'icons/hud/actions_ecult.dmi'
	button_icon_state = "uncuff"
	sound = 'sound/effects/magic/swap.ogg'

	school = SCHOOL_FORBIDDEN
	charge_max = 5 MINUTES

	invocation = "F'K 'FF."
	invocation_type = "whisper"


	range = 3

/obj/effect/proc_holder/spell/aoe/wave_of_desperation/is_valid_target(mob/living/carbon/cast_on)
	return ..() && istype(cast_on) && (cast_on.handcuffed || cast_on.legcuffed)

// Before the cast, we do some small AOE damage around the caster
/obj/effect/proc_holder/spell/aoe/wave_of_desperation/before_cast(mob/living/carbon/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(cast_on.handcuffed)
		cast_on.visible_message(span_danger("[cast_on.handcuffed] on [cast_on] shatter!"))
		QDEL_NULL(cast_on.handcuffed)
	if(cast_on.legcuffed)
		cast_on.visible_message(span_danger("[cast_on.legcuffed] on [cast_on] shatters!"))
		QDEL_NULL(cast_on.legcuffed)

	cast_on.apply_status_effect(/datum/status_effect/heretic_lastresort)
	new /obj/effect/temp_visual/knockblast(get_turf(cast_on))

	for(var/mob/living/victim in get_things_to_cast_on(cast_on, radius_override = 1))
		victim.AdjustWeakened(3 SECONDS)
		victim.AdjustParalyzed(0.5 SECONDS)

/obj/effect/proc_holder/spell/aoe/wave_of_desperation/get_things_to_cast_on(atom/center, radius_override)
	. = list()
	for(var/atom/nearby in orange(center, radius_override ? radius_override : range))
		if(nearby == owner || nearby == center || isarea(nearby))
			continue
		if(!ismob(nearby))
			. += nearby
			continue
		var/mob/living/nearby_mob = nearby
		if(!isturf(nearby_mob.loc))
			continue
		if(ishereticormonster(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		. += nearby_mob

/obj/effect/proc_holder/spell/aoe/wave_of_desperation/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!ismob(victim))
		SEND_SIGNAL(owner, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, victim)

	var/atom/movable/mover = victim
	if(!istype(mover))
		return

	if(mover.anchored)
		return
	var/our_turf = get_turf(caster)
	var/throwtarget = get_edge_target_turf(our_turf, get_dir(our_turf, get_step_away(mover, our_turf)))
	mover.safe_throw_at(throwtarget, 3, 1, force = MOVE_FORCE_STRONG)

/obj/effect/temp_visual/knockblast
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	alpha = 180
	duration = 1 SECONDS

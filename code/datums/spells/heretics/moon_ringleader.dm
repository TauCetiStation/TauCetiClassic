/obj/effect/proc_holder/spell/aoe_turf/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Big AoE spell that deals brain damage and causes hallucinations to everyone in the AoE. \
			The worse their sanity, the stronger this spell becomes. \
			If their sanity is low enough, they even snap and go insane, and the spell then further halves their sanity."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	icon = 'icons/hud/actions_ecult.dmi'
	button_icon_state = "moon_ringleader"
	sound = 'sound/effects/moon_parade.ogg'

	school = SCHOOL_FORBIDDEN
	charge_max = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "R''S 'E"
	invocation_type = "shout"


	range = 5
	/// Effect for when the spell triggers
	var/obj/effect/moon_effect = /obj/effect/temp_visual/moon_ringleader

/obj/effect/proc_holder/spell/aoe_turf/moon_ringleader/cast(mob/living/caster)
	new moon_effect(get_turf(caster))
	return ..()

/obj/effect/proc_holder/spell/aoe_turf/moon_ringleader/get_things_to_cast_on(atom/center, radius_override)
	var/list/stuff = list()
	var/list/o_range = orange(center, radius_override || range) - list(owner, center)
	for(var/mob/living/carbon/nearby_mob in o_range)
		if(nearby_mob.stat == DEAD)
			continue
		if(!nearby_mob.mob_mood)
			continue
		if(ishereticormonster(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		stuff += nearby_mob

	return stuff

/obj/effect/proc_holder/spell/aoe_turf/moon_ringleader/cast_on_thing_in_aoe(mob/living/carbon/victim, mob/living/caster)
	var/victim_sanity = victim.mob_mood.sanity

	victim.adjustOrganLoss(O_BRAIN, 100 - victim_sanity, victim)
	for(var/i in 1 to round((120 - victim_sanity) / 10))
		victim.cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/body), name)
	if(victim_sanity < 15)
		victim.apply_status_effect(/datum/status_effect/moon_converted)
		caster.log_message("made [victim] insane.", LOG_GAME)
		victim.log_message("was driven insane by [caster]")
	victim.mob_mood.set_sanity(victim_sanity * 0.5)


/obj/effect/temp_visual/moon_ringleader
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "ring_leader_effect"
	alpha = 180
	duration = 6

/obj/effect/temp_visual/moon_ringleader/ringleader/atom_init()
	. = ..()
	transform = transform.Scale(10)

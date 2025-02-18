// Currently unused
/obj/effect/proc_holder/spell/in_hand/mad_touch
	name = "Touch of Madness"
	desc = "A touch spell that drains your enemy's sanity and knocks them down."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	icon = 'icons/hud/actions_ecult.dmi'
	action_icon_state = "mad_touch"

	school = SCHOOL_FORBIDDEN
	charge_max = 15 SECONDS
	invocation_type = "none"

	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

/obj/effect/proc_holder/spell/in_hand/mad_touch/is_valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		return FALSE
	var/mob/living/carbon/human/human_cast_on = cast_on
	if(!human_cast_on.mind || !human_cast_on.mob_mood || ishereticormonster(human_cast_on))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/in_hand/mad_touch/on_antimagic_triggered(obj/item/weapon/magic/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("The spell bounces off of [victim]!"),
		span_danger("The spell bounces off of you!"),
	)

/obj/effect/proc_holder/spell/in_hand/mad_touch/cast_on_hand_hit(obj/item/weapon/magic/hand, mob/living/carbon/human/victim, mob/living/carbon/caster)
	to_chat(caster, span_warning("[victim.name] has been cursed!"))
	SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)
	return TRUE

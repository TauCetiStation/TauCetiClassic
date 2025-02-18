/obj/effect/proc_holder/spell/pointed/blood_siphon
	name = "Blood Siphon"
	desc = "A targeted spell that heals your wounds while damaging the enemy. \
		It has a chance to transfer wounds between you and your enemy."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	icon = 'icons/hud/actions_ecult.dmi'
	action_icon_state = "blood_siphon"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	charge_max = 15 SECONDS

	invocation = "FL'MS O'ET'RN'ITY."
	invocation_type = "whisper"


	cast_range = 6

/obj/effect/proc_holder/spell/pointed/blood_siphon/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/obj/effect/proc_holder/spell/pointed/blood_siphon/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)

/obj/effect/proc_holder/spell/pointed/blood_siphon/cast(mob/living/cast_on)
	. = ..()
	playsound(owner, 'sound/effects/demon_attack1.ogg', 75, TRUE)
	if(cast_on.can_block_magic())
		owner.balloon_alert(owner, "spell blocked!")
		cast_on.visible_message(
			span_danger("The spell bounces off of [cast_on]!"),
			span_danger("The spell bounces off of you!"),
		)
		return FALSE

	cast_on.visible_message(
		span_danger("[cast_on] turns pale as a red glow envelops [P_THEM(cast_on)]!"),
		span_danger("You pale as a red glow enevelops you!"),
	)

	var/mob/living/living_owner = owner
	cast_on.adjustBruteLoss(20)
	living_owner.adjustBruteLoss(-20)

	if(!cast_on.blood_volume || !living_owner.blood_volume)
		return TRUE

	cast_on.blood_volume -= 20
	if(living_owner.blood_volume < BLOOD_VOLUME_MAXIMUM) // we dont want to explode from casting
		living_owner.blood_volume += 20

	if(!iscarbon(cast_on) || !iscarbon(owner))
		return TRUE

	var/mob/living/carbon/carbon_target = cast_on
	var/mob/living/carbon/carbon_user = owner
	for(var/obj/item/organ/external/bodypart as anything in carbon_user.bodyparts)
		for(var/datum/wound/iter_wound as anything in bodypart.wounds)
			if(prob(50))
				continue
			var/obj/item/organ/external/target_bodypart = locate(bodypart.type) in carbon_target.bodyparts
			if(!target_bodypart)
				continue
			iter_wound.remove_wound()
			iter_wound.apply_wound(target_bodypart)

	return TRUE

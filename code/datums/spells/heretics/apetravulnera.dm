/obj/effect/proc_holder/spell/pointed/apetra_vulnera
	name = "Apetra Vulnera"
	desc = "Causes severe bleeding on every limb of a target which has more than 15 brute damage. \
		Wounds a random limb if no limb is sufficiently damaged."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	icon = 'icons/hud/actions_ecult.dmi'
	icon_state = "apetra_vulnera"

	school = SCHOOL_FORBIDDEN
	charge_max = 45 SECONDS

	invocation = "AP'TRA VULN'RA!"
	invocation_type = "whisper"


	//cast_range = 4 -- cause idk what that var do, we're maybe fix it sometime in tests

	/// What type of wound we apply
	var/wound_type = /datum/wound/slash/flesh/critical/cleave

/obj/effect/proc_holder/spell/pointed/apetra_vulnera/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/obj/effect/proc_holder/spell/pointed/apetra_vulnera/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(ishereticormonster(cast_on))
		return FALSE

	if(!cast_on.blood_volume)
		return FALSE

	if(cast_on.can_block_magic(antimagic_flags))
		cast_on.visible_message(
			span_danger("[cast_on]'s bruises briefly glow, but repels the effect!"),
			span_danger("Your bruises sting a little, but you are protected!")
		)
		return FALSE

	var/a_limb_got_damaged = FALSE
	for(var/obj/item/bodypart/bodypart in cast_on.bodyparts)
		if(bodypart.brute_dam < 15)
			continue
		a_limb_got_damaged = TRUE
		var/datum/wound/slash/crit_wound = new wound_type()
		crit_wound.apply_wound(bodypart)

	if(!a_limb_got_damaged)
		var/datum/wound/slash/crit_wound = new wound_type()
		crit_wound.apply_wound(pick(cast_on.bodyparts))

	cast_on.visible_message(
		span_danger("[cast_on]'s scratches and bruises are torn open by an unholy force!"),
		span_danger("Your scratches and bruises are torn open by some horrible unholy force!")
	)

	new /obj/effect/temp_visual/cleave(get_turf(cast_on))

	return TRUE

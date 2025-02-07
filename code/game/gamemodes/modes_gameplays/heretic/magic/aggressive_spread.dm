/obj/effect/proc_holder/spell/aoe/rust_conversion
	name = "Aggressive Spread"
	desc = "Spreads rust onto nearby surfaces."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	icon = 'icons/hud/actions_ecult.dmi'
	button_icon_state = "corrode"
	sound = 'sound/items/Welder.ogg'

	school = SCHOOL_FORBIDDEN
	charge_max = 30 SECONDS

	invocation = "A'GRSV SPR'D"
	invocation_type = "whisper"

	range = 2

/obj/effect/proc_holder/spell/aoe/rust_conversion/get_things_to_cast_on(atom/center)

	var/list/things_to_convert = RANGE_TURFS(range, center)

	// Also converts things right next to you.
	for(var/atom/movable/nearby_movable in view(1, center))
		if(nearby_movable == owner || !isstructure(nearby_movable) )
			continue
		things_to_convert += nearby_movable

	return things_to_convert

/obj/effect/proc_holder/spell/aoe/rust_conversion/cast_on_thing_in_aoe(turf/victim, mob/living/caster)
	// We have less chance of rusting stuff that's further
	var/distance_to_caster = get_dist(victim, caster)
	var/chance_of_not_rusting = (max(distance_to_caster, 1) - 1) * 100 / (range + 1)

	if(prob(chance_of_not_rusting))
		return

	if(ismob(caster))
		caster.do_rust_heretic_act(victim)
	else
		victim.rust_heretic_act()

/obj/effect/proc_holder/spell/aoe/rust_conversion/construct
	name = "Construct Spread"
	charge_max = 15 SECONDS

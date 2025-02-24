// Given to heretic monsters.
/obj/effect/proc_holder/spell/emp/eldritch
	name = "Energetic Pulse"
	desc = "A spell that causes a large EMP around you, disabling electronics."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	charge_max = 30 SECONDS

	invocation = "E'P"
	invocation_type = "whisper"

	var/emp_heavy = 2
	var/emp_light = 3

/obj/effect/proc_holder/spell/emp/eldritch/cast(list/targets)

	for(var/mob/living/target in targets)
		empulse(target.loc, emp_heavy, emp_light, custom_effects = EMP_SEBB)

	return

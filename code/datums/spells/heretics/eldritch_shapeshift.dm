// Given to heretic monsters.
/obj/effect/proc_holder/spell/no_target/shapeshift/eldritch
	name = "Shapechange"
	desc = "A spell that allows you to take on the form of another creature, gaining their abilities. \
		After making your choice, you will be unable to change to another."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	invocation = "SH'PE"
	invocation_type = "whisper"


	possible_shapes = list(
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/cat,
		/mob/living/simple_animal/corgi,
		/mob/living/simple_animal/fox
	)

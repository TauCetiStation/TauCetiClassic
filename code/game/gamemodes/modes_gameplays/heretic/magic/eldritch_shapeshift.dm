// Given to heretic monsters.
/obj/effect/proc_holder/spell/shapeshift/eldritch
	name = "Shapechange"
	desc = "A spell that allows you to take on the form of another creature, gaining their abilities. \
		After making your choice, you will be unable to change to another."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	invocation = "SH'PE"
	invocation_type = "whisper"


	possible_shapes = list(
		/mob/living/basic/carp,
		/mob/living/basic/mouse,
		/mob/living/basic/pet/cat,
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/pet/fox,
		/mob/living/simple_animal/bot/secbot,
	)

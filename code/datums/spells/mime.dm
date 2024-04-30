/obj/effect/proc_holder/spell/no_target/mime_speak
	name = "Miming"
	desc = "Make or break a vow of silence."
	panel = "Mime"
	clothes_req = FALSE
	charge_max = 5 MINUTES
	action_icon_state = "mime_speech"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/no_target/mime_speak/can_cast(mob/living/carbon/human/user = usr)
	return istype(user) && ..()

/obj/effect/proc_holder/spell/no_target/mime_speak/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!HAS_TRAIT(user, TRAIT_MIMING))
		name = "Start miming"
		ADD_TRAIT(user, TRAIT_MIMING, GENERIC_TRAIT)
		to_chat(user, "<span class='warning'>You break your vow of silence.</span>")
	else
		name = "Stop miming"
		REMOVE_TRAIT(user, TRAIT_MIMING, GENERIC_TRAIT)
		to_chat(user, "<span class='notice'>You make a vow of silence.</span>")

/obj/effect/proc_holder/spell/targeted/forcewall/mimewall
	name = "Invisible wall"
	desc = "Create an invisible wall on your location."
	panel = "Mime"
	charge_max = 1 MINUTE
	sound = null
	invocation_type = "none"
	summon_path = /obj/effect/forcefield/magic/mime
	action_icon_state = "invisible_wall"
	action_background_icon_state = "bg_mime"

/obj/effect/proc_holder/spell/targeted/forcewall/mimewall/can_cast(mob/living/carbon/human/user = usr)
	return HAS_TRAIT(user, TRAIT_MIMING) && ..()

/obj/effect/proc_holder/spell/targeted/forcewall/mimewall/perform(list/targets, recharge, mob/living/carbon/human/user = usr)
	if(!HAS_TRAIT(user, TRAIT_MIMING))
		to_chat(user, "<span class='warning'>You must dedicate yourself to silence first!</span>")
		revert_cast(user)
		return
	..()

/obj/effect/proc_holder/spell/targeted/forcewall/mimewall/cast(list/targets, mob/living/carbon/human/user = usr)
	user.visible_message("<span class='notice'>[user] looks as if a wall is in front of them.</span>", "You form a wall in front of yourself.")
	new summon_path(get_turf(user), user, 1 MINUTE)

/obj/effect/forcefield/magic/mime
	icon_state = "empty"
	name = "invisible wall"
	desc = "You have a bad feeling about this."

/obj/effect/forcefield/magic/mime/atom_init(mapload, mob/wiz, timeleft = 300)
	. = ..()
	var/image/I = image('icons/turf/walls/riveted.dmi', src, "box")
	I.override = TRUE
	I.alpha = 160
	I.layer = INFRONT_MOB_LAYER
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/mime, "mime_wall", I)

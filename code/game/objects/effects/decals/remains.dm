/obj/effect/decal/remains/human
	name = "remains"
	desc = "They look like human remains. They have a strange aura about them."
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains1"
	anchored = FALSE

/obj/effect/decal/remains/human/atom_init()
	icon_state = "remains[rand(1, 3)]"
	. = ..()

/obj/effect/decal/remains/human/burned
	name = "burned remains"
	desc = "They look like burned human remains. They have a strange aura about them."
	color = "#bababa"

/obj/effect/decal/remains/xeno
	name = "remains"
	desc = "They look like the remains of something... alien. They have a strange aura about them."
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'
	icon_state = "xenoremains"
	anchored = FALSE

/obj/effect/decal/remains/xeno/burned
	name = "burned remains"
	desc = "They look like burned remains of something... alien. They have a strange aura about them."
	color = "#bababa"

/obj/effect/decal/remains/robot
	name = "remains"
	desc = "They look like the remains of something mechanical. They have a strange aura about them."
	gender = PLURAL
	icon = 'icons/mob/robots.dmi'
	icon_state = "remainsrobot"
	anchored = FALSE

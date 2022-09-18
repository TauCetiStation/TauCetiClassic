/obj/effect/temp_visual/cult
	randomdir = FALSE
	duration = 10

/obj/effect/temp_visual/cult/sparks
	randomdir = TRUE
	name = "blood sparks"
	icon_state = "bloodsparkles"

/obj/effect/temp_visual/cult/blood
	name = "blood jaunt"
	duration = 12
	icon_state = "bloodin"

/obj/effect/temp_visual/cult/blood/out
	icon_state = "bloodout"

/obj/effect/temp_visual/religion/pulse
	icon_state = "religion_pulse"
	duration = 11
	color = "#ffff00"

/obj/effect/temp_visual/heal
	name = "healing glow"
	icon_state = "heal"
	duration = 15

/obj/effect/temp_visual/heal/atom_init(colors)
	. = ..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)

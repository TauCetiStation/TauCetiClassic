/particles/cargo_infill
	icon = 'icons/effects/particles/cargo_infill.dmi'
	icon_state = "infill4"

	width = 100
	height = 100

	count = 25
	spawning = 100

	lifespan = 15
	fadein = 2
	fade = 5

	position = generator("box", list(-8, -8, 0), list(8, 8, 0))
	velocity = generator("box", list(-5, 3, 0), list(5, 7, 0), "UNIFORM_RAND")

	gravity = list(0, -0.85, 0)
	friction = 0.25
	spin = generator("num", -30, 30, "SQUARE_RAND")

	scale = generator("num", 0.75, 1, "SQUARE_RAND")

/particles/cargo_infill/New()
	..()
	color = pick("#ffffff", "#ffccff", "#ffcccc", "#ffffcc", "#ccffcc", "#ccffff", "#ccecff")


/particles/cracker
	icon = 'icons/effects/particles/cargo_infill.dmi'
	icon_state = list("infill1", "infill2", "infill3", "infill4")

	width = 300
	height = 300

	count = 50
	spawning = 100

	lifespan = 30
	fade = 15

	gravity = list(0, -1, 0)
	friction = generator("num", 0.6, 0.9, "UNIFORM_RAND")

	rotation = generator("num", -45, 45, "UNIFORM_RAND")
	spin = generator("num", -15, 15, "UNIFORM_RAND")
	scale = generator("num", 0.5, 0.75, "UNIFORM_RAND")

	drift = generator("circle", 3, 5, "UNIFORM_RAND")

/particles/cracker/New()
	..()

	color = generator("color", "#000000", "#0000ff", LINEAR_RAND) + generator("color", "#000000", "#00ff00", LINEAR_RAND) + generator("color", "#000000", "#ff0000", LINEAR_RAND)

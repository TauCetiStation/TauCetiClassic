/particles/cargo_infill
	icon = 'icons/effects/particles/cargo_infill.dmi'
	icon_state = list("infill1" = 20, "infill2" = 10, "infill3" = 10, "infill4" = 60)

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

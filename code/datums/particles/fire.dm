/particles/smoke
	icon = 'icons/effects/particles/fire.dmi'
	icon_state = list("fire1", "fire2", "fire3")

	width = 100
	height = 100

	count = 50
	spawning = 1

	lifespan = 50
	fadein = 5
	fade = 20

	position = generator("box", list(-3, 0, 0), list(3, 0, 0), "UNIFORM_RAND")
	gravity = list(0, 0.5)
	velocity = generator("box", list(-1, 1, 0), list(1, 2, 0), "SQUARE_RAND")
	drift = generator("vector", list(-2, 0, 0), list(2, 0, 0), "UNIFORM_RAND")
	spin = generator("num", -5, 5, "SQUARE_RAND")

	friction = 0.1

	grow = 0.1

	gradient = list("grey", "black")
	color_change = 0.1

/particles/sparkler_inner
	icon = 'icons/effects/particles/fire.dmi'
	icon_state = "fire4"

	width = 32
	height = 32

	lifespan = 1

	count = 100
	spawning = 30

	gradient = list(0, "#ffffff", 1, "#ffcc66")
	color_change = 0.5

	velocity = generator("circle", 8, 12, "UNIFORM_RAND")

/particles/sparkler_outer
	icon = 'icons/effects/particles/fire.dmi'
	icon_state = "fire4"

	width = 32
	height = 32

	lifespan = 5
	fade = 4

	count = 100
	spawning = 10

	gradient = list(0, "#ffcc66", 1, "#333333")
	color_change = 0.2

	position = generator("circle", 8, 12, "UNIFORM_RAND")

	drift = generator("circle", 3, 3, "UNIFORM_RAND")

	rotation = generator("num", -45, 45, "UNIFORM_RAND")
	spin = generator("num", -15, 15, "UNIFORM_RAND")

	grow = generator("num", 0.05, 0.1, "UNIFORM_RAND")

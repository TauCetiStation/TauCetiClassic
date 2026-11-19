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

/particles/suit_storage_mist
	icon = 'icons/effects/particles/clouds.dmi'
	icon_state = list("cloud1", "cloud2", "cloud3")

	width = 100
	height = 100

	count = 30
	spawning = 100

	lifespan = 10
	fade = 25

	position = generator("square", 8, 8, "UNIFORM_RAND")
	gravity = list(0, 0.5)
	velocity = generator("box", list(100, 100, 0), list(-100, -100, 0), "SQUARE_RAND")
	drift = generator("box", list(50, 50, 0), list(-50, -50, 0), "UNIFORM_RAND")

	rotation = generator("num", -45, 45, "UNIFORM_RAND")
	spin = generator("num", -15, 15, "UNIFORM_RAND")

	friction = 1
	gravity = list(0, -9.81)

	scale = 0.25
	grow = 0.1

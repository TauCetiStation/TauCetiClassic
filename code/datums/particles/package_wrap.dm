/particles/package_wrap
	icon = 'icons/effects/particles/package_wrap.dmi'
	icon_state = list("package1", "package2", "package3", "package4")

	width = 100
	height = 100

	count = 5
	spawning = 100

	lifespan = 10
	fadein = 2
	fade = 5

	position = generator("box", list(-8, -8, 0), list(8, 8, 0))
	velocity = generator("box", list(-3, -3, 0), list(3, -3, 0), "SQUARE_RAND")

	scale = generator("num", 0.75, 1, "UNIFORM_RAND")

	rotation = generator("num", -45, 45, "UNIFORM_RAND")
	spin = generator("num", -15, 15, "UNIFORM_RAND")

	gravity = list(0, -0.2, 0)
	friction = 0.3

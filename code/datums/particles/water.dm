/particles/drinking_fountain
	width = 100
	height = 100

	count = 25
	spawning = 2

	lifespan = 10
	fade = 5

	position = list(-1, 4)
	velocity = generator("vector", list(-1.5, 5, 0), list(1.5, 5, 0), "NORMAL_RAND")

	gravity = list(0, -1, 0)
	friction = 0.5

	gradient = list("#336699", "#ffffff")
	color_change = 0.1

/particles/splash
	width = 100
	height = 100

	count = 15
	spawning = 50

	lifespan = 10
	fade = 25

	position = list(0, 0)
	velocity = generator("box", list(-12, 4, 0), list(12, 0, 0), "UNIFORM_RAND")

	gravity = list(0, -0.75, 0)
	friction = generator("num", 0.3, 0.5, "UNIFORM_RAND")

	rotation = generator("num", -45, 45, "UNIFORM_RAND")
	spin = generator("num", -5, 5, "UNIFORM_RAND")

/particles/splash/slime
	icon = 'icons/effects/particles/clouds.dmi'
	icon_state = list("cloud1", "cloud2", "cloud3")

	scale = 0.3
	grow = 0.05

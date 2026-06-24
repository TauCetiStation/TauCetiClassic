/particles/sleeper_mist
	width = 100
	height = 100

	count = 25
	spawning = 1

	lifespan = generator("num", 10, 20, "NORMAL_RAND")
	fade = generator("num", 5, 15, "NORMAL_RAND")
	fadein = generator("num", 15, 25, "NORMAL_RAND")

	icon = 'icons/effects/particles/clouds.dmi'
	icon_state = list("cloud1", "cloud2", "cloud3")

	color = "#ffffff33"

	position = generator("box", list(-16, 4), list(16, -8), "NORMAL_RAND")
	grow = generator("num", 0.15, 0.25, "NORMAL_RAND")
	rotation = generator("num", -45, 45, "NORMAL_RAND")
	spin = generator("num", -5, 5, "NORMAL_RAND")

	gravity = list(0, -0.25)
	friction = 0.5

	drift = generator("vector", list(1, 0), list(-1, 0), "NORMAL_RAND")

/particles/sleeper_mist/opendoor
	count = 50
	spawning = 50

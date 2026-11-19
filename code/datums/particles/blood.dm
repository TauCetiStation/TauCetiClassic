/particles/blood_squirt
	width = 1000
	height = 1000

	icon = 'icons/effects/particles/clouds.dmi'
	icon_state = list("cloud1", "cloud2", "cloud3")

	count = 250
	spawning = 300

	lifespan = 5
	fade = 5

	velocity = generator("vector", list(0, 32), list(0, 26), "UNIFORM_RAND")

	gravity = list(0, -9.81, 0)
	friction = generator("num", 0.55, 1, "UNIFORM_RAND")
	color = "#dd000099"

	scale = 0.3

	position = generator("box", list(1, 1), list(-1, -1), "UNIFORM_RAND")

/particles/blood_hit
	width = 200
	height = 200

	icon = 'icons/effects/particles/clouds.dmi'
	icon_state = list("cloud1", "cloud2", "cloud3")

	count = 10
	spawning = 100

	lifespan = 5
	fade = 20

	velocity = generator("vector", list(-6, 32), list(6, 32), "UNIFORM_RAND")

	friction = generator("num", 0.5, 0.6, "UNIFORM_RAND")
	color = "#dd000099"

	scale = 0.25
	grow = generator("num", 0.3, 0.5, "UNIFORM_RAND")

	rotation = generator("num", -45, 45, "UNIFORM_RAND")
	spin = generator("num", -15, 15, "UNIFORM_RAND")

	position = generator("box", list(1, 1), list(-1, -1), "UNIFORM_RAND")

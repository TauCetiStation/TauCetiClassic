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

/particles/turf_fire
	icon = 'icons/effects/particles/clouds.dmi'
	icon_state = list("cloud1", "cloud2", "cloud3")

	width = 150
	height = 150

	count = 150
	spawning = 30

	lifespan = generator("num", 5, 10, "UNIFORM_RAND")
	fadein = generator("num", 0, 5, "UNIFORM_RAND")
	fade = generator("num", 3, 5, "UNIFORM_RAND")

	position = generator("box", list(-16, -16, 100), list(16, 16, 150), "UNIFORM_RAND")
	gravity = list(0, 0.5)
	velocity = list(0,0,-0.5)
	drift = generator("box", list(-0.5, 0.05, -0.1), list(0.5, 0.05, 0.1), "UNIFORM_RAND")

	friction = generator("num", 0.1, 0.2, "UNIFORM_RAND")

	gradient = list(0,"#ffffff",1,"#ffffc2",3,"#fb722d",7,"#ff3110")
	color_change = generator("num", 0.5, 0.75, "UNIFORM_RAND")

/particles/turf_fire/stage_0
	count = 100
	spawning = 20
	color_change = generator("num", 0.75, 1.5, "UNIFORM_RAND")
	drift = generator("box", list(-0.5, 0.01, -0.1), list(0.5, 0.01, 0.1), "UNIFORM_RAND")
	lifespan = generator("num", 7, 10, "UNIFORM_RAND")

/particles/turf_fire/stage_2
	count = 200
	spawning = 40
	color_change = generator("num", 0.1, 0.5, "UNIFORM_RAND")
	drift = generator("box", list(-0.5, 0.25, -0.1), list(0.5, 0.25, 0.1), "UNIFORM_RAND")
	lifespan = generator("num", 3, 5, "UNIFORM_RAND")
	fade = generator("num", 2, 3, "UNIFORM_RAND")

/particles/turf_fire/stage_3
	count = 250
	spawning = 50
	color_change = generator("num", 0.01, 0.1, "UNIFORM_RAND")
	drift = generator("box", list(-0.5, 0.5, -0.1), list(0.5, 0.5, 0.1), "UNIFORM_RAND")
	lifespan = generator("num", 1, 3, "UNIFORM_RAND")
	fade = generator("num", 1, 2, "UNIFORM_RAND")

/particles/turf_smoke
	icon = 'icons/effects/particles/clouds.dmi'
	icon_state = list("cloud1", "cloud2", "cloud3")

	width = 150
	height = 150

	count = 150
	spawning = 30

	lifespan = generator("num", 5, 10, "UNIFORM_RAND")
	fadein = generator("num", 5, 10, "UNIFORM_RAND")
	fade = generator("num", 5, 15, "UNIFORM_RAND")

	position = generator("box", list(-20, 0, 10), list(20, 24, 50), "UNIFORM_RAND")
	gravity = list(0, 0.2)
	velocity = generator("box", list(-0.25, 0.25, -0.5), list(0.25, 0.25, -0.25), "UNIFORM_RAND")
	drift = generator("box", list(-0.5, 0.1, -0.1), list(0.5, 0.1, 0.1), "UNIFORM_RAND")

	friction = 0.1

	gradient = list(0,"#333333",3,"#000000")
	color_change = generator("num", 0.1, 0.3, "UNIFORM_RAND")

/particles/mist
	icon = 'icons/effects/particles/clouds.dmi'
	icon_state = list("cloud1", "cloud2", "cloud3")

	width = 100
	height = 100

	count = 30
	spawning = 100

	lifespan = 10
	fade = 25
	fadein = 3

	velocity = generator("box", list(100, 100, 0), list(-100, -100, 0), "SQUARE_RAND")
	drift = generator("box", list(50, 50, 0), list(-50, -50, 0), "UNIFORM_RAND")

	rotation = generator("num", -45, 45, "UNIFORM_RAND")
	spin = generator("num", -15, 15, "UNIFORM_RAND")

	friction = 1
	gravity = list(0, -5)

	scale = 0.25
	grow = 0.1

/particles/mist/vent
	spawning = 2
	lifespan = 15
	gravity = list(0, 8)
	position = generator("box", list(-7, -7), list(7, 7), "UNIFORM_RAND")

/particles/mist/cryotube
	height = 300
	count = 60
	position = generator("box", list(-5, 3), list(5, 41), "UNIFORM_RAND")

/particles/mist/freezer
	position = generator("box", list(-12, -10), list(12, 1), "UNIFORM_RAND")

/particles/mist/fridge
	position = generator("box", list(-12, -14), list(12, 8), "UNIFORM_RAND")

/particles/mist/canister
	spawning = 1
	lifespan = 15
	position = generator("box", list(-8, -16), list(8, 6), "UNIFORM_RAND")

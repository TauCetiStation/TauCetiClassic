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

/particles/turf_fire/cold
	count = 100
	spawning = 20
	color_change = generator("num", 0.75, 1.5, "UNIFORM_RAND")
	drift = generator("box", list(-0.5, 0.01, -0.1), list(0.5, 0.01, 0.1), "UNIFORM_RAND")
	lifespan = generator("num", 7, 10, "UNIFORM_RAND")

/particles/turf_fire/hot
	count = 200
	spawning = 40
	color_change = generator("num", 0.1, 0.5, "UNIFORM_RAND")
	drift = generator("box", list(-0.5, 0.25, -0.1), list(0.5, 0.25, 0.1), "UNIFORM_RAND")
	lifespan = generator("num", 3, 5, "UNIFORM_RAND")
	fade = generator("num", 2, 3, "UNIFORM_RAND")

/particles/turf_fire/phoron
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

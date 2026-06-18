/particles/leaves
	icon = 'icons/effects/particles/leaves.dmi'
	icon_state = list("leaf1", "leaf2", "leaf3", "leaf4", "leaf5")

	width = 256
	height = 256

	count = 50
	spawning = 0.0375

	lifespan = 100
	fadein = 10
	fade = 25

	position = generator("box", list(0, 128, 0), list(96, 64, 0), "SQUARE_RAND")
	gravity = list(0, -0.25)
	drift = generator("vector", list(-1, 0, 0), list(1, 0, 0), "UNIFORM_RAND")
	spin = generator("num", -15, 15, "UNIFORM_RAND")

	friction = 0.3

/particles/leaves/small
	lifespan = 50

	position = generator("box", list(0, 80, 0), list(96, 32, 0), "SQUARE_RAND")

/particles/leaves/hit
	spawning = 50

	position = generator("box", list(-48, 108, 0), list(48, 44, 0), "SQUARE_RAND")

/particles/leaves/small/hit
	spawning = 50

	position = generator("box", list(-32, 80, 0), list(64, 32, 0), "SQUARE_RAND")

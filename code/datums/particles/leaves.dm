/particles/leaves
	icon = 'icons/effects/particles/leaves.dmi'
	icon_state = list("leaf1", "leaf2", "leaf3", "leaf4", "leaf5")

	width = 512
	height = 512

	count = 50
	spawning = 0.05

	lifespan = 100
	fadein = 10
	fade = 25

	position = generator("box", list(0, 128, 0), list(96, 64, 0), "SQUARE_RAND")
	gravity = list(0, -0.25)
	drift = generator("vector", list(-1, 0, 0), list(1, 0, 0), "UNIFORM_RAND")
	spin = generator("num", -15, 15, "UNIFORM_RAND")

	friction = 0.3

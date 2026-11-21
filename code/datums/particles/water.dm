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

/particles/droplet
	width = 32
	height = 32

	icon = 'icons/effects/particles/misc.dmi'
	icon_state = "droplet"

	count = 3
	spawning = 0.1

	lifespan = 5
	fade = 1

	position = generator("box", list(-8, -8, 0), list(8, 8, 0), "UNIFORM_RAND")

	gravity = list(0, 5, 0)
	velocity = list(0, -4.5, 0)
	drift = list(0, -2.5, 0)

	scale = 0.5
	grow = 0.05

/particles/droplet/tank
	position = generator("box", list(1, -6, 0), list(12, 6, 0), "UNIFORM_RAND")

/particles/droplet/coolant
	position = generator("vector", list(-1, -10, 0), list(0, -10, 0), "UNIFORM_RAND")

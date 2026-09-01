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

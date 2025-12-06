/particles/papameat
	icon = 'icons/effects/particles/meat.dmi'
	icon_state = list("1", "2", "3", "4", "5")

	width = 256
	height = 256

	count = 15
	spawning = 15

	lifespan = 30
	fadein = 5
	fade = 20

	position = generator("box", list(42, 52, 0), list(52, 62, 0), "UNIFORM_RAND")
	gravity = list(0, -0.15)
	velocity = generator("box", list(2, 3, 0), list(-2, 1, 0), "SQUARE_RAND")
	spin = generator("num", -5, 5, "SQUARE_RAND")

	grow = 0.01

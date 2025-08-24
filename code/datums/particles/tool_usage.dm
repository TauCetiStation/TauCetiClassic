/particles/proc/change_dir(newDir)
	return

/particles/tool
	icon = 'icons/effects/particles/tools.dmi'

	width = 100
	height = 100

	count = 3
	spawning = 0.25

	lifespan = 10
	fadein = 2
	fade = 5

	position = generator("box", list(-2, -4, 0), list(2, -0, 0))
	velocity = generator("box", list(-3, 2, 0), list(3, 4, 0), "SQUARE_RAND")

	gravity = list(0, -0.85, 0)
	friction = 0.1
	spin = generator("num", -7, 7, "SQUARE_RAND")

/particles/tool/New(usageDir)
	..()

/particles/tool/change_dir(newDir)
	if(!newDir)
		return

	var/offsetX = X_OFFSET(8, newDir)
	var/offsetY = Y_OFFSET(8, newDir)

	position = generator("box", list(-2 + offsetX, -4 + offsetY, 0), list(2 + offsetX, -0 + offsetY, 0))

/particles/tool/wrench
	icon_state = list("wrench1", "wrench2", "wrench3", "wrench4", "wrench5")

/particles/tool/screw
	icon_state = list("screw1", "screw2", "screw3", "screw4", "screw5", "screw6")

/particles/tool/cut
	icon_state = list("cut1", "cut2", "cut3", "cut4", "cut5", "cut6", "cut7", "cut8", "cut9", "cut10", "cut11", "cut12")

/particles/tool/generic
	icon_state = list("generic1")



/particles/tool/digging
	count = 5
	spawning = 5
	scale = list(0.75, 0.75)

	icon = 'icons/effects/particles/mining.dmi'
	icon_state = list("rock1", "rock2", "rock3", "rock4", "rock5", "rock6", "rock7", "rock8")

/particles/tool/digging/trash
	icon = 'icons/obj/structures/scrap/trash.dmi'
	icon_state = list("base1", "base2", "base3", "base4", "base5", "base6", "base7", "base8", "base9", "base10", "base11", "base12", "base13", "base14", "base15", "base16", "base17", "base18")

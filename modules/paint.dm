/obj/effect/decal/cleanable/toilet_paint
	name = "lettering"
	desc = "A lettering."
	layer = 2.1
	anchored = 1

	New(main = random_color(),shade = random_color())
		..()

		var/type = pick("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa")

		var/icon/mainOverlay = new/icon('icons/effects/crayondecal.dmi',"[type]",2.1)
		var/icon/shadeOverlay = new/icon('icons/effects/crayondecal.dmi',"[type]s",2.1)

		mainOverlay.Blend(main,ICON_ADD)
		shadeOverlay.Blend(shade,ICON_ADD)

		overlays += mainOverlay
		overlays += shadeOverlay
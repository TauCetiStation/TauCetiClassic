/obj/effect/overlay
	name = "overlay"
	unacidable = 1
	var/i_attached //Added for possible image attachments to objects. For hallucinations and the like.

/obj/effect/overlay/attackby()
	return

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	var/tmp/atom/BeamSource

/obj/effect/overlay/beam/atom_init()
	. = ..()
	QDEL_IN(src, 10)

/obj/effect/overlay/palmtree_r
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm1"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/palmtree_l
	name = "Palm tree"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "palm2"
	density = 1
	layer = 5
	anchored = 1

/obj/effect/overlay/coconut
	name = "Coconuts"
	icon = 'icons/misc/beach.dmi'
	icon_state = "coconuts"

/obj/effect/overlay/wall_rot
	name = "Wallrot"
	desc = "Ick..."
	icon = 'icons/effects/wallrot.dmi'
	anchored = TRUE
	density = TRUE
	mouse_opacity = 0

/obj/effect/overlay/wall_rot/atom_init()
	..()
	pixel_x += rand(-10, 10)
	pixel_y += rand(-10, 10)

/obj/effect/overlay/singularity_act()
	return

/obj/effect/overlay/singularity_pull()
	return

/obj/effect/overlay/slice
	name = "Slice"
	icon = 'icons/effects/effects.dmi'
	icon_state = "Slice"
	layer = LIGHTING_LAYER + 1
	plane = LIGHTING_PLANE + 1
	anchored = 1

/obj/effect/overlay/droppod_open
	layer = 4
	plane = 4
	anchored = 1
	icon = 'icons/obj/structures/droppod.dmi'
	icon_state = "panel_opening"

/obj/effect/overlay/droppod_open/atom_init(mapload, icon_modifier)
	. = ..()
	if(icon_modifier)
		icon_state += icon_modifier
	QDEL_IN(src, 27)

/obj/effect/overlay
	name = "overlay"
	unacidable = 1
	var/i_attached//Added for possible image attachments to objects. For hallucinations and the like.

	/obj/effect/overlay/attackby()
		return

/obj/effect/overlay/beam//Not actually a projectile, just an effect.
	name="beam"
	icon='icons/effects/beam.dmi'
	icon_state="b_beam"
	var/tmp/atom/BeamSource
	New()
		..()
		spawn(10) qdel(src)

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

/obj/effect/overlay/cult
	var/duration = 10
	icon = 'icons/effects/effects.dmi'
	layer = LIGHTING_LAYER + 1
	plane = LIGHTING_PLANE + 1

/obj/effect/overlay/cult/New(loc, set_dir)
	if(set_dir)
		dir = set_dir
	..()
	spawn(duration)
		qdel(src)

/obj/effect/overlay/cult/sparks
	name = "blood sparks"
	icon_state = "bloodsparkles"

/obj/effect/overlay/cult/phase
	name = "phase glow"
	icon_state = "cultin"
	duration = 8

/obj/effect/overlay/cult/phase/out
	icon_state = "cultout"

/obj/effect/overlay/cult/floor
	icon_state = "floorglow"
	duration = 5

/obj/effect/overlay/cult/door
	name = "unholy glow"
	icon_state = "doorglow"
	layer = 21 //above closed doors

/obj/effect/overlay/cult/sac
	name = "maw of Nar-Sie"
	icon_state = "sacconsume"

/obj/effect/overlay/cult/heal //color is white by default, set to whatever is needed
	name = "healing glow"
	icon_state = "heal"
	duration = 15

/obj/effect/overlay/cult/heal/New(loc, colour)
	..()
	pixel_x = rand(-12, 12)
	pixel_y = rand(-9, 0)
	if(colour)
		color = colour
// todo: we can save more on objects if we redo windowsills and fulltile windows as turfs
/obj/structure/windowsill
	name = "windowsill"
	desc = "A windowsill. You can mount a window on it."
	icon = 'icons/obj/smooth_structures/windows/window_sill.dmi'
	icon_state = "box"

	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	throwpass = TRUE
	climbable = TRUE

	smooth = SMOOTH_TRUE
	canSmoothWith = CAN_SMOOTH_WITH_WALLS
	smooth_adapters = SMOOTH_ADAPTERS_WALLS

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

/obj/structure/window/fulltile
	name = "fulltile window"
	icon = 'icons/obj/smooth_structures/windows/placeholder.dmi' // todo: placeholder icon
	icon_state = "box"

	dir = 5 // todo

	smooth = SMOOTH_TRUE
	canSmoothWith = CAN_SMOOTH_WITH_WALLS
	smooth_adapters = SMOOTH_ADAPTERS_WALLS

	// has own smoothing algoritm
	var/smooth_icon_windowstill = 'icons/obj/smooth_structures/windows/window_sill.dmi'
	var/smooth_icon_window = 'icons/obj/smooth_structures/windows/window.dmi'
	var/smooth_icon_grille = 'icons/obj/smooth_structures/grille.dmi'

	var/grilled = TRUE
	var/glass_color

/obj/structure/window/fulltile/atom_init()
	. = ..()

	if(color) // tmp remove me
		glass_color = color
		color = null

	for(var/atom/A in get_turf(src))
		if(istype(A, /obj/structure/window) && A != src)
			world.log << "WARNING: [x].[y].[z]: type [A.type]"
		else if(istype(A, /obj/structure/grille))
			world.log << "WARNING: [x].[y].[z]: type [A.type]"

/obj/structure/window/fulltile/reinforced
	name = "reinforced fulltile window"
	icon = 'icons/obj/smooth_structures/windows/placeholder.dmi'

	smooth_icon_window = 'icons/obj/smooth_structures/windows/window_reinforced.dmi'

/obj/structure/window/fulltile/reinforced/phoron
	name = "reinforced phoron window"
	desc = "A phoron-glass alloy window, with rods supporting it. It looks hopelessly tough to break. It also looks completely fireproof, considering how basic phoron windows are insanely fireproof."
	shardtype = /obj/item/weapon/shard/phoron
	max_integrity = 600

/obj/structure/window/fulltile/reinforced/phoron/atom_init()
	. = ..()

	glass_color = BlendRGB(glass_color, "#8000FF", 0.5)

/obj/structure/window/fulltile/reinforced/phoron/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/fulltile/reinforced/tinted
	name = "reinforced tinted window"
	desc = "It looks rather strong and opaque. Might take a few good hits to shatter it."
	opacity = 1

/obj/structure/window/fulltile/reinforced/tinted/atom_init()
	. = ..()

	glass_color = BlendRGB(glass_color, "#000000", 0.7)

/obj/structure/window/fulltile/reinforced/polarized
	name = "electrochromic window"
	desc = "Adjusts its tint with voltage. Might take a few good hits to shatter it."
	var/id

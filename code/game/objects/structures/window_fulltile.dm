/*/client/verb/checksmooth() // remove me
	var/choice = tgui_input_list(src,"Choose a file to access:","Download", global.baked_smooth_icons)
	var/icon/I = global.baked_smooth_icons[choice]
	usr << ftp(I,"smooth.dmi")*/

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

	if(color)
		glass_color = color
		color = null

/obj/structure/window/fulltile/reinforced
	name = "reinforced fulltile window"
	icon = 'icons/obj/smooth_structures/windows/placeholder.dmi'

	smooth_icon_window = 'icons/obj/smooth_structures/windows/window_reinforced.dmi'

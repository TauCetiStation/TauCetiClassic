/**
 * Windowsill
 */

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

/obj/effect/fluid/update_icon()

	overlays.Cut()

	if(fluid_amount > FLUID_DEEP)
		alpha = FLUID_MAX_ALPHA
		layer = FLY_LAYER
	else
		alpha = min(FLUID_MAX_ALPHA, max(FLUID_MIN_ALPHA, ceil(255 * (fluid_amount / FLUID_DEEP))))
		layer = TURF_LAYER + 0.1

	if(fluid_amount > FLUID_DELETING && fluid_amount <= FLUID_EVAPORATION_POINT)
		overlays += get_fluid_icon("shallow_still")
	else if(fluid_amount > FLUID_EVAPORATION_POINT && fluid_amount < FLUID_SHALLOW)
		overlays += get_fluid_icon("mid_still")
	else if(fluid_amount >= FLUID_SHALLOW && fluid_amount < (FLUID_DEEP * 2))
		overlays += get_fluid_icon("deep_still")
	else if(fluid_amount >= (FLUID_DEEP * 2))
		overlays += get_fluid_icon("ocean")

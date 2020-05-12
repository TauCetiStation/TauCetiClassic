/obj/effect/fluid/update_icon()

	cut_overlays()

	if(fluid_amount > FLUID_DEEP)
		alpha = FLUID_MAX_ALPHA
		layer = FLY_LAYER
	else
		alpha = min(FLUID_MAX_ALPHA, max(FLUID_MIN_ALPHA, CEIL(255 * (fluid_amount / FLUID_DEEP))))
		layer = TURF_LAYER + 0.1

	if(fluid_amount > FLUID_DELETING && fluid_amount <= FLUID_EVAPORATION_POINT)
		add_overlay(get_fluid_icon("shallow_still"))
	else if(fluid_amount > FLUID_EVAPORATION_POINT && fluid_amount < FLUID_SHALLOW)
		add_overlay(get_fluid_icon("mid_still"))
	else if(fluid_amount >= FLUID_SHALLOW && fluid_amount < (FLUID_DEEP * 2))
		add_overlay(get_fluid_icon("deep_still"))
	else if(fluid_amount >= (FLUID_DEEP * 2))
		add_overlay(get_fluid_icon("ocean"))

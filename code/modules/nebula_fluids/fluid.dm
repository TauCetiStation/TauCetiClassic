/obj/effect/fluid_overlay
	name              = ""
	icon              = 'icons/effects/liquids_nebula.dmi'
	icon_state        = ""
	anchored          = TRUE
	simulated         = FALSE
	opacity           = FALSE
	mouse_opacity     = MOUSE_OPACITY_TRANSPARENT
	layer             = FLY_LAYER
	alpha             = 0
	color             = COLOR_LIQUID_WATER
//	is_spawnable_type = FALSE
	appearance_flags  = KEEP_TOGETHER
	var/last_update_depth
	var/updating_edge_mask
	var/force_flow_direction

//obj/effect/fluid_overlay/on_turf_height_change(new_height)
//	update_icon()
//	return TRUE

/obj/effect/fluid_overlay/update_icon()

	var/datum/reagents/loc_reagents = loc?.reagents
	var/reagent_volume = loc_reagents?.total_volume

	// Update layer.
	var/new_layer
	var/turf/flow_turf = get_turf(src)
	if(flow_turf.pixel_z < 0)
		new_layer = flow_turf.layer + 0.2
	else if(reagent_volume > FLUID_DEEP)
		new_layer = DEEP_FLUID_LAYER
	else
		new_layer = SHALLOW_FLUID_LAYER

	if(layer != new_layer)
		layer = new_layer

	// Update colour.
	var/new_color = loc_reagents?.get_master_reagent()?.color//get_color()
	if(color != new_color)
		color = new_color

	cut_overlays()
	// Update alpha.
	if(reagent_volume)

		var/datum/reagent/main_reagent = loc_reagents?.get_master_reagent()//get_primary_reagent_decl()
		var/new_alpha
		if(main_reagent) // TODO: weighted alpha from all reagents, not just primary
			new_alpha = clamp(ceil(255*(reagent_volume/FLUID_DEEP)) * main_reagent.opacity, main_reagent.min_fluid_opacity, main_reagent.max_fluid_opacity)
		else
			new_alpha = FLUID_MIN_ALPHA
		if(new_alpha != alpha)
			alpha = new_alpha

		var/flow_dir = force_flow_direction || flow_turf.last_flow_dir
		set_dir(flow_dir)
		// Update icon state. We use overlays so flick() can work on the base fluid overlay.
		if(reagent_volume <= FLUID_PUDDLE)
			add_overlay("puddle")
		else if(reagent_volume <= FLUID_SHALLOW)
			add_overlay(flow_dir ? "shallow_flow" : "shallow")
		else if(reagent_volume < FLUID_DEEP)
			add_overlay(flow_dir ? "mid_flow"     : "mid")
		else if(reagent_volume < (FLUID_DEEP*2))
			add_overlay(flow_dir ? "deep_flow"    : "deep")
		else
			add_overlay("ocean")
	//else
	//	cut_overlays()
// Define FLUID_AMOUNT_DEBUG before this to get a handy overlay of fluid amounts.
#ifdef FLUID_AMOUNT_DEBUG
	var/image/I = new()
	I.maptext = STYLE_SMALLFONTS_OUTLINE("<center>[num2text(reagent_volume)]</center>", 6, COLOR_WHITE, COLOR_BLACK)
	I.maptext_y = 8
	I.appearance_flags |= KEEP_APART
	add_overlay(I)
#endif
	//compile_overlays()

	if((last_update_depth > FLUID_PUDDLE) != (reagent_volume > FLUID_PUDDLE))

		// Update alpha masks.
		for(var/checkdir in global.alldirs)
			var/turf/neighbor = get_step(loc, checkdir)
			if(istype(neighbor) && neighbor.fluid_overlay && !neighbor.fluid_overlay.updating_edge_mask)
				neighbor.fluid_overlay.update_alpha_mask()
		if(!updating_edge_mask)
			update_alpha_mask()

		// Update everything on our atom too.
		/*if(length(loc?.contents) && (last_update_depth > FLUID_PUDDLE && last_update_depth <= FLUID_SHALLOW) != (reagent_volume <= FLUID_SHALLOW))
			for(var/atom/movable/AM in loc.contents)
				if(AM.simulated)
					AM.update_turf_alpha_mask()*/

	last_update_depth = reagent_volume

var/global/list/_fluid_edge_mask_cache = list()
/obj/effect/fluid_overlay/proc/update_alpha_mask()

	set waitfor = FALSE
	// Delay to avoid multiple updates.
	if(updating_edge_mask)
		return
	updating_edge_mask = TRUE
	sleep(0)
	updating_edge_mask = FALSE

	if(loc?.reagents?.total_volume <= FLUID_PUDDLE)
		remove_filter("fluid_edge_mask")
		return

	// Collect neighbor info.
	var/list/ignored
	var/list/connections
	for(var/checkdir in global.alldirs)
		var/turf/neighbor = get_step(loc, checkdir)
		if(!neighbor || neighbor.density || neighbor?.reagents?.total_volume > FLUID_PUDDLE)
			LAZYADD(connections, checkdir)
		else
			LAZYADD(ignored, checkdir)

	if(!length(connections))
		remove_filter("fluid_edge_mask")
		return

	// Generate and apply an alpha filter for our edges.
	// Need to use icons here due to overlays being hell with directional states.

	var/cache_key = "[length(connections) ? jointext(connections, "-") : 0]|[length(ignored) ? jointext(ignored, "-") : 0]"
	var/icon/edge_mask = global._fluid_edge_mask_cache[cache_key]
	if(isnull(edge_mask))
		connections = dirs_to_corner_states(connections)
		edge_mask = icon(icon, "blank")
		for(var/i = 1 to 4)
			if(length(connections) >= i)
				edge_mask.Blend(icon(icon, "edgemask[connections[i]]", dir = (1 << i-1)), ICON_OVERLAY)
		global._fluid_edge_mask_cache[cache_key] = edge_mask || FALSE

	if(edge_mask)
		add_filter("fluid_edge_mask", 1, list(type = "alpha", icon = edge_mask, flags = MASK_INVERSE))
	else
		remove_filter("fluid_edge_mask")

//obj/effect/fluid_overlay/Destroy()
//	var/atom/oldloc = loc
//	. = ..()
/*	if(istype(oldloc))
		for(var/atom/movable/AM in oldloc.contents)
			if(AM.simulated)
				AM.update_turf_alpha_mask()*/

#define CORNER_NONE             0
#define CORNER_COUNTERCLOCKWISE 1
#define CORNER_DIAGONAL         2
#define CORNER_CLOCKWISE        4

/proc/dirs_to_corner_states(list/dirs)
	if(!istype(dirs)) return

	var/list/ret = list(NORTHWEST, SOUTHEAST, NORTHEAST, SOUTHWEST)

	for(var/i = 1 to ret.len)
		var/dir = ret[i]
		. = CORNER_NONE
		if(dir in dirs)
			. |= CORNER_DIAGONAL
		if(turn(dir,45) in dirs)
			. |= CORNER_COUNTERCLOCKWISE
		if(turn(dir,-45) in dirs)
			. |= CORNER_CLOCKWISE
		ret[i] = "[.]"

	return ret
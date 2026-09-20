/proc/emissive_appearance(icon, icon_state = "", layer = FLOAT_LAYER, dir = null)
	var/mutable_appearance/emissive = mutable_appearance(icon, icon_state, layer)
	if(!isnull(dir))
		emissive.dir = dir
	emissive.appearance_flags |= KEEP_APART | RESET_COLOR
	emissive.add_overlay(emissive_mask_appearance(icon, icon_state, dir = dir))
	return emissive

/proc/emissive_mask_appearance(icon, icon_state = "", layer = FLOAT_LAYER, dir = null)
	var/mutable_appearance/mask = mutable_appearance(icon, icon_state, layer, EMISSIVE_MASK_PLANE)
	if(!isnull(dir))
		mask.dir = dir
	mask.appearance_flags = RESET_COLOR | KEEP_APART
	var/static/list/mask_color = list(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,255, 1,1,1,0)
	mask.color = mask_color
	return mask

var/global/mutable_appearance/emissive_visibility_mask = create_emissive_visibility_mask()

/proc/create_emissive_visibility_mask()
	var/mutable_appearance/mask = mutable_appearance('icons/blank.dmi', "white", plane = EMISSIVE_VISIBILITY_PLANE)
	mask.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | NO_CLIENT_COLOR
	mask.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	return mask

/proc/copy_without_emissive_planes(image/source)
	if(!source || source.plane == EMISSIVE_MASK_PLANE || source.plane == EMISSIVE_COLOR_PLANE)
		return null
	var/mutable_appearance/copy = new(source)
	copy.plane = source.plane
	copy.overlays = list()
	copy.underlays = list()
	for(var/image/overlay as anything in source.overlays)
		var/mutable_appearance/child = copy_without_emissive_planes(overlay)
		if(child)
			copy.overlays += child
	for(var/image/underlay as anything in source.underlays)
		var/mutable_appearance/child = copy_without_emissive_planes(underlay)
		if(child)
			copy.underlays += child
	return copy

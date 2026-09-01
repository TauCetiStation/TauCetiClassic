/**
 * # Polychromic element
 *
 * Owns the worn/world/inventory sprite assembly and dyeing for polychromic
 * jumpsuits, keeping that behaviour off /obj/item/clothing/under.
 *
 * Per-instance state (poly_style / poly_pattern / poly_colors / rolled_down)
 * stays on the item — prefs, savefiles and the character UI read it there.
 * The element is stateless and reads the state off the target.
 *
 * The worn sprite is supplied through the COMSIG_ITEM_GET_WORN_OVERLAY hook
 * (added to the base get_standing_overlay), so the clothing type needs no
 * render override. The item's own in-world/inventory icon (update_icon) and
 * dyeing still call the element directly — those paths have no signal.
 */
/datum/element/polychromic
	element_flags = ELEMENT_DETACH

/datum/element/polychromic/Attach(datum/target)
	. = ..()
	if(!isunder(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_GET_WORN_OVERLAY, PROC_REF(on_get_worn_overlay))

/datum/element/polychromic/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ITEM_GET_WORN_OVERLAY)

/datum/element/polychromic/proc/on_get_worn_overlay(obj/item/clothing/under/U, list/result, mob/living/carbon/human/H, sprite_sheet_slot, layer, bloodied_icon_state)
	SIGNAL_HANDLER
	if(sprite_sheet_slot == SPRITE_SHEET_HELD || !length(U.poly_colors))
		return
	result[1] = build_worn(U, H, layer, bloodied_icon_state)
	return COMPONENT_WORN_OVERLAY_OVERRIDE

/datum/element/polychromic/proc/make_overlay(state, color_hex = null, icon_file = 'icons/mob/uniform_poly.dmi')
	var/mutable_appearance/overlay = mutable_appearance(icon_file, state)
	if(color_hex)
		overlay.color = color_luminance_max(color_hex, 12)
	overlay.appearance_flags |= RESET_COLOR
	return overlay

/datum/element/polychromic/proc/build_worn(obj/item/clothing/under/U, mob/living/carbon/human/H, layer, bloodied_icon_state = null)
	var/datum/poly_style/eff = U.poly_style.get_effective(H)
	// Blank KEEP_TOGETHER container: the caller's update_height filter covers the flattened
	// stack as one unit, while each layer keeps its own color. The container itself must stay
	// colorless — a parent color would multiply onto the flattened children, base tinting the pattern.
	var/mutable_appearance/MA = new()
	MA.layer = layer
	MA.appearance_flags = KEEP_TOGETHER
	MA.add_overlay(make_overlay(eff.get_mob_base_state(U, H), U.poly_colors[1], U.poly_style.icon))
	for(var/mutable_appearance/overlay as anything in get_mob_overlays(U, eff, H, bloodied_icon_state))
		MA.add_overlay(overlay)
	return MA

/datum/element/polychromic/proc/get_mob_overlays(obj/item/clothing/under/U, datum/poly_style/eff, mob/living/carbon/human/H, bloodied_icon_state)
	. = list()
	var/detail_state = eff.get_mob_detail_state(U, H)
	if(detail_state)
		. += make_overlay(detail_state)
	var/pattern_state = eff.get_mob_pattern_state(U, H)
	if(pattern_state && length(U.poly_colors) >= 2)
		. += make_overlay(pattern_state, U.poly_colors[2])
	if(U.dirt_overlay && bloodied_icon_state)
		var/mutable_appearance/blood = make_overlay(bloodied_icon_state, null, 'icons/effects/blood.dmi')
		blood.color = U.dirt_overlay.color
		. += blood

/datum/element/polychromic/proc/get_inventory_overlays(obj/item/clothing/under/U)
	. = list()
	if(U.poly_pattern && length(U.poly_colors) >= 2)
		var/pat_state = U.poly_style.get_inventory_pattern_state(U)
		if(pat_state)
			. += make_overlay(pat_state, U.poly_colors[2])
	if(U.dirt_overlay)
		var/mutable_appearance/blood = make_overlay("uniformblood", null, 'icons/effects/blood.dmi')
		blood.color = U.dirt_overlay.color
		. += blood

/datum/element/polychromic/proc/get_world_overlays(obj/item/clothing/under/U)
	. = list()
	if(U.poly_pattern && length(U.poly_colors) >= 2)
		var/pat_state = U.poly_style.get_world_pattern_state(U)
		if(pat_state)
			. += make_overlay(pat_state, U.poly_colors[2])
	if(U.dirt_overlay)
		var/mutable_appearance/blood = make_overlay("uniformblood", null, 'icons/effects/blood.dmi')
		blood.color = U.dirt_overlay.color
		. += blood

/datum/element/polychromic/proc/build_icon(obj/item/clothing/under/U)
	U.cut_overlays()
	U.icon = U.poly_style.icon
	U.color = color_luminance_max(U.poly_colors[1], 12)
	if(U.flags_2 & IN_INVENTORY || U.flags_2 & IN_STORAGE)
		U.icon_state = U.poly_style.get_inventory_state()
		U.add_overlay(get_inventory_overlays(U))
	else
		U.icon_state = U.poly_style.get_world_state()
		U.add_overlay(get_world_overlays(U))
	// cut_overlays() above also wipes attached accessory overlays, restore them
	for(var/obj/item/clothing/accessory/A in U.accessories)
		U.add_overlay(A.inv_overlay)

/datum/element/polychromic/proc/try_dye(obj/item/clothing/under/U, w_color)
	var/static/list/dye_to_hex = list(
		"red"    = "#cc4444",
		"orange" = "#cc7722",
		"yellow" = "#daa520",
		"green"  = "#228b22",
		"blue"   = "#4169e1",
		"purple" = "#7b3fa0",
		"white"  = "#ffffff",
		"mime"   = "#c8c8c8"
	)
	var/hex = dye_to_hex[w_color]
	if(!hex)
		return FALSE
	U.poly_colors = list(U.poly_colors[1], hex)
	U.update_icon()
	return TRUE

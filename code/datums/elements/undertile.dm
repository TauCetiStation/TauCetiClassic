/// The alpha we give to stuff under tiles, if they want it
#define ALPHA_UNDERTILE 128

///Add to an object if you want to be able to be hidden under tiles
///If you allow object to be undertile, you need to add checks for TRAIT_UNDERFLOOR && UNDERFLOOR_INTERACTABLE for any interactions
/datum/element/undertile
	element_flags = ELEMENT_BESPOKE | COMPONENT_DUPE_HIGHLANDER
	id_arg_index = 2

	///the invisiblity trait applied, like TRAIT_T_RAY_VISIBLE
	var/invisibility_trait
	///level of invisibility applied when under a tile. Could be INVISIBILITY_OBSERVER if you still want it to be visible to ghosts
	var/invisibility_level
	///an overlay for the tile if we wish to apply that
	var/tile_overlay
	///whether we use alpha or not. TRUE uses ALPHA_UNDERTILE because otherwise we have 200 different instances of this element for different alphas
	var/use_alpha
	///We will switch between anchored and unanchored. for stuff like satchels that shouldn't be pullable under tiles but are otherwise unanchored
	var/use_anchor

/datum/element/undertile/Attach(datum/target, invisibility_trait, invisibility_level = INVISIBILITY_MAXIMUM, tile_overlay, use_alpha = TRUE, use_anchor = FALSE)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_OBJ_LEVELUPDATE, PROC_REF(hide))

	src.invisibility_trait = invisibility_trait
	src.invisibility_level = invisibility_level
	src.tile_overlay = tile_overlay
	src.use_alpha = use_alpha
	src.use_anchor = use_anchor

///called when a tile has been covered or uncovered
/datum/element/undertile/proc/hide(atom/movable/source, underfloor_accessibility)
	SIGNAL_HANDLER

	if(underfloor_accessibility < UNDERFLOOR_VISIBLE)
		source.invisibility = invisibility_level
	else
		source.invisibility = initial(invisibility_level)

	var/turf/T = get_turf(source)

	if(underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		source.plane = UNDERFLOOR_PLANE
		ADD_TRAIT(source, TRAIT_UNDERFLOOR, REF(src))

		if(tile_overlay)
			T.add_overlay(tile_overlay)

		if(use_anchor)
			source.anchored = TRUE

		if(underfloor_accessibility < UNDERFLOOR_VISIBLE)
			if(use_alpha)
				source.alpha = ALPHA_UNDERTILE

			if(invisibility_trait)
				ADD_TRAIT(source, invisibility_trait, ELEMENT_TRAIT(type))

	else
		source.plane = initial(source.plane)
		REMOVE_TRAIT(source, TRAIT_UNDERFLOOR, REF(src))

		if(invisibility_trait)
			REMOVE_TRAIT(source, invisibility_trait, ELEMENT_TRAIT(type))

		if(tile_overlay)
			T.overlays -= tile_overlay

		if(use_alpha)
			source.alpha = initial(source.alpha)

		if(use_anchor)
			source.anchored = FALSE

/datum/element/undertile/Detach(atom/movable/source, visibility_trait, invisibility_level = INVISIBILITY_MAXIMUM)
	. = ..()

	hide(source, UNDERFLOOR_INTERACTABLE)
	UnregisterSignal(source, COMSIG_OBJ_LEVELUPDATE)

#undef ALPHA_UNDERTILE

// Polychromic jumpsuit styles.
// Each style is one datum that owns the icon_state logic for a jumpsuit style, so the
// rendering code on /obj/item/clothing/under stays data-driven instead of switch chains.
// Style keys ("std_w"/"belt_w"/"turt_w") are savefile-stable — see code/__DEFINES/clothing.dm.
//
// icon_state naming in uniform_poly.dmi (context_style[_variant]):
//   mob_base_<style>      worn base sprite (greyscale, tinted with the base color)
//   mob_detail_<...>      non-colorable detail layer (zippers/seams)
//   mob_pattern_<n>       colorable pattern overlay (tinted with the accent color)
//   world_base/pattern_   in-world / in-hand sprite
//   inv_base/inv_pattern_ inventory sprite
//   variants: _fem (female), _fat, _vox, _belt, _rolled

/datum/poly_style
	var/key                          // savefile key
	var/display_name
	var/icon = 'icons/mob/uniform_poly.dmi'
	var/white_base = TRUE            // supports base-color tinting (greyscale base sprite)
	var/can_roll = TRUE              // turtleneck can't be rolled down
	var/forced_pattern = null        // turtleneck forces this pattern instead of the player's pick

	// Mob (worn) layers.
	var/mob_base = "mob_base_standard"
	var/has_detail = TRUE            // turtleneck has no zipper detail
	var/is_belt = FALSE              // belt has its own detail sprite and belt-specific pattern sprites
	var/list/belt_patterns = list()  // patterns that have a dedicated belt sprite

	// World (in-world / in-hand) and inventory layers.
	var/world_base = "world_base_standard"
	var/world_pattern = "world_pattern_standard"
	var/inv_pattern = "inv_pattern_standard"

// Style to actually render as for this mob. Fat mobs have no turtleneck sprites, so a fat
// turtleneck renders as standard to keep base/detail/pattern consistent.
/datum/poly_style/proc/get_effective(mob/living/carbon/human/H)
	return src

/datum/poly_style/proc/get_mob_base_state(obj/item/clothing/under/U, mob/living/carbon/human/H)
	var/base = U.rolled_down ? "mob_base_rolled" : mob_base
	if(H && H.species?.name == VOX)
		return "mob_base_vox"                      // vox has a single base sprite
	if(H && HAS_TRAIT(H, TRAIT_FAT) && base == "mob_base_belt")
		return "mob_base_standard_fat"             // belt has no fat sprite
	var/static/list/has_fat = list("mob_base_standard", "mob_base_rolled")
	if(H && HAS_TRAIT(H, TRAIT_FAT) && (base in has_fat))
		return "[base]_fat"
	if(H && H.gender == FEMALE)
		return "[base]_fem"
	return base

/datum/poly_style/proc/get_mob_detail_state(obj/item/clothing/under/U, mob/living/carbon/human/H)
	if(U.rolled_down || !has_detail)
		return null
	if(H && H.species?.name == VOX)
		return "mob_detail_vox"
	if(H && HAS_TRAIT(H, TRAIT_FAT))
		return "mob_detail_fat"
	if(U.poly_pattern == "5" && !is_belt && !(H && H.gender == FEMALE))
		return "mob_detail_pattern5"               // pattern 5's zipper sits differently
	if(H && H.gender == FEMALE)
		return is_belt ? "mob_detail_belt_fem" : "mob_detail_standard_fem"
	return is_belt ? "mob_detail_belt" : "mob_detail_standard"

/datum/poly_style/proc/get_mob_pattern_state(obj/item/clothing/under/U, mob/living/carbon/human/H)
	var/pattern = U.poly_pattern
	if(!pattern || U.rolled_down)
		return null
	if(H && (HAS_TRAIT(H, TRAIT_FAT) || H.species?.name == VOX))
		return null                                // fat and vox bases have no pattern overlays
	if(pattern == POLY_PATTERN_TURT)
		return (H && H.gender == FEMALE) ? "mob_pattern_turtleneck_fem" : "mob_pattern_turtleneck"
	var/pat = "mob_pattern_[pattern]"
	if(is_belt && (pattern in belt_patterns))
		pat = "mob_pattern_[pattern]_belt"
	if(H && H.gender == FEMALE)
		return "[pat]_fem"
	return pat

/datum/poly_style/proc/get_world_state()
	return world_base

/datum/poly_style/proc/get_world_pattern_state(obj/item/clothing/under/U)
	return U.poly_pattern ? world_pattern : null

/datum/poly_style/proc/get_inventory_state()
	return "inv_base"

/datum/poly_style/proc/get_inventory_pattern_state(obj/item/clothing/under/U)
	return U.poly_pattern ? inv_pattern : null


/datum/poly_style/standard
	key = POLY_STYLE_STD
	display_name = "Poly-Standard"

/datum/poly_style/belt
	key = POLY_STYLE_BELT
	display_name = "Poly-Belt"
	mob_base = "mob_base_belt"
	is_belt = TRUE
	belt_patterns = list("1", "3", "5")
	// World/inventory sprites are shared with the standard style.

/datum/poly_style/turtleneck
	key = POLY_STYLE_TURT
	display_name = "Poly-Turtleneck"
	mob_base = "mob_base_turtleneck"
	has_detail = FALSE
	can_roll = FALSE
	forced_pattern = POLY_PATTERN_TURT
	world_base = "world_base_turtleneck"
	world_pattern = "world_pattern_turtleneck"
	inv_pattern = "inv_pattern_turtleneck"

/datum/poly_style/turtleneck/get_effective(mob/living/carbon/human/H)
	if(H && HAS_TRAIT(H, TRAIT_FAT))
		return global.poly_styles_by_key[POLY_STYLE_STD]
	return src


// key => singleton datum. "job" is absent on purpose — it means "no polychromic jumpsuit".
var/global/list/poly_styles_by_key = build_poly_styles()

/proc/build_poly_styles()
	. = list()
	for(var/T in subtypesof(/datum/poly_style))
		var/datum/poly_style/S = new T()
		.[S.key] = S

/// Display name for a style key, including the "job" (no-poly) option.
/proc/poly_style_name(key)
	if(key == POLY_STYLE_JOB)
		return "Job Default"
	var/datum/poly_style/S = global.poly_styles_by_key[key]
	return S ? S.display_name : key

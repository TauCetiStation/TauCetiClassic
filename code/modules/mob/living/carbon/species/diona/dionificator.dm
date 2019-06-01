/proc/icon_dionify(icon/A)
	A.SetIntensity(1.5, 1.5, 1.5)
	A.Blend(icon('icons/misc/tools.dmi', "diona_filter"), ICON_MULTIPLY)
	return A

/obj/item
	var/dionified = FALSE

// This proc converts our item into plant form.
/obj/item/proc/dionify(obj/item/copy_item)
	// Obj vars.
	unacidable = FALSE
	//

	dionified = TRUE
	flags |= ABSTRACT|NODROP
	flags &= ~(CONDUCT)
	var/datum/species/diona/D
	siemens_coefficient = initial(D.siemens_coefficient)
	// Get some whoosh-whoosh sound.
	hitsound = 'sound/weapons/slice.ogg'
	can_embed = FALSE

	damtype = "brute"

	force *= 0.5
	sharp = FALSE
	edge = FALSE

	throwforce *= 0.5
	throw_speed *= 0.5
	throw_range *= 0.5

	m_amt = 0
	g_amt = 0

	attack_verb = list("hit")

	max_heat_protection_temperature = initial(D.heat_level_3)
	min_cold_protection_temperature = initial(D.cold_level_3)

	slowdown += 1 // Come on, it's made out of "wood", it got to be heavy.

	for(var/obj/item/I in contents) // Copying a toolbox shouldn't copy it's contents.
		qdel(I)

	if(reagents)
		reagents.clear_reagents()

	return src

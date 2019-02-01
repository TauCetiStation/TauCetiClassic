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

/obj/item/clothing/dionify(obj/item/copy_item)
	. = ..()
	species_restricted = list("exclude", DIONA)

/obj/item/device/dionify(obj/item/copy_item) // Diona's aren't cool enough to replicate actual machinery, so we turn it into
	if(!dionified) // We can some very cool ancient devices dionified, but that would need to be overwritten in parent.
		var/obj/item/device/plant_analyzer/P = new(loc)
		P.dionified = TRUE // So it doesn't get turned into plant analyzer thus repeating the loop.
		P.dionify(copy_item)
		qdel(src)
		return
	else
		. = ..()

/obj/item/weapon/weldingtool/dionify(obj/item/copy_item)
	. = ..()
	max_fuel = 0

/obj/item/weapon/stock_parts/cell/dionify(obj/item/copy_item)
	. = ..()
	charge = 300    // We lost our nutrition to get this charge.
	maxcharge = 300 // Even lower than the worst.
	rigged = TRUE

/obj/item/weapon/gun/dionify(obj/item/copy_item)
	if(!dionified)
		var/obj/item/weapon/gun/magic/peashooter/P = new(loc)
		P.dionify(copy_item)
		qdel(src)
		return
	else
		. = ..()

/obj/item/weapon/gun/magic/peashooter
	name = "peashooter"
	ammo_type = /obj/item/ammo_casing/pea
	can_charge = FALSE
	dionified = TRUE
	max_charges = 1
	fire_sound = 'sound/items/syringeproj.ogg'
	flags = 0
	fire_delay = 1 // Really fast shots since it deals no damage.

/obj/item/weapon/gun/magic/peashooter/special_check(mob/M, atom/target)
	if(!charges)
		if(istype(loc, /obj/item/nymph_morph_ball))
			var/obj/item/nymph_morph_ball/NM = loc
			var/mob/living/carbon/monkey/diona/D = locate() in NM
			if(D.nutrition > 210)
				D.nutrition -= 10
				charges++
				return TRUE
		if(M.get_species() == DIONA)
			if(istype(M, /mob/living))
				var/mob/living/L = M
				L.nutrition -= 10
				charges++
				return TRUE
		return FALSE
	else
		return TRUE

/obj/item/weapon/gun/magic/peashooter/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, "<span class='warning'>The [name] pops quietly.<span>")
	return
/* Types of tanks!
 * Contains:
 *		Oxygen
 *		Anesthetic
 *		Air
 *		Phoron
 *		Emergency Oxygen
 */

/*
 * Oxygen
 */
/obj/item/weapon/tank/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen."
	hitsound = list('sound/items/misc/balloon_big-hit.ogg')
	icon_state = "oxygen"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


/obj/item/weapon/tank/oxygen/atom_init()
	. = ..()
	air_contents.adjust_gas("oxygen", (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"

/obj/item/weapon/tank/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"

/*
 * Anesthetic
 */
/obj/item/weapon/tank/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	hitsound = list('sound/items/misc/balloon_big-hit.ogg')
	icon_state = "anesthetic"
	item_state = "an_tank"

/obj/item/weapon/tank/anesthetic/atom_init()
	. = ..()

	air_contents.gas["oxygen"] = (3 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C) * O2STANDARD
	air_contents.gas["sleeping_agent"] = (3 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C) * N2STANDARD
	air_contents.update_values()

/*
 * Air
 */
/obj/item/weapon/tank/air
	name = "air tank"
	desc = "Mixed anyone?"
	hitsound = list('sound/items/misc/balloon_big-hit.ogg')
	icon_state = "oxygen"

/obj/item/weapon/tank/air/atom_init()
	. = ..()
	air_contents.adjust_multi("oxygen", (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * O2STANDARD, "nitrogen", (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * N2STANDARD)

/*
 * Phoron
 */
/obj/item/weapon/tank/phoron
	name = "phoron tank"
	desc = "Contains dangerous phoron. Do not inhale. Warning: extremely flammable."
	hitsound = list('sound/items/misc/balloon_small-hit.ogg')
	icon_state = "phoron"
	item_state = "plasma"
	flags = CONDUCT
	slot_flags = null	//they have no straps!


/obj/item/weapon/tank/phoron/atom_init()
	. = ..()
	air_contents.adjust_gas("phoron", (3 * ONE_ATMOSPHERE) * 70 / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/phoron/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/flamethrower))
		var/obj/item/weapon/flamethrower/F = I
		if (!F.status || F.ptank)
			return

		master = F
		F.ptank = src
		user.remove_from_mob(src)
		forceMove(F)
	else
		return ..()

/*
 * Emergency Oxygen
 */
/obj/item/weapon/tank/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	hitsound = list('sound/items/misc/balloon_small-hit.ogg')
	icon_state = "emergency"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = ITEM_SIZE_SMALL
	force = 2.0
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	volume = 2 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)


/obj/item/weapon/tank/emergency_oxygen/atom_init()
	. = ..()
	air_contents.adjust_gas("oxygen", (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/obj/item/weapon/tank/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 6

/obj/item/weapon/tank/emergency_oxygen/double
	name = "double emergency oxygen tank"
	force = 3.0
	icon_state = "emergency_double"
	volume = 10

/*
 * Emergency nitrogen
 * hi vox people!
 */
/obj/item/weapon/tank/emergency_nitrogen
	name = "emergency nitrogen tank"
	desc = "Used for Vox-related emergencies. Contains very little nitrogen, so try to conserve it until you actually need it."
	hitsound = list('sound/items/misc/balloon_small-hit.ogg')
	icon_state = "emergency"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = ITEM_SIZE_SMALL
	force = 2.0
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	volume = 2

/obj/item/weapon/tank/emergency_nitrogen/atom_init()
	. = ..()
	air_contents.adjust_gas("nitrogen", (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/*
 * Nitrogen
 */
/obj/item/weapon/tank/nitrogen
	name = "nitrogen tank"
	desc = "A tank of nitrogen."
	hitsound = list('sound/items/misc/balloon_big-hit.ogg')
	icon_state = "oxygen_fr"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


/obj/item/weapon/tank/nitrogen/atom_init()
	. = ..()
	air_contents.adjust_gas("nitrogen", (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

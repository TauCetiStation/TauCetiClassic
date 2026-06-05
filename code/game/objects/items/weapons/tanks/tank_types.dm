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
	cases = list("баллон с кислородом", "баллона с кислородом", "баллону с кислородом","баллон с кислородом", "баллоном с кислородом", "баллоне с кислородом")
	desc = "Баллон с кислородом, ничего необычного."
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
	cases = list("баллон с анестетиком", "баллона с анестетиком", "баллону с анестетиком","баллон с анестетиком", "баллоном с анестетиком", "баллоне с анестетиком")
	desc = "Баллон со смесью закиси азота."
	hitsound = list('sound/items/misc/balloon_big-hit.ogg')
	icon_state = "anesthetic"
	item_state = "an_tank"

/obj/item/weapon/tank/anesthetic/atom_init()
	. = ..()

	air_contents.gas["oxygen"] = (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * O2STANDARD
	air_contents.gas["sleeping_agent"] = (6 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * N2STANDARD
	air_contents.update_values()

/obj/item/weapon/tank/anesthetic/small
	name = "small anesthetic tank"
	cases = list("маленький баллон с анестетиком", " маленького баллона с анестетиком", "маленькому баллону с анестетиком"," маленький баллон с анестетиком", " маленьким баллоном с анестетиком", "маленьком баллоне с анестетиком")
	desc = "Небольшой баллон с закисью азота."
	hitsound = list('sound/items/misc/balloon_big-hit.ogg')
	icon_state = "smallanesthetic"
	item_state = "an_tank"
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_TINY
	force = 2.0
	volume = 2

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
	cases = list("баллон с фороном", "баллона с фороном", "баллону с фороном", "баллон с фороном", "баллоном с фороном", "баллоне с фороном")
	desc = "Содержит форон. Не вдыхать! Огнеопасно!"
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
	cases = list("аварийный баллон с кислородом", "аварийного баллона с кислородом", "аварийному баллону с кислородом", "аварийный баллон с кислородом", "аварийным баллоном с кислородом", "аварийном баллоне с кислородом")
	desc = "Для экстренных ситуаций. Запас кислорода крайне мал, так что берегите его до самого крайнего случая."
	hitsound = list('sound/items/misc/balloon_small-hit.ogg')
	icon_state = "emergency"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_TINY
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
	cases = list("экстренный баллон с азотом", "экстренного баллона с азотом", "экстренному баллону с азотом", "экстренный баллон с азотом", "экстренным баллоном с азотом", "экстренном баллоне с азотом")
	desc = "Используется в экстренных ситуациях для воксов. Запас азота крайне мал, так что берегите его до самого крайнего случая."
	hitsound = list('sound/items/misc/balloon_small-hit.ogg')
	icon_state = "ni_emergency"
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	w_class = SIZE_TINY
	force = 2.0
	distribute_pressure = ONE_ATMOSPHERE * O2STANDARD
	volume = 2

/obj/item/weapon/tank/emergency_nitrogen/double
	name = "double emergency nitrogen tank"
	force = 3.0
	icon_state = "ni_double"
	volume = 7

/obj/item/weapon/tank/emergency_nitrogen/atom_init()
	. = ..()
	air_contents.adjust_gas("nitrogen", (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/*
 * Nitrogen
 */
/obj/item/weapon/tank/nitrogen
	name = "nitrogen tank"
	cases = list("баллон с азотом", "баллона с азотом", "баллону с азотом", "баллон с азотом", "баллоном с азотом", "баллоне с азотом")
	desc = "Баллон с азотом, ничего необычного."
	hitsound = list('sound/items/misc/balloon_big-hit.ogg')
	icon_state = "oxygen_fr"
	distribute_pressure = ONE_ATMOSPHERE*O2STANDARD


/obj/item/weapon/tank/nitrogen/atom_init()
	. = ..()
	air_contents.adjust_gas("nitrogen", (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C))

/* Surgery Tools
 * Contains:
 *		Retractor
 *		Hemostat
 *		Cautery
 *		Surgical Drill
 *		Scalpel
 *		Circular Saw
 */

/*
 * Retractor
 */
/obj/item/weapon/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "retractor"
	m_amt = 10000
	g_amt = 5000
	flags = CONDUCT
	w_class = ITEM_SIZE_SMALL
	origin_tech = "materials=1;biotech=1"
	usesound = 'sound/items/surgery/Retract.ogg'

/*
 * Hemostat
 */
/obj/item/weapon/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hemostat"
	m_amt = 5000
	g_amt = 2500
	flags = CONDUCT
	w_class = ITEM_SIZE_SMALL
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "pinched")
	usesound = 'sound/items/surgery/Hemostat.ogg'

/*
 * Cautery
 */
/obj/item/weapon/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "cautery"
	m_amt = 5000
	g_amt = 2500
	flags = CONDUCT
	w_class = ITEM_SIZE_SMALL
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("burnt")
	usesound = 'sound/items/surgery/cautery.ogg'


/*
 * Surgical Drill
 */
/obj/item/weapon/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "drill"
	hitsound = list('sound/weapons/circsawhit.ogg')
	m_amt = 15000
	g_amt = 10000
	flags = CONDUCT
	force = 15.0
	w_class = ITEM_SIZE_SMALL
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("drilled")
	usesound = 'sound/items/surgery/SurgDrill.ogg'

/obj/item/weapon/surgicaldrill/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='warning'><b>[user] is pressing the [src.name] to \his temple and activating it! It looks like \he's trying to commit suicide.</b></span>", \
						"<span class='warning'><b>[user] is pressing [src.name] to \his chest and activating it! It looks like \he's trying to commit suicide.</b></span>"))
	return (BRUTELOSS)

/*
 * Scalpel
 */
/obj/item/weapon/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	flags = CONDUCT
	force = 10.0
	sharp = 1
	edge = 1
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	m_amt = 10000
	g_amt = 5000
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	tools = list(
		TOOL_KNIFE = 1
		)

/obj/item/weapon/scalpel/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='warning'><b>[user] is slitting \his wrists with the [src.name]! It looks like \he's trying to commit suicide.</b></span>", \
						"<span class='warning'><b>[user] is slitting \his throat with the [src.name]! It looks like \he's trying to commit suicide.</b></span>", \
						"<span class='warning'><b>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</b></span>"))
	return (BRUTELOSS)

/*
 * Researchable Scalpels
 */
/obj/item/weapon/scalpel/laser1
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks basic and could be improved."
	icon_state = "scalpel_laser1_on"
	damtype = "fire"
	usesound = 'sound/items/surgery/laserscalp.ogg'
	toolspeed = 1.2

/obj/item/weapon/scalpel/laser2
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks somewhat advanced."
	icon_state = "scalpel_laser2_on"
	damtype = "fire"
	force = 12.0
	usesound = 'sound/items/surgery/laserscalp.ogg'

/obj/item/weapon/scalpel/laser3
	name = "laser scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field.  This one looks to be the pinnacle of precision energy cutlery!"
	icon_state = "scalpel_laser3_on"
	damtype = "fire"
	force = 15.0
	usesound = 'sound/items/surgery/laserscalp.ogg'
	toolspeed = 0.6

/obj/item/weapon/scalpel/manager
	name = "incision management system"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	icon_state = "scalpel_manager_on"
	force = 7.5
	toolspeed = 0.6
	tools = list()
/*
 * Circular Saw
 */
/obj/item/weapon/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "saw"
	hitsound = list('sound/weapons/circsawhit.ogg')
	flags = CONDUCT
	force = 15.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	m_amt = 20000
	g_amt = 10000
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("attacked", "slashed", "sawed", "cut")
	sharp = 1
	edge = 1
	usesound = 'sound/items/surgery/Bone_Saw.ogg'


//misc, formerly from code/defines/weapons.dm
/obj/item/weapon/bonegel
	name = "bone gel"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	force = 0
	w_class = ITEM_SIZE_SMALL
	throwforce = 1.0
	usesound = 'sound/items/surgery/Bone_Gel.ogg'

/obj/item/weapon/FixOVein
	name = "FixOVein"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fixovein"
	force = 0
	throwforce = 1.0
	origin_tech = "materials=1;biotech=3"
	w_class = ITEM_SIZE_SMALL
	var/usage_amount = 10
	usesound = 'sound/items/surgery/Fix-O-vein.ogg'

/obj/item/weapon/bonesetter
	name = "bone setter"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"
	force = 8.0
	throwforce = 9.0
	throw_speed = 3
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("attacked", "hit", "bludgeoned")
	usesound = 'sound/items/surgery/BonSet.ogg'



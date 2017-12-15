/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 */

/*
 * First Aid Kits
 */
/obj/item/weapon/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	var/empty = 0


/obj/item/weapon/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"

/obj/item/weapon/storage/firstaid/fire/atom_init()
	. = ..()
	if (empty)
		return

	icon_state = pick("ointment","firefirstaid")

	new /obj/item/device/healthanalyzer(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	for (var/i in 1 to 2)
		new /obj/item/stack/medical/ointment(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/pill/kelotane(src)// Replaced ointment with these since they actually work --Errorage

/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"

/obj/item/weapon/storage/firstaid/regular/atom_init()
	. = ..()
	if (empty)
		return
	for (var/i in 1 to 3)
		new /obj/item/stack/medical/bruise_pack(src)
	for (var/i in 1 to 2)
		new /obj/item/stack/medical/ointment(src)
	new /obj/item/device/healthanalyzer(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )

/obj/item/weapon/storage/firstaid/toxin
	name = "toxin first aid"
	desc = "Used to treat when you have a high amoutn of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

/obj/item/weapon/storage/firstaid/toxin/atom_init()
	. = ..()
	if (empty)
		return

	icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/syringe/antitoxin( src )
	for (var/i in 1 to 3)
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
	new /obj/item/device/healthanalyzer( src )

/obj/item/weapon/storage/firstaid/o2
	name = "oxygen deprivation first aid"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"

/obj/item/weapon/storage/firstaid/o2/atom_init()
	. = ..()
	if (empty)
		return
	for (var/i in 1 to 4)
		new /obj/item/weapon/reagent_containers/pill/dexalin(src)
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector(src)
	new /obj/item/weapon/reagent_containers/syringe/inaprovaline(src)
	new /obj/item/device/healthanalyzer(src)

/obj/item/weapon/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"

/obj/item/weapon/storage/firstaid/adv/atom_init()
	. = ..()
	if (empty)
		return
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
	for (var/i in 1 to 3)
		new /obj/item/stack/medical/advanced/bruise_pack(src)
	for (var/i in 1 to 2)
		new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)

/*
 * Pill Bottles
 */
/obj/item/weapon/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = 2.0
	can_hold = list("/obj/item/weapon/reagent_containers/pill","/obj/item/weapon/dice","/obj/item/weapon/paper")
	allow_quick_gather = 1
	use_to_pickup = 1
	storage_slots = 14
	use_sound = null

/obj/item/weapon/storage/pill_bottle/kelotane
	name = "bottle of kelotane pills"
	desc = "Contains pills used to treat burns."

/obj/item/weapon/storage/pill_bottle/kelotane/atom_init()
	. = ..()
	for (var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/kelotane(src)

/obj/item/weapon/storage/pill_bottle/antitox
	name = "Dylovene pills"
	desc = "Contains pills used to counter toxins."

/obj/item/weapon/storage/pill_bottle/antitox/atom_init()
	. = ..()
	for (var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/antitox(src)

/obj/item/weapon/storage/pill_bottle/inaprovaline
	name = "Inaprovaline pills"
	desc = "Contains pills used to stabilize patients."

/obj/item/weapon/storage/pill_bottle/inaprovaline/atom_init()
	. = ..()
	for (var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/inaprovaline(src)

/obj/item/weapon/storage/pill_bottle/tramadol
	name = "Tramadol Pills"
	desc = "Contains pills used to relieve pain."

/obj/item/weapon/storage/pill_bottle/tramadol/atom_init()
	. = ..()
	for (var/i in 1 to 7)
		new /obj/item/weapon/reagent_containers/pill/tramadol(src)
